/// EN: Notifications controller for list and read state.
/// KO: 알림 목록/읽음 처리를 위한 컨트롤러.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/notifications/in_app_notification_queue.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/realtime/sse_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/entities/notification_entities.dart';
import '../domain/entities/notification_navigation.dart';
import '../domain/repositories/notifications_repository.dart';

class _NotificationNavigationHint {
  const _NotificationNavigationHint({
    this.type,
    this.actionUrl,
    this.deeplink,
    this.entityId,
    this.projectCode,
  });

  final String? type;
  final String? actionUrl;
  final String? deeplink;
  final String? entityId;
  final String? projectCode;
}

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<bool>(isAuthenticatedProvider, (_, isAuthenticated) {
      if (!isAuthenticated) {
        _resetNotificationSnapshot();
        state = const AsyncData([]);
        unawaited(stopRealtimeSync());
        return;
      }
      if (_isRealtimeActive) {
        unawaited(_connectRealtime());
      }
    });
    load();
  }

  final Ref _ref;
  bool _isBackgroundSyncing = false;
  DateTime? _lastBackgroundSyncAt;
  SseConnection? _realtimeConnection;
  StreamSubscription<SseEvent>? _realtimeSubscription;
  Timer? _realtimeReconnectTimer;
  Duration _reconnectDelay = const Duration(seconds: 2);
  DateTime? _lastRealtimeRefreshAt;
  bool _isRealtimeActive = false;
  bool _isRealtimeConnected = false;
  final Random _random = Random();
  DateTime? _reconnectBlockedUntil;
  String? _lastReconnectFailureSignature;
  DateTime? _lastReconnectFailureLoggedAt;
  bool _hasSeededNotificationSnapshot = false;
  final Set<String> _knownNotificationIds = <String>{};
  final Map<String, _NotificationNavigationHint> _navigationHintsById =
      <String, _NotificationNavigationHint>{};
  bool _hasCheckedLocalPermission = false;
  bool _canShowLocalAlerts = false;

  /// EN: Start realtime notification sync via SSE with polling fallback.
  /// KO: 폴링 폴백을 유지한 채 SSE 기반 실시간 알림 동기화를 시작합니다.
  Future<void> startRealtimeSync() async {
    if (_isRealtimeActive) return;
    _isRealtimeActive = true;
    await _connectRealtime();
  }

  /// EN: Stop realtime SSE sync and keep polling fallback only.
  /// KO: SSE 실시간 동기화를 중지하고 폴링 폴백만 유지합니다.
  Future<void> stopRealtimeSync() async {
    _isRealtimeActive = false;
    _realtimeReconnectTimer?.cancel();
    _realtimeReconnectTimer = null;
    _isRealtimeConnected = false;
    _reconnectBlockedUntil = null;
    _lastReconnectFailureSignature = null;
    _lastReconnectFailureLoggedAt = null;
    _reconnectDelay = const Duration(seconds: 2);
    await _disposeRealtimeConnection();
  }

  Future<void> _connectRealtime() async {
    if (!_isRealtimeActive || _isRealtimeConnected) return;
    if (!_ref.read(isAuthenticatedProvider)) return;
    if (_realtimeConnection != null || _realtimeSubscription != null) return;
    final blockedUntil = _reconnectBlockedUntil;
    if (blockedUntil != null) {
      final now = DateTime.now();
      if (now.isBefore(blockedUntil)) {
        _scheduleRealtimeReconnect(
          delayOverride: blockedUntil.difference(now),
          freezeBackoff: true,
        );
        return;
      }
      _reconnectBlockedUntil = null;
    }

    // EN: SSE bypasses the Dio interceptor, so proactively refresh the access
    // EN: token here to avoid a wasted connection attempt and the 5-minute
    // EN: auth-failure cooldown that follows a 401 on the stream endpoint.
    // KO: SSE는 Dio 인터셉터를 거치지 않으므로 여기서 액세스 토큰을 선제 갱신합니다.
    // KO: 스트림 엔드포인트 401 후 발생하는 5분 재연결 대기와
    // KO: 불필요한 연결 시도를 방지합니다.
    final apiClient = _ref.read(apiClientProvider);
    final tokenReady = await apiClient.proactiveRefreshIfExpired();
    if (!tokenReady) {
      // EN: Refresh token is invalid; wait for auth state to change.
      // KO: 리프레시 토큰이 무효합니다; 인증 상태 변경을 기다립니다.
      AppLogger.warning(
        '[Notifications] SSE skipped: token refresh failed',
        tag: 'NotificationsController',
      );
      return;
    }

    final sseClient = _ref.read(sseClientProvider);
    try {
      final connection = await sseClient.connect(
        path: ApiEndpoints.notificationsStream,
      );
      _realtimeConnection = connection;
      _isRealtimeConnected = true;
      _reconnectDelay = const Duration(seconds: 2);
      _lastReconnectFailureSignature = null;
      _lastReconnectFailureLoggedAt = null;

      _realtimeSubscription = connection.events.listen(
        _handleRealtimeEvent,
        onError: (Object error, StackTrace stackTrace) {
          AppLogger.warning(
            '[Notifications] SSE error; fallback to polling',
            tag: 'NotificationsController',
          );
          unawaited(_handleRealtimeDisconnect());
        },
        onDone: () {
          unawaited(_handleRealtimeDisconnect());
        },
        cancelOnError: true,
      );
    } catch (error, stackTrace) {
      final classification = _classifyReconnectError(error);
      final shouldLog = _shouldLogReconnectFailure(classification.signature);
      if (shouldLog) {
        AppLogger.debug(
          '[Notifications] SSE connect failed; fallback to polling',
          tag: 'NotificationsController',
        );
        AppLogger.error(
          '[Notifications] SSE connect exception',
          tag: 'NotificationsController',
          error: error,
          stackTrace: stackTrace,
        );
      }
      _isRealtimeConnected = false;
      if (classification.retryCooldown != null) {
        // EN: Pause retries after client-side/auth stream failures to avoid
        // noisy reconnect loops and battery/network waste.
        // KO: 인증/클라이언트 오류에서는 재연결 루프를 잠시 멈춰
        // 배터리/네트워크 낭비와 로그 폭주를 줄입니다.
        _reconnectBlockedUntil = DateTime.now().add(
          classification.retryCooldown!,
        );
        _scheduleRealtimeReconnect(
          delayOverride: classification.retryCooldown,
          freezeBackoff: true,
        );
        return;
      }
      _scheduleRealtimeReconnect();
    }
  }

  void _handleRealtimeEvent(SseEvent event) {
    if (!_isRealtimeActive) return;
    if (!_isNotificationEvent(event)) return;
    _captureNavigationHint(event);

    final now = DateTime.now();
    if (_lastRealtimeRefreshAt != null &&
        now.difference(_lastRealtimeRefreshAt!) <
            const Duration(milliseconds: 900)) {
      return;
    }
    _lastRealtimeRefreshAt = now;
    unawaited(refreshInBackground(minInterval: Duration.zero));
  }

  bool _isNotificationEvent(SseEvent event) {
    final rawType =
        event.event ?? event.dataAsJson?['eventType']?.toString() ?? '';
    if (rawType.isEmpty) {
      return true;
    }
    final normalized = rawType.toLowerCase();
    return normalized.contains('notification') ||
        normalized.contains('notice') ||
        normalized.contains('unread');
  }

  Future<void> _handleRealtimeDisconnect() async {
    _isRealtimeConnected = false;
    await _disposeRealtimeConnection();
    _scheduleRealtimeReconnect();
  }

  void _scheduleRealtimeReconnect({
    Duration? delayOverride,
    bool freezeBackoff = false,
  }) {
    if (!_isRealtimeActive) return;
    _realtimeReconnectTimer?.cancel();
    final baseDelay = delayOverride ?? _reconnectDelay;
    // EN: Add bounded jitter to prevent synchronized reconnect spikes.
    // KO: 동시 재연결 스파이크를 줄이기 위해 제한된 지터를 추가합니다.
    final jitterUpperBound = min(
      1200,
      max(150, (baseDelay.inMilliseconds * 0.15).round()),
    );
    final jitterMs = _random.nextInt(jitterUpperBound + 1);
    final delay = baseDelay + Duration(milliseconds: jitterMs);
    _realtimeReconnectTimer = Timer(delay, () {
      unawaited(_connectRealtime());
    });
    if (delayOverride == null && !freezeBackoff) {
      final nextSeconds = (_reconnectDelay.inSeconds * 2).clamp(2, 120);
      _reconnectDelay = Duration(seconds: nextSeconds);
    }
  }

  bool _shouldLogReconnectFailure(String signature) {
    final now = DateTime.now();
    if (_lastReconnectFailureSignature != signature) {
      _lastReconnectFailureSignature = signature;
      _lastReconnectFailureLoggedAt = now;
      return true;
    }
    final lastLoggedAt = _lastReconnectFailureLoggedAt;
    if (lastLoggedAt == null ||
        now.difference(lastLoggedAt) >= const Duration(minutes: 2)) {
      _lastReconnectFailureLoggedAt = now;
      return true;
    }
    return false;
  }

  _ReconnectErrorClassification _classifyReconnectError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('http 401') || raw.contains('http 403')) {
      return const _ReconnectErrorClassification(
        retryCooldown: Duration(minutes: 5),
        signature: 'auth_unauthorized',
      );
    }
    if (raw.contains('http 400')) {
      return const _ReconnectErrorClassification(
        retryCooldown: Duration(minutes: 10),
        signature: 'client_bad_request',
      );
    }
    if (raw.contains('http 404')) {
      return const _ReconnectErrorClassification(
        retryCooldown: Duration(minutes: 10),
        signature: 'stream_not_found',
      );
    }
    if (raw.contains('connection refused')) {
      return const _ReconnectErrorClassification(
        retryCooldown: null,
        signature: 'connection_refused',
      );
    }
    if (raw.contains('connection closed before full header was received')) {
      return const _ReconnectErrorClassification(
        retryCooldown: null,
        signature: 'connection_closed_early',
      );
    }
    if (raw.contains('socketexception')) {
      return const _ReconnectErrorClassification(
        retryCooldown: null,
        signature: 'socket_exception',
      );
    }
    return const _ReconnectErrorClassification(
      retryCooldown: null,
      signature: 'unknown',
    );
  }

  Future<void> _disposeRealtimeConnection() async {
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    if (_realtimeConnection != null) {
      await _realtimeConnection!.close();
      _realtimeConnection = null;
    }
  }

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(notificationsRepositoryProvider.future);
    final result = await repository.getNotifications(
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<NotificationItem>>) {
      final enrichedItems = _enrichNotifications(result.data);
      await _captureNotificationDelta(enrichedItems, allowLocalAlert: false);
      state = AsyncData(enrichedItems);
    } else if (result is Err<List<NotificationItem>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<void> refreshInBackground({
    Duration minInterval = const Duration(seconds: 40),
  }) async {
    if (_isRealtimeConnected && minInterval > Duration.zero) {
      return;
    }
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated || _isBackgroundSyncing) {
      return;
    }

    final now = DateTime.now();
    if (_lastBackgroundSyncAt != null &&
        now.difference(_lastBackgroundSyncAt!) < minInterval) {
      return;
    }

    _isBackgroundSyncing = true;
    try {
      final repository = await _ref.read(
        notificationsRepositoryProvider.future,
      );
      final result = await repository.getNotifications(forceRefresh: true);
      if (result is Success<List<NotificationItem>>) {
        final enrichedItems = _enrichNotifications(result.data);
        await _captureNotificationDelta(enrichedItems, allowLocalAlert: true);
        state = AsyncData(enrichedItems);
      } else if (result is Err<List<NotificationItem>> &&
          state.valueOrNull == null) {
        state = AsyncError(result.failure, StackTrace.current);
      }
    } finally {
      _lastBackgroundSyncAt = DateTime.now();
      _isBackgroundSyncing = false;
    }
  }

  Future<Result<void>> markAsRead(
    String notificationId, {
    bool refresh = true,
  }) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return Result.failure(
        const AuthFailure('Login required', code: 'auth_required'),
      );
    }

    final repository = await _ref.read(notificationsRepositoryProvider.future);
    final result = await repository.markAsRead(notificationId);
    if (result is Success<void> && refresh) {
      await load(forceRefresh: true);
    }
    return result;
  }

  Future<void> markAllAsRead() async {
    final items = state.maybeWhen(data: (data) => data, orElse: () => []);
    if (items.isEmpty) return;

    for (final item in items.where((item) => !item.isRead)) {
      await markAsRead(item.id, refresh: false);
    }
    await load(forceRefresh: true);
  }

  /// EN: Optimistically remove a notification then call the delete API.
  /// KO: 알림을 즉시 로컬에서 제거한 후 삭제 API를 호출합니다.
  Future<void> deleteNotification(String notificationId) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) return;

    // EN: Optimistic remove from local state.
    // KO: 로컬 상태에서 즉시 제거합니다.
    final prev = state.valueOrNull;
    if (prev != null) {
      state = AsyncData(prev.where((e) => e.id != notificationId).toList());
      _knownNotificationIds.remove(notificationId);
    }

    final repository = await _ref.read(notificationsRepositoryProvider.future);
    await repository.deleteNotification(notificationId);
  }

  /// EN: Optimistically clear all notifications then call the delete-all API.
  /// KO: 모든 알림을 즉시 로컬에서 제거한 후 전체 삭제 API를 호출합니다.
  Future<void> deleteAllNotifications() async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) return;

    // EN: Optimistic clear.
    // KO: 즉시 전체 제거합니다.
    state = const AsyncData([]);
    _knownNotificationIds.clear();

    final repository = await _ref.read(notificationsRepositoryProvider.future);
    await repository.deleteAllNotifications();
  }

  /// EN: Detect newly arrived unread notifications and raise local alerts.
  /// KO: 새로 도착한 미읽음 알림을 감지해 로컬 알림을 발생시킵니다.
  Future<void> _captureNotificationDelta(
    List<NotificationItem> items, {
    required bool allowLocalAlert,
  }) async {
    final currentIds = items.map((item) => item.id).toSet();

    if (!_hasSeededNotificationSnapshot) {
      _knownNotificationIds
        ..clear()
        ..addAll(currentIds);
      _hasSeededNotificationSnapshot = true;
      return;
    }

    final newlyArrivedUnread = items
        .where(
          (item) => !item.isRead && !_knownNotificationIds.contains(item.id),
        )
        .toList(growable: false);

    _knownNotificationIds
      ..clear()
      ..addAll(currentIds);

    if (!allowLocalAlert || newlyArrivedUnread.isEmpty) {
      return;
    }

    // EN: Push following-post and comment notifications as in-app banners.
    // KO: 팔로잉 새글·댓글 알림을 인앱 배너로 표시합니다.
    final inAppBannerTypes = {
      notificationTypePostCreated,   // POST_CREATED  (팔로잉 새글)
      'COMMENT_CREATED',             // 댓글
      'COMMENT_REPLY_CREATED',       // 대댓글
    };
    final inAppQueue = _ref.read(inAppNotificationQueueProvider.notifier);
    for (final item in newlyArrivedUnread.take(3)) {
      final type = normalizeNotificationType(item.type);
      if (inAppBannerTypes.contains(type)) {
        inAppQueue.push(InAppNotificationEntry(
          id: item.id,
          title: item.title,
          body: item.body,
          type: type,
          entityId: item.entityId,
          deeplink: item.deeplink,
          actionUrl: item.actionUrl,
          projectCode: item.projectCode,
        ));
      }
    }

    if (!await _isPushEnabledByUserSetting()) {
      return;
    }
    if (!await _ensureLocalPermission()) {
      return;
    }

    final localNotifier = _ref.read(localNotificationsServiceProvider);
    for (final item in newlyArrivedUnread.take(3)) {
      await localNotifier.showNotificationItem(item);
    }
  }

  void _resetNotificationSnapshot() {
    _hasSeededNotificationSnapshot = false;
    _knownNotificationIds.clear();
    _navigationHintsById.clear();
    _lastBackgroundSyncAt = null;
  }

  List<NotificationItem> _enrichNotifications(List<NotificationItem> items) {
    if (_navigationHintsById.isEmpty) {
      return items;
    }
    return items
        .map((item) {
          final hint = _navigationHintsById[item.id];
          if (hint == null) {
            return item;
          }
          return NotificationItem(
            id: item.id,
            title: item.title,
            body: item.body,
            createdAt: item.createdAt,
            isRead: item.isRead,
            type: item.type ?? hint.type,
            actionUrl: item.actionUrl ?? hint.actionUrl,
            deeplink: item.deeplink ?? hint.deeplink,
            entityId: item.entityId ?? hint.entityId,
            projectCode: item.projectCode ?? hint.projectCode,
          );
        })
        .toList(growable: false);
  }

  void _captureNavigationHint(SseEvent event) {
    final payload = event.dataAsJson;
    if (payload == null) return;

    final notificationId =
        payload['notificationId']?.toString() ??
        payload['targetId']?.toString() ??
        payload['entityId']?.toString() ??
        event.id;
    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    _navigationHintsById[notificationId] = _NotificationNavigationHint(
      type: normalizeNotificationType(
        payload['notificationType']?.toString() ?? payload['type']?.toString(),
      ),
      actionUrl: payload['actionUrl']?.toString(),
      deeplink:
          payload['deeplink']?.toString() ?? payload['deepLink']?.toString(),
      entityId:
          payload['targetId']?.toString() ??
          payload['contentId']?.toString() ??
          payload['entityId']?.toString(),
      projectCode:
          payload['projectCode']?.toString() ??
          payload['projectId']?.toString(),
    );
    if (_navigationHintsById.length > 300) {
      _navigationHintsById.remove(_navigationHintsById.keys.first);
    }
  }

  Future<bool> _isPushEnabledByUserSetting() async {
    final storage = await _ref.read(localStorageProvider.future);
    return storage.getBool(LocalStorageKeys.notificationsEnabled) ?? true;
  }

  Future<bool> _ensureLocalPermission() async {
    if (_hasCheckedLocalPermission) {
      return _canShowLocalAlerts;
    }
    final localNotifier = _ref.read(localNotificationsServiceProvider);
    _canShowLocalAlerts = await localNotifier.requestPermissions();
    _hasCheckedLocalPermission = true;
    return _canShowLocalAlerts;
  }

  @override
  void dispose() {
    _isRealtimeActive = false;
    _realtimeReconnectTimer?.cancel();
    unawaited(_disposeRealtimeConnection());
    super.dispose();
  }
}

