/// EN: Post detail and comment controllers.
/// KO: 게시글 상세 및 댓글 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/feed_entities.dart';
import 'feed_repository_provider.dart';

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

/// EN: Post detail controller provider.
/// KO: 게시글 상세 컨트롤러 프로바이더.
final postDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<PostDetailController, AsyncValue<PostDetail>, String>((
      ref,
      postId,
    ) {
      return PostDetailController(ref, postId)..load();
    });

/// EN: Post comments controller provider.
/// KO: 게시글 댓글 컨트롤러 프로바이더.
final postCommentsControllerProvider = StateNotifierProvider.autoDispose
    .family<PostCommentsController, AsyncValue<List<PostComment>>, String>((
      ref,
      postId,
    ) {
      return PostCommentsController(ref, postId)..load();
    });
