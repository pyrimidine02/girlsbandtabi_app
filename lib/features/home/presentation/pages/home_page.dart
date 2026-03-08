/// EN: Home page — greeting header + carousels + compact news
/// KO: 홈 페이지 — 인사말 헤더 + 캐러셀 + 컴팩트 뉴스
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/accessibility/a11y_wrapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
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
import '../../../ads/domain/entities/ad_slot_entities.dart';
import '../../../ads/presentation/widgets/hybrid_sponsored_slot.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../../settings/application/settings_controller.dart';
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
    final selectedProjectKey = ref.watch(selectedProjectKeyProvider);
    final projectsState = ref.watch(projectsControllerProvider);
    final state = ref.watch(homeControllerProvider);
    final avatarUrl = ref
        .watch(userProfileControllerProvider)
        .valueOrNull
        ?.avatarUrl;
    final isProjectSelected =
        selectedProjectKey != null && selectedProjectKey.isNotEmpty;

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
            onPressed: () => context.goToSearch(),
            tooltip: context.l10n(ko: '검색', en: 'Search', ja: '検索'),
          ),
          GBTAppBarIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () => context.push('/notifications'),
            tooltip: context.l10n(ko: '알림', en: 'Notifications', ja: '通知'),
          ),
          GBTProfileAction(avatarUrl: avatarUrl),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeControllerProvider.notifier).load(forceRefresh: true),
        edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight,
        child: !isProjectSelected
            ? _buildProjectGate(projectsState)
            : state.when(
                loading: () => _buildLoading(),
                error: (error, _) => _buildError(error),
                data: (summary) => _buildContent(summary),
              ),
      ),
    );
  }

  Widget _buildProjectGate(AsyncValue<List<Project>> projectsState) {
    return projectsState.when(
      loading: _buildLoading,
      error: (error, _) => _buildError(
        error,
        onRetry: () {
          ref
              .read(projectsControllerProvider.notifier)
              .load(forceRefresh: true);
          ref.read(homeControllerProvider.notifier).load(forceRefresh: true);
        },
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return _buildError(
            const ValidationFailure(
              'No projects available',
              code: 'projects_empty',
            ),
            onRetry: () => ref
                .read(projectsControllerProvider.notifier)
                .load(forceRefresh: true),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final current = ref.read(selectedProjectKeyProvider);
          if (current != null && current.isNotEmpty) {
            return;
          }
          final first = projects.first;
          final firstProjectKey = first.code.isNotEmpty ? first.code : first.id;
          ref
              .read(projectSelectionControllerProvider.notifier)
              .selectProject(firstProjectKey, projectId: first.id);
        });

        return _buildLoading();
      },
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

  Widget _buildError(Object error, {VoidCallback? onRetry}) {
    final message = error is Failure
        ? error.userMessage
        : context.l10n(
            ko: '홈 정보를 불러오지 못했어요',
            en: 'Failed to load home content',
            ja: 'ホーム情報を読み込めませんでした',
          );
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
            onRetry:
                onRetry ??
                () => ref
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

        // EN: Single native sponsored slot on home to keep exposure light.
        // KO: 노출 부담을 줄이기 위해 홈에는 네이티브 스폰서 슬롯 1개만 배치.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: GBTSpacing.md),
            child: _HomeSponsoredSlot(
              onTap: () => context.goNamed(AppRoutes.places),
            ),
          ),
        ),

        // EN: Hard empty state (no cards + no source data)
        // KO: 완전 빈 상태 (카드/원천 데이터 모두 없음)
        if (summary.shouldShowNoContentEmptyState)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: GBTSpacing.xl),
              child: GBTEmptyState(
                message: context.l10n(
                  ko: '표시할 홈 콘텐츠가 없습니다',
                  en: 'No home content available',
                  ja: '表示できるホームコンテンツがありません',
                ),
              ),
            ),
          ),
        // EN: Soft empty state (cards empty but source rows exist)
        // KO: 소프트 빈 상태 (카드는 비었지만 원천 데이터가 존재)
        if (summary.shouldShowFilteredEmptyState)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: GBTSpacing.xl),
              child: GBTEmptyState(
                message: context.l10n(
                  ko: '조건에 맞는 최신 항목이 없습니다',
                  en: 'No recent items match current conditions',
                  ja: '条件に合う最新項目がありません',
                ),
              ),
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
              title: context.l10n(
                ko: '추천 장소',
                en: 'Recommended Places',
                ja: 'おすすめスポット',
              ),
              itemCount: summary.recommendedPlaces.length,
              itemHeight: 220,
              onSeeAll: () => context.go('/places'),
              itemBuilder: (context, index) {
                final place = summary.recommendedPlaces[index];
                return GBTPlaceCardCarousel(
                  placeId: place.id,
                  name: place.name,
                  location:
                      place.location ??
                      context.l10n(
                        ko: '방문 ${place.visitCount}회',
                        en: '${place.visitCount} visits',
                        ja: '${place.visitCount}回訪問',
                      ),
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
              title: context.l10n(
                ko: '트렌딩 라이브',
                en: 'Trending Live',
                ja: 'トレンドライブ',
              ),
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
              title: context.l10n(ko: '최신 소식', en: 'Latest News', ja: '最新ニュース'),
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

/// EN: Home sponsored slot card shown once per screen build.
/// KO: 화면당 한 번만 노출되는 홈 스폰서 슬롯 카드입니다.
class _HomeSponsoredSlot extends StatelessWidget {
  const _HomeSponsoredSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HybridSponsoredSlot(
      request: const AdSlotRequest(placement: AdSlotPlacement.homePrimary),
      noDecisionStrategy: NoDecisionStrategy.house,
      deliveryNoneStrategy: DeliveryNoneStrategy.fallback,
      fallback: SponsoredFallbackContent(
        badgeLabel: context.l10n(ko: '광고', en: 'AD', ja: '広告'),
        sponsorLabel: context.l10n(
          ko: 'GirlsBandTabi 추천',
          en: 'GirlsBandTabi Sponsored',
          ja: 'GirlsBandTabi スポンサー',
        ),
        title: context.l10n(
          ko: '성지 방문 전, 장소 태그와 동선을 먼저 확인해보세요',
          en: 'Check place tags and routes before your visit',
          ja: '聖地訪問前に場所タグと動線を確認しましょう',
        ),
        description: context.l10n(
          ko: '근처 장소를 빠르게 비교해 오늘 동선을 자연스럽게 정할 수 있어요.',
          en: 'Compare nearby places quickly and plan today\'s route naturally.',
          ja: '近くの場所をすぐ比較して今日の動線を自然に決められます。',
        ),
        ctaLabel: context.l10n(
          ko: '장소 탐색 시작',
          en: 'Start Exploring Places',
          ja: '場所探索を開始',
        ),
        icon: Icons.map_outlined,
        accentColor: GBTColors.accentTeal,
        onTap: onTap,
      ),
      margin: const EdgeInsets.symmetric(horizontal: GBTSpacing.pageHorizontal),
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
            label:
                '$title ${context.l10n(ko: "전체 보기", en: "see all", ja: "すべて見る")}',
            button: true,
            child: TextButton(
              onPressed: onSeeAll,
              child: Text(
                context.l10n(ko: '전체 보기', en: 'See all', ja: 'すべて見る'),
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
      hint: context.l10n(
        ko: '탭하면 뉴스 상세로 이동합니다',
        en: 'Tap to open news details',
        ja: 'タップしてニュース詳細へ移動',
      ),
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
                          semanticLabel:
                              '${item.title} ${context.l10n(ko: "뉴스 썸네일", en: "news thumbnail", ja: "ニュースサムネイル")}',
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
