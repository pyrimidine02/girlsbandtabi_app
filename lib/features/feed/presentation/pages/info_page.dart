/// EN: Info page with tabbed sections — news, units (with member/VA accordion), songs.
/// KO: 탭 구조의 정보 페이지 — 소식, 유닛(멤버/성우 아코디언), 악곡.
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
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

// EN: Deterministic palette for unit/member avatar backgrounds.
// KO: 유닛/멤버 아바타 배경용 결정적 팔레트.
const _kAvatarPalette = [
  Color(0xFF6366F1), // indigo
  Color(0xFF3B82F6), // blue
  Color(0xFFEC4899), // pink
  Color(0xFFF59E0B), // amber
  Color(0xFF10B981), // emerald
  Color(0xFF8B5CF6), // violet
  Color(0xFFEF4444), // red
  Color(0xFF14B8A6), // teal
];

Color _paletteColor(String seed) =>
    _kAvatarPalette[seed.hashCode.abs() % _kAvatarPalette.length];

// ===========================================================================
// EN: Info page root
// KO: 정보 페이지 루트
// ===========================================================================

/// EN: Info page with wiki-style tabs and inline project selector in AppBar.
/// KO: 위키 스타일 탭과 AppBar 인라인 프로젝트 선택기가 있는 정보 페이지.
class InfoPage extends ConsumerStatefulWidget {
  const InfoPage({super.key});

