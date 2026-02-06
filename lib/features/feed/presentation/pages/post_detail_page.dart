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
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Post detail page widget.
/// KO: 게시글 상세 페이지 위젯.
enum _PostAction { edit, delete }
enum _CommentAction { edit, delete }
enum _PostOtherAction { report, blockToggle }
enum _CommentOtherAction { report }

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailControllerProvider(widget.postId));
    final commentsState = ref.watch(
      postCommentsControllerProvider(widget.postId),
    );
    final likeState = ref.watch(postLikeControllerProvider(widget.postId));
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profileState = ref.watch(userProfileControllerProvider);
    final currentUserId = profileState.maybeWhen(
      data: (profile) => profile?.id,
      orElse: () => null,
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
                  onSelected: (action) =>
                      _handlePostAction(context, action, currentPost),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _PostAction.edit,
                      child: Text('수정'),
                    ),
                    PopupMenuItem(
                      value: _PostAction.delete,
                      child: Text('삭제'),
                    ),
                  ],
                ),
              ]
            : [
                PopupMenuButton<_PostOtherAction>(
                  onSelected: (action) =>
                      _handlePostOtherAction(context, action, currentPost),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _PostOtherAction.report,
                      child: Text('신고'),
                    ),
                    PopupMenuItem(
                      value: _PostOtherAction.blockToggle,
                      child: Text(blockLabel),
                    ),
                  ],
                ),
              ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: actions,
      ),
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
          currentUserId: currentUserId,
          isAuthenticated: isAuthenticated,
          isSubmitting: _isSubmitting,
          commentController: _commentController,
          onToggleLike: () async {
            final result = await ref
                .read(postLikeControllerProvider(post.id).notifier)
                .toggleLike();
            if (result is Err<PostLikeStatus> && context.mounted) {
              _showSnackBar(context, '좋아요를 반영하지 못했어요');
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
          ),
          onReportComment: (comment) => _showReportFlow(
            context,
            CommunityReportTargetType.comment,
            comment.id,
          ),
          onTapAuthor: (authorId) => context.goToUserProfile(authorId),
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
      await _showEditPostSheet(context, post);
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
      await _showReportFlow(
        context,
        CommunityReportTargetType.post,
        post.id,
      );
      return;
    }
    if (action == _PostOtherAction.blockToggle) {
      await _toggleBlockUser(context, post.authorId);
    }
  }

  Future<void> _showEditPostSheet(
    BuildContext context,
    PostDetail post,
  ) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로젝트를 먼저 선택해주세요')),
      );
      return;
    }
    final payload = await showModalBottomSheet<_PostEditPayload>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _PostEditSheet(post: post),
    );
    if (payload == null) return;

    final repository = await ref.read(feedRepositoryProvider.future);
    final result = await repository.updatePost(
      projectCode: projectCode,
      postId: post.id,
      title: payload.title,
      content: payload.content,
    );

    if (!context.mounted) return;
    if (result is Success<PostDetail>) {
      await ref
          .read(postDetailControllerProvider(post.id).notifier)
          .load(forceRefresh: true);
      await ref.read(postListControllerProvider.notifier).load(
            forceRefresh: true,
          );
      if (context.mounted) {
        _showSnackBar(context, '게시글을 수정했어요');
      }
    } else if (result is Err<PostDetail> && context.mounted) {
      _showSnackBar(context, '게시글을 수정하지 못했어요');
    }
  }

  Future<void> _confirmDeletePost(
    BuildContext context,
    PostDetail post,
  ) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로젝트를 먼저 선택해주세요')),
      );
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
      await ref.read(postListControllerProvider.notifier).load(
            forceRefresh: true,
          );
      if (context.mounted) {
        _showSnackBar(context, '게시글을 삭제했어요');
        context.goNamed(AppRoutes.feed);
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
          decoration: const InputDecoration(
            hintText: '댓글 내용을 입력하세요',
          ),
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

    final result = await ref
        .read(postCommentsControllerProvider(postId).notifier)
        .deleteComment(comment.id);
    if (result is Err<void> && context.mounted) {
      _showSnackBar(context, '댓글을 삭제하지 못했어요');
      return;
    }
    if (result is Success<void> && context.mounted) {
      _showSnackBar(context, '댓글을 삭제했어요');
    }
  }

  Future<void> _showReportFlow(
    BuildContext context,
    CommunityReportTargetType targetType,
    String targetId,
  ) async {
    final payload = await showModalBottomSheet<_ReportPayload>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ReportSheet(),
    );
    if (payload == null) return;

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
    if (context.mounted) {
      _showSnackBar(context, '신고가 접수되었어요');
    }
  }

  Future<void> _toggleBlockUser(
    BuildContext context,
    String userId,
  ) async {
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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}

