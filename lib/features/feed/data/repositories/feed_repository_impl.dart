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
}
