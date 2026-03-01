/// EN: Feed controllers for news and community posts.
/// KO: 뉴스 및 커뮤니티 게시글 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
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

enum CommunityFeedMode { latest, trending, following }

const Object _communityFeedNoChange = Object();

extension CommunityFeedModeX on CommunityFeedMode {
  String get label {
    switch (this) {
      case CommunityFeedMode.latest:
        return '최신';
      case CommunityFeedMode.trending:
        return '트렌딩';
      case CommunityFeedMode.following:
        return '구독 피드';
    }
  }
}

class CommunityFeedViewState {
  const CommunityFeedViewState({
    this.mode = CommunityFeedMode.latest,
    this.searchQuery = '',
    this.posts = const [],
    this.subscriptions = const [],
    this.isInitialLoading = true,
    this.isLoadingMore = false,
    this.isSubscriptionsLoading = true,
    this.hasMore = false,
    this.page = 0,
    this.nextCursor,
    this.failure,
  });

  final CommunityFeedMode mode;
  final String searchQuery;
  final List<PostSummary> posts;
  final List<ProjectSubscriptionSummary> subscriptions;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isSubscriptionsLoading;
  final bool hasMore;
  final int page;
  final String? nextCursor;
  final Failure? failure;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  CommunityFeedViewState copyWith({
    CommunityFeedMode? mode,
    String? searchQuery,
    List<PostSummary>? posts,
    List<ProjectSubscriptionSummary>? subscriptions,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isSubscriptionsLoading,
    bool? hasMore,
    int? page,
    Object? nextCursor = _communityFeedNoChange,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CommunityFeedViewState(
      mode: mode ?? this.mode,
      searchQuery: searchQuery ?? this.searchQuery,
      posts: posts ?? this.posts,
      subscriptions: subscriptions ?? this.subscriptions,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubscriptionsLoading:
          isSubscriptionsLoading ?? this.isSubscriptionsLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      nextCursor: identical(nextCursor, _communityFeedNoChange)
          ? this.nextCursor
          : nextCursor as String?,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class CommunityFeedController extends StateNotifier<CommunityFeedViewState> {
  CommunityFeedController(this._ref) : super(const CommunityFeedViewState()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      reload(forceRefresh: true);
      _loadSubscriptions(forceRefresh: true);
    });
  }

  final Ref _ref;
  static const int _pageSize = 20;

  Future<void> initialize() async {
    await _loadSubscriptions();
    await reload();
  }

  Future<void> setMode(CommunityFeedMode mode) async {
    if (mode == state.mode) return;
    state = state.copyWith(mode: mode, clearFailure: true);
    await reload(forceRefresh: true);
  }

  Future<void> applySearch(String query) async {
    final trimmed = query.trim();
    if (trimmed == state.searchQuery.trim()) return;
    state = state.copyWith(searchQuery: trimmed, clearFailure: true);
    await reload(forceRefresh: true);
  }

  Future<void> clearSearch() async {
    if (state.searchQuery.isEmpty) return;
    state = state.copyWith(searchQuery: '', clearFailure: true);
    await reload(forceRefresh: true);
  }

  Future<void> reload({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      state = state.copyWith(
        posts: const [],
        isInitialLoading: false,
        hasMore: false,
        nextCursor: null,
        page: 0,
        failure: const AuthFailure(
          'Project selection required',
          code: 'project_required',
        ),
      );
      return;
    }

    state = state.copyWith(
      isInitialLoading: true,
      isLoadingMore: false,
      posts: const [],
      hasMore: false,
      nextCursor: null,
      page: 0,
      clearFailure: true,
    );

    final repository = await _ref.read(feedRepositoryProvider.future);
    if (state.isSearching) {
      final result = await repository.searchPosts(
        projectCode: projectKey,
        query: state.searchQuery,
        page: 0,
        size: _pageSize,
      );
      _applyInitialListResult(result, hasMore: false, nextCursor: null);
      return;
    }

    switch (state.mode) {
      case CommunityFeedMode.latest:
        final result = await repository.getPostsByCursor(
          projectCode: projectKey,
          cursor: null,
          size: _pageSize,
        );
        if (result is Success<PostCursorPage>) {
          state = state.copyWith(
            posts: result.data.items,
            hasMore: result.data.hasNext,
            nextCursor: result.data.nextCursor ?? '',
            isInitialLoading: false,
            clearFailure: true,
          );
        } else if (result is Err<PostCursorPage>) {
          state = state.copyWith(
            posts: const [],
            hasMore: false,
            nextCursor: null,
            isInitialLoading: false,
            failure: result.failure,
          );
        }
      case CommunityFeedMode.trending:
        final result = await repository.getTrendingPosts(
          projectCode: projectKey,
          page: 0,
          size: _pageSize,
          forceRefresh: forceRefresh,
        );
        if (result is Success<List<PostSummary>>) {
          final items = result.data;
          state = state.copyWith(
            posts: items,
            page: 0,
            hasMore: items.length >= _pageSize,
            nextCursor: null,
            isInitialLoading: false,
            clearFailure: true,
          );
        } else if (result is Err<List<PostSummary>>) {
          state = state.copyWith(
            posts: const [],
            hasMore: false,
            page: 0,
            isInitialLoading: false,
            failure: result.failure,
          );
        }
      case CommunityFeedMode.following:
        final result = await repository.getCommunityFeedByCursor(
          cursor: null,
          size: _pageSize,
        );
        if (result is Success<PostCursorPage>) {
          state = state.copyWith(
            posts: result.data.items,
            hasMore: result.data.hasNext,
            nextCursor: result.data.nextCursor ?? '',
            isInitialLoading: false,
            clearFailure: true,
          );
        } else if (result is Err<PostCursorPage>) {
          state = state.copyWith(
            posts: const [],
            hasMore: false,
            nextCursor: null,
            isInitialLoading: false,
            failure: result.failure,
          );
        }
    }
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasMore) return;
    if (state.isSearching) return;

    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) return;

    state = state.copyWith(isLoadingMore: true, clearFailure: true);
    final repository = await _ref.read(feedRepositoryProvider.future);

    switch (state.mode) {
      case CommunityFeedMode.latest:
        final cursor = state.nextCursor;
        if (cursor == null || cursor.isEmpty) {
          state = state.copyWith(isLoadingMore: false, hasMore: false);
          return;
        }
        final result = await repository.getPostsByCursor(
          projectCode: projectKey,
          cursor: cursor,
          size: _pageSize,
        );
        _appendCursorResult(result);
      case CommunityFeedMode.trending:
        final nextPage = state.page + 1;
        final result = await repository.getTrendingPosts(
          projectCode: projectKey,
          page: nextPage,
          size: _pageSize,
        );
        if (result is Success<List<PostSummary>>) {
          final merged = [...state.posts, ...result.data];
          state = state.copyWith(
            posts: merged,
            page: nextPage,
            hasMore: result.data.length >= _pageSize,
            isLoadingMore: false,
            clearFailure: true,
          );
        } else if (result is Err<List<PostSummary>>) {
          state = state.copyWith(isLoadingMore: false, failure: result.failure);
        }
      case CommunityFeedMode.following:
        final cursor = state.nextCursor;
        if (cursor == null || cursor.isEmpty) {
          state = state.copyWith(isLoadingMore: false, hasMore: false);
          return;
        }
        final result = await repository.getCommunityFeedByCursor(
          cursor: cursor,
          size: _pageSize,
        );
        _appendCursorResult(result);
    }
  }