class _ReconnectErrorClassification {
  const _ReconnectErrorClassification({
    required this.retryCooldown,
    required this.signature,
  });

  final Duration? retryCooldown;
  final String signature;
}

/// EN: Notifications repository provider.
/// KO: 알림 리포지토리 프로바이더.
final notificationsRepositoryProvider = FutureProvider<NotificationsRepository>(
  (ref) async {
    final apiClient = ref.watch(apiClientProvider);
    final cacheManager = await ref.read(cacheManagerProvider.future);
    return NotificationsRepositoryImpl(
      remoteDataSource: NotificationsRemoteDataSource(apiClient),
      cacheManager: cacheManager,
    );
  },
);

/// EN: Notifications controller provider.
/// KO: 알림 컨트롤러 프로바이더.
final notificationsControllerProvider =
    StateNotifierProvider<
      NotificationsController,
      AsyncValue<List<NotificationItem>>
    >((ref) {
      return NotificationsController(ref);
    });

/// EN: Global bootstrap provider for realtime notification sync.
/// KO: 실시간 알림 동기화를 전역에서 부트스트랩하는 프로바이더입니다.
final notificationsRealtimeBootstrapProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authStateProvider, (_, next) {
    final notifier = ref.read(notificationsControllerProvider.notifier);
    if (next == AuthState.authenticated) {
      unawaited(notifier.startRealtimeSync());
    } else if (next == AuthState.unauthenticated) {
      unawaited(notifier.stopRealtimeSync());
    }
  });

  final notifier = ref.read(notificationsControllerProvider.notifier);
  if (ref.read(isAuthenticatedProvider)) {
    unawaited(notifier.startRealtimeSync());
  } else {
    unawaited(notifier.stopRealtimeSync());
  }
});
