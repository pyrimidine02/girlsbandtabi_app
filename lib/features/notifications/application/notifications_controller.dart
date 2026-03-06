/// EN: Notifications controller for list and read state.
/// KO: 알림 목록/읽음 처리를 위한 컨트롤러.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/realtime/sse_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/entities/notification_entities.dart';
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
  Duration _reconnectDelay = const Duration(seconds: 1);
  DateTime? _lastRealtimeRefreshAt;
  bool _isRealtimeActive = false;
  bool _isRealtimeConnected = false;
  final Random _random = Random();
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
    await _disposeRealtimeConnection();
  }

  Future<void> _connectRealtime() async {
    if (!_isRealtimeActive || _isRealtimeConnected) return;
    if (!_ref.read(isAuthenticatedProvider)) return;
    if (_realtimeConnection != null || _realtimeSubscription != null) return;

    final sseClient = _ref.read(sseClientProvider);
    try {
      final connection = await sseClient.connect(
        path: ApiEndpoints.notificationsStream,
      );
      _realtimeConnection = connection;
      _isRealtimeConnected = true;
      _reconnectDelay = const Duration(seconds: 1);

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
      _isRealtimeConnected = false;
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

  void _scheduleRealtimeReconnect() {
    if (!_isRealtimeActive) return;
    _realtimeReconnectTimer?.cancel();
    final baseDelay = _reconnectDelay;
    // EN: Add small jitter to avoid reconnect stampedes across clients.
    // KO: 클라이언트 동시 재연결 폭주를 줄이기 위해 작은 지터를 추가합니다.
    final jitterMs = _random.nextInt(250);
    final delay = baseDelay + Duration(milliseconds: jitterMs);
    _realtimeReconnectTimer = Timer(delay, () {
      unawaited(_connectRealtime());
    });
    final nextSeconds = (_reconnectDelay.inSeconds * 2).clamp(1, 8);
    _reconnectDelay = Duration(seconds: nextSeconds);
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
        payload['entityId']?.toString() ??
        event.id;
    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    _navigationHintsById[notificationId] = _NotificationNavigationHint(
      type:
          payload['notificationType']?.toString() ??
          payload['type']?.toString(),
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