  @override
  ConsumerState<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends ConsumerState<InfoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['소식', '유닛', '악곡'];
  static const _tabIcons = [
    Icons.newspaper_outlined,
    Icons.groups_outlined,
    Icons.music_note_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        await ref
            .read(newsListControllerProvider.notifier)
            .load(forceRefresh: true);
        return;
      case 1:
        final selection = ref.read(projectSelectionControllerProvider);
        final projectKey = selection.projectKey;
        if (projectKey == null || projectKey.isEmpty) return;
        await ref
            .read(projectUnitsControllerProvider(projectKey).notifier)
            .load(forceRefresh: true);
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        // EN: Inline project selector in AppBar for consistent navigation pattern.
        // KO: 일관된 네비게이션 패턴을 위해 AppBar에 인라인 프로젝트 선택기 배치.
        title: Row(
          children: [
            const SizedBox(width: GBTSpacing.md),
            Text(
              '정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
              child: Container(
                width: 1,
                height: 16,
                color: isDark ? GBTColors.darkBorder : GBTColors.border,
              ),
            ),
            const Expanded(child: ProjectSelectorCompact()),
          ],
        ),
        actions: const [GBTProfileAction()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.sm,
              ),
              labelStyle: GBTTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GBTTypography.labelMedium,
              indicatorSize: TabBarIndicatorSize.label,
              dividerHeight: 0,
              tabs: List.generate(_tabs.length, (i) {
                return Tab(
                  height: 44,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_tabIcons[i], size: 16),
                      const SizedBox(width: GBTSpacing.xs),
                      Text(_tabs[i]),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCurrentTab,
        child: TabBarView(
          controller: _tabController,
          children: const [
            _NewsTab(),
            _UnitsTab(),
            _SongsTab(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// EN: News tab — featured hero + compact list (wiki/media-style)
// KO: 소식 탭 — 피처드 히어로 + 컴팩트 리스트 (위키/미디어 스타일)
// ===========================================================================

class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsListControllerProvider);

    return newsState.when(
      loading: () => const _NewsTabSkeleton(),
      error: (error, _) {
        final message =
            error is Failure ? error.userMessage : '뉴스를 불러오지 못했어요';
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(
              message: message,
              onRetry: () =>
                  ref.read(newsListControllerProvider.notifier).load(
                    forceRefresh: true,
                  ),
            ),
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
              GBTEmptyState(
                icon: Icons.newspaper_outlined,
                message: '아직 소식이 없어요',
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              // EN: First item — large hero card for maximum impact.
              // KO: 첫 번째 항목 — 최대 임팩트를 위한 큰 히어로 카드.
              return _NewsHeroCard(news: newsList[0]);
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index == 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      GBTSpacing.pageHorizontal,
                      GBTSpacing.md,
                      GBTSpacing.pageHorizontal,
                      GBTSpacing.xs,
                    ),
                    child: _SectionHeader(
                      icon: Icons.article_outlined,
                      label: '최근 소식',
                    ),
                  ),
                _NewsRowItem(news: newsList[index]),
                if (index < newsList.length - 1)
                  const Divider(
                    height: 1,
                    indent: GBTSpacing.pageHorizontal,
                    endIndent: GBTSpacing.pageHorizontal,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// EN: Hero news card — large image banner + overlay gradient title.
/// KO: 히어로 뉴스 카드 — 큰 이미지 배너 + 오버레이 그라데이션 제목.
class _NewsHeroCard extends StatelessWidget {
  const _NewsHeroCard({required this.news});
  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbnail = news.thumbnailUrl;
    final hasThumbnail = thumbnail != null && thumbnail.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.md,
        GBTSpacing.pageHorizontal,
        0,
      ),
      child: InkWell(
        onTap: () => context.goToNewsDetail(news.id),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            color: isDark
                ? GBTColors.darkSurfaceVariant
                : GBTColors.surfaceVariant,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Hero image — 16:9 aspect ratio.
              // KO: 히어로 이미지 — 16:9 비율.
              AspectRatio(
                aspectRatio: 16 / 9,
                child: hasThumbnail
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          GBTImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            semanticLabel: '소식 이미지',
                          ),
                          // EN: Bottom gradient overlay for text legibility.
                          // KO: 텍스트 가독성을 위한 하단 그라데이션 오버레이.
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xCC000000),
                                ],
                                stops: [0.5, 1.0],
                              ),
                            ),
                          ),
                          // EN: NEW badge overlay.
                          // KO: NEW 배지 오버레이.
                          Positioned(
                            top: GBTSpacing.sm,
                            left: GBTSpacing.sm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: GBTSpacing.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: GBTColors.primary,
                                borderRadius: BorderRadius.circular(
                                  GBTSpacing.radiusFull,
                                ),
                              ),
                              child: Text(
                                'NEW',
                                style: GBTTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ColoredBox(
                        color: isDark
                            ? GBTColors.darkSurfaceElevated
                            : GBTColors.surfaceAlternate,
                        child: Center(
                          child: Icon(
                            Icons.newspaper_outlined,
                            size: 48,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                          ),
                        ),
                      ),
              ),
              // EN: Title + date below image.
              // KO: 이미지 아래 제목 + 날짜.
              Padding(
                padding: const EdgeInsets.all(GBTSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: GBTTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
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
                        color: isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary,
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

/// EN: Compact news row for non-hero items — with 24h NEW badge.
/// KO: 히어로가 아닌 항목용 컴팩트 뉴스 행 — 24시간 이내 NEW 배지 포함.
class _NewsRowItem extends StatelessWidget {
  const _NewsRowItem({required this.news});
  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbnail = news.thumbnailUrl;
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    // EN: Flag as NEW if published within the last 24 hours.
    // KO: 24시간 이내 게시된 경우 NEW로 표시합니다.
    final isNew = DateTime.now().difference(news.publishedAt).inHours < 24;

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
            // EN: 80×80 rounded thumbnail.
            // KO: 80×80 둥근 썸네일.
            _NewsThumbnail(imageUrl: thumbnail),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
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
                      ),
                      if (isNew) ...[
                        const SizedBox(width: GBTSpacing.xs),
                        // EN: NEW badge — red dot for freshness signal.
                        // KO: 신선도 신호로서 빨간 NEW 배지.
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: GBTColors.live,
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusFull,
                            ),
                          ),
                          child: Text(
                            'NEW',
                            style: GBTTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
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

/// EN: GBTShimmer-based skeleton for news loading state.
/// KO: GBTShimmer 기반 뉴스 로딩 상태 스켈레톤.
class _NewsTabSkeleton extends StatelessWidget {
  const _NewsTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return GBTShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: GBTSpacing.md),
        children: [
          // EN: Hero card placeholder.
          // KO: 히어로 카드 플레이스홀더.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.pageHorizontal,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: GBTShimmerContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: GBTSpacing.radiusMd,
              ),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.pageHorizontal,
                vertical: GBTSpacing.sm,
              ),
              child: Row(
                children: [
                  GBTShimmerContainer(
                    width: 80,
                    height: 80,
                    borderRadius: GBTSpacing.radiusMd,
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GBTShimmerContainer(
                          width: double.infinity,
                          height: 14,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: GBTSpacing.xs),
                        GBTShimmerContainer(
                          width: 160,
                          height: 14,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: GBTSpacing.sm),
                        GBTShimmerContainer(
                          width: 80,
                          height: 10,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// EN: Units tab — wiki-style grid with expandable member/VA accordion
// KO: 유닛 탭 — 위키 스타일 그리드 + 멤버/성우 확장 아코디언
// ===========================================================================

class _UnitsTab extends ConsumerWidget {
  const _UnitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(projectSelectionControllerProvider);
    final projectKey = selection.projectKey;

    if (projectKey == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTEmptyState(
            icon: Icons.groups_outlined,
            message: '프로젝트를 먼저 선택해주세요',
          ),
        ],
      );
    }

    final unitsState = ref.watch(projectUnitsControllerProvider(projectKey));

    return unitsState.when(
      loading: () => const _UnitsTabSkeleton(),
      error: (error, _) {
        final message =
            error is Failure ? error.userMessage : '유닛을 불러오지 못했어요';
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(
              message: message,
              onRetry: () =>
                  ref
                      .read(
                        projectUnitsControllerProvider(projectKey).notifier,
                      )
                      .load(forceRefresh: true),
            ),
          ],
        );
      },
      data: (units) {
        if (units.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(
                icon: Icons.groups_outlined,
                message: '등록된 유닛이 없습니다',
              ),
            ],
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                GBTSpacing.sm,
                GBTSpacing.pageHorizontal,
                GBTSpacing.sm,
              ),
              child: _SectionHeader(
                icon: Icons.groups_outlined,
                label: '유닛 (${units.length})',
              ),
            ),
            ...units.map(
              (unit) => _UnitAccordionCard(
                unit: unit,
                projectId: projectKey,
                paletteColor: _paletteColor(unit.displayName),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// EN: Accordion-style unit card — tap to expand member/VA roster.
/// KO: 아코디언 스타일 유닛 카드 — 탭하면 멤버/성우 로스터 확장.
class _UnitAccordionCard extends ConsumerStatefulWidget {
  const _UnitAccordionCard({
    required this.unit,
    required this.projectId,
    required this.paletteColor,
  });

  final Unit unit;
  final String projectId;
  final Color paletteColor;

  @override
  ConsumerState<_UnitAccordionCard> createState() => _UnitAccordionCardState();
}

class _UnitAccordionCardState extends ConsumerState<_UnitAccordionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgAlpha = isDark ? 0.18 : 0.10;
    final borderAlpha = 0.25;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final surfaceColor = isDark ? GBTColors.darkSurface : GBTColors.surface;
    final initial = widget.unit.displayName.isNotEmpty
        ? widget.unit.displayName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.xs,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _expanded
              ? widget.paletteColor.withValues(alpha: bgAlpha + 0.05)
              : (isDark ? GBTColors.darkSurface : GBTColors.surface),
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          border: Border.all(
            color: _expanded
                ? widget.paletteColor.withValues(alpha: borderAlpha + 0.1)
                : (isDark ? GBTColors.darkBorder : GBTColors.border),
          ),
        ),
        child: Column(
          children: [
            // EN: Unit header row — always visible.
            // KO: 유닛 헤더 행 — 항상 표시.
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(GBTSpacing.md),
                child: Row(
                  children: [
                    // EN: Avatar circle with initial or palette color.
                    // KO: 이니셜 또는 팔레트 색상 아바타 원.
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.paletteColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.unit.displayName,
                                  style: GBTTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: GBTSpacing.xs),
                              // EN: Member count badge — shown after members loaded.
                              // KO: 멤버 로드 후 표시되는 멤버 수 배지.
                              Consumer(
                                builder: (context, ref, _) {
                                  final membersState = ref.watch(
                                    unitMembersControllerProvider(
                                      (widget.projectId, widget.unit.id),
                                    ),
                                  );
                                  return membersState.maybeWhen(
                                    data: (members) => members.isEmpty
                                        ? const SizedBox.shrink()
                                        : Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.paletteColor
                                                      .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    GBTSpacing.radiusFull,
                                                  ),
                                            ),
                                            child: Text(
                                              '${members.length}명',
                                              style:
                                                  GBTTypography.labelSmall
                                                      .copyWith(
                                                        color:
                                                            widget.paletteColor,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 10,
                                                      ),
                                            ),
                                          ),
                                    orElse: () => const SizedBox.shrink(),
                                  );
                                },
                              ),
                            ],
                          ),
                          Text(
                            widget.unit.code,
                            style: GBTTypography.labelSmall.copyWith(
                              color: textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // EN: Unit detail navigation button.
                    // KO: 유닛 상세 이동 버튼.
                    GestureDetector(
                      onTap: () => context.goToUnitDetail(
                        unit: widget.unit,
                        projectId: widget.projectId,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.xs),
                    // EN: Expand/collapse chevron with rotation animation.
                    // KO: 회전 애니메이션이 있는 확장/축소 꺾쇠.
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnim),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // EN: Expandable member section.
            // KO: 확장 가능한 멤버 섹션.
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color: isDark ? GBTColors.darkBorder : GBTColors.border,
                  ),
                  Container(
                    color: surfaceColor.withValues(alpha: 0.5),
                    padding: const EdgeInsets.fromLTRB(
                      GBTSpacing.md,
                      GBTSpacing.sm,
                      GBTSpacing.md,
                      GBTSpacing.md,
                    ),
                    child: _UnitMembersList(
                      projectId: widget.projectId,
                      unit: widget.unit,
                      paletteColor: widget.paletteColor,
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

/// EN: Inline member list loaded from API when unit is expanded.
/// KO: 유닛 확장 시 API에서 불러오는 인라인 멤버 목록.
class _UnitMembersList extends ConsumerWidget {
  const _UnitMembersList({
    required this.projectId,
    required this.unit,
    required this.paletteColor,
  });

  final String projectId;
  final Unit unit;
  final Color paletteColor;

  String get unitId => unit.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersState = ref.watch(
      unitMembersControllerProvider((projectId, unitId)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return membersState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: GBTSpacing.md),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
        child: Text(
          '멤버 정보를 불러오지 못했어요',
          style: GBTTypography.labelSmall.copyWith(
            color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          ),
        ),
      ),
      data: (members) {
        if (members.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
            child: Text(
              '멤버 정보가 없습니다',
              style: GBTTypography.labelSmall.copyWith(
                color: isDark
                    ? GBTColors.darkTextTertiary
                    : GBTColors.textTertiary,
              ),
            ),
          );
        }

        // EN: Sort by order field if available, then alphabetically.
        // KO: order 필드 기준으로 정렬하고, 없으면 이름 순.
        final sorted = [...members]..sort((a, b) {
          if (a.order != null && b.order != null) {
            return a.order!.compareTo(b.order!);
          }
          return a.name.compareTo(b.name);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
              child: Text(
                '멤버 · 성우',
                style: GBTTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: paletteColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            ...sorted.map(
              (m) => _MemberInlineRow(
                member: m,
                unit: unit,
                projectId: projectId,
                paletteColor: paletteColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// EN: Single member row inside unit accordion — avatar, name+VA, role, tappable.
/// KO: 유닛 아코디언 내 단일 멤버 행 — 아바타, 이름+성우, 역할, 탭 가능.
class _MemberInlineRow extends StatelessWidget {
  const _MemberInlineRow({
    required this.member,
    required this.unit,
    required this.projectId,
    required this.paletteColor,
  });

  final UnitMember member;
  final Unit unit;
  final String projectId;
  final Color paletteColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final initial = member.name.isNotEmpty ? member.name[0] : '?';

    return InkWell(
      onTap: () => context.goToMemberDetail(
        unit: unit,
        member: member,
        projectId: projectId,
      ),
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: GBTSpacing.xs,
          horizontal: 2,
        ),
        child: Row(
          children: [
            // EN: Small member avatar with image or palette initial.
            // KO: 이미지 또는 팔레트 이니셜이 있는 작은 멤버 아바타.
            _MemberAvatar(
              imageUrl: member.imageUrl,
              initial: initial,
              paletteColor: paletteColor,
              size: 36,
            ),
            const SizedBox(width: GBTSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EN: Character name + VA name on same line for quick scan.
                  // KO: 빠른 스캔을 위해 캐릭터명 + 성우명을 한 줄에 표시.
                  Row(
                    children: [
                      Text(
                        member.name,
                        style: GBTTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      if (member.voiceActorName != null &&
                          member.voiceActorName!.isNotEmpty) ...[
                        const SizedBox(width: GBTSpacing.xs),
                        Container(
                          width: 1,
                          height: 11,
                          color: textTertiary.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: GBTSpacing.xs),
                        Icon(
                          Icons.mic_rounded,
                          size: 11,
                          color: paletteColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            member.voiceActorName!,
                            style: GBTTypography.labelSmall.copyWith(
                              color: textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // EN: Role / instrument tags row.
                  // KO: 역할 / 악기 태그 행.
                  if (member.instrument != null || member.role != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (member.instrument != null) ...[
                            _MiniTag(
                              label: member.instrument!,
                              color: paletteColor,
                            ),
                            const SizedBox(width: GBTSpacing.xs),
                          ],
                          if (member.role != null &&
                              member.role != member.instrument)
                            _MiniTag(
                              label: member.role!,
                              color: paletteColor,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: textTertiary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Small tag chip for role / instrument labels inside member rows.
/// KO: 멤버 행 내 역할/악기 레이블용 작은 태그 칩.
class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: GBTTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _UnitsTabSkeleton extends StatelessWidget {
  const _UnitsTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return GBTShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(GBTSpacing.md),
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
            child: GBTShimmerContainer(
              width: double.infinity,
              height: 72,
              borderRadius: GBTSpacing.radiusMd,
            ),
          ),
        ),
      ),
    );
  }
}
/// EN: Member avatar widget — shows network image or palette initial fallback.
/// KO: 멤버 아바타 위젯 — 네트워크 이미지 또는 팔레트 이니셜 폴백.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.imageUrl,
    required this.initial,
    required this.paletteColor,
    required this.size,
  });

  final String? imageUrl;
  final String initial;
  final Color paletteColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (hasImage) {
      return GBTImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
        fit: BoxFit.cover,
        semanticLabel: '$initial 멤버 이미지',
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: paletteColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// EN: Songs tab — enriched coming-soon placeholder with visual flair
// KO: 악곡 탭 — 시각적 포인트가 있는 개선된 준비 중 플레이스홀더
// ===========================================================================

class _SongsTab extends StatelessWidget {
  const _SongsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.xl,
      ),
      children: [
        // EN: Icon placeholder for upcoming song list.
        // KO: 악곡 목록 준비 중 아이콘 플레이스홀더.
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.album_outlined,
              size: 40,
              color: textTertiary,
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.md),
        Center(
          child: Text(
            '악곡 목록',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        Center(
          child: Text(
            '준비 중이에요',
            style: GBTTypography.bodySmall.copyWith(color: textTertiary),
          ),
        ),
        const SizedBox(height: GBTSpacing.xl),
        // EN: Fake album placeholders to give visual depth.
        // KO: 시각적 깊이를 주는 가짜 앨범 플레이스홀더.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: GBTSpacing.sm,
            mainAxisSpacing: GBTSpacing.sm,
            childAspectRatio: 1,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final color = _kAvatarPalette[index % _kAvatarPalette.length];
            return Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
              child: Icon(
                Icons.music_note_outlined,
                color: color.withValues(alpha: 0.6),
                size: 28,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ===========================================================================
// EN: Shared section header widget
// KO: 공유 섹션 헤더 위젯
// ===========================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return Row(
      children: [
        Icon(icon, size: 14, color: textSecondary),
        const SizedBox(width: GBTSpacing.xs),
        Text(
          label,
          style: GBTTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
