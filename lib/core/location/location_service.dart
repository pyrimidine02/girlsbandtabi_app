/// EN: Location service wrapper for current device position.
/// KO: 현재 기기 위치를 가져오는 위치 서비스 래퍼.
library;

import 'package:geolocator/geolocator.dart';

import '../error/failure.dart';

/// EN: Snapshot of a device location reading.
/// KO: 디바이스 위치 스냅샷.
class LocationSnapshot {
  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
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

    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }
}
