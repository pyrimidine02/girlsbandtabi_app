/// EN: Community board list controllers (latest/trending/following).
/// KO: 커뮤니티 게시판 목록 컨트롤러(최신/트렌딩/구독).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/feed_entities.dart';
import 'feed_repository_provider.dart';

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
