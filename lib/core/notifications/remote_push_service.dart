/// EN: Firebase remote push service for token lifecycle and tap routing.
/// KO: 토큰 생명주기/탭 라우팅을 위한 Firebase 원격 푸시 서비스입니다.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../features/notifications/domain/entities/notification_entities.dart';
import '../../features/notifications/domain/entities/notification_navigation.dart';
import '../constants/api_constants.dart';
import '../error/failure.dart';
import '../logging/app_logger.dart';
import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../utils/result.dart';
import 'firebase_runtime_options.dart';
import 'local_notifications_service.dart';

/// EN: Register Firebase background message handler once at startup.
/// KO: 앱 시작 시 Firebase 백그라운드 메시지 핸들러를 1회 등록합니다.
void registerRemotePushBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

const String _kPushChannelId = 'gbt_notifications_high';
const String _kPushChannelName = 'GBT Notifications';
const String _kPushChannelDescription =
    'Realtime community and system notifications';
final FlutterLocalNotificationsPlugin _backgroundNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
bool _backgroundNotificationsInitialized = false;

class _PushCredential {
  const _PushCredential({required this.provider, required this.token});

  final String provider;
  final String token;
}

Future<void> _ensureBackgroundNotificationPluginInitialized() async {
  if (_backgroundNotificationsInitialized) {
    return;
  }

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const settings = InitializationSettings(android: android, iOS: ios);

  await _backgroundNotificationsPlugin.initialize(settings);

  const channel = AndroidNotificationChannel(
    _kPushChannelId,
    _kPushChannelName,
    description: _kPushChannelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  await _backgroundNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  _backgroundNotificationsInitialized = true;
}

Future<void> _showBackgroundLocalNotificationIfNeeded(
  RemoteMessage message,
) async {
  // EN: Skip local duplication when OS will present remote notification itself.
  // KO: OS가 원격 알림을 직접 표시하는 경우 로컬 중복 표시를 건너뜁니다.
  if (message.notification != null) {
    return;
  }

  final title = _firstNonEmpty(_resolvePushTitle(message), 'GirlsBandTabi');
  final body = _resolvePushBody(message);
  if (title == null || body == null || body.isEmpty) {
    return;
  }

  await _ensureBackgroundNotificationPluginInitialized();

  final details = NotificationDetails(
    android: const AndroidNotificationDetails(
      _kPushChannelId,
      _kPushChannelName,
      channelDescription: _kPushChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  final notificationId = _stableBackgroundNotificationId(
    _firstNonEmpty(
          message.data['notificationId']?.toString(),
          message.data['id']?.toString(),
          message.messageId,
        ) ??
        'fcm-${DateTime.now().microsecondsSinceEpoch}',
  );

  await _backgroundNotificationsPlugin.show(
    notificationId,
    title,
    body,
    details,
    payload: jsonEncode({
      'notificationId': _firstNonEmpty(
        message.data['notificationId']?.toString(),
        message.data['id']?.toString(),
        message.messageId,
      ),
      'type': _firstNonEmpty(
        message.data['notificationType']?.toString(),
        message.data['type']?.toString(),
      ),
      'notificationType': _firstNonEmpty(
        message.data['notificationType']?.toString(),
        message.data['type']?.toString(),
      ),
      'deeplink': _firstNonEmpty(
        message.data['deeplink']?.toString(),
        message.data['deepLink']?.toString(),
      ),
      'deepLink': _firstNonEmpty(
        message.data['deeplink']?.toString(),
        message.data['deepLink']?.toString(),
      ),
      'actionUrl': message.data['actionUrl']?.toString(),
      'entityId': _firstNonEmpty(
        message.data['targetId']?.toString(),
        message.data['entityId']?.toString(),
        message.data['contentId']?.toString(),
      ),
      'targetId': _firstNonEmpty(
        message.data['targetId']?.toString(),
        message.data['entityId']?.toString(),
        message.data['contentId']?.toString(),
      ),
      'projectCode': _firstNonEmpty(
        message.data['projectCode']?.toString(),
        message.data['projectId']?.toString(),
      ),
      'projectId': _firstNonEmpty(
        message.data['projectCode']?.toString(),
        message.data['projectId']?.toString(),
      ),
      'priority': _firstNonEmpty(
        message.data['priority']?.toString(),
        'normal',
      ),
    }),
  );
}

Future<void> _ensureFirebaseAppInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    await Firebase.initializeApp();
    return;
  } catch (_) {
    // EN: Fallback to dart-define runtime options when bundled config is absent.
    // KO: 번들 설정 파일이 없을 때 dart-define 런타임 옵션으로 대체 초기화합니다.
  }

  final runtimeOptions = FirebaseRuntimeOptions.resolveForCurrentPlatform();
  if (runtimeOptions == null) {
    throw StateError('Firebase options are missing for this platform.');
  }
  await Firebase.initializeApp(options: runtimeOptions);
  AppLogger.info(
    'Firebase initialized with runtime options',
    tag: 'RemotePushService',
  );
}

int _stableBackgroundNotificationId(String seed) {
  return seed.hashCode & 0x7fffffff;
}

/// EN: Background entrypoint for Firebase Messaging.
/// KO: Firebase Messaging 백그라운드 엔트리포인트입니다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    widgets.WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await _ensureFirebaseAppInitialized();
    await _showBackgroundLocalNotificationIfNeeded(message);
  } catch (_) {
    // EN: Ignore to keep background isolate safe when Firebase config is absent.
    // KO: Firebase 설정 파일이 없을 때도 백그라운드 isolate 안정성을 위해 무시합니다.
  }
}

