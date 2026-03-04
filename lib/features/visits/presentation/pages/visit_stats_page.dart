/// EN: Visit statistics page — Premium dashboard with ranking banner and charts.
/// KO: 방문 통계 페이지 — 랭킹 배너와 차트가 있는 프리미엄 대시보드.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../places/domain/entities/place_entities.dart';
import '../../application/visits_controller.dart';
import '../../domain/entities/visit_entities.dart';

/// EN: Visit statistics page widget — premium dashboard.
/// KO: 방문 통계 페이지 위젯 — 프리미엄 대시보드.
class VisitStatsPage extends ConsumerStatefulWidget {
  const VisitStatsPage({super.key});

  @override
  ConsumerState<VisitStatsPage> createState() => _VisitStatsPageState();
}

class _VisitStatsPageState extends ConsumerState<VisitStatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userVisitsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitsState = ref.watch(userVisitsControllerProvider);
    final placesMapState = ref.watch(visitPlacesMapProvider);
    final rankingState = ref.watch(userRankingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 통계'),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.history_rounded,
            tooltip: '방문 기록',
            onPressed: () => context.goToVisitHistory(),
          ),
        ],
      ),
      body: visitsState.when(
        loading: () =>
            const Center(child: GBTLoading(message: '통계를 불러오는 중...')),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '통계를 불러오지 못했습니다.';
          return _StatsEmptyState(
            message: message,
            onRetry: () {
              ref
                  .read(userVisitsControllerProvider.notifier)
                  .load(forceRefresh: true);
            },
          );
        },
        data: (visits) {
          if (visits.isEmpty) {
            return const _StatsEmptyState(
              message: '아직 통계가 없습니다.\n장소를 방문하면 통계가 생성됩니다.',
            );
          }

          final stats = _VisitStats.fromVisits(visits);
          final placesLoading = placesMapState is AsyncLoading;
          final placeMap =
              placesMapState.valueOrNull ?? const <String, PlaceSummary>{};

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userRankingProvider);
              await ref
                  .read(userVisitsControllerProvider.notifier)
                  .load(forceRefresh: true);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // EN: [0] Ranking banner
                // KO: [0] 랭킹 배너
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      GBTSpacing.pageHorizontal,
                      GBTSpacing.sm,
                      GBTSpacing.pageHorizontal,
                      GBTSpacing.md,
                    ),
                    child: _RankingBanner(rankingState: rankingState),
                  ),
                ),

                // EN: [1] Stat cards grid
                // KO: [1] 통계 카드 그리드
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.pageHorizontal,
                  ),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: GBTSpacing.sm,
                    crossAxisSpacing: GBTSpacing.sm,
                    childAspectRatio: 1.6,
                    children: [
                      _StatCard(
                        icon: Icons.check_circle_rounded,
                        title: '총 방문',
                        value: '${stats.totalVisits}',
                        unit: '회',
                        color: GBTColors.primary,
                      ),
                      _StatCard(
                        icon: Icons.place_rounded,
                        title: '방문 장소',
                        value: '${stats.uniquePlaces}',
                        unit: '곳',
                        color: GBTColors.accentTeal,
                      ),
                      _StatCard(
                        icon: Icons.flag_rounded,
                        title: '첫 방문',
                        value: stats.firstVisitLabel,
                        color: const Color(0xFF6366F1),
                      ),
                      _StatCard(
                        icon: Icons.update_rounded,
                        title: '최근 방문',
                        value: stats.lastVisitLabel,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),

                // EN: [2] Top places section header
                // KO: [2] 자주 방문한 장소 섹션 헤더
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          GBTSpacing.pageHorizontal,
                          GBTSpacing.xl,
                          GBTSpacing.pageHorizontal,
                          GBTSpacing.xs,
                        ),
                        child: Text(
                          '자주 방문한 장소',
                          style: GBTTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // EN: [3] Top places list
                // KO: [3] 자주 방문한 장소 목록
                if (stats.topPlaces.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.pageHorizontal,
                      ),
                      child: Text(
                        '표시할 방문 기록이 없습니다.',
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.pageHorizontal,
                    ),
                    sliver: SliverList.separated(
                      itemCount: stats.topPlaces.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: GBTSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = stats.topPlaces[index];
                        final placeFound = placeMap.containsKey(item.placeId);
                        final showLoading = placesLoading && !placeFound;
                        final place = placeMap[item.placeId];

                        return _TopPlaceCard(
                          rank: index + 1,
                          place: place,
                          visitCount: item.count,
                          isLoading: showLoading,
                          onTap: () => context.goToPlaceDetail(item.placeId),
                        );
                      },
                    ),
                  ),

                // EN: Bottom safe area
                // KO: 하단 안전 영역
                SliverToBoxAdapter(
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + GBTSpacing.xl,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Ranking banner with gradient background
// KO: 그라디언트 배경의 랭킹 배너
// ---------------------------------------------------------------------------

class _RankingBanner extends StatelessWidget {
  const _RankingBanner({required this.rankingState});

  final AsyncValue<UserRanking?> rankingState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return rankingState.when(
      loading: () => GBTShimmer(
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isDark
                ? GBTColors.darkSurfaceVariant
                : GBTColors.surfaceVariant,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (ranking) {
        if (ranking == null) return const SizedBox.shrink();
        return _buildBanner(ranking, isDark);
      },
    );
  }

  Widget _buildBanner(UserRanking ranking, bool isDark) {
    final percentage = ranking.totalUsers > 0
        ? ((ranking.rank / ranking.totalUsers) * 100).toStringAsFixed(0)
        : '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
        border: Border.all(
          color: isDark ? GBTColors.darkBorder : GBTColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // EN: Rank circle
          // KO: 순위 원형
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkPrimary.withValues(alpha: 0.15)
                  : GBTColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${ranking.rank}',
                  style: GBTTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                    height: 1,
                  ),
                ),
                Text(
                  '등',
                  style: GBTTypography.labelSmall.copyWith(
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: GBTSpacing.md),

          // EN: Rank info
          // KO: 순위 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내 순위',
                  style: GBTTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '전체 ${ranking.totalUsers}명 중 상위 $percentage%',
                  style: GBTTypography.bodySmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                // EN: Progress bar showing rank position
                // KO: 순위 위치를 보여주는 진행 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: ranking.totalUsers > 0
                        ? 1 - (ranking.rank / ranking.totalUsers)
                        : 0,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? GBTColors.darkSurfaceVariant
                        : GBTColors.surfaceVariant,
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: GBTSpacing.sm),
          Icon(
            Icons.emoji_events_rounded,
            color: const Color(0xFFF59E0B),
            size: 32,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Stat card with colored accent
// KO: 색상 악센트가 있는 통계 카드
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.unit,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: unit != null ? '$title: $value$unit' : '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(GBTSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          border: Border.all(
            color: isDark ? GBTColors.darkBorder : GBTColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GBTTypography.labelSmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: GBTTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit != null)
                      Text(
                        unit!,
                        style: GBTTypography.bodySmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextSecondary
                              : GBTColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Top place card with rank badge, image, and visit bar
// KO: 순위 배지, 이미지, 방문 바가 있는 상위 장소 카드
// ---------------------------------------------------------------------------

class _TopPlaceCard extends StatelessWidget {
  const _TopPlaceCard({
    required this.rank,
    required this.place,
    required this.visitCount,
    required this.isLoading,
    required this.onTap,
  });

  final int rank;
  final PlaceSummary? place;
  final int visitCount;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeName = place?.name ?? '장소 정보 없음';
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Semantics(
      label: isLoading
          ? '장소 이름 로딩 중, 방문 $visitCount회'
          : '$placeName, 방문 $visitCount회',
      button: true,
      child: Material(
        color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
            padding: const EdgeInsets.all(GBTSpacing.sm),
            child: Row(
              children: [
                // EN: Rank badge
                // KO: 순위 배지
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _rankColor(rank).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: GBTTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _rankColor(rank),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),

                // EN: Place thumbnail
                // KO: 장소 썸네일
                ClipRRect(
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: _buildThumbnail(isDark),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),

                // EN: Place info
                // KO: 장소 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        GBTShimmer(
                          child: Container(
                            height: 14,
                            width: 100,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? GBTColors.darkSurfaceVariant
                                  : GBTColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        )
                      else
                        Text(
                          placeName,
                          style: GBTTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '방문 $visitCount회',
                        style: GBTTypography.bodySmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextSecondary
                              : GBTColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    if (place?.imageUrl != null && place!.imageUrl!.isNotEmpty) {
      return GBTImage(
        imageUrl: place!.imageUrl!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        semanticLabel: '${place!.name} 썸네일',
      );
    }
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.place_rounded,
          size: 20,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFF59E0B), // gold
      2 => const Color(0xFF94A3B8), // silver
      3 => const Color(0xFFCD7F32), // bronze
      _ => GBTColors.primary,
    };
  }
}

// ---------------------------------------------------------------------------
// EN: Visit stats computation
// KO: 방문 통계 계산
// ---------------------------------------------------------------------------

class _VisitStats {
  const _VisitStats({
    required this.totalVisits,
    required this.uniquePlaces,
    required this.firstVisit,
    required this.lastVisit,
    required this.topPlaces,
  });

  final int totalVisits;
  final int uniquePlaces;
  final DateTime? firstVisit;
  final DateTime? lastVisit;
  final List<_PlaceCount> topPlaces;

  String get firstVisitLabel => _formatDate(firstVisit);
  String get lastVisitLabel => _formatDate(lastVisit);

  static _VisitStats fromVisits(List<VisitEvent> visits) {
    final totalVisits = visits.length;
    final placeCounts = <String, int>{};
    DateTime? firstVisit;
    DateTime? lastVisit;

    for (final visit in visits) {
      placeCounts.update(
        visit.placeId,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      final visitedAt = visit.visitedAt;
      if (visitedAt == null) continue;
      if (firstVisit == null || visitedAt.isBefore(firstVisit)) {
        firstVisit = visitedAt;
      }
      if (lastVisit == null || visitedAt.isAfter(lastVisit)) {
        lastVisit = visitedAt;
      }
    }

    final topPlaces =
        placeCounts.entries
            .map((entry) => _PlaceCount(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));

    return _VisitStats(
      totalVisits: totalVisits,
      uniquePlaces: placeCounts.length,
      firstVisit: firstVisit,
      lastVisit: lastVisit,
      topPlaces: topPlaces.take(5).toList(),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy.MM.dd').format(date.toLocal());
  }
}

class _PlaceCount {
  const _PlaceCount(this.placeId, this.count);

  final String placeId;
  final int count;
}

// ---------------------------------------------------------------------------
// EN: Empty state
// KO: 빈 상태
// ---------------------------------------------------------------------------

class _StatsEmptyState extends StatelessWidget {
  const _StatsEmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(
          Icons.bar_chart_rounded,
          size: 64,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GBTTypography.bodyLarge.copyWith(
            color: isDark
                ? GBTColors.darkTextSecondary
                : GBTColors.textSecondary,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: GBTSpacing.lg),
          Center(
            child: FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ),
        ],
      ],
    );
  }
}
