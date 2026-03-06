/// EN: Local notifications service for in-app alert delivery.
/// KO: 인앱 알림 전달을 위한 로컬 알림 서비스입니다.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/domain/entities/notification_entities.dart';

class LocalNotificationsService {
  LocalNotificationsService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _channelId = 'gbt_notifications_high';
  static const String _channelName = 'GBT Notifications';
  static const String _channelDescription =
      'Realtime community and system notifications';

  /// EN: Initialize plugin and Android channel.
  /// KO: 플러그인과 Android 채널을 초기화합니다.
  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// EN: Request runtime notification permissions.
  /// KO: 런타임 알림 권한을 요청합니다.
  Future<bool> requestPermissions() async {
    await initialize();

    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final macGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final grantedValues = <bool>[
      if (iosGranted != null) iosGranted,
      if (macGranted != null) macGranted,
      if (androidGranted != null) androidGranted,
    ];

    if (grantedValues.isEmpty) {
      return true;
    }
    return grantedValues.any((value) => value);
  }

  /// EN: Show a local alert for a newly arrived notification item.
  /// KO: 새로 도착한 알림 항목에 대해 로컬 알림을 표시합니다.
  Future<void> showNotificationItem(NotificationItem item) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      _stableNotificationId(item.id),
      item.title,
      item.body,
      details,
      payload: item.id,
    );
  }

  int _stableNotificationId(String raw) {
    return raw.hashCode & 0x7fffffff;
  }
}