/// EN: Remote push coordinator.
/// KO: 원격 푸시 동기화 코디네이터입니다.
class RemotePushService {
  RemotePushService({
    required ApiClient apiClient,
    required Future<LocalStorage> localStorageFuture,
    required LocalNotificationsService localNotificationsService,
    FirebaseMessaging? messaging,
  }) : _apiClient = apiClient,
       _localStorageFuture = localStorageFuture,
       _localNotificationsService = localNotificationsService,
       _messaging = messaging;

  final ApiClient _apiClient;
  final Future<LocalStorage> _localStorageFuture;
  final LocalNotificationsService _localNotificationsService;
  FirebaseMessaging? _messaging;
  final StreamController<LocalNotificationTapEvent> _tapEventsController =
      StreamController<LocalNotificationTapEvent>.broadcast();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  bool _initialized = false;
  bool _firebaseReady = false;
  bool _isAuthenticated = false;
  // EN: Prevents concurrent device registration/token sync calls.
  // KO: 디바이스 등록/토큰 동기화 동시 호출을 방지합니다.
  bool _isSyncing = false;

  /// EN: Stream of push-open tap events mapped to existing notification routing model.
  /// KO: 기존 알림 라우팅 모델로 매핑된 푸시 오픈 탭 이벤트 스트림입니다.
  Stream<LocalNotificationTapEvent> get tapEvents =>
      _tapEventsController.stream;

  /// EN: Initialize Firebase messaging hooks.
  /// KO: Firebase 메시징 훅을 초기화합니다.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final ready = await _ensureFirebaseReady();
    if (!ready) {
      return;
    }
    final messaging = _messaging;
    if (messaging == null) {
      return;
    }
    _firebaseReady = true;
    _initialized = true;

