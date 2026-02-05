/// EN: Remote data source for feed (news & community posts).
/// KO: 피드(뉴스/커뮤니티) 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/news_dto.dart';
import '../dto/post_comment_dto.dart';
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

  /// EN: Fetch community posts by author.
  /// KO: 작성자별 커뮤니티 게시글을 조회합니다.
  Future<Result<List<PostSummaryDto>>> fetchPostsByAuthor({
    required String projectCode,
    required String userId,
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<PostSummaryDto>>(
      ApiEndpoints.postsByAuthor(projectCode, userId),
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

  /// EN: Create a community post.
  /// KO: 커뮤니티 게시글을 생성합니다.
  Future<Result<PostDetailDto>> createPost({
    required String projectCode,
    required PostCreateRequestDto request,
  }) {
    return _apiClient.post<PostDetailDto>(
      ApiEndpoints.posts(projectCode),
      data: request.toJson(),
      fromJson: (json) => PostDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Update a community post.
  /// KO: 커뮤니티 게시글을 수정합니다.
  Future<Result<PostDetailDto>> updatePost({
    required String projectCode,
    required String postId,
    required Map<String, dynamic> request,
  }) {
    return _apiClient.put<PostDetailDto>(
      ApiEndpoints.post(projectCode, postId),
      data: request,
      fromJson: (json) => PostDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Delete a community post.
  /// KO: 커뮤니티 게시글을 삭제합니다.
  Future<Result<void>> deletePost({
    required String projectCode,
    required String postId,
  }) {
    return _apiClient.delete<void>(
      ApiEndpoints.post(projectCode, postId),
      fromJson: (_) {},
    );
  }

  /// EN: Fetch comments for a post.
  /// KO: 게시글 댓글을 조회합니다.
  Future<Result<List<PostCommentDto>>> fetchPostComments({
    required String projectCode,
    required String postId,
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<PostCommentDto>>(
      ApiEndpoints.postComments(projectCode, postId),
      queryParameters: {
        'page': page,
        'size': size,
      },
      fromJson: (json) => _decodeList(json, PostCommentDto.fromJson),
    );
  }

  /// EN: Fetch comments by author.
  /// KO: 작성자별 댓글을 조회합니다.
  Future<Result<List<PostCommentDto>>> fetchCommentsByAuthor({
    required String projectCode,
    required String userId,
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<PostCommentDto>>(
      ApiEndpoints.commentsByAuthor(projectCode, userId),
      queryParameters: {
        'page': page,
        'size': size,
      },
      fromJson: (json) => _decodeList(json, PostCommentDto.fromJson),
    );
  }

  /// EN: Create a comment for a post.
  /// KO: 게시글 댓글을 생성합니다.
  Future<Result<PostCommentDto>> createPostComment({
    required String projectCode,
    required String postId,
    required PostCommentCreateRequestDto request,
  }) {
    return _apiClient.post<PostCommentDto>(
      ApiEndpoints.postComments(projectCode, postId),
      data: request.toJson(),
      fromJson: (json) => PostCommentDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Update a comment for a post.
  /// KO: 게시글 댓글을 수정합니다.
  Future<Result<PostCommentDto>> updatePostComment({
    required String projectCode,
    required String postId,
    required String commentId,
    required Map<String, dynamic> request,
  }) {
    return _apiClient.put<PostCommentDto>(
      ApiEndpoints.postComment(projectCode, postId, commentId),
      data: request,
      fromJson: (json) => PostCommentDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Delete a comment for a post.
  /// KO: 게시글 댓글을 삭제합니다.
  Future<Result<void>> deletePostComment({
    required String projectCode,
    required String postId,
    required String commentId,
  }) {
    return _apiClient.delete<void>(
      ApiEndpoints.postComment(projectCode, postId, commentId),
      fromJson: (_) {},
    );
  }

  /// EN: Fetch like status for a post.
  /// KO: 게시글 좋아요 상태를 조회합니다.
  Future<Result<PostLikeStatusDto>> fetchPostLikeStatus({
    required String projectCode,
    required String postId,
  }) {
    return _apiClient.get<PostLikeStatusDto>(
      ApiEndpoints.postLike(projectCode, postId),
      fromJson: (json) =>
          PostLikeStatusDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Like a post.
  /// KO: 게시글에 좋아요를 누릅니다.
  Future<Result<PostLikeStatusDto>> likePost({
    required String projectCode,
    required String postId,
  }) {
    return _apiClient.post<PostLikeStatusDto>(
      ApiEndpoints.postLike(projectCode, postId),
      fromJson: (json) =>
          PostLikeStatusDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Unlike a post.
  /// KO: 게시글 좋아요를 취소합니다.
  Future<Result<PostLikeStatusDto>> unlikePost({
    required String projectCode,
    required String postId,
  }) {
    return _apiClient.delete<PostLikeStatusDto>(
      ApiEndpoints.postLike(projectCode, postId),
      fromJson: (json) =>
          PostLikeStatusDto.fromJson(json as Map<String, dynamic>),
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
