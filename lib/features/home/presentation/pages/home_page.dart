/// EN: Home page — greeting header + carousels + compact news
/// KO: 홈 페이지 — 인사말 헤더 + 캐러셀 + 컴팩트 뉴스
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/accessibility/a11y_wrapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_animations.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/animations/staggered_list_item.dart';
import '../../../../core/widgets/cards/gbt_event_card_carousel.dart';
import '../../../../core/widgets/cards/gbt_place_card_carousel.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/layout/gbt_carousel_section.dart';
import '../../../../core/widgets/layout/gbt_greeting_header.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/home_controller.dart';
import '../../domain/entities/home_summary.dart';

/// EN: Home page widget — CustomScrollView with greeting header + carousels
/// KO: 홈 페이지 위젯 — 인사말 헤더 + 캐러셀을 갖춘 CustomScrollView
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    // EN: Eagerly initialize project selection — prevents deadlock where
    // HomeController waits for selectedProjectKey but ProjectSelector only
    // renders after content loads.
    // KO: 프로젝트 선택을 즉시 초기화 — HomeController가 selectedProjectKey를
    // 기다리지만 ProjectSelector가 콘텐츠 로드 후에만 렌더링되는 데드락 방지.
    ref.watch(projectSelectionControllerProvider);
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Girls Band Tabi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        actions: [
          GBTAppBarIconButton(
            icon: Icons.search,
            onPressed: () => context.push('/search'),
            tooltip: '검색',
          ),
          GBTAppBarIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () => context.push('/notifications'),
            tooltip: '알림',
          ),
          const GBTProfileAction(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeControllerProvider.notifier).load(forceRefresh: true),
        edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight,
        child: state.when(
          loading: () => _buildLoading(),
          error: (error, _) => _buildError(error),
          data: (summary) => _buildContent(summary),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // EN: Spacer for SliverAppBar overlap
        // KO: SliverAppBar 겹침을 위한 스페이서
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
        ),
        // EN: Greeting header shimmer placeholder
        // KO: 인사말 헤더 쉬머 플레이스홀더
        SliverToBoxAdapter(
          child: GBTShimmer(
            child: Container(
              height: 100,
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.primaryLight,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: GBTSpacing.sectionSpacingLg),
        ),
        // EN: Carousel shimmer placeholders
        // KO: 캐러셀 쉬머 플레이스홀더
        SliverToBoxAdapter(child: _buildCarouselShimmer(isDark)),
        const SliverToBoxAdapter(
          child: SizedBox(height: GBTSpacing.sectionSpacingLg),
        ),
        SliverToBoxAdapter(child: _buildCarouselShimmer(isDark)),
      ],
    );
  }

  Widget _buildCarouselShimmer(bool isDark) {
    final bgColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.pageHorizontal,
          ),
          child: GBTShimmer(
            child: Container(
              height: 22,
              width: 120,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
              ),
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.sm),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.pageHorizontal,
            ),
            itemCount: 4,
            separatorBuilder: (_, __) =>
                const SizedBox(width: GBTSpacing.carouselItemGap),
            itemBuilder: (_, __) => GBTShimmer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    final message = error is Failure ? error.userMessage : '홈 정보를 불러오지 못했어요';
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: GBTErrorState(
            message: message,
            onRetry: () => ref
                .read(homeControllerProvider.notifier)
                .load(forceRefresh: true),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(HomeSummary summary) {
    final featuredLive = _pickFeaturedLive(summary.trendingLiveEvents);
    final headerImageUrl = _pickHeaderImage(summary, featuredLive);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // 1. GBTGreetingHeader (includes SafeArea + AppBar space)
        SliverToBoxAdapter(
          child: GBTGreetingHeader(
            backgroundImageUrl: headerImageUrl,
            featuredTitle: featuredLive?.title,
            featuredDate: featuredLive?.dateLabel,
            featuredPosterUrl: featuredLive?.posterUrl,
            onFeaturedTap: featuredLive == null
                ? null
                : () => context.goToLiveDetail(featuredLive.id),
          ),
        ),

        // 2. ProjectSelector — edge-to-edge pill row
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: GBTSpacing.lg),
            child: ProjectSelector(),
          ),
        ),

        // 3. Service hub — compact 3-column quick access row (Naver-style)
        // EN: Surface all three core services at a glance.
        // KO: 세 핵심 서비스를 한눈에 — 커뮤니티/장소/정보 빠른 진입.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.pageHorizontal,
              GBTSpacing.lg,
              GBTSpacing.pageHorizontal,
              0,
            ),
            child: _ServiceHub(
              onCommunityTap: () => context.go('/board'),
              onPlacesTap: () => context.go('/places'),
              onInfoTap: () => context.go('/info'),
            ),
          ),
        ),

        // EN: Empty state
        // KO: 빈 상태
        if (summary.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: GBTSpacing.xl),
              child: GBTEmptyState(message: '표시할 홈 콘텐츠가 없습니다'),
            ),
          ),

        // 4. Recommended places carousel
        if (summary.recommendedPlaces.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height: GBTResponsiveSpacing.responsiveSectionSpacing(context),
            ),
          ),
          SliverToBoxAdapter(
            child: GBTCarouselSection(
              title: '추천 장소',
              itemCount: summary.recommendedPlaces.length,
              itemHeight: 220,
              onSeeAll: () => context.go('/places'),
              itemBuilder: (context, index) {
                final place = summary.recommendedPlaces[index];
                return GBTPlaceCardCarousel(
                  placeId: place.id,
                  name: place.name,
                  location: place.location ?? '방문 ${place.visitCount}회',
                  imageUrl: place.imageUrl,
                  onTap: () => context.goToPlaceDetail(place.id),
                );
              },
            ),
          ),
        ],

        // 5. Trending live events carousel
        if (summary.trendingLiveEvents.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height: GBTResponsiveSpacing.responsiveSectionSpacing(context),
            ),
          ),
          SliverToBoxAdapter(
            child: GBTCarouselSection(
              title: '트렌딩 라이브',
              itemCount: summary.trendingLiveEvents.length,
              itemHeight: 220,
              onSeeAll: () => context.go('/live'),
              itemBuilder: (context, index) {
                final event = summary.trendingLiveEvents[index];
                return GBTEventCardCarousel(
                  title: event.title,
                  date: event.dateLabel,
                  posterUrl: event.posterUrl,
                  isLive: event.isLive,
                  onTap: () => context.goToLiveDetail(event.id),
                );
              },
            ),
          ),
        ],

        // 6. Latest news — compact borderless list
        if (summary.latestNews.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height: GBTResponsiveSpacing.responsiveSectionSpacing(context),
            ),
          ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '최신 소식',
              onSeeAll: () => context.go('/info'),
            ),
          ),
          SliverList.builder(
            itemCount: summary.latestNews.take(5).length,
            itemBuilder: (context, index) {
              final news = summary.latestNews[index];
              final delay = GBTStaggerAnimations.delayFor(index);

              // EN: Wrap in StaggeredListItem for fade + slide animation
              // KO: fade + slide 애니메이션을 위해 StaggeredListItem으로 래핑
              return StaggeredListItem(
                key: ValueKey(news.id),
                delay: delay,
                child: _CompactNewsTile(item: news),
              );
            },
          ),
        ],

        // 7. Bottom spacing
        SliverToBoxAdapter(
          child: SizedBox(
            height: GBTSpacing.xxl + MediaQuery.of(context).padding.bottom,
          ),
        ),
      ],
    );
  }

  HomeEventItem? _pickFeaturedLive(List<HomeEventItem> events) {
    if (events.isEmpty) {
      return null;
    }
    for (final event in events) {
      if (_hasText(event.posterUrl)) {
        return event;
      }
    }
    return events.first;
  }

  String? _pickHeaderImage(HomeSummary summary, HomeEventItem? featuredLive) {
    final candidates = <String?>[
      featuredLive?.posterUrl,
      ...summary.trendingLiveEvents.map((event) => event.posterUrl),
      ...summary.recommendedPlaces.map((place) => place.imageUrl),
      ...summary.latestNews.map((news) => news.imageUrl),
    ];
    for (final candidate in candidates) {
      if (_hasText(candidate)) {
        return candidate!.trim();
      }
    }
    return null;
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}

