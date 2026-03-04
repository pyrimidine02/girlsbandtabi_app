/// EN: Community post detail page with comments.
/// KO: 댓글을 포함한 커뮤니티 게시글 상세 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/image_url_extractor.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/common/gbt_action_icons.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../application/report_rate_limiter.dart';
import '../../application/user_follow_controller.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';
import '../widgets/community_report_sheet.dart';

/// EN: Post detail page widget.
/// KO: 게시글 상세 페이지 위젯.
enum _PostAction { edit, delete }

enum _CommentAction { edit, delete }

enum _PostOtherAction { report, blockToggle }

enum _CommentOtherAction { report }

enum _CommentSort { latest, oldest }

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _contentScrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  Future<void> _focusCommentComposer() async {
    if (_contentScrollController.hasClients) {
      await _contentScrollController.animateTo(
        _contentScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
    if (!mounted) {
      return;
    }
    _commentFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailControllerProvider(widget.postId));
    final commentsState = ref.watch(
      postCommentsControllerProvider(widget.postId),
    );
    final likeState = ref.watch(postLikeControllerProvider(widget.postId));
    final bookmarkState = ref.watch(
      postBookmarkControllerProvider(widget.postId),
    );
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profileState = ref.watch(userProfileControllerProvider);
    final currentUserId = profileState.maybeWhen(
      data: (profile) => profile?.id,
      orElse: () => null,
    );
    final isAdmin = profileState.maybeWhen(
      data: (profile) => _isAdminRole(profile?.role),
      orElse: () => false,
    );
    final currentPost = state.maybeWhen(
      data: (post) => post,
      orElse: () => null,
    );
    final canManagePost =
        currentPost != null && currentUserId == currentPost.authorId;
    final blockStatusState =
        !canManagePost && currentPost != null && isAuthenticated
        ? ref.watch(blockStatusControllerProvider(currentPost.authorId))
        : null;
    final blockStatus = blockStatusState?.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final authorFollowState =
        !canManagePost && currentPost != null && isAuthenticated
        ? ref.watch(userFollowControllerProvider(currentPost.authorId))
        : null;
    final blockLabel = blockStatus?.blockedByMe == true ? '차단 해제' : '차단';

    final actions = !isAuthenticated || currentPost == null
        ? null
        : canManagePost
        ? [
            PopupMenuButton<_PostAction>(
              tooltip: '게시글 관리',
              onSelected: (action) =>
                  _handlePostAction(context, action, currentPost),
              itemBuilder: (menuContext) {
                final cs = Theme.of(menuContext).colorScheme;
                return [
                  const PopupMenuItem(
                    value: _PostAction.edit,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: GBTSpacing.sm),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _PostAction.delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: cs.error),
                        SizedBox(width: GBTSpacing.sm),
                        Text('삭제', style: TextStyle(color: cs.error)),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ]
        : [
            PopupMenuButton<_PostOtherAction>(
              tooltip: '게시글 옵션',
              onSelected: (action) =>
                  _handlePostOtherAction(context, action, currentPost),
              itemBuilder: (menuContext) => [
                const PopupMenuItem(
                  value: _PostOtherAction.report,
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 18),
                      SizedBox(width: GBTSpacing.sm),
                      Text('신고'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _PostOtherAction.blockToggle,
                  child: Row(
                    children: [
                      Icon(Icons.person_off_outlined, size: 18),
                      SizedBox(width: GBTSpacing.sm),
                      Text(blockLabel),
                    ],
                  ),
                ),
              ],
            ),
          ];

    return Scaffold(
      appBar: AppBar(title: const Text('게시글'), actions: actions),
      body: state.when(
        loading: () => const _PostDetailSkeleton(),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '게시글을 불러오지 못했어요';
          return GBTErrorState(
            message: message,
            onRetry: () => ref
                .read(postDetailControllerProvider(widget.postId).notifier)
                .load(forceRefresh: true),
          );
        },
        data: (post) => _PostDetailContent(
          post: post,
          commentsState: commentsState,
          likeState: likeState,
          bookmarkState: bookmarkState,
          currentUserId: currentUserId,
          isAdmin: isAdmin,
          isAuthenticated: isAuthenticated,
          isSubmitting: _isSubmitting,
          scrollController: _contentScrollController,
          commentController: _commentController,
          commentFocusNode: _commentFocusNode,
          onToggleLike: () async {
            final result = await ref
                .read(postLikeControllerProvider(post.id).notifier)
                .toggleLike();
            if (result is Err<PostLikeStatus> && context.mounted) {
              _showSnackBar(context, '좋아요/좋아요 취소를 반영하지 못했어요');
            }
          },
          onToggleBookmark: () async {
            final result = await ref
                .read(postBookmarkControllerProvider(post.id).notifier)
                .toggleBookmark();
            if (result is Err<PostBookmarkStatus> && context.mounted) {
              _showSnackBar(context, '북마크를 반영하지 못했어요');
            }
          },
          onSubmitComment: () async {
            final content = _commentController.text.trim();
            if (content.isEmpty || _isSubmitting) return;
            setState(() => _isSubmitting = true);
            final result = await ref
                .read(postCommentsControllerProvider(post.id).notifier)
                .addComment(content);
            if (result is Err<PostComment> && context.mounted) {
              _showSnackBar(context, '댓글을 등록하지 못했어요');
            }
            if (result is Success<PostComment>) {
              _commentController.clear();
              if (context.mounted) {
                _showSnackBar(context, '댓글이 등록되었어요');
              }
            }
            if (mounted) {
              setState(() => _isSubmitting = false);
            }
          },
          onEditComment: (comment) => _showEditCommentDialog(
            context,
            postId: post.id,
            comment: comment,
          ),
          onDeleteComment: (comment) => _confirmDeleteComment(
            context,
            postId: post.id,
            comment: comment,
            useModeration:
                isAdmin &&
                currentUserId != null &&
                currentUserId != comment.authorId,
          ),
          onReportComment: (comment) => _showReportFlow(
            context,
            CommunityReportTargetType.comment,
            comment.id,
          ),
          onOpenCommentThread: (comment) =>
              _showCommentThread(context, postId: post.id, comment: comment),
          onAppealPost: () =>
              _showAppealFlow(context, CommunityReportTargetType.post, post.id),
          onTapAuthor: (authorId) => context.goToUserProfile(authorId),
          onFocusComment: _focusCommentComposer,
          authorBlockStatus: blockStatus,
          authorFollowState: authorFollowState,
          onToggleFollowAuthor:
              !isAuthenticated || currentPost == null || canManagePost
              ? null
              : () async {
                  final result = await ref
                      .read(
                        userFollowControllerProvider(
                          currentPost.authorId,
                        ).notifier,
                      )
                      .toggleFollow();
                  if (!context.mounted) {
                    return;
                  }
                  if (result is Success<bool>) {
                    _showSnackBar(
                      context,
                      result.data ? '작성자를 팔로우했어요' : '팔로우를 취소했어요',
                    );
                  } else {
                    _showSnackBar(context, '팔로우 상태를 변경하지 못했어요');
                  }
                },
        ),
      ),
    );
  }

  Future<void> _handlePostAction(
    BuildContext context,
    _PostAction action,
    PostDetail post,
  ) async {
    if (action == _PostAction.edit) {
      context.goToPostEdit(post);
      return;
    }
    if (action == _PostAction.delete) {
      await _confirmDeletePost(context, post);
    }
  }

  Future<void> _handlePostOtherAction(
    BuildContext context,
    _PostOtherAction action,
    PostDetail post,
  ) async {
    if (action == _PostOtherAction.report) {
      await _showReportFlow(context, CommunityReportTargetType.post, post.id);
      return;
    }
    if (action == _PostOtherAction.blockToggle) {
      await _toggleBlockUser(context, post.authorId);
    }
  }

  Future<void> _confirmDeletePost(BuildContext context, PostDetail post) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로젝트를 먼저 선택해주세요')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final repository = await ref.read(feedRepositoryProvider.future);
    final result = await repository.deletePost(
      projectCode: projectCode,
      postId: post.id,
    );

    if (!context.mounted) return;
    if (result is Success<void>) {
      await ref
          .read(postListControllerProvider.notifier)
          .load(forceRefresh: true);
      if (context.mounted) {
        _showSnackBar(context, '게시글을 삭제했어요');
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRoutes.board);
        }
      }
    } else if (result is Err<void> && context.mounted) {
      _showSnackBar(context, '게시글을 삭제하지 못했어요');
    }
  }

  Future<void> _showEditCommentDialog(
    BuildContext context, {
    required String postId,
    required PostComment comment,
  }) async {
    final controller = TextEditingController(text: comment.content);
    final newContent = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GBTSpacing.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.sm,
            GBTSpacing.md,
            bottomInset + GBTSpacing.md,
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final trimmed = value.text.trim();
              final canSave = trimmed.isNotEmpty && trimmed != comment.content;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '댓글 수정',
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  TextField(
                    controller: controller,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: '댓글 내용을 입력하세요',
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusMd,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(GBTSpacing.md),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: canSave
                              ? () => Navigator.of(sheetContext).pop(trimmed)
                              : null,
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    controller.dispose();

    if (newContent == null || newContent == comment.content) return;

    final result = await ref
        .read(postCommentsControllerProvider(postId).notifier)
        .updateComment(comment.id, newContent);
    if (result is Err<PostComment> && context.mounted) {
      _showSnackBar(context, '댓글을 수정하지 못했어요');
      return;
    }
    if (result is Success<PostComment> && context.mounted) {
      _showSnackBar(context, '댓글을 수정했어요');
    }
  }

  Future<void> _confirmDeleteComment(
    BuildContext context, {
    required String postId,
    required PostComment comment,
    required bool useModeration,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('댓글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final Result<void> result;
    if (useModeration) {
      final projectCode = ref.read(selectedProjectKeyProvider);
      if (projectCode == null || projectCode.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, '프로젝트를 먼저 선택해주세요');
        }
        return;
      }
      final repository = await ref.read(communityRepositoryProvider.future);
      result = await repository.moderateDeletePostComment(
        projectCode: projectCode,
        postId: postId,
        commentId: comment.id,
      );
      if (result is Success<void>) {
        await ref
            .read(postCommentsControllerProvider(postId).notifier)
            .load(forceRefresh: true);
      }
    } else {
      result = await ref
          .read(postCommentsControllerProvider(postId).notifier)
          .deleteComment(comment.id);
    }
    if (result is Err<void> && context.mounted) {
      _showSnackBar(context, '댓글을 삭제하지 못했어요');
      return;
    }
    if (result is Success<void> && context.mounted) {
      _showSnackBar(context, '댓글을 삭제했어요');
    }
  }

  Future<void> _showCommentThread(
    BuildContext context, {
    required String postId,
    required PostComment comment,
  }) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      if (context.mounted) {
        _showSnackBar(context, '프로젝트를 먼저 선택해주세요');
      }
      return;
    }

    final repository = await ref.read(feedRepositoryProvider.future);
    final result = await repository.getPostCommentThread(
      projectCode: projectCode,
      postId: postId,
      parentCommentId: comment.id,
      maxDepth: 3,
      size: 50,
    );

    if (!context.mounted) return;
    if (result is Err<List<CommentThreadNode>>) {
      _showSnackBar(context, '답글 스레드를 불러오지 못했어요');
      return;
    }

    final thread = result is Success<List<CommentThreadNode>>
        ? result.data
        : <CommentThreadNode>[];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(GBTSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('답글 스레드', style: GBTTypography.titleSmall),
                const SizedBox(height: GBTSpacing.sm),
                Expanded(
                  child: thread.isEmpty
                      ? const Center(child: Text('표시할 답글이 없습니다'))
                      : ListView(
                          children: thread
                              .map((node) => _CommentThreadNodeView(node: node))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReportFlow(
    BuildContext context,
    CommunityReportTargetType targetType,
    String targetId,
  ) async {
    // EN: Check cooldown before opening report flow.
    // KO: 신고 플로우 시작 전 쿨다운을 확인합니다.
    final rateLimiter = ref.read(reportRateLimiterProvider);
    if (!rateLimiter.canReport(targetId)) {
      final remaining = rateLimiter.remainingCooldown(targetId);
      final minutes = remaining.inMinutes + 1;
      if (!context.mounted) return;
      _showSnackBar(context, '$minutes분 후 다시 신고할 수 있어요');
      return;
    }

    final payload = await showModalBottomSheet<CommunityReportPayload>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const CommunityReportSheet(),
    );
    if (payload == null) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('신고 접수'),
        content: Text(
          '${targetType.label}을(를) "${payload.reason.label}" 사유로 신고합니다.\n'
          '접수하시겠어요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('신고 접수'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.createReport(
      targetType: targetType,
      targetId: targetId,
      reason: payload.reason,
      description: payload.description,
    );

    if (result is Err<void> && context.mounted) {
      _showSnackBar(context, '신고를 접수하지 못했어요');
      return;
    }
    if (result is Success<void>) {
      rateLimiter.recordReport(targetId);
      if (context.mounted) {
        _showSnackBar(context, '신고가 접수되었어요. 검토 후 조치할게요');
      }
    }
  }

  Future<void> _showAppealFlow(
    BuildContext context,
    CommunityReportTargetType targetType,
    String targetId,
  ) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('이의제기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이의제기 사유를 입력해주세요.'),
            const SizedBox(height: GBTSpacing.md),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(hintText: '사유를 입력하세요'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(dialogContext).pop(text);
            },
            child: const Text('제출'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reason == null || !context.mounted) return;

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.submitAppeal(
      targetType: targetType,
      targetId: targetId,
      reason: reason,
    );

    if (!context.mounted) return;
    if (result is Success<void>) {
      _showSnackBar(context, '이의제기가 접수되었어요');
      return;
    }
    if (result is Err<void>) {
      _showSnackBar(context, '이의제기 접수에 실패했어요');
    }
  }

  Future<void> _toggleBlockUser(BuildContext context, String userId) async {
    final controller = ref.read(blockStatusControllerProvider(userId).notifier);
    final result = await controller.toggleBlock();

    if (result is Err<void> && context.mounted) {
      _showSnackBar(context, '차단 상태를 변경하지 못했어요');
      return;
    }

    if (!context.mounted) return;
    final state = ref.read(blockStatusControllerProvider(userId));
    final blockedByMe = state.maybeWhen(
      data: (value) => value.blockedByMe,
      orElse: () => false,
    );
    _showSnackBar(context, blockedByMe ? '사용자를 차단했어요' : '차단을 해제했어요');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PostDetailContent extends StatelessWidget {
  const _PostDetailContent({
    required this.post,
    required this.commentsState,
    required this.likeState,
    required this.bookmarkState,
    required this.currentUserId,
    required this.isAdmin,
    required this.isAuthenticated,
    required this.isSubmitting,
    required this.scrollController,
    required this.commentController,
    required this.commentFocusNode,
    required this.onToggleLike,
    required this.onToggleBookmark,
    required this.onSubmitComment,
    required this.onEditComment,
    required this.onDeleteComment,
    required this.onReportComment,
    required this.onOpenCommentThread,
    required this.onAppealPost,
    required this.onTapAuthor,
    required this.onFocusComment,
    required this.authorBlockStatus,
    required this.authorFollowState,
    required this.onToggleFollowAuthor,
  });

  final PostDetail post;
  final AsyncValue<List<PostComment>> commentsState;
  final AsyncValue<PostLikeStatus> likeState;
  final AsyncValue<PostBookmarkStatus> bookmarkState;
  final String? currentUserId;
  final bool isAdmin;
  final bool isAuthenticated;
  final bool isSubmitting;
  final ScrollController scrollController;
  final TextEditingController commentController;
  final FocusNode commentFocusNode;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleBookmark;
  final VoidCallback onSubmitComment;
  final ValueChanged<PostComment> onEditComment;
  final ValueChanged<PostComment> onDeleteComment;
  final ValueChanged<PostComment> onReportComment;
  final ValueChanged<PostComment> onOpenCommentThread;
  final VoidCallback onAppealPost;
  final ValueChanged<String> onTapAuthor;
  final VoidCallback onFocusComment;
  final BlockStatus? authorBlockStatus;
  final AsyncValue<UserFollowStatus>? authorFollowState;
  final Future<void> Function()? onToggleFollowAuthor;

  @override
  Widget build(BuildContext context) {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : '익명';
    final authorAvatarUrl = post.authorAvatarUrl?.isNotEmpty == true
        ? post.authorAvatarUrl
        : null;
    final likeStatus = likeState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final likeCount = likeStatus?.likeCount ?? post.likeCount ?? 0;
    final isLiked = likeStatus?.isLiked ?? false;
    final bookmarkStatus = bookmarkState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final isBookmarked = bookmarkStatus?.isBookmarked ?? false;
    final commentCountLabel = _commentCountLabel(
      commentsState,
      fallback: post.commentCount,
    );
    final contentText = stripImageMarkdown(post.content ?? '');
    // EN: Use API imageUrls as primary source. Only fall back to embedded
    //     extraction when the API returns no images, to avoid duplicates.
    // KO: API imageUrls를 우선 사용. 중복 방지를 위해 API에 이미지가 없을 때만
    //     콘텐츠에서 추출합니다.
    // EN: Normalize and de-duplicate URLs to avoid showing the same image twice.
    // KO: 동일 이미지가 중복 표시되지 않도록 URL을 정규화하고 중복 제거합니다.
    final List<String> mergedImageUrls = post.imageUrls.isNotEmpty
        ? _normalizeImageUrls(post.imageUrls)
        : _normalizeImageUrls(extractImageUrls(post.content));
    final isOwnPost = currentUserId != null && currentUserId == post.authorId;
    final followStatus = authorFollowState?.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final isFollowLoading = authorFollowState?.isLoading ?? false;
    final isAuthorBlocked =
        authorBlockStatus?.blockedByMe == true ||
        authorBlockStatus?.blockedMe == true ||
        authorBlockStatus?.blockedByAdmin == true;

    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final commentActionColor = isDark
        ? GBTColors.darkPrimary
        : GBTColors.accentBlue;

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: GBTSpacing.paddingPage,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(
                    url: authorAvatarUrl,
                    radius: 22,
                    semanticLabel: '$authorLabel 프로필 사진',
                    onTap: () => onTapAuthor(post.authorId),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  authorLabel,
                                  style: GBTTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: GBTSpacing.xs),
                              Text(
                                '· ${post.timeAgoLabel}',
                                style: GBTTypography.labelSmall.copyWith(
                                  color: tertiaryColor,
                                ),
                              ),
                              if (post.updatedAt != null &&
                                  post.updatedAt!.isAfter(post.createdAt)) ...[
                                const SizedBox(width: GBTSpacing.xs),
                                Text(
                                  '수정됨',
                                  style: GBTTypography.labelSmall.copyWith(
                                    color: tertiaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (!isOwnPost && isAuthenticated)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: GBTSpacing.xs,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: FilledButton.tonal(
                                      onPressed:
                                          (isFollowLoading || isAuthorBlocked)
                                          ? null
                                          : onToggleFollowAuthor,
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: GBTSpacing.sm,
                                        ),
                                      ),
                                      child: Text(
                                        isAuthorBlocked
                                            ? '차단됨'
                                            : (followStatus?.following ?? false)
                                            ? '팔로우 취소'
                                            : '팔로우',
                                        style: GBTTypography.labelSmall,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: GBTSpacing.xs),
                                  TextButton(
                                    onPressed: () => onTapAuthor(post.authorId),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 30),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: GBTSpacing.xs,
                                      ),
                                    ),
                                    child: const Text('프로필 보기'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            post.title,
                            style: GBTTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.sm + 2),
              if (post.moderationStatus == ContentModerationStatus.quarantined)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(GBTSpacing.md),
                  decoration: BoxDecoration(
                    color: GBTColors.warningLight,
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: GBTColors.warningDark,
                        size: GBTSpacing.iconSm,
                      ),
                      const SizedBox(width: GBTSpacing.sm),
                      Expanded(
                        child: Text(
                          '이 콘텐츠는 현재 검토 중입니다.',
                          style: GBTTypography.bodySmall.copyWith(
                            color: GBTColors.warningDark,
                          ),
                        ),
                      ),
                      if (isOwnPost)
                        TextButton(
                          onPressed: onAppealPost,
                          child: const Text('이의제기'),
                        ),
                    ],
                  ),
                ),
              if (post.moderationStatus == ContentModerationStatus.quarantined)
                const SizedBox(height: GBTSpacing.md),
              if (contentText.isNotEmpty)
                SelectableText(
                  contentText,
                  style: GBTTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: secondaryColor,
                  ),
                ),
              if (mergedImageUrls.isNotEmpty) ...[
                const SizedBox(height: GBTSpacing.md),
                // EN: Horizontal swipeable image carousel (Twitter-style).
                // KO: 가로로 넘기는 이미지 캐러셀 (트위터 스타일).
                _ImageCarousel(
                  imageUrls: mergedImageUrls,
                  onTapImage: (index) =>
                      _showFullScreenImage(context, mergedImageUrls, index),
                ),
              ],
              const SizedBox(height: GBTSpacing.md),
              // EN: Stats bar — social proof context (like count) before actions
              // KO: 액션 버튼 전에 소셜 증거(좋아요 수)를 보여주는 통계 바
              if (likeCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 13,
                        color: GBTColors.favorite.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '좋아요 $likeCount명이 공감했어요',
                        style: GBTTypography.labelSmall.copyWith(
                          color: secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              // EN: Card-style action bar with vertical dividers between buttons
              // KO: 버튼 사이 세로 구분선이 있는 카드 스타일 액션 바
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? GBTColors.darkSurfaceVariant.withValues(alpha: 0.4)
                      : GBTColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
                child: Semantics(
                  label:
                      '좋아요 $likeCount개, '
                      '${isLiked ? "좋아요 누른 상태" : "좋아요 안 누른 상태"}, '
                      '댓글 $commentCountLabel개',
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimelineActionButton(
                          icon: GBTActionIcons.comment,
                          label: commentCountLabel,
                          color: commentActionColor,
                          onTap: onFocusComment,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: isDark ? GBTColors.darkBorder : GBTColors.border,
                      ),
                      Expanded(
                        child: _TimelineActionButton(
                          icon: isLiked
                              ? GBTActionIcons.likeActive
                              : GBTActionIcons.like,
                          label: _compactCountLabel(likeCount),
                          color: isLiked ? GBTColors.favorite : tertiaryColor,
                          onTap: onToggleLike,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: isDark ? GBTColors.darkBorder : GBTColors.border,
                      ),
                      Expanded(
                        child: _TimelineActionButton(
                          icon: isBookmarked
                              ? GBTActionIcons.bookmarkActive
                              : GBTActionIcons.bookmark,
                          label: '',
                          color: isBookmarked
                              ? (isDark
                                    ? GBTColors.darkPrimary
                                    : GBTColors.primary)
                              : tertiaryColor,
                          onTap: onToggleBookmark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              const Divider(),
              const SizedBox(height: GBTSpacing.md),
              // EN: Comment section header with icon for visual clarity.
              // KO: 시각적 명확성을 위한 아이콘이 있는 댓글 섹션 헤더.
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                  const SizedBox(width: GBTSpacing.xs),
                  Text(
                    '댓글 $commentCountLabel개',
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.md),
              _PostCommentsSection(
                state: commentsState,
                postAuthorId: post.authorId,
                onTapAuthor: onTapAuthor,
                currentUserId: currentUserId,
                isAdmin: isAdmin,
                isAuthenticated: isAuthenticated,
                onEditComment: onEditComment,
                onDeleteComment: onDeleteComment,
                onReportComment: onReportComment,
                onOpenCommentThread: onOpenCommentThread,
              ),
            ],
          ),
        ),
        if (isAuthenticated)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              minimum: const EdgeInsets.only(bottom: GBTSpacing.xs),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: commentController,
                builder: (context, value, _) {
                  final canSubmit =
                      value.text.trim().isNotEmpty && !isSubmitting;

                  return ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // EN: User avatar in composer for social context.
                        // KO: 소셜 맥락을 위한 입력창 내 사용자 아바타.
                        Padding(
                          padding: const EdgeInsets.only(left: GBTSpacing.sm),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: isDark
                                ? GBTColors.darkSurfaceVariant
                                : GBTColors.surfaceVariant,
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: isDark
                                  ? GBTColors.darkTextTertiary
                                  : GBTColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            focusNode: commentFocusNode,
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: '댓글 작성...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: GBTSpacing.md,
                                vertical: GBTSpacing.sm + 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          height: 52,
                          child: IconButton(
                            onPressed: canSubmit ? onSubmitComment : null,
                            padding: EdgeInsets.zero,
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, size: 20),
                            tooltip: '댓글 등록',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: secondaryColor),
                  const SizedBox(width: GBTSpacing.sm),
                  Text(
                    '댓글을 작성하려면 로그인하세요.',
                    style: GBTTypography.bodySmall.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PostCommentsSection extends StatefulWidget {
  const _PostCommentsSection({
    required this.state,
    required this.postAuthorId,
    required this.onTapAuthor,
    required this.currentUserId,
    required this.isAdmin,
    required this.isAuthenticated,
    required this.onEditComment,
    required this.onDeleteComment,
    required this.onReportComment,
    required this.onOpenCommentThread,
  });

  final AsyncValue<List<PostComment>> state;
  final String postAuthorId;
  final ValueChanged<String> onTapAuthor;
  final String? currentUserId;
  final bool isAdmin;
  final bool isAuthenticated;
  final ValueChanged<PostComment> onEditComment;
  final ValueChanged<PostComment> onDeleteComment;
  final ValueChanged<PostComment> onReportComment;
  final ValueChanged<PostComment> onOpenCommentThread;

  @override
  State<_PostCommentsSection> createState() => _PostCommentsSectionState();
}

class _PostCommentsSectionState extends State<_PostCommentsSection> {
  _CommentSort _sort = _CommentSort.latest;

  List<PostComment> _sortedComments(List<PostComment> comments) {
    final items = List<PostComment>.from(comments);
    items.sort((a, b) {
      if (_sort == _CommentSort.latest) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final selectedColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return widget.state.when(
      loading: () => const GBTLoading(message: '댓글을 불러오는 중...'),
      error: (error, _) {
        final message = error is Failure ? error.userMessage : '댓글을 불러오지 못했어요';
        return GBTErrorState(message: message);
      },
      data: (comments) {
        if (comments.isEmpty) {
          // EN: Motivational empty state CTA to encourage first comment.
          // KO: 첫 댓글을 유도하는 동기부여 빈 상태 CTA.
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: GBTSpacing.xl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? GBTColors.darkSurfaceVariant
                          : GBTColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 26,
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  Text(
                    '아직 댓글이 없어요',
                    style: GBTTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? GBTColors.darkTextPrimary
                          : GBTColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    '첫 번째로 생각을 남겨보세요!',
                    style: GBTTypography.bodySmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final sortedComments = _sortedComments(comments);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${comments.length}개 댓글',
                  style: GBTTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _CommentSortTextButton(
                  label: '최신순',
                  selected: _sort == _CommentSort.latest,
                  selectedColor: selectedColor,
                  textColor: tertiaryColor,
                  onTap: () => setState(() => _sort = _CommentSort.latest),
                ),
                const SizedBox(width: GBTSpacing.xs),
                _CommentSortTextButton(
                  label: '등록순',
                  selected: _sort == _CommentSort.oldest,
                  selectedColor: selectedColor,
                  textColor: tertiaryColor,
                  onTap: () => setState(() => _sort = _CommentSort.oldest),
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.sm),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < sortedComments.length; index++)
                    _CommentItem(
                      comment: sortedComments[index],
                      postAuthorId: widget.postAuthorId,
                      showDivider: index < sortedComments.length - 1,
                      onTapAuthor: widget.onTapAuthor,
                      canEdit:
                          widget.currentUserId ==
                          sortedComments[index].authorId,
                      canDelete:
                          widget.currentUserId ==
                              sortedComments[index].authorId ||
                          (widget.isAdmin && widget.currentUserId != null),
                      canReport: widget.isAuthenticated,
                      onEdit: widget.onEditComment,
                      onDelete: widget.onDeleteComment,
                      onReport: widget.onReportComment,
                      onOpenThread: widget.onOpenCommentThread,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// EN: Comment item widget.
/// KO: 댓글 아이템 위젯.
class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.postAuthorId,
    required this.showDivider,
    required this.onTapAuthor,
    required this.canEdit,
    required this.canDelete,
    required this.canReport,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
    required this.onOpenThread,
  });

  final PostComment comment;
  final String postAuthorId;
  final bool showDivider;
  final ValueChanged<String> onTapAuthor;
  final bool canEdit;
  final bool canDelete;
  final bool canReport;
  final ValueChanged<PostComment> onEdit;
  final ValueChanged<PostComment> onDelete;
  final ValueChanged<PostComment> onReport;
  final ValueChanged<PostComment> onOpenThread;

  @override
  Widget build(BuildContext context) {
    final authorLabel = comment.authorName?.isNotEmpty == true
        ? comment.authorName!
        : '익명';
    final avatarUrl = comment.authorAvatarUrl?.isNotEmpty == true
        ? comment.authorAvatarUrl
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final contentColor = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final nestedSurfaceColor = isDark
        ? GBTColors.darkSurfaceVariant.withValues(alpha: 0.18)
        : GBTColors.surfaceVariant.withValues(alpha: 0.48);
    final replyActionColor = isDark
        ? GBTColors.darkPrimary
        : GBTColors.accentBlue;
    final isEdited =
        comment.updatedAt != null &&
        comment.updatedAt!.isAfter(comment.createdAt);
    final replyCount = comment.replyCount ?? 0;
    final rawDepth = comment.depth ?? 0;
    final normalizedDepth = comment.parentCommentId == null
        ? 0
        : (rawDepth > 1 ? rawDepth - 1 : 1);
    final indent = normalizedDepth > 0
        ? (normalizedDepth * 10.0).clamp(10.0, 30.0)
        : 0.0;
    final isPostAuthor = comment.authorId == postAuthorId;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: indent),
      decoration: BoxDecoration(
        color: normalizedDepth > 0 ? nestedSurfaceColor : null,
        border: showDivider
            ? Border(bottom: BorderSide(color: borderColor))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.sm,
        GBTSpacing.sm,
        GBTSpacing.sm,
        GBTSpacing.sm2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (normalizedDepth > 0)
            Container(
              width: 2,
              height: 50,
              margin: const EdgeInsets.only(
                top: GBTSpacing.xxs,
                right: GBTSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
              ),
            ),
          _Avatar(
            url: avatarUrl,
            radius: 14,
            semanticLabel: '$authorLabel 프로필 사진',
            onTap: () => onTapAuthor(comment.authorId),
          ),
          const SizedBox(width: GBTSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (normalizedDepth > 0) ...[
                      Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        size: 14,
                        color: tertiaryColor,
                      ),
                      const SizedBox(width: GBTSpacing.xs),
                    ],
                    Flexible(
                      child: InkWell(
                        onTap: () => onTapAuthor(comment.authorId),
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusXs,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          child: Text(
                            authorLabel,
                            style: GBTTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: contentColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    if (isPostAuthor) ...[
                      const SizedBox(width: GBTSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          '글쓴이',
                          style: GBTTypography.labelSmall.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      comment.timeAgoLabel,
                      style: GBTTypography.labelSmall.copyWith(
                        color: tertiaryColor,
                      ),
                    ),
                    if (isEdited) ...[
                      const SizedBox(width: GBTSpacing.xs),
                      Text(
                        '수정',
                        style: GBTTypography.labelSmall.copyWith(
                          color: tertiaryColor,
                        ),
                      ),
                    ],
                    if (canEdit || canDelete)
                      PopupMenuButton<_CommentAction>(
                        tooltip: '댓글 관리',
                        icon: Icon(
                          Icons.more_horiz,
                          size: 18,
                          color: tertiaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onSelected: (action) {
                          if (action == _CommentAction.edit) {
                            onEdit(comment);
                          } else {
                            onDelete(comment);
                          }
                        },
                        itemBuilder: (context) => [
                          if (canEdit)
                            const PopupMenuItem(
                              value: _CommentAction.edit,
                              child: Text('수정'),
                            ),
                          if (canDelete)
                            PopupMenuItem(
                              value: _CommentAction.delete,
                              child: Text(canEdit ? '삭제' : '관리 삭제'),
                            ),
                        ],
                      )
                    else if (canReport)
                      PopupMenuButton<_CommentOtherAction>(
                        tooltip: '댓글 옵션',
                        icon: Icon(
                          Icons.more_horiz,
                          size: 18,
                          color: tertiaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onSelected: (_) => onReport(comment),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _CommentOtherAction.report,
                            child: Text('신고'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: GBTSpacing.xxs),
                Text(
                  comment.content,
                  style: GBTTypography.bodyMedium.copyWith(
                    color: contentColor,
                    fontWeight: FontWeight.w500,
                    height: 1.52,
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                Wrap(
                  spacing: GBTSpacing.sm,
                  runSpacing: GBTSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => onOpenThread(comment),
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 1,
                        ),
                        child: Text(
                          '답글',
                          style: GBTTypography.labelSmall.copyWith(
                            color: secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (replyCount > 0)
                      InkWell(
                        onTap: () => onOpenThread(comment),
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusXs,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          child: Text(
                            '답글 $replyCount개 보기',
                            style: GBTTypography.labelSmall.copyWith(
                              color: replyActionColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSortTextButton extends StatelessWidget {
  const _CommentSortTextButton({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : textColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.xs,
          vertical: GBTSpacing.xs,
        ),
        child: Text(
          label,
          style: GBTTypography.labelSmall.copyWith(
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TimelineActionButton extends StatelessWidget {
  const _TimelineActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 36),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _compactCountLabel(int count) {
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}천';
  return count.toString();
}

class _CommentThreadNodeView extends StatelessWidget {
  const _CommentThreadNodeView({required this.node, this.depth = 0});

  final CommentThreadNode node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final comment = node.comment;
    final author = comment.authorName?.isNotEmpty == true
        ? comment.authorName!
        : '익명';
    final leftPadding = (depth * GBTSpacing.lg).toDouble();

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: GBTSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$author · ${comment.timeAgoLabel}',
            style: GBTTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
            ),
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(comment.content, style: GBTTypography.bodySmall),
          if (node.replies.isNotEmpty) ...[
            const SizedBox(height: GBTSpacing.xs),
            ...node.replies.map(
              (reply) => _CommentThreadNodeView(node: reply, depth: depth + 1),
            ),
          ],
        ],
      ),
    );
  }
}

bool _isAdminRole(String? role) {
  if (role == null) return false;
  final normalized = role.toUpperCase();
  return normalized.contains('ADMIN') || normalized.contains('MODERATOR');
}

// ========================================
// EN: Post detail skeleton loading state
// KO: 게시글 상세 스켈레톤 로딩 상태
// ========================================

/// EN: Skeleton placeholder for post detail while data loads.
/// KO: 데이터 로딩 중 게시글 상세의 스켈레톤 플레이스홀더.
class _PostDetailSkeleton extends StatelessWidget {
  const _PostDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        // EN: Author row — avatar + name + timestamp
        // KO: 작성자 행 — 아바타 + 이름 + 타임스탬프
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GBTShimmerContainer(
              width: 44,
              height: 44,
              borderRadius: GBTSpacing.radiusFull,
            ),
            const SizedBox(width: GBTSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GBTShimmerContainer(width: 100, height: 13),
                const SizedBox(height: GBTSpacing.xs),
                GBTShimmerContainer(width: 200, height: 20),
              ],
            ),
          ],
        ),
        const SizedBox(height: GBTSpacing.md),
        // EN: Body text skeleton
        // KO: 본문 텍스트 스켈레톤
        GBTShimmerContainer(width: double.infinity, height: 15),
        const SizedBox(height: GBTSpacing.xs),
        GBTShimmerContainer(width: double.infinity, height: 15),
        const SizedBox(height: GBTSpacing.xs),
        GBTShimmerContainer(width: 260, height: 15),
        const SizedBox(height: GBTSpacing.xs),
        GBTShimmerContainer(width: double.infinity, height: 15),
        const SizedBox(height: GBTSpacing.xs),
        GBTShimmerContainer(width: 180, height: 15),
        const SizedBox(height: GBTSpacing.md),
        // EN: Image placeholder skeleton (16:9)
        // KO: 이미지 플레이스홀더 스켈레톤 (16:9)
        AspectRatio(
          aspectRatio: 16 / 9,
          child: GBTShimmerContainer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: GBTSpacing.radiusMd,
          ),
        ),
        const SizedBox(height: GBTSpacing.md),
        // EN: Action bar skeleton
        // KO: 액션 바 스켈레톤
        Row(
          children: [
            Expanded(child: GBTShimmerContainer(width: double.infinity, height: 36)),
            const SizedBox(width: GBTSpacing.sm),
            Expanded(child: GBTShimmerContainer(width: double.infinity, height: 36)),
            const SizedBox(width: GBTSpacing.sm),
            Expanded(child: GBTShimmerContainer(width: double.infinity, height: 36)),
          ],
        ),
      ],
    );
  }
}

/// EN: Twitter-style horizontal swipeable image carousel with dot indicator.
/// KO: 점 인디케이터가 있는 트위터 스타일 가로 스와이프 이미지 캐러셀.
class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.imageUrls, required this.onTapImage});

  final List<String> imageUrls;
  final ValueChanged<int> onTapImage;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Semantics(
                  label: '첨부 이미지 ${index + 1}/${widget.imageUrls.length}',
                  hint: '탭하면 확대합니다',
                  button: true,
                  child: GestureDetector(
                    onTap: () => widget.onTapImage(index),
                    child: GBTImage(
                      imageUrl: widget.imageUrls[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: '첨부 이미지 ${index + 1}',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (hasMultiple) ...[
          const SizedBox(height: GBTSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? (isDark ? GBTColors.darkPrimary : GBTColors.primary)
                      : (isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// EN: Opens a full-screen zoomable image viewer.
/// KO: 풀스크린 확대 가능한 이미지 뷰어를 엽니다.
void _showFullScreenImage(
  BuildContext context,
  List<String> imageUrls,
  int initialIndex,
) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: hasMultiple
            ? Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: '닫기',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: GBTImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.contain,
                  semanticLabel: '이미지 ${index + 1}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// EN: Normalize image URLs and remove duplicates while preserving order.
/// KO: 이미지 URL을 정규화하고 순서를 유지하며 중복을 제거합니다.
List<String> _normalizeImageUrls(Iterable<String> rawUrls) {
  final normalized = <String>[];
  final seen = <String>{};

  for (final rawUrl in rawUrls) {
    final url = resolveMediaUrl(rawUrl.trim());
    if (url.isEmpty) continue;
    if (seen.add(url)) {
      normalized.add(url);
    }
  }

  return normalized;
}

String _commentCountLabel(
  AsyncValue<List<PostComment>> state, {
  int? fallback,
}) {
  return state.maybeWhen(
    data: (comments) => comments.length.toString(),
    orElse: () => (fallback ?? 0).toString(),
  );
}

/// EN: Avatar widget with accessible touch targets.
/// KO: 접근 가능한 터치 타겟을 가진 아바타 위젯.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.radius,
    this.onTap,
    this.semanticLabel,
  });

  final String? url;
  final double radius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // EN: Use theme-aware placeholder colors.
    // KO: 테마 인식 플레이스홀더 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final iconColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(Icons.person, size: radius, color: iconColor),
    );

    final content = (url == null || url!.isEmpty)
        ? fallback
        : ClipOval(
            child: GBTImage(
              imageUrl: url!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              semanticLabel: semanticLabel ?? '프로필 사진',
            ),
          );

    if (onTap == null) return content;

    // EN: Ensure minimum 48x48 touch target for accessibility.
    // KO: 접근성을 위해 최소 48x48 터치 타겟을 보장합니다.
    return Semantics(
      button: true,
      label: semanticLabel ?? '프로필 보기',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: GBTSpacing.touchTarget,
            minHeight: GBTSpacing.touchTarget,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