    await messaging.setForegroundNotificationPresentationOptions(
      // EN: Let iOS present push in foreground so it appears in notification center.
      // KO: iOS 포그라운드에서도 알림센터에 표시되도록 시스템 표시를 허용합니다.
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) {
      if (!_isAuthenticated || token.trim().isEmpty) {
        return;
      }
      unawaited(
        _upsertDeviceRegistration(
          token.trim(),
          provider: 'FCM',
          forceRegister: false,
        ),
      );
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _emitTapEvent(initialMessage);
    }
  }

  /// EN: Update auth state and sync registration when authenticated.
  /// KO: 인증 상태를 갱신하고 인증됨 상태에서 디바이스 등록을 동기화합니다.
  Future<void> setAuthenticated(bool value) async {
    _isAuthenticated = value;
    if (!value) {
      return;
    }
    await syncRegistration();
  }

  /// EN: Request push permission from OS.
  /// KO: OS 푸시 권한을 요청합니다.
  Future<bool> requestPermission() async {
    final ready = await _ensureFirebaseReady();
    if (!ready) {
      return false;
    }
    final messaging = _messaging;
    if (messaging == null) {
      return false;
    }

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    final status = settings.authorizationStatus;
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  /// EN: Sync device registration/token with backend.
  /// EN: Concurrent calls are serialized: a second call while one is in
  /// EN: progress is silently dropped to prevent duplicate POST/PATCH requests.
  /// KO: 디바이스 등록/토큰을 백엔드와 동기화합니다.
  /// KO: 동시 호출은 직렬화됩니다: 진행 중에 두 번째 호출이 오면
  /// KO: 중복 POST/PATCH 요청을 방지하기 위해 조용히 무시됩니다.
  Future<void> syncRegistration() async {
    if (!_isAuthenticated) {
      return;
    }
    // EN: Drop concurrent sync to avoid duplicate device POST/PATCH races.
    // KO: 디바이스 POST/PATCH 경쟁을 방지하기 위해 동시 동기화를 건너뜁니다.
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    try {
      final ready = await _ensureFirebaseReady();
      if (!ready) {
        return;
      }
      final messaging = _messaging;
      if (messaging == null) {
        return;
      }

      final storage = await _localStorageFuture;
      final pushEnabled =
          storage.getBool(LocalStorageKeys.notificationsEnabled) ?? true;
      if (!pushEnabled) {
        return;
      }

      final credential = await _resolvePushCredential(messaging);
      if (credential == null) {
        AppLogger.warning(
          'Push token is unavailable; skip registration sync',
          tag: 'RemotePushService',
        );
        return;
      }

      await _upsertDeviceRegistration(
        credential.token,
        provider: credential.provider,
        forceRegister: false,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// EN: Deactivate current backend device registration and clear local keys.
  /// KO: 현재 백엔드 디바이스 등록을 비활성화하고 로컬 키를 정리합니다.
  Future<void> deactivateCurrentDevice() async {
    final storage = await _localStorageFuture;
    final deviceId = _resolveStoredDeviceId(storage);
    if (deviceId == null || deviceId.isEmpty) {
      return;
    }

    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.notificationDevice(deviceId),
    );

    if (result is Success<dynamic>) {
      await _clearLocalRegistrationKeys(storage);
      return;
    }

    if (result is Err<dynamic>) {
      final failure = result.failure;
      if (failure is NotFoundFailure && failure.code == '404') {
        await _clearLocalRegistrationKeys(storage);
        return;
      }
      AppLogger.warning(
        'Failed to deactivate notification device registration',
        data: failure,
        tag: 'RemotePushService',
      );
    }
  }

  /// EN: Dispose stream/listener resources.
  /// KO: 스트림/리스너 리소스를 해제합니다.
  void dispose() {
    unawaited(_tokenRefreshSubscription?.cancel());
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
    _tapEventsController.close();
  }

  Future<bool> _ensureFirebaseReady() async {
    if (_firebaseReady) {
      return true;
    }
    try {
      await _ensureFirebaseAppInitialized();
      _messaging ??= FirebaseMessaging.instance;
      _firebaseReady = true;
      return true;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Firebase is not configured; remote push is disabled',
        data: error,
        tag: 'RemotePushService',
      );
      AppLogger.error(
        'Firebase initialize failed',
        error: error,
        stackTrace: stackTrace,
        tag: 'RemotePushService',
      );
      _firebaseReady = false;
      return false;
    }
  }

  Future<void> _upsertDeviceRegistration(
    String pushToken, {
    required String provider,
    required bool forceRegister,
  }) async {
    if (!_isAuthenticated) {
      return;
    }
    final storage = await _localStorageFuture;
    final deviceId = await _resolveOrCreateDeviceId(storage);
    if (deviceId.isEmpty) {
      return;
    }

    final shouldRegister =
        forceRegister ||
        !storage.containsKey(LocalStorageKeys.notificationDeviceId);
    if (shouldRegister) {
      await _registerDevice(
        storage: storage,
        deviceId: deviceId,
        provider: provider,
        pushToken: pushToken,
      );
      return;
    }

    final patchResult = await _apiClient.patch<dynamic>(
      ApiEndpoints.notificationDeviceToken(deviceId),
      data: {'pushToken': pushToken, 'provider': provider},
    );
    if (patchResult is Success<dynamic>) {
      await storage.setString(
        LocalStorageKeys.notificationPushToken,
        pushToken,
      );
      return;
    }

    if (patchResult is Err<dynamic>) {
      final failure = patchResult.failure;
      if (failure is NotFoundFailure && failure.code == '404') {
        await _registerDevice(
          storage: storage,
          deviceId: deviceId,
          provider: provider,
          pushToken: pushToken,
        );
        return;
      }
      AppLogger.warning(
        'Failed to update push token',
        data: failure,
        tag: 'RemotePushService',
      );
    }
  }

  Future<void> _registerDevice({
    required LocalStorage storage,
    required String deviceId,
    required String provider,
    required String pushToken,
  }) async {
    final locale = _resolveDeviceLocale(storage);
    final timezone = _resolveDeviceTimezone();
    final payload = <String, dynamic>{
      'platform': _platformValue(),
      'provider': provider,
      'deviceId': deviceId,
      'pushToken': pushToken,
      if (locale != null) 'locale': locale,
      if (timezone != null) 'timezone': timezone,
    };

    final registerResult = await _apiClient.post<dynamic>(
      ApiEndpoints.notificationDevices,
      data: payload,
    );
    if (registerResult is Success<dynamic>) {
      final responseData = registerResult.data;
      var persistedDeviceId = deviceId;
      if (responseData is Map<String, dynamic>) {
        final candidate = _firstNonEmpty(
          responseData['deviceId']?.toString(),
          responseData['id']?.toString(),
        );
        if (candidate != null && candidate.isNotEmpty) {
          persistedDeviceId = candidate;
        }
      }
      await storage.setString(
        LocalStorageKeys.notificationDeviceId,
        persistedDeviceId,
      );
      await storage.remove(LocalStorageKeys.notificationDeviceIdLegacy);
      await storage.setString(
        LocalStorageKeys.notificationPushToken,
        pushToken,
      );
      return;
    }

    if (registerResult is Err<dynamic>) {
      AppLogger.warning(
        'Failed to register notification device',
        data: registerResult.failure,
        tag: 'RemotePushService',
      );
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final storage = await _localStorageFuture;
    final pushEnabled =
        storage.getBool(LocalStorageKeys.notificationsEnabled) ?? true;
    if (!pushEnabled) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS &&
        message.notification != null) {
      // EN: iOS already presents remote notification in foreground via
      // EN: setForegroundNotificationPresentationOptions(alert/sound/badge).
      // KO: iOS는 setForegroundNotificationPresentationOptions 설정으로
      // KO: 포그라운드 원격 알림을 이미 시스템이 표시하므로 중복 표시를 피합니다.
      return;
    }

    final item = _toNotificationItem(message);
    if (item == null) {
      return;
    }
    await _localNotificationsService.showNotificationItem(item);
  }

  void _handleOpenedMessage(RemoteMessage message) {
    _emitTapEvent(message);
  }

  void _emitTapEvent(RemoteMessage message) {
    final data = message.data;
    final notificationId = _firstNonEmpty(
      data['notificationId']?.toString(),
      data['id']?.toString(),
      message.messageId,
    );
    if (notificationId == null || notificationId.isEmpty) {
      return;
    }

    _tapEventsController.add(
      LocalNotificationTapEvent(
        notificationId: notificationId,
        type: normalizeNotificationType(
          _firstNonEmpty(
            data['notificationType']?.toString(),
            data['type']?.toString(),
          ),
        ),
        deeplink: _firstNonEmpty(
          data['deeplink']?.toString(),
          data['deepLink']?.toString(),
        ),
        actionUrl: data['actionUrl']?.toString(),
        entityId: _firstNonEmpty(
          data['targetId']?.toString(),
          data['entityId']?.toString(),
          data['contentId']?.toString(),
        ),
        projectCode: _firstNonEmpty(
          data['projectCode']?.toString(),
          data['projectId']?.toString(),
        ),
      ),
    );
  }

  NotificationItem? _toNotificationItem(RemoteMessage message) {
    final data = message.data;
    final id = _firstNonEmpty(
      data['notificationId']?.toString(),
      data['id']?.toString(),
      message.messageId,
      'fcm-${DateTime.now().millisecondsSinceEpoch}',
    );
    if (id == null || id.isEmpty) {
      return null;
    }

    final title = _firstNonEmpty(_resolvePushTitle(message), 'GirlsBandTabi');
    final body = _firstNonEmpty(_resolvePushBody(message), '');
    if (title == null || body == null) {
      return null;
    }

    return NotificationItem(
      id: id,
      title: title,
      body: body,
      createdAt: DateTime.now().toUtc(),
      isRead: false,
      type: normalizeNotificationType(
        _firstNonEmpty(
          data['notificationType']?.toString(),
          data['type']?.toString(),
        ),
      ),
      actionUrl: data['actionUrl']?.toString(),
      deeplink: _firstNonEmpty(
        data['deeplink']?.toString(),
        data['deepLink']?.toString(),
      ),
      entityId: _firstNonEmpty(
        data['targetId']?.toString(),
        data['entityId']?.toString(),
        data['contentId']?.toString(),
      ),
      projectCode: _firstNonEmpty(
        data['projectCode']?.toString(),
        data['projectId']?.toString(),
      ),
    );
  }

  String? _resolveStoredDeviceId(LocalStorage storage) {
    final primary = storage.getString(LocalStorageKeys.notificationDeviceId);
    if (primary != null && primary.trim().isNotEmpty) {
      return primary.trim();
    }
    final legacy = storage.getString(
      LocalStorageKeys.notificationDeviceIdLegacy,
    );
    if (legacy != null && legacy.trim().isNotEmpty) {
      return legacy.trim();
    }
    return null;
  }

  Future<String> _resolveOrCreateDeviceId(LocalStorage storage) async {
    final existing = _resolveStoredDeviceId(storage);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = '${_platformValue().toLowerCase()}-${const Uuid().v4()}';
    await storage.setString(LocalStorageKeys.notificationDeviceId, generated);
    await storage.remove(LocalStorageKeys.notificationDeviceIdLegacy);
    return generated;
  }

  Future<void> _clearLocalRegistrationKeys(LocalStorage storage) async {
    await Future.wait([
      storage.remove(LocalStorageKeys.notificationDeviceId),
      storage.remove(LocalStorageKeys.notificationDeviceIdLegacy),
      storage.remove(LocalStorageKeys.notificationPushToken),
    ]);
  }

  String _platformValue() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ANDROID',
      TargetPlatform.iOS => 'IOS',
      _ => 'UNKNOWN',
    };
  }

  Future<_PushCredential?> _resolvePushCredential(
    FirebaseMessaging messaging,
  ) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apnsToken = (await messaging.getAPNSToken())?.trim();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        return _PushCredential(provider: 'APNS', token: apnsToken);
      }
      final fcmToken = (await messaging.getToken())?.trim();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        return _PushCredential(provider: 'FCM', token: fcmToken);
      }
      return null;
    }

    final fcmToken = (await messaging.getToken())?.trim();
    if (fcmToken == null || fcmToken.isEmpty) {
      return null;
    }
    return _PushCredential(provider: 'FCM', token: fcmToken);
  }

  String? _resolveDeviceLocale(LocalStorage storage) {
    final storedLocale = storage.getLocale()?.trim();
    if (storedLocale != null &&
        storedLocale.isNotEmpty &&
        storedLocale.toLowerCase() != 'system') {
      return storedLocale;
    }
    final currentLocale = Intl.getCurrentLocale().trim();
    return currentLocale.isEmpty ? null : currentLocale;
  }

  String? _resolveDeviceTimezone() {
    final timezone = DateTime.now().timeZoneName.trim();
    return timezone.isEmpty ? null : timezone;
  }
}

String? _firstNonEmpty(
  String? first, [
  String? second,
  String? third,
  String? fourth,
]) {
  final values = [first, second, third, fourth];
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _resolvePushTitle(RemoteMessage message) {
  return _firstNonEmpty(
    message.notification?.title,
    message.data['title']?.toString(),
    message.data['notificationTitle']?.toString(),
    message.data['subject']?.toString(),
  );
}

String? _resolvePushBody(RemoteMessage message) {
  return _firstNonEmpty(
    message.notification?.body,
    message.data['body']?.toString(),
    message.data['message']?.toString(),
    message.data['content']?.toString(),
  );
}
