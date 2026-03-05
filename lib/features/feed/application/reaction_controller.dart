/// EN: Post reaction controllers (like/bookmark).
/// KO: 게시글 반응 컨트롤러(좋아요/북마크).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/feed_entities.dart';
import 'feed_repository_provider.dart';

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

/// EN: Post like controller provider.
/// KO: 게시글 좋아요 컨트롤러 프로바이더.
final postLikeControllerProvider = StateNotifierProvider.autoDispose
    .family<PostLikeController, AsyncValue<PostLikeStatus>, String>((
      ref,
      postId,
    ) {
      return PostLikeController(ref, postId);
    });

/// EN: Post bookmark controller provider.
/// KO: 게시글 북마크 컨트롤러 프로바이더.
final postBookmarkControllerProvider = StateNotifierProvider.autoDispose
    .family<PostBookmarkController, AsyncValue<PostBookmarkStatus>, String>((
      ref,
      postId,
    ) {
      return PostBookmarkController(ref, postId);
    });
