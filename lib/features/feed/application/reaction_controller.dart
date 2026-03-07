/// EN: Post reaction controllers (like/bookmark).
/// KO: 게시글 반응 컨트롤러(좋아요/북마크).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../../projects/application/projects_controller.dart';
import '../domain/entities/feed_entities.dart';
import 'feed_repository_provider.dart';

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{12}$',
);

/// EN: Resolve feed reaction project reference(id/code) into project code.
/// KO: 피드 반응용 프로젝트 참조값(id/code)을 프로젝트 코드로 해석합니다.
String? _normalizeProjectCode(Ref ref, String? rawReference) {
  final reference = rawReference?.trim() ?? '';
  if (reference.isEmpty) {
    return null;
  }

  final projects = ref.read(projectsControllerProvider).valueOrNull;
  if (projects != null) {
    for (final project in projects) {
      if (project.code == reference || project.id == reference) {
        return project.code.isNotEmpty ? project.code : project.id;
      }
    }
  }

  final selectedProjectId = ref.read(selectedProjectIdProvider);
  final selectedProjectKey = ref.read(selectedProjectKeyProvider);
  if (selectedProjectId != null &&
      selectedProjectId == reference &&
      selectedProjectKey != null &&
      selectedProjectKey.isNotEmpty) {
    return selectedProjectKey;
  }

  if (_uuidPattern.hasMatch(reference)) {
    return null;
  }

  return reference;
}

String? _resolveReactionProjectCode(Ref ref, PostReactionTarget target) {
  final override = _normalizeProjectCode(ref, target.projectCodeOverride);
  if (override != null && override.isNotEmpty) {
    return override;
  }

  final selectedProjectKey = ref.read(selectedProjectKeyProvider);
  if (selectedProjectKey == null || selectedProjectKey.isEmpty) {
    return null;
  }
  return selectedProjectKey;
}

/// EN: Identifies a post reaction request context.
/// KO: 게시글 반응 요청 컨텍스트를 식별합니다.
class PostReactionTarget {
  const PostReactionTarget({required this.postId, this.projectCodeOverride});

  final String postId;
  final String? projectCodeOverride;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PostReactionTarget &&
            other.postId == postId &&
            other.projectCodeOverride == projectCodeOverride;
  }

  @override
  int get hashCode => Object.hash(postId, projectCodeOverride);
}

/// EN: Post like status controller provider.
/// KO: 게시글 좋아요 상태 컨트롤러 프로바이더.
class PostLikeController extends StateNotifier<AsyncValue<PostLikeStatus>> {
  PostLikeController(this._ref, this.target) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final PostReactionTarget target;

  Future<void> load() async {
    final projectCode = _resolveReactionProjectCode(_ref, target);
    if (projectCode == null || projectCode.isEmpty) {
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
      projectCode: projectCode,
      postId: target.postId,
    );

    if (result is Success<PostLikeStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostLikeStatus>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<PostLikeStatus>> toggleLike() async {
    final projectCode = _resolveReactionProjectCode(_ref, target);
    if (projectCode == null || projectCode.isEmpty) {
      const failure = AuthFailure(
        'Project selection required',
        code: 'project_required',
      );
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final current = state.maybeWhen(data: (value) => value, orElse: () => null);
    final repository = await _ref.read(feedRepositoryProvider.future);
    final isUnlikeFlow = current?.isLiked == true;
    Result<PostLikeStatus> result = isUnlikeFlow
        ? await repository.unlikePost(
            projectCode: projectCode,
            postId: target.postId,
          )
        : await repository.likePost(
            projectCode: projectCode,
            postId: target.postId,
          );

    if (isUnlikeFlow && result is Err<PostLikeStatus>) {
      final selectedProjectId = _ref.read(selectedProjectIdProvider);
      final shouldRetryWithProjectId =
          selectedProjectId != null &&
          selectedProjectId.isNotEmpty &&
          selectedProjectId != projectCode &&
          result.failure is ServerFailure &&
          result.failure.code == '500';

      // EN: Backend workaround — retry unlike once with UUID projectId when
      // slug-based unlike returns 500 but like endpoint works.
      // KO: 백엔드 우회 — slug 기반 unlike에서 500이 발생하면 UUID projectId로
      // 한 번 재시도합니다.
      if (shouldRetryWithProjectId) {
        result = await repository.unlikePost(
          projectCode: selectedProjectId,
          postId: target.postId,
        );
      }
    }

    if (result is Success<PostLikeStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostLikeStatus>) {
      // EN: Preserve current data on toggle failure to avoid breaking action UI.
      // KO: 토글 실패 시 액션 UI가 깨지지 않도록 현재 데이터를 유지합니다.
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(result.failure, StackTrace.current);
      }
    }

    return result;
  }
}

/// EN: Post bookmark status controller provider.
/// KO: 게시글 북마크 상태 컨트롤러 프로바이더.
class PostBookmarkController
    extends StateNotifier<AsyncValue<PostBookmarkStatus>> {
  PostBookmarkController(this._ref, this.target) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final PostReactionTarget target;

  Future<void> load() async {
    final projectCode = _resolveReactionProjectCode(_ref, target);
    if (projectCode == null || projectCode.isEmpty) {
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
      projectCode: projectCode,
      postId: target.postId,
    );

    if (result is Success<PostBookmarkStatus>) {
      state = AsyncData(result.data);
    } else if (result is Err<PostBookmarkStatus>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<PostBookmarkStatus>> toggleBookmark() async {
    final projectCode = _resolveReactionProjectCode(_ref, target);
    if (projectCode == null || projectCode.isEmpty) {
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
            projectCode: projectCode,
            postId: target.postId,
          )
        : await repository.bookmarkPost(
            projectCode: projectCode,
            postId: target.postId,
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
    .family<PostLikeController, AsyncValue<PostLikeStatus>, PostReactionTarget>(
      (ref, target) {
        return PostLikeController(ref, target);
      },
    );

/// EN: Post bookmark controller provider.
/// KO: 게시글 북마크 컨트롤러 프로바이더.
final postBookmarkControllerProvider = StateNotifierProvider.autoDispose
    .family<
      PostBookmarkController,
      AsyncValue<PostBookmarkStatus>,
      PostReactionTarget
    >((ref, target) {
      return PostBookmarkController(ref, target);
    });
