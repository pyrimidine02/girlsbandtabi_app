/// EN: Feed page with news and community tabs — unified SNS-style design.
/// KO: 뉴스 및 커뮤니티 탭을 포함한 피드 페이지 — 통일된 SNS 스타일 디자인.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_action_icons.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../application/report_rate_limiter.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';
import '../widgets/community_report_sheet.dart';

/// EN: Actions available on a community post card.
/// KO: 커뮤니티 게시글 카드에서 사용 가능한 액션.
enum _FeedPostCardAction { report }

/// EN: Feed page widget with modern pill-style segmented tab bar.
/// KO: 모던 필 스타일 세그먼트 탭바를 포함한 피드 페이지 위젯.
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCommunityFab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _showCommunityFab = _tabController.index == 1;
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) return;
    final shouldShow = _tabController.index == 1;
    if (shouldShow == _showCommunityFab) return;
    setState(() => _showCommunityFab = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsListControllerProvider);
    final postState = ref.watch(postListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('소식'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.goToSearch(),
            tooltip: '검색',
          ),
        ],
        // EN: Pill-style segmented tab bar — matches board_page design
        // KO: 필 스타일 세그먼트 탭바 — board_page 디자인과 일치
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: GBTSegmentedTabBar(
            controller: _tabController,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
            tabs: const [
              Tab(text: '뉴스'),
              Tab(text: '커뮤니티'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // EN: Project selector — compact style
          // KO: 프로젝트 선택기 — 컴팩트 스타일
          const Padding(
            padding: EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              0,
            ),
            child: ProjectSelectorCompact(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _NewsList(
                  state: newsState,
                  onRetry: () => ref
                      .read(newsListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
                _CommunityList(
                  state: postState,
                  onRetry: () => ref
                      .read(postListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
              ],
            ),
          ),
        ],
      ),
      // EN: Compact FAB reduces visual weight in timeline screens.
      // KO: 타임라인 화면에서 시각적 부담을 줄이기 위한 컴팩트 FAB.
      floatingActionButton: _showCommunityFab
          ? FloatingActionButton(
              onPressed: () => context.goToPostCreate(),
              tooltip: '글쓰기',
              child: const Icon(Icons.edit_outlined),
            )
          : null,
    );
  }
}

/// EN: News list widget — divider-separated, borderless cards.
/// KO: 뉴스 리스트 위젯 — 구분선 분리, 무테두리 카드.
class _NewsList extends StatelessWidget {
  const _NewsList({required this.state, required this.onRetry});

  final AsyncValue<List<NewsSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
        children: [
          GBTListSkeleton(
            itemCount: 4,
            padding: EdgeInsets.zero,
            spacing: GBTSpacing.sm,
            itemBuilder: (_) => const GBTNewsCardSkeleton(),
          ),
        ],
      ),
      error: (error, _) {
        final message = error is Failure ? error.userMessage : '뉴스를 불러오지 못했어요';
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(message: message, onRetry: onRetry),
          ],
        );
      },
      data: (newsList) {
        if (newsList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(message: '표시할 뉴스가 없습니다'),
            ],
          );
        }

        // EN: Divider-separated list for modern look
        // KO: 모던한 느낌의 구분선 분리 리스트
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
          itemCount: newsList.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: GBTSpacing.pageHorizontal,
            endIndent: GBTSpacing.pageHorizontal,
          ),
          itemBuilder: (context, index) {
            final news = newsList[index];
            return _NewsCard(news: news);
          },
        );
      },
    );
  }
}

/// EN: News card widget — borderless with thumbnail.
/// KO: 뉴스 카드 위젯 — 썸네일 포함 무테두리.
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final thumbnail = news.thumbnailUrl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    // EN: Borderless card — no Card wrapper, just InkWell + Padding
    // KO: 무테두리 카드 — Card 래퍼 없이, InkWell + Padding만 사용
    return InkWell(
      onTap: () => context.goToNewsDetail(news.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.pageHorizontal,
          vertical: GBTSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsThumbnail(imageUrl: thumbnail),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: GBTTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? GBTColors.darkTextPrimary
                          : GBTColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    news.dateLabel,
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
    );
  }
}

/// EN: News thumbnail widget with rounded corners.
/// KO: 둥근 모서리의 뉴스 썸네일 위젯.
class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
        child: Icon(
          Icons.article_outlined,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          size: 28,
        ),
      );
    }

    return GBTImage(
      imageUrl: imageUrl!,
      width: 80,
      height: 80,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      semanticLabel: '뉴스 썸네일',
    );
  }
}

/// EN: Community list widget — divider-separated, SNS-style.
/// KO: 커뮤니티 리스트 위젯 — 구분선 분리, SNS 스타일.
class _CommunityList extends StatelessWidget {
  const _CommunityList({required this.state, required this.onRetry});

  final AsyncValue<List<PostSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
        children: [
          GBTListSkeleton(
            itemCount: 5,
            padding: EdgeInsets.zero,
            spacing: GBTSpacing.none,
            itemBuilder: (_) => const GBTCommunityPostSkeleton(),
          ),
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

        // EN: Divider-separated SNS-style list
        // KO: 구분선 분리 SNS 스타일 리스트
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: GBTSpacing.pageHorizontal,
            endIndent: GBTSpacing.pageHorizontal,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];
            return _CommunityPostCard(post: post);
          },
        );
      },
    );
  }
}

