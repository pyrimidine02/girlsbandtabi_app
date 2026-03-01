/// EN: Feed page with news and community tabs — unified SNS-style design.
/// KO: 뉴스 및 커뮤니티 탭을 포함한 피드 페이지 — 통일된 SNS 스타일 디자인.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
            ),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? GBTColors.darkSurface : GBTColors.surface,
                borderRadius:
                    BorderRadius.circular(GBTSpacing.radiusSm + 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: isDark
                  ? GBTColors.darkTextPrimary
                  : GBTColors.textPrimary,
              unselectedLabelColor: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              labelStyle: GBTTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GBTTypography.labelLarge,
              tabs: const [
                Tab(text: '뉴스'),
                Tab(text: '커뮤니티'),
              ],
            ),
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
      // EN: Extended FAB for consistency with board page
      // KO: 게시판 페이지와 일관성을 위한 확장 FAB
      floatingActionButton: _showCommunityFab
          ? FloatingActionButton.extended(
              onPressed: () => context.goToPostCreate(),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('글쓰기'),
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
        padding: GBTSpacing.paddingPage,
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTLoading(message: '뉴스를 불러오는 중...'),
        ],
      ),
      error: (error, _) {
        final message =
            error is Failure ? error.userMessage : '뉴스를 불러오지 못했어요';
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
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

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
          color:
              isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
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
class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post});

  final PostSummary post;

  @override
  Widget build(BuildContext context) {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : '익명';
    final avatarUrl = post.authorAvatarUrl?.isNotEmpty == true
        ? post.authorAvatarUrl
        : null;
    final commentCount = post.commentCount ?? 0;
    final likeCount = post.likeCount ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    // EN: Borderless post card — no Card wrapper
    // KO: 무테두리 게시글 카드 — Card 래퍼 없음
    return InkWell(
      onTap: () => context.goToPostDetail(post.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.pageHorizontal,
          vertical: GBTSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Author row
            // KO: 작성자 행
            Row(
              children: [
                _Avatar(
                  url: avatarUrl,
                  radius: 18,
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
                      Text(
                        post.timeAgoLabel,
                        style: GBTTypography.labelSmall.copyWith(
                          color: tertiaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // EN: Horizontal more icon — matches board page
                // KO: 수평 더보기 아이콘 — 게시판 페이지와 일치
                Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: tertiaryColor,
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.sm),
            // EN: Title with semi-bold weight
            // KO: 세미볼드 가중치의 제목
            Text(
              post.title,
              style: GBTTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: GBTSpacing.sm),
            // EN: Engagement stats row
            // KO: 참여 통계 행
            Semantics(
              label: '좋아요 $likeCount개, 댓글 $commentCount개',
              child: Row(
                children: [
                  Icon(Icons.favorite_border,
                      size: 16, color: tertiaryColor),
                  const SizedBox(width: GBTSpacing.xxs),
                  Text(
                    likeCount.toString(),
                    style: GBTTypography.labelSmall.copyWith(
                      color: tertiaryColor,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  Icon(Icons.chat_bubble_outline,
                      size: 16, color: tertiaryColor),
                  const SizedBox(width: GBTSpacing.xxs),
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
