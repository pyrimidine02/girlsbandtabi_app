/// EN: Board page showing community posts.
/// KO: 커뮤니티 게시글을 표시하는 게시판 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/image_url_extractor.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
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
  const _CommunityList({required this.state, required this.onRetry});

  final AsyncValue<List<PostSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => ListView(
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
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(message: '아직 커뮤니티 글이 없습니다'),
            ],
          );
        }

        return ListView.builder(
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
    );
  }
}

/// EN: Community post card widget.
/// KO: 커뮤니티 게시글 카드 위젯.
class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post});

  final PostSummary post;

  @override
  Widget build(BuildContext context) {
    final authorLabel =
        post.authorName?.isNotEmpty == true ? post.authorName! : '익명';
    final avatarUrl = post.authorAvatarUrl?.isNotEmpty == true
        ? post.authorAvatarUrl
        : null;
    final commentCount = post.commentCount ?? 0;
    final likeCount = post.likeCount ?? 0;
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    // EN: Resolve first image URL for thumbnail (fallback: extract from content).
    // KO: 썸네일용 첫 번째 이미지 URL을 해석합니다 (폴백: 콘텐츠에서 추출).
    final String? firstImageUrl;
    if (post.imageUrls.isNotEmpty) {
      firstImageUrl = resolveMediaUrl(post.imageUrls.first);
    } else {
      final contentImages = extractImageUrls(post.content)
          .map(resolveMediaUrl)
          .where((url) => url.isNotEmpty);
      firstImageUrl = contentImages.isNotEmpty ? contentImages.first : null;
    }

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
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                    tooltip: '더 보기',
                    onPressed: () {},
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
    final bgColor =
        isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    final iconColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

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
