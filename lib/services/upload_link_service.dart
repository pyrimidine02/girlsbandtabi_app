import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class UploadLinkService {
  final _api = ApiClient.instance;

  Future<void> attachPlaceImage({
    required String projectId,
    required String placeId,
    required String uploadId,
    bool isPrimary = false,
  }) async {
    await _api.post(ApiConstants.placeImages(projectId, placeId), data: {
      'uploadId': uploadId,
      'isPrimary': isPrimary,
    });
  }

  Future<void> attachNewsImage({
    required String projectId,
    required String newsId,
    required String uploadId,
    bool isPrimary = false,
  }) async {
    await _api.post(ApiConstants.newsImages(projectId, newsId), data: {
      'uploadId': uploadId,
      if (isPrimary) 'isPrimary': true,
    });
  }

  Future<void> attachLiveBanner({
    required String projectId,
    required String liveEventId,
    required String uploadId,
  }) async {
    await _api.post(ApiConstants.liveEventBanner(projectId, liveEventId), data: {
      'uploadId': uploadId,
    });
  }

  Future<void> reorderPlaceImages({
    required String projectId,
    required String placeId,
    required List<String> order,
  }) async {
    await _api.post(ApiConstants.placeImagesReorder(projectId, placeId), data: {
      'order': order,
    });
  }

  Future<void> reorderNewsImages({
    required String projectId,
    required String newsId,
    required List<String> order,
  }) async {
    await _api.post(ApiConstants.newsImagesReorder(projectId, newsId), data: {
      'order': order,
    });
  }

  Future<void> setPrimaryPlaceImage({
    required String projectId,
    required String placeId,
    required String imageId,
  }) async {
    await _api.post(ApiConstants.placeImagePrimary(projectId, placeId, imageId));
  }

  Future<void> setPrimaryNewsImage({
    required String projectId,
    required String newsId,
    required String imageId,
  }) async {
    await _api.post(ApiConstants.newsImagePrimary(projectId, newsId, imageId));
  }

  Future<void> deletePlaceImage({
    required String projectId,
    required String placeId,
    required String imageId,
  }) async {
    await _api.delete(ApiConstants.placeImage(projectId, placeId, imageId));
  }

  Future<void> deleteNewsImage({
    required String projectId,
    required String newsId,
    required String imageId,
  }) async {
    await _api.delete(ApiConstants.newsImage(projectId, newsId, imageId));
  }

  Future<void> deleteLiveBanner({
    required String projectId,
    required String liveEventId,
  }) async {
    await _api.delete(ApiConstants.liveEventBanner(projectId, liveEventId));
  }
}
