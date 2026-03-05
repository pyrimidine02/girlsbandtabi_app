/// EN: Location service wrapper for current device position.
/// KO: 현재 기기 위치를 가져오는 위치 서비스 래퍼.
library;

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../error/failure.dart';
import '../logging/app_logger.dart';

/// EN: Snapshot of a device location reading.
/// KO: 디바이스 위치 스냅샷.
class LocationSnapshot {
  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isMocked,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isMocked;
  final DateTime timestamp;
}

/// EN: Service for resolving current device location with permission checks.
/// KO: 권한 확인과 함께 현재 위치를 조회하는 서비스.
class LocationService {
  const LocationService();

  /// EN: Fetches current location or throws a [LocationFailure].
  /// KO: 현재 위치를 조회하거나 [LocationFailure]를 발생시킵니다.
  Future<LocationSnapshot> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(
        'Location services disabled',
        code: 'service_disabled',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        'Location permission denied',
        code: 'permission_denied',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Location permission denied forever',
        code: 'permission_denied_forever',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    // EN: Prevent false-positives on older OS versions.
    // KO: 구형 OS 버전에서의 오탐지를 방지합니다.
    bool finalIsMocked = position.isMocked;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 30) {
          finalIsMocked = false; // API 30 이하는 서버 탐지에 맡기고 false 고정
        }
      } else if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        final versionParts = iosInfo.systemVersion.split('.');
        if (versionParts.isNotEmpty) {
          final majorVersion = int.tryParse(versionParts[0]) ?? 0;
          if (majorVersion <= 14) {
            finalIsMocked = false; // iOS 14 이하는 false 고정
          }
        }
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to verify OS version for isMocked: $e',
        tag: 'LocationService',
      );
    }

    // EN: Log location metadata for debugging mocked-location false-positives.
    // KO: 모의 위치 오탐 디버깅을 위해 위치 메타데이터를 로깅합니다.
    if (finalIsMocked) {
      AppLogger.warning(
        'isMocked=true detected on device — '
        'accuracy=${position.accuracy}m, '
        'speed=${position.speed}, '
        'altitude=${position.altitude}',
        tag: 'LocationService',
      );
    } else {
      AppLogger.info(
        'Location acquired: isMocked=false, accuracy=${position.accuracy}m',
        tag: 'LocationService',
      );
    }

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      isMocked: finalIsMocked,
      timestamp: position.timestamp,
    );
  }
}
