/// EN: Feed repository implementation with caching.
/// KO: 캐시를 포함한 피드 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/feed_entities.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';
import '../dto/news_dto.dart';
import '../dto/post_comment_dto.dart';
import '../dto/post_dto.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({
    required FeedRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final FeedRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<List<NewsSummary>>> getNews({
    required String projectId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _newsListCacheKey(projectId, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<List<NewsSummaryDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 15),
        fetcher: () => _fetchNews(projectId, page, size),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(NewsSummaryDto.fromJson)
                .toList();
          }
          return <NewsSummaryDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => NewsSummary.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<NewsDetail>> getNewsDetail({
    required String projectId,
    required String newsId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _newsDetailCacheKey(projectId, newsId);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<NewsDetailDto>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 15),
        fetcher: () => _fetchNewsDetail(projectId, newsId),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => NewsDetailDto.fromJson(json),
      );

      return Result.success(NewsDetail.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<PostSummary>>> getPosts({
    required String projectCode,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _postListCacheKey(projectCode, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PostSummaryDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 3),
        fetcher: () => _fetchPosts(projectCode, page, size),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PostSummaryDto.fromJson)
                .toList();
          }
          return <PostSummaryDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PostSummary.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostDetail>> getPostDetail({
    required String projectCode,
    required String postId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _postDetailCacheKey(projectCode, postId);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<PostDetailDto>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 3),
        fetcher: () => _fetchPostDetail(projectCode, postId),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => PostDetailDto.fromJson(json),
      );

      return Result.success(PostDetail.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostDetail>> createPost({
    required String projectCode,
    required String title,
    required String content,
  }) async {
    try {
      final request = PostCreateRequestDto(title: title, content: content);
      final result = await _remoteDataSource.createPost(
        projectCode: projectCode,
        request: request,
      );

      if (result is Success<PostDetailDto>) {
        await _cacheManager.remove(_postListCacheKey(projectCode, 0, 20));
        return Result.success(PostDetail.fromDto(result.data));
      }
      if (result is Err<PostDetailDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown create post result',
          code: 'unknown_create_post',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostDetail>> updatePost({
    required String projectCode,
    required String postId,
    required String title,
    required String content,
  }) async {
    try {
      final result = await _remoteDataSource.updatePost(
        projectCode: projectCode,
        postId: postId,
        request: {'title': title, 'content': content},
      );

      if (result is Success<PostDetailDto>) {
        await _cacheManager.remove(_postDetailCacheKey(projectCode, postId));
        return Result.success(PostDetail.fromDto(result.data));
      }
      if (result is Err<PostDetailDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown update post result',
          code: 'unknown_update_post',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> deletePost({
    required String projectCode,
    required String postId,
  }) async {
    try {
      final result = await _remoteDataSource.deletePost(
        projectCode: projectCode,
        postId: postId,
      );

      if (result is Success<void>) {
        await _cacheManager.remove(_postDetailCacheKey(projectCode, postId));
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown delete post result',
          code: 'unknown_delete_post',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<PostComment>>> getPostComments({
    required String projectCode,
    required String postId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _postCommentsCacheKey(projectCode, postId, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PostCommentDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 2),
        fetcher: () => _fetchPostComments(projectCode, postId, page, size),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PostCommentDto.fromJson)
                .toList();
          }
          return <PostCommentDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PostComment.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostComment>> createPostComment({
    required String projectCode,
    required String postId,
    required String content,
  }) async {
    try {
      final request = PostCommentCreateRequestDto(content: content);
      final result = await _remoteDataSource.createPostComment(
        projectCode: projectCode,
        postId: postId,
        request: request,
      );

      if (result is Success<PostCommentDto>) {
        await _cacheManager.remove(
          _postCommentsCacheKey(projectCode, postId, 0, 20),
        );
        return Result.success(PostComment.fromDto(result.data));
      }
      if (result is Err<PostCommentDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown create post comment result',
          code: 'unknown_create_post_comment',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostComment>> updatePostComment({
    required String projectCode,
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      final result = await _remoteDataSource.updatePostComment(
        projectCode: projectCode,
        postId: postId,
        commentId: commentId,
        request: {'content': content},
      );

      if (result is Success<PostCommentDto>) {
        await _cacheManager.remove(
          _postCommentsCacheKey(projectCode, postId, 0, 20),
        );
        return Result.success(PostComment.fromDto(result.data));
      }
      if (result is Err<PostCommentDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown update post comment result',
          code: 'unknown_update_post_comment',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> deletePostComment({
    required String projectCode,
    required String postId,
    required String commentId,
  }) async {
    try {
      final result = await _remoteDataSource.deletePostComment(
        projectCode: projectCode,
        postId: postId,
        commentId: commentId,
      );

      if (result is Success<void>) {
        await _cacheManager.remove(
          _postCommentsCacheKey(projectCode, postId, 0, 20),
        );
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown delete post comment result',
          code: 'unknown_delete_post_comment',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<PostSummary>>> getPostsByAuthor({
    required String projectCode,
    required String userId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _postsByAuthorCacheKey(projectCode, userId, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PostSummaryDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 3),
        fetcher: () => _fetchPostsByAuthor(projectCode, userId, page, size),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PostSummaryDto.fromJson)
                .toList();
          }
          return <PostSummaryDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PostSummary.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<PostComment>>> getCommentsByAuthor({
    required String projectCode,
    required String userId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _commentsByAuthorCacheKey(projectCode, userId, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PostCommentDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 2),
        fetcher: () => _fetchCommentsByAuthor(projectCode, userId, page, size),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PostCommentDto.fromJson)
                .toList();
          }
          return <PostCommentDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PostComment.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostLikeStatus>> getPostLikeStatus({
    required String projectCode,
    required String postId,
  }) async {
    try {
      final result = await _remoteDataSource.fetchPostLikeStatus(
        projectCode: projectCode,
        postId: postId,
      );

      if (result is Success<PostLikeStatusDto>) {
        return Result.success(PostLikeStatus.fromDto(result.data));
      }
      if (result is Err<PostLikeStatusDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown post like status result',
          code: 'unknown_post_like_status',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostLikeStatus>> likePost({
    required String projectCode,
    required String postId,
  }) async {
    try {
      final result = await _remoteDataSource.likePost(
        projectCode: projectCode,
        postId: postId,
      );

      if (result is Success<PostLikeStatusDto>) {
        return Result.success(PostLikeStatus.fromDto(result.data));
      }
      if (result is Err<PostLikeStatusDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown like post result',
          code: 'unknown_like_post',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<PostLikeStatus>> unlikePost({
    required String projectCode,
    required String postId,
  }) async {
    try {
      final result = await _remoteDataSource.unlikePost(
        projectCode: projectCode,
        postId: postId,
      );

      if (result is Success<PostLikeStatusDto>) {
        return Result.success(PostLikeStatus.fromDto(result.data));
      }
      if (result is Err<PostLikeStatusDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown unlike post result',
          code: 'unknown_unlike_post',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<List<NewsSummaryDto>> _fetchNews(
    String projectId,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchNews(
      projectId: projectId,
      page: page,
      size: size,
    );

    if (result is Success<List<NewsSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<NewsSummaryDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown news list result',
      code: 'unknown_news_list',
    );
  }

  Future<NewsDetailDto> _fetchNewsDetail(
    String projectId,
    String newsId,
  ) async {
    final result = await _remoteDataSource.fetchNewsDetail(
      projectId: projectId,
      newsId: newsId,
    );

    if (result is Success<NewsDetailDto>) {
      return result.data;
    }
    if (result is Err<NewsDetailDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown news detail result',
      code: 'unknown_news_detail',
    );
  }

  Future<List<PostSummaryDto>> _fetchPosts(
    String projectCode,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchPosts(
      projectCode: projectCode,
      page: page,
      size: size,
    );

    if (result is Success<List<PostSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<PostSummaryDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown posts list result',
      code: 'unknown_posts_list',
    );
  }

  Future<List<PostSummaryDto>> _fetchPostsByAuthor(
    String projectCode,
    String userId,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchPostsByAuthor(
      projectCode: projectCode,
      userId: userId,
      page: page,
      size: size,
    );

    if (result is Success<List<PostSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<PostSummaryDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown posts by author result',
      code: 'unknown_posts_by_author',
    );
  }

  Future<PostDetailDto> _fetchPostDetail(
    String projectCode,
    String postId,
  ) async {
    final result = await _remoteDataSource.fetchPostDetail(
      projectCode: projectCode,
      postId: postId,
    );

    if (result is Success<PostDetailDto>) {
      return result.data;
    }
    if (result is Err<PostDetailDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown post detail result',
      code: 'unknown_post_detail',
    );
  }

  Future<List<PostCommentDto>> _fetchPostComments(
    String projectCode,
    String postId,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchPostComments(
      projectCode: projectCode,
      postId: postId,
      page: page,
      size: size,
    );

    if (result is Success<List<PostCommentDto>>) {
      return result.data;
    }
    if (result is Err<List<PostCommentDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown post comments result',
      code: 'unknown_post_comments',
    );
  }

  Future<List<PostCommentDto>> _fetchCommentsByAuthor(
    String projectCode,
    String userId,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchCommentsByAuthor(
      projectCode: projectCode,
      userId: userId,
      page: page,
      size: size,
    );

    if (result is Success<List<PostCommentDto>>) {
      return result.data;
    }
    if (result is Err<List<PostCommentDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown comments by author result',
      code: 'unknown_comments_by_author',
    );
  }

  String _newsListCacheKey(String projectId, int page, int size) {
    return 'news_list:$projectId:p$page:s$size';
  }

  String _newsDetailCacheKey(String projectId, String newsId) {
    return 'news_detail:$projectId:$newsId';
  }

  String _postListCacheKey(String projectCode, int page, int size) {
    return 'post_list:$projectCode:p$page:s$size';
  }

  String _postDetailCacheKey(String projectCode, String postId) {
    return 'post_detail:$projectCode:$postId';
  }

  String _postCommentsCacheKey(
    String projectCode,
    String postId,
    int page,
    int size,
  ) {
    return 'post_comments:$projectCode:$postId:p$page:s$size';
  }

  String _postsByAuthorCacheKey(
    String projectCode,
    String userId,
    int page,
    int size,
  ) {
    return 'post_list:$projectCode:author:$userId:p$page:s$size';
  }

  String _commentsByAuthorCacheKey(
    String projectCode,
    String userId,
    int page,
    int size,
  ) {
    return 'post_comments:$projectCode:author:$userId:p$page:s$size';
  }
}