/// EN: Service hub — 3-column quick access row for community / places / info.
///     Surfaces the app's three core pillars on the home screen (Naver-style).
/// KO: 서비스 허브 — 커뮤니티/장소/정보로 이동하는 3열 빠른 진입 행.
///     홈 화면에서 앱의 세 핵심 서비스를 바로 보여줍니다 (네이버 스타일).
class _ServiceHub extends StatelessWidget {
  const _ServiceHub({
    required this.onCommunityTap,
    required this.onPlacesTap,
    required this.onInfoTap,
  });

  final VoidCallback onCommunityTap;
  final VoidCallback onPlacesTap;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GBTColors.darkSurface : GBTColors.surface;
    final border = isDark
        ? GBTColors.darkSurfaceVariant
        : const Color(0xFFEEEEEE);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _ServiceHubItem(
              icon: Icons.forum_outlined,
              label: '커뮤니티',
              color: GBTColors.primary,
              onTap: onCommunityTap,
              showRightDivider: true,
              isDark: isDark,
            ),
            _ServiceHubItem(
              icon: Icons.place_outlined,
              label: '장소',
              color: GBTColors.accentTeal,
              onTap: onPlacesTap,
              showRightDivider: true,
              isDark: isDark,
            ),
            _ServiceHubItem(
              icon: Icons.auto_stories_outlined,
              label: '정보·위키',
              color: GBTColors.accent,
              onTap: onInfoTap,
              showRightDivider: false,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Individual item in the service hub row.
/// KO: 서비스 허브 행의 개별 아이템.
class _ServiceHubItem extends StatelessWidget {
  const _ServiceHubItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.showRightDivider,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool showRightDivider;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark
        ? GBTColors.darkSurfaceVariant
        : const Color(0xFFEEEEEE);

    return Expanded(
      child: Semantics(
        button: true,
        label: '$label 바로가기',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: GBTSpacing.md),
            decoration: showRightDivider
                ? BoxDecoration(
                    border: Border(
                      right: BorderSide(color: dividerColor),
                    ),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // EN: Icon in a tinted circle — Naver service icon style.
                // KO: 틴트 원 안의 아이콘 — 네이버 서비스 아이콘 스타일.
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: GBTSpacing.xs),
                Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextPrimary
                        : GBTColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Section header widget — headlineLarge style
/// KO: 섹션 헤더 위젯 — headlineLarge 스타일
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // EN: Wrap section title in A11yHeading for proper heading hierarchy
          // KO: 적절한 heading 계층을 위해 섹션 제목을 A11yHeading으로 래핑
          A11yHeading(
            level: 2,
            child: Text(
              title,
              style: GBTTypography.headlineLarge.copyWith(
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
              ),
            ),
          ),
          Semantics(
            label: '$title 전체보기',
            button: true,
            child: TextButton(
              onPressed: onSeeAll,
              child: Text(
                '전체보기',
                style: GBTTypography.bodySmall.copyWith(
                  color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Compact borderless news tile — 56x56 thumbnail + title, no Card wrapper
/// KO: 컴팩트 무테두리 뉴스 타일 — 56x56 썸네일 + 제목, Card 래퍼 없음
class _CompactNewsTile extends StatelessWidget {
  const _CompactNewsTile({required this.item});

  final HomeNewsItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: item.title,
      hint: '탭하면 뉴스 상세로 이동합니다',
      button: true,
      child: InkWell(
        onTap: () => context.goToNewsDetail(item.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.pageHorizontal,
            vertical: GBTSpacing.sm,
          ),
          child: Row(
            children: [
              // EN: 56x56 thumbnail
              // KO: 56x56 썸네일
              ClipRRect(
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: item.imageUrl != null
                      ? GBTImage(
                          imageUrl: item.imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          semanticLabel: '${item.title} 뉴스 썸네일',
                          useShimmer: false,
                        )
                      : Container(
                          color: isDark
                              ? GBTColors.darkSurfaceVariant
                              : GBTColors.primaryLight,
                          child: Icon(
                            Icons.article_outlined,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.primaryMuted,
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: GBTSpacing.md),
              // EN: Title + optional summary
              // KO: 제목 + 선택적 요약
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: isDark
                            ? GBTColors.darkTextPrimary
                            : GBTColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.summary != null) ...[
                      const SizedBox(height: GBTSpacing.xxs),
                      Text(
                        item.summary!,
                        style: GBTTypography.bodySmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextSecondary
                              : GBTColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
