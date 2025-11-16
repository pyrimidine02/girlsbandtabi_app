import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/verification_model.dart';
import '../services/location_service.dart';
import '../services/verification_service.dart';
import '../core/network/api_client.dart' show ApiException;
import 'home_provider.dart';

enum PlaceVerificationStatus {
  idle,
  requestingPermission,
  acquiringLocation,
  buildingPayload,
  verifying,
  success,
  error,
}

class PlaceVerificationState {
  const PlaceVerificationState({
    required this.status,
    this.message,
    this.distanceM,
    this.accuracyM,
    this.latitude,
    this.longitude,
    this.verifiedAt,
  });

  factory PlaceVerificationState.initial() => const PlaceVerificationState(
        status: PlaceVerificationStatus.idle,
      );

  final PlaceVerificationStatus status;
  final String? message;
  final double? distanceM;
  final double? accuracyM;
  final double? latitude;
  final double? longitude;
  final DateTime? verifiedAt;

  bool get isLoading => status == PlaceVerificationStatus.requestingPermission ||
      status == PlaceVerificationStatus.acquiringLocation ||
      status == PlaceVerificationStatus.buildingPayload ||
      status == PlaceVerificationStatus.verifying;

  PlaceVerificationState copyWith({
    PlaceVerificationStatus? status,
    String? message,
    double? distanceM,
    double? accuracyM,
    double? latitude,
    double? longitude,
    DateTime? verifiedAt,
    bool resetMessage = false,
    bool resetTelemetry = false,
  }) {
    return PlaceVerificationState(
      status: status ?? this.status,
      message: resetMessage ? null : message ?? this.message,
      distanceM: resetTelemetry ? null : distanceM ?? this.distanceM,
      accuracyM: resetTelemetry ? null : accuracyM ?? this.accuracyM,
      latitude: resetTelemetry ? null : latitude ?? this.latitude,
      longitude: resetTelemetry ? null : longitude ?? this.longitude,
      verifiedAt: resetTelemetry ? null : verifiedAt ?? this.verifiedAt,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService();
});

final placeVerificationControllerProvider =
    StateNotifierProvider.autoDispose.family<PlaceVerificationController,
        PlaceVerificationState, String>((ref, placeId) {
  return PlaceVerificationController(ref, placeId);
});

class PlaceVerificationController extends StateNotifier<PlaceVerificationState> {
  PlaceVerificationController(this._ref, this._placeId)
      : _locationService = _ref.read(locationServiceProvider),
        _verificationService = _ref.read(verificationServiceProvider),
        super(PlaceVerificationState.initial());

  final Ref _ref;
  final String _placeId;
  final LocationService _locationService;
  final VerificationService _verificationService;

  bool _inFlight = false;

  Future<void> verify({
    required String projectId,
    required double placeLat,
    required double placeLon,
  }) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    try {
      state = state.copyWith(
        status: PlaceVerificationStatus.requestingPermission,
        resetMessage: true,
      );

      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: PlaceVerificationStatus.error,
          message: '위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
        );
        return;
      }

      state = state.copyWith(
        status: PlaceVerificationStatus.acquiringLocation,
        message: '정확한 위치를 확인하는 중입니다...',
        resetTelemetry: true,
      );

      final position = await _locationService.getAccurateLocation(
        samples: 4,
        interval: const Duration(seconds: 1),
      );

      if (position == null) {
        state = state.copyWith(
          status: PlaceVerificationStatus.error,
          message: '현재 위치를 확인할 수 없습니다. 위치 서비스를 활성화해주세요.',
        );
        return;
      }

      final computedDistance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        placeLat,
        placeLon,
      );

      state = state.copyWith(
        status: PlaceVerificationStatus.buildingPayload,
        message: '보안 토큰을 생성하고 있습니다...',
        accuracyM: position.accuracy,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceM: computedDistance,
      );

      final token = await _verificationService.buildLocationToken(
        lat: position.latitude,
        lon: position.longitude,
        accuracyM: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        placeId: _placeId,
      );

      state = state.copyWith(
        status: PlaceVerificationStatus.verifying,
        message: '서버에서 인증을 검증하고 있습니다...',
      );

      final VisitVerificationResponse response =
          await _verificationService.verifyPlaceVisit(
        projectId: projectId,
        placeId: _placeId,
        token: token,
      );

      final bool success = response.result.toUpperCase() == 'VERIFIED';
      state = state.copyWith(
        status:
            success ? PlaceVerificationStatus.success : PlaceVerificationStatus.error,
        message: response.message ??
            (success ? '장소 인증이 완료되었습니다!' : '인증에 실패했습니다.'),
        distanceM: response.distanceM ?? computedDistance,
        verifiedAt: DateTime.now(),
      );
      if (success) {
        _ref.invalidate(homeSummaryProvider);
      }
    } on ApiException catch (apiError) {
      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: apiError.message,
      );
    } on TimeoutException {
      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: '요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.',
      );
    } catch (e) {
      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: '인증 중 오류가 발생했습니다: $e',
      );
    } finally {
      _inFlight = false;
    }
  }

  void reset() {
    state = PlaceVerificationState.initial();
  }
}