  Future<void> _loadSubscriptions({bool forceRefresh = false}) async {
    state = state.copyWith(isSubscriptionsLoading: true);
    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.getCommunitySubscriptions(
      page: 0,
      size: 30,
      forceRefresh: forceRefresh,
    );
    if (result is Success<List<ProjectSubscriptionSummary>>) {
      state = state.copyWith(
        subscriptions: result.data,
        isSubscriptionsLoading: false,
      );
    } else {
      state = state.copyWith(isSubscriptionsLoading: false);
    }
  }

  void _applyInitialListResult(
    Result<List<PostSummary>> result, {
    required bool hasMore,
    required String? nextCursor,
  }) {
    if (result is Success<List<PostSummary>>) {
      state = state.copyWith(
        posts: result.data,
        hasMore: hasMore,
        nextCursor: nextCursor,
        isInitialLoading: false,
        clearFailure: true,
      );
    } else if (result is Err<List<PostSummary>>) {
      state = state.copyWith(
        posts: const [],
        hasMore: false,
        nextCursor: null,
        isInitialLoading: false,
        failure: result.failure,
      );
    }
  }

  void _appendCursorResult(Result<PostCursorPage> result) {
    if (result is Success<PostCursorPage>) {
      final merged = [...state.posts, ...result.data.items];
      state = state.copyWith(
        posts: merged,
        hasMore: result.data.hasNext,
        nextCursor: result.data.nextCursor ?? '',
        isLoadingMore: false,
        clearFailure: true,
      );
    } else if (result is Err<PostCursorPage>) {
      state = state.copyWith(isLoadingMore: false, failure: result.failure);
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

class PostCommentsController
    extends StateNotifier<AsyncValue<List<PostComment>>> {
  PostCommentsController(this._ref, this.postId) : super(const AsyncLoading());

  final Ref _ref;
  final String postId;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.getPostComments(
      projectCode: projectKey,
      postId: postId,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<PostComment>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<PostComment>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<PostComment>> addComment(String content) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = AuthFailure(
        'Project selection required',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.createPostComment(
      projectCode: projectKey,
      postId: postId,
      content: content,
    );

    if (result is Success<PostComment>) {
      final current = state.maybeWhen(
        data: (items) => items,
        orElse: () => <PostComment>[],
      );
      state = AsyncData([result.data, ...current]);
    } else if (result is Err<PostComment>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
  }

  Future<Result<PostComment>> updateComment(
    String commentId,
    String content,
  ) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = AuthFailure(
        'Project selection required',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.updatePostComment(
      projectCode: projectKey,
      postId: postId,
      commentId: commentId,
      content: content,
    );

    if (result is Success<PostComment>) {
      final current = state.maybeWhen(
        data: (items) => items,
        orElse: () => <PostComment>[],
      );
      final updated = current
          .map((comment) => comment.id == commentId ? result.data : comment)
          .toList();
      state = AsyncData(updated);
    } else if (result is Err<PostComment>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
  }

  Future<Result<void>> deleteComment(String commentId) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = AuthFailure(
        'Project selection required',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.deletePostComment(
      projectCode: projectKey,
      postId: postId,
      commentId: commentId,
    );

    if (result is Success<void>) {
      final current = state.maybeWhen(
        data: (items) => items,
        orElse: () => <PostComment>[],
      );
      state = AsyncData(
        current.where((comment) => comment.id != commentId).toList(),
      );
    } else if (result is Err<void>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
  }
}

/// EN: Post like status controller provider.
/// KO: 게시글 좋아요 상태 컨트롤러 프로바이더.
class PostLikeController extends StateNotifier<AsyncValue<PostLikeStatus>> {
  PostLikeController(this._ref, this.postId) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final String postId;

  Future<void> load() async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      state = AsyncError(
        const AuthFailure(
          'Project selection required',
          code: 'project_required',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.getPostLikeStatus(
      projectCode: projectKey,
      postId: postId,
    );

    if (result is Success<PostLikeStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostLikeStatus>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<PostLikeStatus>> toggleLike() async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = AuthFailure(
        'Project selection required',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final current = state.maybeWhen(data: (value) => value, orElse: () => null);
    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = current?.isLiked == true
        ? await repository.unlikePost(projectCode: projectKey, postId: postId)
        : await repository.likePost(projectCode: projectKey, postId: postId);

    if (result is Success<PostLikeStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostLikeStatus>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
  }
}

/// EN: Post bookmark status controller provider.
/// KO: 게시글 북마크 상태 컨트롤러 프로바이더.
class PostBookmarkController
    extends StateNotifier<AsyncValue<PostBookmarkStatus>> {
  PostBookmarkController(this._ref, this.postId) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final String postId;

  Future<void> load() async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      state = AsyncError(
        const AuthFailure(
          'Project selection required',
          code: 'project_required',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(feedRepositoryProvider.future);
    final result = await repository.getPostBookmarkStatus(
      projectCode: projectKey,
      postId: postId,
    );

    if (result is Success<PostBookmarkStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostBookmarkStatus>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<PostBookmarkStatus>> toggleBookmark() async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      const failure = AuthFailure(
        'Project selection required',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final current = state.maybeWhen(data: (value) => value, orElse: () => null);
    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = current?.isBookmarked == true
        ? await repository.unbookmarkPost(
            projectCode: projectKey,
            postId: postId,
          )
        : await repository.bookmarkPost(
            projectCode: projectKey,
            postId: postId,
          );

    if (result is Success<PostBookmarkStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostBookmarkStatus>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
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

/// EN: Post like controller provider.
/// KO: 게시글 좋아요 컨트롤러 프로바이더.
final postLikeControllerProvider =
    StateNotifierProvider.family<
      PostLikeController,
      AsyncValue<PostLikeStatus>,
      String
    >((ref, postId) {
      return PostLikeController(ref, postId);
    });

/// EN: Post bookmark controller provider.
/// KO: 게시글 북마크 컨트롤러 프로바이더.
final postBookmarkControllerProvider =
    StateNotifierProvider.family<
      PostBookmarkController,
      AsyncValue<PostBookmarkStatus>,
      String
    >((ref, postId) {
      return PostBookmarkController(ref, postId);
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

/// EN: Community feed controller provider with mode/search/pagination state.
/// KO: 모드/검색/페이지네이션 상태를 관리하는 커뮤니티 피드 컨트롤러 프로바이더.
final communityFeedControllerProvider =
    StateNotifierProvider<CommunityFeedController, CommunityFeedViewState>((
      ref,
    ) {
      return CommunityFeedController(ref)..initialize();
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

/// EN: Post comments controller provider.
/// KO: 게시글 댓글 컨트롤러 프로바이더.
final postCommentsControllerProvider =
    StateNotifierProvider.family<
      PostCommentsController,
      AsyncValue<List<PostComment>>,
      String
    >((ref, postId) {
      return PostCommentsController(ref, postId)..load();
    });
