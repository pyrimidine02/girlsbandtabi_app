/// EN: Verification controller for place/live check-ins.
/// KO: 장소/라이브 인증 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../../visits/application/visits_controller.dart';
import '../data/datasources/verification_remote_data_source.dart';
import '../data/repositories/verification_repository_impl.dart';
import '../domain/entities/verification_entities.dart';
import '../domain/repositories/verification_repository.dart';
import 'token_service.dart';

class VerificationController
    extends StateNotifier<AsyncValue<VerificationResult?>> {
  VerificationController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  void reset() {
    state = const AsyncData(null);
  }

  Future<Result<VerificationResult>> verifyPlace(String placeId) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      const failure = AuthFailure('Login required', code: 'auth_required');
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final projectKey = _ref.read(selectedProjectKeyProvider);
    final resolvedProjectKey = _resolveProjectKey(projectKey);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = ValidationFailure(
        '프로젝트를 선택해 주세요.',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    state = const AsyncLoading();
    final repository = _ref.read(verificationRepositoryProvider);
    final tokenService = _ref.read(tokenServiceProvider);

    String? token;
    try {
      token = await tokenService.createVerificationToken();
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final result = await repository.verifyPlace(
      projectId: resolvedProjectKey,
      placeId: placeId,
      token: token,
    );

    if (result is Err<VerificationResult> &&
        _shouldRetryWithKeyReset(result.failure)) {
      return _retryWithFreshKey(
        tokenService: tokenService,
        verify: (retryToken) => repository.verifyPlace(
          projectId: resolvedProjectKey,
          placeId: placeId,
          token: retryToken,
        ),
        placeId: placeId,
      );
    }

    if (result is Success<VerificationResult>) {
      state = AsyncData(result.data);
      await _refreshVisitData(placeId);
      return result;
    }
    if (result is Err<VerificationResult>) {
      state = AsyncError(result.failure, StackTrace.current);
      return result;
    }

    return result;
  }

  Future<Result<VerificationResult>> verifyLiveEvent(
    String liveEventId, {
    String? verificationMethod,
  }) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      const failure = AuthFailure('Login required', code: 'auth_required');
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final projectKey = _ref.read(selectedProjectKeyProvider);
    final resolvedProjectKey = _resolveProjectKey(projectKey);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = ValidationFailure(
        '프로젝트를 선택해 주세요.',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    state = const AsyncLoading();
    final repository = _ref.read(verificationRepositoryProvider);
    final tokenService = _ref.read(tokenServiceProvider);

    String? token;
    if (verificationMethod == null || verificationMethod.isEmpty) {
      try {
        token = await tokenService.createVerificationToken();
      } catch (e, stackTrace) {
        final failure = ErrorHandler.mapException(e, stackTrace);
        state = AsyncError(failure, StackTrace.current);
        return Result.failure(failure);
      }
    }

    final result = await repository.verifyLiveEvent(
      projectId: resolvedProjectKey,
      liveEventId: liveEventId,
      verificationMethod: verificationMethod,
      token: token,
    );

    if (token != null &&
        result is Err<VerificationResult> &&
        _shouldRetryWithKeyReset(result.failure)) {
      return _retryWithFreshKey(
        tokenService: tokenService,
        verify: (retryToken) => repository.verifyLiveEvent(
          projectId: resolvedProjectKey,
          liveEventId: liveEventId,
          verificationMethod: verificationMethod,
          token: retryToken,
        ),
        placeId: null,
      );
    }

    if (result is Success<VerificationResult>) {
      state = AsyncData(result.data);
      return result;
    }
    if (result is Err<VerificationResult>) {
      state = AsyncError(result.failure, StackTrace.current);
      return result;
    }

    return result;
  }

  String _resolveProjectKey(String? projectKey) {
    if (projectKey == null || projectKey.isEmpty) {
      return '';
    }

    return projectKey;
  }

  bool _shouldRetryWithKeyReset(Failure failure) {
    final message = failure.message.toLowerCase();
    return message.contains('jws key not found') ||
        message.contains('location jws key not found');
  }

  Future<Result<VerificationResult>> _retryWithFreshKey({
    required TokenService tokenService,
    required Future<Result<VerificationResult>> Function(String token) verify,
    required String? placeId,
  }) async {
    final secureStorage = _ref.read(secureStorageProvider);
    await secureStorage.clearVerificationKeys();

    String retryToken;
    try {
      retryToken = await tokenService.createVerificationToken();
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final retryResult = await verify(retryToken);
    if (retryResult is Success<VerificationResult>) {
      state = AsyncData(retryResult.data);
      await _refreshVisitData(placeId);
    } else if (retryResult is Err<VerificationResult>) {
      state = AsyncError(retryResult.failure, StackTrace.current);
    }
    return retryResult;
  }

  Future<void> _refreshVisitData(String? placeId) async {
    try {
      await _ref
          .read(userVisitsControllerProvider.notifier)
          .load(forceRefresh: true);
      if (placeId != null && placeId.isNotEmpty) {
        _ref.invalidate(visitSummaryProvider(placeId));
      }
      _ref.invalidate(userRankingProvider);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Visit data refresh failed after verification',
        data: e,
        tag: 'VerificationController',
      );
      AppLogger.error(
        'Visit data refresh error',
        error: e,
        stackTrace: stackTrace,
        tag: 'VerificationController',
      );
    }
  }
}

/// EN: Verification repository provider.
/// KO: 인증 리포지토리 프로바이더.
final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VerificationRepositoryImpl(
    remoteDataSource: VerificationRemoteDataSource(apiClient),
  );
});

/// EN: Verification controller provider.
/// KO: 인증 컨트롤러 프로바이더.
final verificationControllerProvider =
    StateNotifierProvider<
      VerificationController,
      AsyncValue<VerificationResult?>
    >((ref) {
      return VerificationController(ref);
    });