class _PostDetailContent extends StatelessWidget {
  const _PostDetailContent({
    required this.post,
    required this.commentsState,
    required this.likeState,
    required this.currentUserId,
    required this.isAuthenticated,
    required this.isSubmitting,
    required this.commentController,
    required this.onToggleLike,
    required this.onSubmitComment,
    required this.onEditComment,
    required this.onDeleteComment,
    required this.onReportComment,
    required this.onTapAuthor,
  });

  final PostDetail post;
  final AsyncValue<List<PostComment>> commentsState;
  final AsyncValue<PostLikeStatus> likeState;
  final String? currentUserId;
  final bool isAuthenticated;
  final bool isSubmitting;
  final TextEditingController commentController;
  final VoidCallback onToggleLike;
  final VoidCallback onSubmitComment;
  final ValueChanged<PostComment> onEditComment;
  final ValueChanged<PostComment> onDeleteComment;
  final ValueChanged<PostComment> onReportComment;
  final ValueChanged<String> onTapAuthor;

  @override
  Widget build(BuildContext context) {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : post.authorId;
    final authorAvatarUrl =
        post.authorAvatarUrl?.isNotEmpty == true ? post.authorAvatarUrl : null;
    final likeStatus = likeState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final likeCount = likeStatus?.likeCount ?? post.likeCount ?? 0;
    final isLiked = likeStatus?.isLiked ?? false;
    final commentCountLabel = _commentCountLabel(
      commentsState,
      fallback: post.commentCount,
    );
    final contentText = _stripImageMarkdown(post.content ?? '');
    final embeddedImageUrls = _extractImageUrls(post.content);
    final mergedImageUrls = {
      ...post.imageUrls.map(resolveMediaUrl),
      ...embeddedImageUrls.map(resolveMediaUrl),
    }.where((url) => url.isNotEmpty).toList();
    final isOwnPost =
        currentUserId != null && currentUserId == post.authorId;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: GBTSpacing.paddingPage,
            children: [
              Row(
                children: [
                  _Avatar(
                    url: authorAvatarUrl,
                    radius: 20,
                    onTap: () => onTapAuthor(post.authorId),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.title, style: GBTTypography.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          '작성자: $authorLabel',
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textTertiary,
                          ),
                        ),
                        Text(
                          post.timeAgoLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textTertiary,
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
              Text(
                post.title,
                style: GBTTypography.bodyMedium.copyWith(height: 1.6),
              ),
              if (contentText.isNotEmpty) ...[
                const SizedBox(height: GBTSpacing.md),
                Text(
                  contentText,
                  style: GBTTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: GBTColors.textSecondary,
                  ),
                ),
              ],
              if (mergedImageUrls.isNotEmpty) ...[
                const SizedBox(height: GBTSpacing.md),
                Wrap(
                  spacing: GBTSpacing.sm,
                  runSpacing: GBTSpacing.sm,
                  children: mergedImageUrls
                      .map(
                        (url) => ClipRRect(
                          borderRadius:
                              BorderRadius.circular(GBTSpacing.radiusMd),
                          child: GBTImage(
                            imageUrl: url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            semanticLabel: '첨부 이미지',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: GBTSpacing.md),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? GBTColors.primary : null,
                    ),
                    onPressed: onToggleLike,
                  ),
                  Text(
                    likeCount.toString(),
                    style: GBTTypography.labelMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {},
                  ),
                  Text(
                    commentCountLabel,
                    style: GBTTypography.labelMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                ],
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
                isAuthenticated: isAuthenticated,
                onEditComment: onEditComment,
                onDeleteComment: onDeleteComment,
                onReportComment: onReportComment,
              ),
            ],
          ),
        ),
        if (isAuthenticated)
          Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: GBTColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요...',
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
                  IconButton(
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: isSubmitting ? null : onSubmitComment,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: GBTColors.border)),
            ),
            child: SafeArea(
              child: Text(
                '댓글을 작성하려면 로그인하세요.',
                style: GBTTypography.bodySmall.copyWith(
                  color: GBTColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PostEditPayload {
  const _PostEditPayload({required this.title, required this.content});

  final String title;
  final String content;
}

class _PostEditSheet extends StatefulWidget {
  const _PostEditSheet({required this.post});

  final PostDetail post;

  @override
  State<_PostEditSheet> createState() => _PostEditSheetState();
}

class _PostEditSheetState extends State<_PostEditSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(
      text: widget.post.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
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
            Text('게시글 수정', style: GBTTypography.titleSmall),
            const SizedBox(height: GBTSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
              maxLines: 1,
            ),
            const SizedBox(height: GBTSpacing.md),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 6,
            ),
            const SizedBox(height: GBTSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  final content = _contentController.text.trim();
                  if (title.isEmpty || content.isEmpty) return;
                  Navigator.of(context).pop(
                    _PostEditPayload(title: title, content: content),
                  );
                },
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportPayload {
  const _ReportPayload({
    required this.reason,
    this.description,
  });

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
    return SafeArea(
      child: SingleChildScrollView(
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
    );
  }
}

class _PostCommentsSection extends StatelessWidget {
  const _PostCommentsSection({
    required this.state,
    required this.onTapAuthor,
    required this.currentUserId,
    required this.isAuthenticated,
    required this.onEditComment,
    required this.onDeleteComment,
    required this.onReportComment,
  });

  final AsyncValue<List<PostComment>> state;
  final ValueChanged<String> onTapAuthor;
  final String? currentUserId;
  final bool isAuthenticated;
  final ValueChanged<PostComment> onEditComment;
  final ValueChanged<PostComment> onDeleteComment;
  final ValueChanged<PostComment> onReportComment;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const GBTLoading(message: '댓글을 불러오는 중...'),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '댓글을 불러오지 못했어요';
        return GBTErrorState(message: message);
      },
      data: (comments) {
        if (comments.isEmpty) {
          return const GBTEmptyState(message: '댓글이 아직 없습니다');
        }
        return Column(
          children: comments
              .map(
                (comment) => Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                  child: _CommentItem(
                    comment: comment,
                    onTapAuthor: onTapAuthor,
                    canManage: currentUserId == comment.authorId,
                    canReport: isAuthenticated,
                    onEdit: onEditComment,
                    onDelete: onDeleteComment,
                    onReport: onReportComment,
                  ),
                ),
              )
              .toList(),
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
    required this.canManage,
    required this.canReport,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  final PostComment comment;
  final ValueChanged<String> onTapAuthor;
  final bool canManage;
  final bool canReport;
  final ValueChanged<PostComment> onEdit;
  final ValueChanged<PostComment> onDelete;
  final ValueChanged<PostComment> onReport;

  @override
  Widget build(BuildContext context) {
    final authorLabel = comment.authorName?.isNotEmpty == true
        ? comment.authorName!
        : comment.authorId;
    final avatarUrl = comment.authorAvatarUrl?.isNotEmpty == true
        ? comment.authorAvatarUrl
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          url: avatarUrl,
          radius: 16,
          onTap: () => onTapAuthor(comment.authorId),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(authorLabel, style: GBTTypography.labelMedium),
                  const SizedBox(width: GBTSpacing.xs),
                  Text(
                    comment.timeAgoLabel,
                    style: GBTTypography.labelSmall.copyWith(
                      color: GBTColors.textTertiary,
                    ),
                  ),
                  if (canManage || canReport) const Spacer(),
                  if (canManage)
                    PopupMenuButton<_CommentAction>(
                      onSelected: (action) {
                        if (action == _CommentAction.edit) {
                          onEdit(comment);
                        } else {
                          onDelete(comment);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _CommentAction.edit,
                          child: Text('수정'),
                        ),
                        PopupMenuItem(
                          value: _CommentAction.delete,
                          child: Text('삭제'),
                        ),
                      ],
                    )
                  else if (canReport)
                    PopupMenuButton<_CommentOtherAction>(
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
              const SizedBox(height: 4),
              Text(comment.content, style: GBTTypography.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
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

List<String> _extractImageUrls(String? content) {
  if (content == null || content.isEmpty) return const [];
  final urls = <String>{};
  urls.addAll(_extractMarkdownImageUrls(content));
  urls.addAll(_extractHtmlImageUrls(content));
  urls.addAll(_extractInlineImageUrls(content));
  return urls.toList();
}

String _stripImageMarkdown(String content) {
  if (content.isEmpty) return content;
  var sanitized = content
      .replaceAll(_markdownImagePattern, '')
      .replaceAll(_htmlImagePattern, '');
  sanitized = _stripInlineImageUrls(sanitized);
  sanitized = sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  sanitized = sanitized.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return sanitized.trim();
}

const _publicR2Host = 'r2.pyrimidines.org';
const _legacyR2Suffix = 'r2.cloudflarestorage.com';
const _imageExtensions = <String>{
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.bmp',
  '.heic',
  '.heif',
};

final _markdownImagePattern =
    RegExp(r'!\[[^\]]*\]\((https?://[^)\s]+)[^)]*\)');
final _htmlImagePattern = RegExp(
  r'''<img[^>]*src=["'](https?://[^"']+)["']''',
  caseSensitive: false,
);
final _urlPattern = RegExp(r'''(https?://[^\s)<>"']+)''');
final _bareR2Pattern = RegExp(
  r'''(r2\.pyrimidines\.org/[^\s)<>"']+)''',
  caseSensitive: false,
);

List<String> _extractMarkdownImageUrls(String content) {
  return _markdownImagePattern
      .allMatches(content)
      .map((match) => match.group(1) ?? '')
      .where((url) => url.isNotEmpty)
      .toList();
}

List<String> _extractHtmlImageUrls(String content) {
  return _htmlImagePattern
      .allMatches(content)
      .map((match) => match.group(1) ?? '')
      .where((url) => url.isNotEmpty)
      .toList();
}

List<String> _extractInlineImageUrls(String content) {
  final urls = <String>[];
  urls.addAll(
    _urlPattern
        .allMatches(content)
        .map((match) => match.group(1) ?? '')
        .where((url) => _isLikelyImageUrl(url)),
  );
  urls.addAll(
    _bareR2Pattern
        .allMatches(content)
        .map((match) => match.group(1) ?? '')
        .where((url) => _isLikelyImageUrl(_ensureScheme(url))),
  );
  return urls;
}

String _stripInlineImageUrls(String content) {
  var sanitized = content.replaceAllMapped(_urlPattern, (match) {
    final url = match.group(1) ?? '';
    return _isLikelyImageUrl(url) ? '' : url;
  });
  sanitized = sanitized.replaceAllMapped(_bareR2Pattern, (match) {
    final url = match.group(1) ?? '';
    return _isLikelyImageUrl(_ensureScheme(url)) ? '' : url;
  });
  return sanitized;
}

bool _isLikelyImageUrl(String value) {
  if (value.isEmpty) return false;
  final resolvedValue = _ensureScheme(value);
  final uri = Uri.tryParse(resolvedValue);
  if (uri == null || uri.host.isEmpty) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;

  final normalizedUri = Uri.tryParse(resolveMediaUrl(resolvedValue)) ?? uri;
  final host = normalizedUri.host.toLowerCase();
  if (host == _publicR2Host || host.endsWith(_legacyR2Suffix)) {
    return true;
  }

  final path = normalizedUri.path.toLowerCase();
  return _imageExtensions.any(path.endsWith);
}

String _ensureScheme(String value) {
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('r2.pyrimidines.org/')) {
    return 'https://$value';
  }
  return value;
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.radius,
    this.onTap,
  });

  final String? url;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: GBTColors.surfaceVariant,
      child: Icon(
        Icons.person,
        size: radius,
        color: GBTColors.textTertiary,
      ),
    );

    final content = (url == null || url!.isEmpty)
        ? fallback
        : ClipOval(
            child: GBTImage(
              imageUrl: url!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              semanticLabel: '프로필 사진',
            ),
          );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
