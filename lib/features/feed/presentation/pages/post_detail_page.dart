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
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../application/report_rate_limiter.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';

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
        loading: () => const GBTLoading(message: '게시글을 불러오는 중...'),
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
              _showSnackBar(context, '좋아요를 반영하지 못했어요');
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
    final newContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: '댓글 내용을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(dialogContext).pop(trimmed);
            },
            child: const Text('저장'),
          ),
        ],
      ),
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

    final payload = await showModalBottomSheet<_ReportPayload>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ReportSheet(),
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

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: GBTSpacing.paddingPage,
            children: [
              Row(
                children: [
                  _Avatar(
                    url: authorAvatarUrl,
                    radius: 20,
                    semanticLabel: '$authorLabel 프로필 사진',
                    onTap: () => onTapAuthor(post.authorId),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: GBTTypography.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authorLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: tertiaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.timeAgoLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: tertiaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isOwnPost)
                    TextButton(
                      onPressed: () {
                        // EN: TODO: Follow user.
                        // KO: TODO: 사용자 팔로우.
                      },
                      child: const Text('팔로우'),
                    ),
                ],
              ),
              const SizedBox(height: GBTSpacing.md),
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
              Semantics(
                label:
                    '좋아요 $likeCount개, '
                    '${isLiked ? "좋아요 누른 상태" : "좋아요 안 누른 상태"}, '
                    '댓글 $commentCountLabel개',
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? GBTColors.favorite : null,
                      ),
                      tooltip: isLiked ? '좋아요 취소' : '좋아요',
                      onPressed: onToggleLike,
                    ),
                    Text(
                      likeCount.toString(),
                      style: GBTTypography.labelMedium.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      tooltip: '댓글',
                      onPressed: onFocusComment,
                    ),
                    Text(
                      commentCountLabel,
                      style: GBTTypography.labelMedium.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      tooltip: isBookmarked ? '북마크 해제' : '북마크',
                      onPressed: onToggleBookmark,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: '공유',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: GBTSpacing.md),
              Text(
                '댓글 $commentCountLabel개',
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _PostCommentsSection(
                state: commentsState,
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
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: commentController,
                builder: (context, value, _) {
                  final canSubmit =
                      value.text.trim().isNotEmpty && !isSubmitting;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          focusNode: commentFocusNode,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요...',
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusFull,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: GBTSpacing.md,
                              vertical: GBTSpacing.sm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.sm),
                      FilledButton(
                        onPressed: canSubmit ? onSubmitComment : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(56, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusFull,
                            ),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
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

class _ReportPayload {
  const _ReportPayload({required this.reason, this.description});

  final CommunityReportReason reason;
  final String? description;
}

class _ReportSheet extends StatefulWidget {
  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  late CommunityReportReason _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _selectedReason = CommunityReportReason.spam;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismissKeyboard,
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.md,
            bottomInset + GBTSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('신고하기', style: GBTTypography.titleSmall),
              const SizedBox(height: GBTSpacing.md),
              RadioGroup<CommunityReportReason>(
                groupValue: _selectedReason,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedReason = value);
                },
                child: Column(
                  children: CommunityReportReason.values
                      .map(
                        (reason) => RadioListTile<CommunityReportReason>(
                          value: reason,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(reason.label),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) => _dismissKeyboard(),
                onSubmitted: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: '추가 설명',
                  hintText: '필요한 설명을 남겨주세요 (선택)',
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final description = _descriptionController.text.trim();
                    Navigator.of(context).pop(
                      _ReportPayload(
                        reason: _selectedReason,
                        description: description.isEmpty ? null : description,
                      ),
                    );
                  },
                  child: const Text('신고 접수'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCommentsSection extends StatefulWidget {
  const _PostCommentsSection({
    required this.state,
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

    return widget.state.when(
      loading: () => const GBTLoading(message: '댓글을 불러오는 중...'),
      error: (error, _) {
        final message = error is Failure ? error.userMessage : '댓글을 불러오지 못했어요';
        return GBTErrorState(message: message);
      },
      data: (comments) {
        if (comments.isEmpty) {
          return const GBTEmptyState(message: '댓글이 아직 없습니다');
        }
        final sortedComments = _sortedComments(comments);

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GBTSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: GBTSpacing.xs,
                spacing: GBTSpacing.sm,
                children: [
                  Text(
                    '${comments.length}개 댓글',
                    style: GBTTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Wrap(
                    spacing: GBTSpacing.xs,
                    children: [
                      ChoiceChip(
                        label: const Text('최신순'),
                        selected: _sort == _CommentSort.latest,
                        onSelected: (_) =>
                            setState(() => _sort = _CommentSort.latest),
                      ),
                      ChoiceChip(
                        label: const Text('등록순'),
                        selected: _sort == _CommentSort.oldest,
                        onSelected: (_) =>
                            setState(() => _sort = _CommentSort.oldest),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            ...sortedComments.map(
              (comment) => Padding(
                padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                child: _CommentItem(
                  comment: comment,
                  onTapAuthor: widget.onTapAuthor,
                  canEdit: widget.currentUserId == comment.authorId,
                  canDelete:
                      widget.currentUserId == comment.authorId ||
                      (widget.isAdmin && widget.currentUserId != null),
                  canReport: widget.isAuthenticated,
                  onEdit: widget.onEditComment,
                  onDelete: widget.onDeleteComment,
                  onReport: widget.onReportComment,
                  onOpenThread: widget.onOpenCommentThread,
                ),
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
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? GBTColors.darkSurfaceVariant.withValues(alpha: 0.28)
        : GBTColors.surfaceVariant.withValues(alpha: 0.42);
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final isEdited =
        comment.updatedAt != null &&
        comment.updatedAt!.isAfter(comment.createdAt);
    final replyCount = comment.replyCount ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(
            url: avatarUrl,
            radius: 16,
            semanticLabel: '$authorLabel 프로필 사진',
            onTap: () => onTapAuthor(comment.authorId),
          ),
          const SizedBox(width: GBTSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        authorLabel,
                        style: GBTTypography.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      comment.timeAgoLabel,
                      style: GBTTypography.labelSmall.copyWith(
                        color: tertiaryColor,
                      ),
                    ),
                    if (isEdited) ...[
                      const SizedBox(width: GBTSpacing.xs),
                      Text(
                        '수정됨',
                        style: GBTTypography.labelSmall.copyWith(
                          color: tertiaryColor,
                        ),
                      ),
                    ],
                    if (canEdit || canDelete || canReport) const Spacer(),
                    if (canEdit || canDelete)
                      PopupMenuButton<_CommentAction>(
                        tooltip: '댓글 관리',
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
                const SizedBox(height: GBTSpacing.xs),
                Text(
                  comment.content,
                  style: GBTTypography.bodySmall.copyWith(
                    color: secondaryColor,
                    height: 1.45,
                  ),
                ),
                if (replyCount > 0) ...[
                  const SizedBox(height: GBTSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => onOpenThread(comment),
                      icon: const Icon(Icons.forum_outlined, size: 16),
                      label: Text('답글 $replyCount개 보기'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
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
          child: SizedBox(
            height: 260,
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
                      height: 260,
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
