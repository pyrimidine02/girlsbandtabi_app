/// EN: Board page showing community posts.
/// KO: 커뮤니티 게시글을 표시하는 게시판 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/image_url_extractor.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Board page widget displaying community posts.
/// KO: 커뮤니티 게시글을 표시하는 게시판 페이지 위젯.
class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        actions: const [GBTProfileAction()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              0,
            ),
            child: const ProjectSelectorCompact(),
          ),
          Expanded(
            child: _CommunityList(
              state: postState,
              onRefresh: () => ref
                  .read(postListControllerProvider.notifier)
                  .load(forceRefresh: true),
              onRetry: () => ref
                  .read(postListControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goToPostCreate(),
        tooltip: '새 글 작성',
        child: const Icon(Icons.edit),
      ),
    );
  }
}

/// EN: Community list widget.
/// KO: 커뮤니티 리스트 위젯.
class _CommunityList extends StatelessWidget {
  const _CommunityList({
    required this.state,
    required this.onRefresh,
    required this.onRetry,
  });

  final AsyncValue<List<PostSummary>> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: const [
            SizedBox(height: GBTSpacing.lg),
            GBTLoading(message: '커뮤니티 글을 불러오는 중...'),
          ],
        ),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '커뮤니티 글을 불러오지 못했어요';
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: [
              const SizedBox(height: GBTSpacing.lg),
              GBTErrorState(message: message, onRetry: onRetry),
            ],
          );
        },
        data: (posts) {
          if (posts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: const [
                SizedBox(height: GBTSpacing.lg),
                GBTEmptyState(message: '아직 커뮤니티 글이 없습니다'),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                child: _CommunityPostCard(post: post),
              );
            },
          );
        },
      ),
    );
  }
}

/// EN: Possible actions for the post action sheet.
/// KO: 게시글 액션시트에서 선택 가능한 동작 열거형.
enum _PostCardAction { edit, delete, ban }

/// EN: Community post card widget with context-aware actions.
/// KO: 사용자 역할에 따른 액션을 제공하는 커뮤니티 게시글 카드 위젯.
class _CommunityPostCard extends ConsumerWidget {
  const _CommunityPostCard({required this.post});

