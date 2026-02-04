/// EN: Remote data source for feed (news & community posts).
/// KO: 피드(뉴스/커뮤니티) 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/news_dto.dart';
import '../dto/post_dto.dart';

class FeedRemoteDataSource {
  FeedRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Fetch paginated news for a project.
  /// KO: 프로젝트의 페이지네이션된 뉴스를 조회합니다.
  Future<Result<List<NewsSummaryDto>>> fetchNews({
    required String projectId,
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<NewsSummaryDto>>(
      ApiEndpoints.news(projectId),
      queryParameters: {
        'page': page,
        'size': size,
      },
      fromJson: (json) => _decodeList(json, NewsSummaryDto.fromJson),
    );
  }

  Future<Result<NewsDetailDto>> fetchNewsDetail({
    required String projectId,
    required String newsId,
  }) {
    return _apiClient.get<NewsDetailDto>(
      ApiEndpoints.newsDetail(projectId, newsId),
      fromJson: (json) => NewsDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Fetch paginated community posts for a project.
  /// KO: 프로젝트의 페이지네이션된 커뮤니티 게시글을 조회합니다.
  Future<Result<List<PostSummaryDto>>> fetchPosts({
    required String projectCode,
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<PostSummaryDto>>(
      ApiEndpoints.posts(projectCode),
      queryParameters: {
        'page': page,
        'size': size,
      },
      fromJson: (json) => _decodeList(json, PostSummaryDto.fromJson),
    );
  }

  Future<Result<PostDetailDto>> fetchPostDetail({
    required String projectCode,
    required String postId,
  }) {
    return _apiClient.get<PostDetailDto>(
      ApiEndpoints.post(projectCode, postId),
      fromJson: (json) => PostDetailDto.fromJson(json as Map<String, dynamic>),
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
