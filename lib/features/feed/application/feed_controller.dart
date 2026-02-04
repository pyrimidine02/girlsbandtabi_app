/// EN: Feed controllers for news and community posts.
/// KO: 뉴스 및 커뮤니티 게시글 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/feed_remote_data_source.dart';
import '../data/repositories/feed_repository_impl.dart';
import '../domain/entities/feed_entities.dart';
import '../domain/repositories/feed_repository.dart';

class NewsListController extends StateNotifier<AsyncValue<List<NewsSummary>>> {
  NewsListController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      load(forceRefresh: true);
    });
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = await repository.getNews(
      projectId: projectKey,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<NewsSummary>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<NewsSummary>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

}

class NewsDetailController extends StateNotifier<AsyncValue<NewsDetail>> {
  NewsDetailController(this._ref, this.newsId) : super(const AsyncLoading());

  final Ref _ref;
  final String newsId;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = await repository.getNewsDetail(
      projectId: projectKey,
      newsId: newsId,
      forceRefresh: forceRefresh,
    );

    if (result is Success<NewsDetail>) {
      state = AsyncData(result.data);
    } else if (result is Err<NewsDetail>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

}

class PostListController extends StateNotifier<AsyncValue<List<PostSummary>>> {
  PostListController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      load(forceRefresh: true);
    });
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = await repository.getPosts(
      projectCode: projectKey,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<PostSummary>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<PostSummary>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

}

class PostDetailController extends StateNotifier<AsyncValue<PostDetail>> {
  PostDetailController(this._ref, this.postId) : super(const AsyncLoading());

  final Ref _ref;
  final String postId;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = await repository.getPostDetail(
      projectCode: projectKey,
      postId: postId,
      forceRefresh: forceRefresh,
    );

    if (result is Success<PostDetail>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostDetail>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

}

/// EN: Feed repository provider.
/// KO: 피드 리포지토리 프로바이더.
final feedRepositoryProvider = FutureProvider<FeedRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return FeedRepositoryImpl(
    remoteDataSource: FeedRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: News list controller provider.
/// KO: 뉴스 리스트 컨트롤러 프로바이더.
final newsListControllerProvider =
    StateNotifierProvider<NewsListController, AsyncValue<List<NewsSummary>>>((
      ref,
    ) {
      return NewsListController(ref)..load();
    });

/// EN: News detail controller provider.
/// KO: 뉴스 상세 컨트롤러 프로바이더.
final newsDetailControllerProvider =
    StateNotifierProvider.family<
      NewsDetailController,
      AsyncValue<NewsDetail>,
      String
    >((ref, newsId) {
      return NewsDetailController(ref, newsId)..load();
    });

/// EN: Post list controller provider.
/// KO: 게시글 리스트 컨트롤러 프로바이더.
final postListControllerProvider =
    StateNotifierProvider<PostListController, AsyncValue<List<PostSummary>>>((
      ref,
    ) {
      return PostListController(ref)..load();
    });

/// EN: Post detail controller provider.
/// KO: 게시글 상세 컨트롤러 프로바이더.
final postDetailControllerProvider =
    StateNotifierProvider.family<
      PostDetailController,
      AsyncValue<PostDetail>,
      String
    >((ref, postId) {
      return PostDetailController(ref, postId)..load();
    });
