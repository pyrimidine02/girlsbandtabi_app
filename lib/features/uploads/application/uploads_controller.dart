/// EN: Uploads controller and Riverpod providers.
/// KO: 업로드 컨트롤러 및 Riverpod 프로바이더.
library;

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/uploads_remote_data_source.dart';
import '../data/dto/upload_dto.dart';
import '../data/repositories/uploads_repository_impl.dart';
import '../domain/entities/upload_entity.dart';
import '../domain/repositories/uploads_repository.dart';
import '../utils/presigned_upload_helper.dart';

/// EN: Controller for managing user uploads.
/// KO: 사용자 업로드를 관리하는 컨트롤러.
class UploadsController extends StateNotifier<AsyncValue<List<UploadInfo>>> {
  UploadsController(this._ref) : super(const AsyncLoading());

  final Ref _ref;

  /// EN: Load the user's uploads.
  /// KO: 사용자의 업로드를 로드합니다.
  Future<void> load({bool forceRefresh = false}) async {
    state = const AsyncLoading();

    final repository = await _ref.read(uploadsRepositoryProvider.future);
    final result = await repository.getMyUploads(forceRefresh: forceRefresh);

    if (result is Success<List<UploadInfo>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<UploadInfo>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  /// EN: Request a presigned URL and return it.
  /// KO: presigned URL을 요청하고 반환합니다.
  Future<Result<PresignedUrlResponse>> requestPresignedUrl({
    required String filename,
    required String contentType,
    required int size,
  }) async {
    final repository = await _ref.read(uploadsRepositoryProvider.future);
    return repository.requestPresignedUrl(
      filename: filename,
      contentType: contentType,
      size: size,
    );
  }

  /// EN: Upload bytes and return upload info (presigned first, direct fallback).
  /// KO: 바이트 업로드 후 업로드 정보를 반환합니다(presigned 우선, direct 폴백).
  ///
  /// EN: For image content types, the server requires using the direct upload
  /// endpoint, so we skip presigned URL and go straight to direct upload.
  /// KO: 이미지 contentType의 경우 서버가 direct 업로드 엔드포인트를
  /// 요구하므로 presigned URL을 건너뛰고 바로 direct 업로드를 사용합니다.
  Future<Result<UploadInfo>> uploadImageBytes({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final repository = await _ref.read(uploadsRepositoryProvider.future);

    // EN: Server rejects presigned URLs for image/* content types with 400.
    // Use direct upload immediately for images.
    // KO: 서버는 image/* contentType에 대해 presigned URL을 400으로 거부합니다.
    // 이미지는 바로 direct 업로드를 사용합니다.
    if (contentType.startsWith('image/')) {
      AppLogger.debug(
        'Image content type detected ($contentType), '
        'using direct upload',
        tag: 'UploadsController',
      );
      final directResult = await repository.directUpload(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
      if (directResult is Success<UploadInfo>) {
        await load(forceRefresh: true);
      }
      return directResult;
    }

    // EN: Non-image files: try presigned URL first, fallback to direct.
    // KO: 이미지가 아닌 파일: presigned URL 우선, direct로 폴백.
    final presignedResult = await _uploadViaPresigned(
      repository: repository,
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );

    if (presignedResult is Success<UploadInfo>) {
      return presignedResult;
    }

    if (presignedResult is Err<UploadInfo>) {
      final failure = presignedResult.failure;
      if (_shouldFallbackToDirect(failure)) {
        AppLogger.warning(
          'Presigned upload failed (${failure.runtimeType}: ${failure.message}), '
          'falling back to direct upload',
          tag: 'UploadsController',
        );
        final directResult = await repository.directUpload(
          bytes: bytes,
          filename: filename,
          contentType: contentType,
        );
        if (directResult is Success<UploadInfo>) {
          await load(forceRefresh: true);
        }
        return directResult;
      }
    }

    return presignedResult;
  }

  /// EN: Confirm an upload after file has been sent to S3/R2.
  /// KO: 파일이 S3/R2에 전송된 후 업로드를 확인합니다.
  Future<Result<ConfirmUploadResponse>> confirmUpload(String uploadId) async {
    final repository = await _ref.read(uploadsRepositoryProvider.future);
    final result = await repository.confirmUpload(uploadId);
    if (result is Success<ConfirmUploadResponse>) {
      // EN: Refresh the list after confirming.
      // KO: 확인 후 목록을 새로고침합니다.
      await load(forceRefresh: true);
    }
    return result;
  }

  /// EN: Delete an upload.
  /// KO: 업로드를 삭제합니다.
  Future<Result<void>> deleteUpload(String uploadId) async {
    final repository = await _ref.read(uploadsRepositoryProvider.future);
    final result = await repository.deleteUpload(uploadId);
    if (result is Success<void>) {
      await load(forceRefresh: true);
    }
    return result;
  }

  bool _shouldFallbackToDirect(Failure failure) {
    // EN: Network failures (timeout, connection error) should always fallback.
    // KO: 네트워크 실패(타임아웃, 연결 오류)는 항상 direct로 폴백합니다.
    if (failure is NetworkFailure) {
      return true;
    }
    if (failure is NotFoundFailure) {
      return true;
    }
    if (failure is ServerFailure) {
      return switch (failure.code) {
        '404' => true,
        '405' => true,
        '500' => true,
        '501' => true,
        '502' => true,
        '503' => true,
        _ =>
          failure.message.toLowerCase().contains('presigned') &&
              failure.message.toLowerCase().contains('unsupported'),
      };
    }
    // EN: Unknown failures should also try direct upload as a last resort.
    // KO: 알 수 없는 실패도 최후 수단으로 direct 업로드를 시도합니다.
    if (failure is UnknownFailure) {
      return true;
    }
    return false;
  }

  Future<Result<UploadInfo>> _uploadViaPresigned({
    required UploadsRepository repository,
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final presignedResult = await repository.requestPresignedUrl(
      filename: filename,
      contentType: contentType,
      size: bytes.length,
    );
    if (presignedResult is Err<PresignedUrlResponse>) {
      return Result.failure(presignedResult.failure);
    }

    final presigned = switch (presignedResult) {
      Success(:final data) => data,
      Err(:final failure) => throw failure,
    };

    try {
      await uploadToPresignedUrl(
        url: presigned.url,
        bytes: bytes,
        contentType: contentType,
        headers: presigned.headers,
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }

    final confirmResult = await repository.confirmUpload(presigned.uploadId);
    if (confirmResult is Err<ConfirmUploadResponse>) {
      return Result.failure(confirmResult.failure);
    }

    final listResult = await repository.getMyUploads(forceRefresh: true);
    if (listResult is Success<List<UploadInfo>>) {
      final match = listResult.data
          .where((item) => item.uploadId == presigned.uploadId)
          .toList();
      if (match.isNotEmpty) {
        return Result.success(match.first);
      }
    } else if (listResult is Err<List<UploadInfo>>) {
      return Result.failure(listResult.failure);
    }

    return const Result.failure(
      UnknownFailure('Uploaded file not found after confirm'),
    );
  }
}

// ========================================
// EN: Riverpod Providers
// KO: Riverpod 프로바이더
// ========================================

/// EN: Uploads repository provider.
/// KO: 업로드 리포지토리 프로바이더.
final uploadsRepositoryProvider = FutureProvider<UploadsRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
  return UploadsRepositoryImpl(
    remoteDataSource: UploadsRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Uploads controller provider.
/// KO: 업로드 컨트롤러 프로바이더.
final uploadsControllerProvider =
    StateNotifierProvider<UploadsController, AsyncValue<List<UploadInfo>>>((
      ref,
    ) {
      return UploadsController(ref);
    });
