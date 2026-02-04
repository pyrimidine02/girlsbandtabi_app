/// EN: Verification repository implementation.
/// KO: 인증 리포지토리 구현.
library;

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/verification_entities.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';
import '../dto/verification_dto.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl({
    required VerificationRemoteDataSource remoteDataSource,
    required LocationService locationService,
  })  : _remoteDataSource = remoteDataSource,
        _locationService = locationService;

  final VerificationRemoteDataSource _remoteDataSource;
  final LocationService _locationService;

  @override
  Future<Result<VerificationConfig>> getConfig() async {
    try {
      final result = await _remoteDataSource.fetchConfig();

      if (result is Success<VerificationConfigDto>) {
        return Result.success(VerificationConfig.fromDto(result.data));
      }
      if (result is Err<VerificationConfigDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown verification config result',
          code: 'unknown_verification_config',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<VerificationChallenge>> getChallenge() async {
    try {
      final result = await _remoteDataSource.fetchChallenge();

      if (result is Success<VerificationChallengeDto>) {
        return Result.success(VerificationChallenge.fromDto(result.data));
      }
      if (result is Err<VerificationChallengeDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown verification challenge result',
          code: 'unknown_verification_challenge',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<VerificationResult>> verifyPlace({
    required String projectId,
    required String placeId,
  }) async {
    try {
      final request = await _buildRequest();
      final result = await _remoteDataSource.verifyPlace(
        projectId: projectId,
        placeId: placeId,
        request: request,
      );

      if (result is Success<VerificationResultDto>) {
        return Result.success(VerificationResult.fromDto(result.data));
      }
      if (result is Err<VerificationResultDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown place verification result',
          code: 'unknown_place_verification',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<VerificationResult>> verifyLiveEvent({
    required String projectId,
    required String liveEventId,
    String? verificationMethod,
  }) async {
    try {
      final request = await _buildRequest(verificationMethod: verificationMethod);
      final result = await _remoteDataSource.verifyLiveEvent(
        projectId: projectId,
        liveEventId: liveEventId,
        request: request,
      );

      if (result is Success<VerificationResultDto>) {
        return Result.success(VerificationResult.fromDto(result.data));
      }
      if (result is Err<VerificationResultDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown live event verification result',
          code: 'unknown_live_event_verification',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<VerificationRequestDto> _buildRequest({
    String? verificationMethod,
  }) async {
    if (verificationMethod != null && verificationMethod.isNotEmpty) {
      return VerificationRequestDto(verificationMethod: verificationMethod);
    }

    final location = await _locationService.getCurrentLocation();
    return VerificationRequestDto(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
    );
  }
}
