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

  /// EN: Upload bytes and return upload info.
  /// KO: 바이트 업로드 후 업로드 정보를 반환합니다.
  ///
  /// EN: GIF files are routed through the presigned URL flow because the
  /// direct upload endpoint converts files to WebP (which would destroy
  /// animation). The server's presigned-url endpoint explicitly allows
  /// image/gif. All other image/* types use the direct upload endpoint
  /// which performs server-side WebP conversion.
  /// KO: GIF 파일은 presigned URL 경로를 사용합니다. direct 업로드 엔드포인트는
  /// 파일을 WebP로 변환하므로 애니메이션이 손실됩니다. 서버의 presigned-url
  /// 엔드포인트는 image/gif를 명시적으로 허용합니다. 그 외 image/* 타입은
  /// 서버 측 WebP 변환을 수행하는 direct 업로드 엔드포인트를 사용합니다.
  Future<Result<UploadInfo>> uploadImageBytes({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final repository = await _ref.read(uploadsRepositoryProvider.future);

    // EN: GIF must go through presigned URL (server converts direct-upload
    // images to WebP, which breaks animation). Presigned URL stores the
    // file as-is in R2.
    // KO: GIF는 presigned URL을 통해 업로드해야 합니다. direct 업로드는
    // 이미지를 WebP로 변환하여 애니메이션이 손실됩니다. Presigned URL은
    // 파일을 R2에 그대로 저장합니다.
    if (contentType != 'image/gif' && contentType.startsWith('image/')) {
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
        _upsertUpload(directResult.data);
      }
      return directResult;
    }

    // EN: GIF and non-image files: presigned URL first, fallback to direct.
    // KO: GIF 및 이미지 외 파일: presigned URL 우선, direct로 폴백.
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
          _upsertUpload(directResult.data);
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

    final uploaded = UploadInfo(
      uploadId: presigned.uploadId,
      url: _stripQueryAndFragment(presigned.url),
      filename: filename,
      isApproved: true,
    );
    _upsertUpload(uploaded);
    return Result.success(uploaded);
  }

  void _upsertUpload(UploadInfo upload) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final next = <UploadInfo>[
      upload,
      ...current.where((item) => item.uploadId != upload.uploadId),
    ];
    state = AsyncData(next);
  }

  String _stripQueryAndFragment(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return rawUrl;
    }
    return uri.replace(query: null, fragment: null).toString();
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