/// EN: Community post card — borderless, divider-separated SNS style.
/// KO: 커뮤니티 게시글 카드 — 무테두리, 구분선 분리 SNS 스타일.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    // EN: Determine if the current user can report this post.
    // KO: 현재 사용자가 이 게시글을 신고할 수 있는지 확인합니다.
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final myProfile = ref.watch(userProfileControllerProvider).valueOrNull;
    final isAuthor = myProfile?.id == post.authorId;
    final showMoreButton = isAuthenticated && !isAuthor;

    // EN: Borderless post card — no Card wrapper
    // KO: 무테두리 게시글 카드 — Card 래퍼 없음
    final hasImage = post.imageUrls.isNotEmpty || post.thumbnailUrl != null;
    final firstImageUrl = post.imageUrls.isNotEmpty
        ? post.imageUrls.first
        : post.thumbnailUrl;

    // EN: Card container — rounded border, surface background.
    // KO: 카드 컨테이너 — 둥근 테두리, 표면 배경.
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurface : GBTColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? GBTColors.darkBorder.withValues(alpha: 0.55)
              : GBTColors.border.withValues(alpha: 0.55),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.goToPostDetail(post.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 6, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN: Author row — avatar + name + time + report menu
                    // KO: 작성자 행 — 아바타 + 이름 + 시간 + 신고 메뉴
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                style: GBTTypography.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.timeAgoLabel,
                                style: GBTTypography.labelSmall.copyWith(
                                  color: tertiaryColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showMoreButton)
                          PopupMenuButton<_FeedPostCardAction>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: tertiaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: '더보기',
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: _FeedPostCardAction.report,
                                child: Row(
                                  children: [
                                    Icon(Icons.flag_outlined, size: 18),
                                    SizedBox(width: GBTSpacing.sm),
                                    Text('신고'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (action) {
                              if (action == _FeedPostCardAction.report) {
                                _showReportFlow(context, ref);
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // EN: Content area — right thumbnail when image, full-width when text-only.
                    // KO: 콘텐츠 영역 — 이미지가 있으면 오른쪽 썸네일, 없으면 전체 너비.
                    if (hasImage && firstImageUrl != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: GBTTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 78,
                                  height: 78,
                                  child: GBTImage(
                                    imageUrl: firstImageUrl,
                                    fit: BoxFit.cover,
                                    semanticLabel: '${post.title} 첨부 이미지',
                                  ),
                                ),
                                if (post.imageUrls.length > 1)
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          GBTSpacing.radiusFull,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.photo_library_outlined,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${post.imageUrls.length}',
                                            style: GBTTypography.labelSmall
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: GBTTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (post.content != null &&
                              post.content!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              post.content!,
                              style: GBTTypography.bodySmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextTertiary
                                    : GBTColors.textTertiary,
                                height: 1.45,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              // EN: Stats bar with subtle top border.
              // KO: 미묘한 상단 테두리가 있는 통계 바.
              Semantics(
                label: '좋아요 $likeCount개, 댓글 $commentCount개',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? GBTColors.darkBorder.withValues(alpha: 0.45)
                            : GBTColors.border.withValues(alpha: 0.45),
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: Row(
                    children: [
                      _StatChip(
                        icon: GBTActionIcons.like,
                        count: likeCount,
                        color: tertiaryColor,
                      ),
                      const SizedBox(width: GBTSpacing.md),
                      _StatChip(
                        icon: GBTActionIcons.comment,
                        count: commentCount,
                        color: tertiaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// EN: Report flow — rate-limit check, report sheet, confirmation, submit.
  /// KO: 신고 흐름 — 레이트리밋 확인, 신고 시트, 확인 다이얼로그, 제출.
  Future<void> _showReportFlow(BuildContext context, WidgetRef ref) async {
    final rateLimiter = ref.read(reportRateLimiterProvider);
    if (!rateLimiter.canReport(post.id)) {
      final remaining = rateLimiter.remainingCooldown(post.id);
      final minutes = remaining.inMinutes + 1;
      _showSnackBar(context, '$minutes분 후 다시 신고할 수 있어요');
      return;
    }

    final payload = await showModalBottomSheet<CommunityReportPayload>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CommunityReportSheet(),
    );
    if (payload == null || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('신고 접수'),
        content: Text('게시글을 "${payload.reason.label}" 사유로 신고합니다.\n접수하시겠어요?'),
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
    if (confirmed != true || !context.mounted) return;

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.createReport(
      targetType: CommunityReportTargetType.post,
      targetId: post.id,
      reason: payload.reason,
      description: payload.description,
    );
    if (!context.mounted) return;
    if (result is Success<void>) {
      rateLimiter.recordReport(post.id);
      _showSnackBar(context, '신고가 접수되었어요. 검토 후 조치할게요');
    } else {
      _showSnackBar(context, '신고를 접수하지 못했어요');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// EN: Compact stat chip — icon + count, used in feed card stats bar.
// KO: 아이콘 + 숫자 컴팩트 통계 칩, 피드 카드 통계 바에서 사용.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: GBTSpacing.xxs),
          Text(
            count.toString(),
            style: GBTTypography.labelSmall.copyWith(color: color),
          ),
        ],
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
