/// EN: Verification controller for place/live check-ins.
/// KO: 장소/라이브 인증 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/verification_remote_data_source.dart';
import '../data/repositories/verification_repository_impl.dart';
import '../domain/entities/verification_entities.dart';
import '../domain/repositories/verification_repository.dart';

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
    final repository = await _ref.read(verificationRepositoryProvider.future);

    final result = await repository.verifyPlace(
      projectId: resolvedProjectKey,
      placeId: placeId,
    );

    if (result is Success<VerificationResult>) {
      state = AsyncData(result.data);
    } else if (result is Err<VerificationResult>) {
      state = AsyncError(result.failure, StackTrace.current);
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
    final repository = await _ref.read(verificationRepositoryProvider.future);

    final result = await repository.verifyLiveEvent(
      projectId: resolvedProjectKey,
      liveEventId: liveEventId,
      verificationMethod: verificationMethod,
    );

    if (result is Success<VerificationResult>) {
      state = AsyncData(result.data);
    } else if (result is Err<VerificationResult>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
  }

  String _resolveProjectKey(String? projectKey) {
    if (projectKey == null || projectKey.isEmpty) {
      return '';
    }

    return projectKey;
  }

}

/// EN: Verification repository provider.
/// KO: 인증 리포지토리 프로바이더.
final verificationRepositoryProvider = FutureProvider<VerificationRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final locationService = ref.watch(locationServiceProvider);
  return VerificationRepositoryImpl(
    remoteDataSource: VerificationRemoteDataSource(apiClient),
    locationService: locationService,
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
