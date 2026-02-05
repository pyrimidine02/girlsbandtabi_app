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
  PostCommentsController(this._ref, this.postId)
    : super(const AsyncLoading());

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
  PostLikeController(this._ref, this.postId)
    : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final String postId;

  Future<void> load() async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      state = AsyncError(
        const AuthFailure('Project selection required', code: 'project_required'),
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

    final current = state.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final repository = await _ref.read(feedRepositoryProvider.future);

    final result = current?.isLiked == true
        ? await repository.unlikePost(
            projectCode: projectKey,
            postId: postId,
          )
        : await repository.likePost(
            projectCode: projectKey,
            postId: postId,
          );

    if (result is Success<PostLikeStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostLikeStatus>) {
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
    StateNotifierProvider.family<PostLikeController, AsyncValue<PostLikeStatus>, String>((
      ref,
      postId,
    ) {
      return PostLikeController(ref, postId);
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