  final PostSummary post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : '익명';
    final avatarUrl = post.authorAvatarUrl?.isNotEmpty == true
        ? post.authorAvatarUrl
        : null;
    final commentCount = post.commentCount ?? 0;
    final likeCount = post.likeCount ?? 0;
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    // EN: Resolve first image URL for thumbnail.
    // KO: 썸네일용 첫 번째 이미지 URL을 해석합니다.
    // EN: Priority: imageUrls → content extraction → thumbnailUrl.
    // KO: 우선순위: imageUrls → 콘텐츠 추출 → thumbnailUrl.
    final String? firstImageUrl;
    if (post.imageUrls.isNotEmpty) {
      firstImageUrl = resolveMediaUrl(post.imageUrls.first);
    } else {
      final contentImages = extractImageUrls(
        post.content,
      ).map(resolveMediaUrl).where((url) => url.isNotEmpty);
      if (contentImages.isNotEmpty) {
        firstImageUrl = contentImages.first;
      } else if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
        firstImageUrl = resolveMediaUrl(post.thumbnailUrl!);
      } else {
        firstImageUrl = null;
      }
    }

    // EN: Determine current user identity and admin status.
    // KO: 현재 사용자 ID와 관리자 여부를 확인합니다.
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
    final isAuthor =
        currentUserId != null && currentUserId == post.authorId;
    // EN: Show the more button only for the author or admin.
    // KO: 작성자 또는 관리자에게만 더보기 버튼을 표시합니다.
    final showMoreButton = isAuthenticated && (isAuthor || isAdmin);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.goToPostDetail(post.id),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Padding(
          padding: GBTSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(
                    url: avatarUrl,
                    radius: 16,
                    semanticLabel: '$authorLabel 프로필 사진',
                    onTap: () => context.goToUserProfile(post.authorId),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorLabel,
                          style: GBTTypography.labelMedium,
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
                  if (showMoreButton)
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                      tooltip: '더 보기',
                      onPressed: () => _showPostActions(
                        context,
                        ref,
                        isAuthor: isAuthor,
                        isAdmin: isAdmin,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: GBTSpacing.sm),
              // EN: Title row with optional thumbnail on the right.
              // KO: 오른쪽에 선택적 썸네일이 있는 제목 행.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: GBTTypography.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (firstImageUrl != null) ...[
                    const SizedBox(width: GBTSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                      child: GBTImage(
                        imageUrl: firstImageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        semanticLabel: '${post.title} 첨부 이미지',
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: GBTSpacing.sm),
              Semantics(
                label: '좋아요 $likeCount개, 댓글 $commentCount개',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: tertiaryColor),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      likeCount.toString(),
                      style: GBTTypography.labelSmall.copyWith(
                        color: tertiaryColor,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: tertiaryColor,
                    ),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      commentCount.toString(),
                      style: GBTTypography.labelSmall.copyWith(
                        color: tertiaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// EN: Show the context-aware action sheet for the post.
  /// KO: 게시글에 대한 역할별 액션시트를 표시합니다.
  void _showPostActions(
    BuildContext context,
    WidgetRef ref, {
    required bool isAuthor,
    required bool isAdmin,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<_PostCardAction>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EN: Drag handle indicator.
              // KO: 드래그 핸들 표시.
              Container(
                margin: const EdgeInsets.only(top: GBTSpacing.sm),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
                child: Text(
                  '게시글 관리',
                  style: GBTTypography.titleSmall,
                ),
              ),
              const SizedBox(height: GBTSpacing.xs),
              // EN: Edit option (author or admin).
              // KO: 수정 옵션 (작성자 또는 관리자).
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('수정'),
                onTap: () => Navigator.of(sheetContext).pop(_PostCardAction.edit),
              ),
              // EN: Delete option (author or admin).
              // KO: 삭제 옵션 (작성자 또는 관리자).
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text('삭제', style: TextStyle(color: colorScheme.error)),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PostCardAction.delete),
              ),
              // EN: Ban option (admin only, for non-author posts).
              // KO: 차단 옵션 (관리자 전용, 타인의 게시글만).
              if (isAdmin && !isAuthor)
                ListTile(
                  leading: Icon(Icons.block, color: colorScheme.error),
                  title: Text('차단', style: TextStyle(color: colorScheme.error)),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PostCardAction.ban),
                ),
              const SizedBox(height: GBTSpacing.sm),
            ],
          ),
        );
      },
    ).then((action) {
      if (action == null || !context.mounted) return;
      switch (action) {
        case _PostCardAction.edit:
          // EN: Navigate to post detail page for editing.
          // KO: 수정을 위해 게시글 상세 페이지로 이동합니다.
          context.goToPostDetail(post.id);
        case _PostCardAction.delete:
          _confirmDeletePost(context, ref);
        case _PostCardAction.ban:
          _confirmBanUser(context, ref);
      }
    });
  }

  /// EN: Show delete confirmation dialog and delete the post.
  /// KO: 삭제 확인 다이얼로그를 표시하고 게시글을 삭제합니다.
  Future<void> _confirmDeletePost(BuildContext context, WidgetRef ref) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      _showSnackBar(context, '프로젝트를 먼저 선택해주세요');
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

    if (confirm != true || !context.mounted) return;

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
      }
    } else if (result is Err<void>) {
      _showSnackBar(context, '게시글을 삭제하지 못했어요');
    }
  }

  /// EN: Show ban confirmation dialog and ban the post author.
  /// KO: 차단 확인 다이얼로그를 표시하고 게시글 작성자를 차단합니다.
  Future<void> _confirmBanUser(BuildContext context, WidgetRef ref) async {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : '익명';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사용자 차단'),
        content: Text('$authorLabel 사용자를 차단할까요?\n차단하면 해당 사용자의 글이 보이지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('차단'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final controller = ref.read(
      blockStatusControllerProvider(post.authorId).notifier,
    );
    final result = await controller.blockUser();

    if (!context.mounted) return;
    if (result is Success<void>) {
      await ref
          .read(postListControllerProvider.notifier)
          .load(forceRefresh: true);
      if (context.mounted) {
        _showSnackBar(context, '$authorLabel 사용자를 차단했어요');
      }
    } else if (result is Err<void>) {
      _showSnackBar(context, '차단에 실패했어요');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// EN: Returns true when a role has admin/moderator privileges.
/// KO: 관리자/모더레이터 권한이 있는 역할인지 반환합니다.
bool _isAdminRole(String? role) {
  if (role == null) return false;
  final normalized = role.toUpperCase();
  return normalized.contains('ADMIN') || normalized.contains('MODERATOR');
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

