import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/upload_model.dart';

class UploadService {
  UploadService();

  final ApiClient _api = ApiClient.instance;

  Future<PresignedUpload> getPresignedUrl({
    required String filename,
    required String contentType,
    required int size,
  }) async {
    final envelope = await _api.post(
      ApiConstants.presignedUrl,
      data: {
        'filename': filename,
        'contentType': contentType,
        'size': size,
      },
    );
    return PresignedUpload.fromMap(envelope.requireDataAsMap());
  }

  Future<Map<String, dynamic>> confirmUpload(String uploadId) async {
    final envelope = await _api.post(
      ApiConstants.uploadConfirm(uploadId),
    );
    return envelope.requireDataAsMap();
  }

  Future<UploadsPage> getMyUploads({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final envelope = await _api.get(
      ApiConstants.myUploads,
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      },
    );

    final raw = envelope.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic>
            ? (raw['items'] as List?) ?? const <dynamic>[]
            : const <dynamic>[]);
    final items = list
        .whereType<Map<String, dynamic>>()
        .map(UploadItem.fromMap)
        .toList(growable: false);
    final pagination = envelope.pagination;

    return UploadsPage(
      items: items,
      page: pagination?.currentPage ?? page,
      size: pagination?.pageSize ?? size,
      total: pagination?.totalItems ?? items.length,
      totalPages: pagination?.totalPages,
      hasNext: pagination?.hasNext ?? false,
      hasPrevious: pagination?.hasPrevious ?? false,
    );
  }

  Future<void> deleteUpload(String uploadId) async {
    await _api.delete(ApiConstants.upload(uploadId));
  }
}
