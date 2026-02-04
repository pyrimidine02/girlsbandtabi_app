/// EN: Remote data source for upload APIs.
/// KO: 업로드 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/upload_dto.dart';

/// EN: Handles upload-related API requests.
/// KO: 업로드 관련 API 요청을 처리합니다.
class UploadsRemoteDataSource {
  UploadsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Request a presigned URL for direct file upload.
  /// KO: 직접 파일 업로드를 위한 presigned URL을 요청합니다.
  Future<Result<PresignedUrlResponse>> requestPresignedUrl(
    CreateUploadUrlRequest request,
  ) {
    return _apiClient.post<PresignedUrlResponse>(
      ApiEndpoints.uploadsPresignedUrl,
      data: request.toJson(),
      fromJson: (json) =>
          PresignedUrlResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Confirm that a file has been uploaded successfully.
  /// KO: 파일이 성공적으로 업로드되었음을 확인합니다.
  Future<Result<ConfirmUploadResponse>> confirmUpload(String uploadId) {
    return _apiClient.post<ConfirmUploadResponse>(
      ApiEndpoints.uploadsConfirm(uploadId),
      fromJson: (json) =>
          ConfirmUploadResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Approve or reject an upload (admin).
  /// KO: 업로드 승인/반려(관리자).
  Future<Result<ApproveUploadResponse>> approveUpload({
    required String uploadId,
    required bool isApproved,
  }) {
    return _apiClient.put<ApproveUploadResponse>(
      ApiEndpoints.uploadsApprove(uploadId),
      data: ApproveUploadRequest(isApproved: isApproved).toJson(),
      fromJson: (json) =>
          ApproveUploadResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Fetch the current user's uploads.
  /// KO: 현재 사용자의 업로드 목록을 조회합니다.
  Future<Result<List<UploadInfoResponse>>> fetchMyUploads({
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<UploadInfoResponse>>(
      ApiEndpoints.uploadsMy,
      queryParameters: {'page': page, 'size': size},
      fromJson: (json) => _decodeList(json, UploadInfoResponse.fromJson),
    );
  }

  /// EN: Delete an upload.
  /// KO: 업로드를 삭제합니다.
  Future<Result<void>> deleteUpload(String uploadId) {
    return _apiClient.delete<void>(
      ApiEndpoints.uploadsDelete(uploadId),
      fromJson: (_) {},
    );
  }
}

List<T> _decodeList<T>(dynamic json, T Function(Map<String, dynamic>) mapper) {
  if (json is List) {
    return json.whereType<Map<String, dynamic>>().map(mapper).toList();
  }
  if (json is Map<String, dynamic>) {
    const listKeys = ['items', 'content', 'data', 'results'];
    for (final key in listKeys) {
      final value = json[key];
      if (value is List) {
        return value.whereType<Map<String, dynamic>>().map(mapper).toList();
      }
    }
  }
  return <T>[];
}
