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
    this.resultCode,
  });

  factory PlaceVerificationState.initial() =>
      const PlaceVerificationState(status: PlaceVerificationStatus.idle);

  final PlaceVerificationStatus status;
  final String? message;
  final double? distanceM;
  final double? accuracyM;
  final double? latitude;
  final double? longitude;
  final DateTime? verifiedAt;
  final String? resultCode;

  bool get isLoading =>
      status == PlaceVerificationStatus.requestingPermission ||
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
    bool resetResultCode = false,
    String? resultCode,
  }) {
    return PlaceVerificationState(
      status: status ?? this.status,
      message: resetMessage ? null : message ?? this.message,
      distanceM: resetTelemetry ? null : distanceM ?? this.distanceM,
      accuracyM: resetTelemetry ? null : accuracyM ?? this.accuracyM,
      latitude: resetTelemetry ? null : latitude ?? this.latitude,
      longitude: resetTelemetry ? null : longitude ?? this.longitude,
      verifiedAt: resetTelemetry ? null : verifiedAt ?? this.verifiedAt,
      resultCode: resetResultCode ? null : resultCode ?? this.resultCode,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final verificationServiceProvider = Provider<VerificationService>((ref) {
  return VerificationService();
});

final placeVerificationControllerProvider = StateNotifierProvider.autoDispose
    .family<PlaceVerificationController, PlaceVerificationState, String>((
      ref,
      placeId,
    ) {
      return PlaceVerificationController(ref, placeId);
    });

class PlaceVerificationController
    extends StateNotifier<PlaceVerificationState> {
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
        resetResultCode: true,
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

      final response = await _executeVerificationRequest(
        projectId: projectId,
        position: position,
      );

      if (response != null) {
        final bool success = response.result.toUpperCase() == 'VERIFIED';
        final resolvedMessage = _mapResultToMessage(
          success: success,
          response: response,
          computedDistance: computedDistance,
          accuracyM: position.accuracy,
        );
        state = state.copyWith(
          status: success
              ? PlaceVerificationStatus.success
              : PlaceVerificationStatus.error,
          message: resolvedMessage,
          distanceM: response.distanceM ?? computedDistance,
          verifiedAt: DateTime.now(),
          resultCode: response.result,
        );
        if (success) {
          _ref.invalidate(homeSummaryProvider);
        }
      }
    } on TimeoutException {
      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: '요청 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.',
        resultCode: 'TIMEOUT',
      );
    } catch (e) {
      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: '인증 중 오류가 발생했습니다: $e',
        resultCode: 'UNKNOWN',
      );
    } finally {
      _inFlight = false;
    }
  }

  void reset() {
    state = PlaceVerificationState.initial();
  }

  String _mapResultToMessage({
    required bool success,
    required VisitVerificationResponse response,
    required double? computedDistance,
    required double? accuracyM,
  }) {
    // EN: Respect backend-provided message when available.
    // KO: 백엔드가 제공한 메시지가 있으면 우선 사용합니다.
    if (success) {
      return '장소 인증이 완료되었습니다!';
    }

    final normalized = response.result.trim().toUpperCase();
    final distanceText = computedDistance != null
        ? '${computedDistance.toStringAsFixed(computedDistance >= 100 ? 0 : 1)} m'
        : null;
    final accuracyText = accuracyM != null
        ? '±${accuracyM.toStringAsFixed(accuracyM >= 100 ? 0 : 1)} m'
        : null;

    if (normalized.contains('DISTANCE') ||
        normalized.contains('RANGE') ||
        normalized.contains('LOCATION')) {
      final hint = distanceText != null ? ' (현재 거리 $distanceText)' : '';
      return '측정된 위치가 성지 반경을 벗어났습니다$hint. 조금 더 가까이 이동한 뒤 다시 시도해주세요.';
    }
    if (normalized.contains('ACCURACY') || normalized.contains('PRECISION')) {
      final hint = accuracyText != null ? ' (현재 정확도 $accuracyText)' : '';
      return 'GPS 신호가 불안정합니다$hint. 하늘이 잘 보이는 장소에서 잠시 기다린 후 다시 시도해주세요.';
    }
    if (normalized.contains('TOKEN') || normalized.contains('SIGNATURE')) {
      return '인증 토큰이 만료되었거나 유효하지 않습니다. 창을 닫고 다시 시도해주세요.';
    }
    if (normalized.contains('SPOOF') || normalized.contains('TAMPER')) {
      return '비정상 위치 접근이 감지되어 인증이 차단되었습니다. 기기의 위치 설정을 확인한 뒤 다시 시도해주세요.';
    }
    if (normalized.contains('COOLDOWN') ||
        normalized.contains('RATE') ||
        normalized.contains('LIMIT') ||
        normalized.contains('FREQUENT')) {
      return '짧은 시간에 너무 많은 인증을 시도했습니다. 잠시 후 다시 시도해주세요.';
    }
    final serverMessage = response.message?.trim();
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }
    if (normalized.contains('ALREADY') ||
        normalized.contains('DUPLICATE') ||
        normalized.contains('RECENT')) {
      return '이미 최근에 인증 처리된 방문입니다.';
    }
    if (normalized.contains('PERMISSION') || normalized.contains('DENIED')) {
      return '위치 권한을 확인할 수 없어 인증이 중단되었습니다. 권한을 허용한 뒤 다시 시도해주세요.';
    }

    final readableCode = normalized.isEmpty
        ? ''
        : ' (코드: ${normalized.replaceAll('_', ' ')})';
    return '인증에 실패했습니다.$readableCode';
  }

  Future<VisitVerificationResponse?> _executeVerificationRequest({
    required String projectId,
    required Position position,
  }) async {
    state = state.copyWith(
      status: PlaceVerificationStatus.verifying,
      message: '서버에서 인증을 검증하고 있습니다...',
    );

    try {
      return await _sendVerification(
        projectId: projectId,
        position: position,
        forceConfigRefresh: false,
      );
    } on StateError catch (stateError) {
      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: '인증 키를 불러올 수 없어 현재 시도할 수 없습니다. 잠시 후 다시 시도해주세요.',
        resultCode: 'CONFIG_MISSING_PUBLIC_KEY',
      );
      return null;
    } on ApiException catch (apiError) {
      if (_shouldRetryWithFreshConfig(apiError)) {
        try {
          _verificationService.invalidateCache();
          return await _sendVerification(
            projectId: projectId,
            position: position,
            forceConfigRefresh: true,
          );
        } on StateError catch (stateError) {
          state = state.copyWith(
            status: PlaceVerificationStatus.error,
            message: '인증 키를 불러올 수 없어 현재 시도할 수 없습니다. 잠시 후 다시 시도해주세요.',
            resultCode: 'CONFIG_MISSING_PUBLIC_KEY',
          );
          return null;
        } on ApiException catch (retryError) {
          state = state.copyWith(
            status: PlaceVerificationStatus.error,
            message: _mapApiExceptionMessage(retryError.message),
            resultCode: retryError.code ?? 'API_EXCEPTION',
          );
          return null;
        }
      }

      state = state.copyWith(
        status: PlaceVerificationStatus.error,
        message: _mapApiExceptionMessage(apiError.message),
        resultCode: apiError.code ?? 'API_EXCEPTION',
      );
      return null;
    }
  }

  Future<VisitVerificationResponse> _sendVerification({
    required String projectId,
    required Position position,
    required bool forceConfigRefresh,
  }) async {
    final token = await _verificationService.buildLocationToken(
      lat: position.latitude,
      lon: position.longitude,
      accuracyM: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      placeId: _placeId,
      forceConfigRefresh: forceConfigRefresh,
    );

    return _verificationService.verifyPlaceVisit(
      projectId: projectId,
      placeId: _placeId,
      token: token,
    );
  }

  bool _shouldRetryWithFreshConfig(ApiException error) {
    final code = error.code?.toUpperCase();
    const retryableCodes = {
      'VERIFICATION_TOKEN_INVALID',
      'VERIFICATION_TOKEN_EXPIRED',
      'CONFIG_VERSION_MISMATCH',
      'CONFIG_NOT_FOUND',
      'PUBLIC_KEY_NOT_FOUND',
      'PUBLIC_KEY_ROTATED',
    };
    if (code != null && retryableCodes.contains(code)) {
      return true;
    }

    final message = error.message.toLowerCase();
    return message.contains('public key') ||
        message.contains('clock skew') ||
        message.contains('timestamp');
  }

  String _mapApiExceptionMessage(String raw) {
    final normalized = raw.toLowerCase().trim();
    if (normalized.contains('too far')) {
      return '측정된 위치가 성지 반경을 벗어났습니다. 조금 더 가까이 이동한 뒤 다시 시도해주세요.';
    }
    if (normalized.contains('suspicious') || normalized.contains('spoof')) {
      return '비정상 위치 접근이 감지되어 인증이 차단되었습니다. 기기의 위치 설정을 확인한 뒤 다시 시도해주세요.';
    }
    if (normalized.isEmpty) {
      return '인증에 실패했습니다.';
    }
    return raw;
  }
}
