/// EN: Visit history page — Timeline-style cards with image previews.
/// KO: 방문 기록 페이지 — 이미지 프리뷰가 있는 타임라인 스타일 카드.
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
import '../../../../core/widgets/layout/gbt_page_intro_card.dart';
import '../../../places/domain/entities/place_entities.dart';
import '../../application/visits_controller.dart';
import '../../domain/entities/visit_entities.dart';

/// EN: Visit history page widget — premium timeline design.
/// KO: 방문 기록 페이지 위젯 — 프리미엄 타임라인 디자인.
class VisitHistoryPage extends ConsumerStatefulWidget {
  const VisitHistoryPage({super.key});

  @override
  ConsumerState<VisitHistoryPage> createState() => _VisitHistoryPageState();
}

class _VisitHistoryPageState extends ConsumerState<VisitHistoryPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: '통계',
            onPressed: () => context.goToVisitStats(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(userVisitsControllerProvider.notifier)
            .load(forceRefresh: true),
        child: visitsState.when(
          loading: () =>
              const Center(child: GBTLoading(message: '방문 기록을 불러오는 중...')),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : '방문 기록을 불러오지 못했습니다.';
            return _VisitEmptyState(
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
              return const _VisitEmptyState(
                message: '아직 방문 기록이 없습니다.\n장소를 방문하고 인증해보세요!',
              );
            }

            final sorted = [...visits]..sort((a, b) => _compareVisitedAt(b, a));
            final placesLoading = placesMapState is AsyncLoading;
            final placeMap =
                placesMapState.valueOrNull ?? const <String, PlaceSummary>{};

            // EN: Group visits by month for timeline sections.
            // KO: 타임라인 섹션을 위해 방문을 월별로 그룹화합니다.
            final grouped = _groupByMonth(sorted);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      GBTSpacing.pageHorizontal,
                      GBTSpacing.sm,
                      GBTSpacing.pageHorizontal,
                      GBTSpacing.sm,
                    ),
                    child: GBTPageIntroCard(
                      icon: Icons.history_rounded,
                      title: '방문 타임라인',
                      description: '월별 방문 기록과 장소 인증 이력을 확인하세요.',
                      trailing: _HistoryCountBadge(count: sorted.length),
                    ),
                  ),
                ),
                // EN: Summary header card
                // KO: 요약 헤더 카드
                SliverToBoxAdapter(
                  child: _SummaryHeader(
                    totalVisits: sorted.length,
                    uniquePlaces: sorted.map((v) => v.placeId).toSet().length,
                  ),
                ),

                for (final entry in grouped.entries) ...[
                  // EN: Month section header
                  // KO: 월별 섹션 헤더
                  SliverToBoxAdapter(child: _MonthHeader(label: entry.key)),

                  // EN: Visit cards for this month
                  // KO: 이 달의 방문 카드
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.pageHorizontal,
                    ),
                    sliver: SliverList.separated(
                      itemCount: entry.value.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: GBTSpacing.sm),
                      itemBuilder: (context, index) {
                        final visit = entry.value[index];
                        final placeFound = placeMap.containsKey(visit.placeId);
                        final place = placeMap[visit.placeId];
                        final showLoading = placesLoading && !placeFound;

                        return _VisitCard(
                          visit: visit,
                          place: place,
                          isLoading: showLoading,
                          onTap: () => context.goToVisitDetail(
                            visitId: visit.id,
                            placeId: visit.placeId,
                            visitedAt: visit.visitedAt?.toIso8601String(),
                            latitude: visit.latitude,
                            longitude: visit.longitude,
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: GBTSpacing.md),
                  ),
                ],

                // EN: Bottom safe area
                // KO: 하단 안전 영역
                SliverToBoxAdapter(
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).padding.bottom + GBTSpacing.lg,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _compareVisitedAt(VisitEvent a, VisitEvent b) {
    final aDate = a.visitedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.visitedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aDate.compareTo(bDate);
  }

  Map<String, List<VisitEvent>> _groupByMonth(List<VisitEvent> visits) {
    final grouped = <String, List<VisitEvent>>{};
    for (final visit in visits) {
      final dt = visit.visitedAt;
      final key = dt != null ? '${dt.year}년 ${dt.month}월' : '날짜 미상';
      grouped.putIfAbsent(key, () => []).add(visit);
    }
    return grouped;
  }
}

class _HistoryCountBadge extends StatelessWidget {
  const _HistoryCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurface : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        '$count건',
        style: GBTTypography.labelSmall.copyWith(
          color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Summary header with total visits and unique places
// KO: 총 방문 및 고유 장소 요약 헤더
// ---------------------------------------------------------------------------

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.totalVisits, required this.uniquePlaces});

  final int totalVisits;
  final int uniquePlaces;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.sm,
        GBTSpacing.pageHorizontal,
        GBTSpacing.md,
      ),
      padding: const EdgeInsets.all(GBTSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [GBTColors.darkSurfaceElevated, GBTColors.darkSurfaceVariant]
              : [
                  GBTColors.primaryLight,
                  GBTColors.primary.withValues(alpha: 0.08),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.check_circle_rounded,
              label: '총 방문',
              value: '$totalVisits회',
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark
                ? GBTColors.darkBorder
                : GBTColors.primary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.place_rounded,
              label: '방문 장소',
              value: '$uniquePlaces곳',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
        ),
        const SizedBox(height: GBTSpacing.xs),
        Text(
          value,
          style: GBTTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GBTTypography.bodySmall.copyWith(
            color: isDark
                ? GBTColors.darkTextSecondary
                : GBTColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Month section header
// KO: 월별 섹션 헤더
// ---------------------------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.xs,
        GBTSpacing.pageHorizontal,
        GBTSpacing.sm,
      ),
      child: Text(
        label,
        style: GBTTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Visit card with image, place name, date, and chevron
// KO: 이미지, 장소 이름, 날짜, 화살표가 있는 방문 카드
// ---------------------------------------------------------------------------

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.visit,
    required this.place,
    required this.isLoading,
    required this.onTap,
  });

  final VisitEvent visit;
  final PlaceSummary? place;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeName = place?.name ?? '장소 정보 없음';

    return Semantics(
      label: isLoading
          ? '방문 기록: 장소 이름 로딩 중, ${visit.visitedAtLabel}'
          : '방문 기록: $placeName, ${visit.visitedAtLabel}',
      button: true,
      child: Material(
        color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 88,
            child: Row(
              children: [
                // EN: Place thumbnail
                // KO: 장소 썸네일
                SizedBox(width: 88, height: 88, child: _buildThumbnail(isDark)),

                // EN: Visit info
                // KO: 방문 정보
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.md,
                      vertical: GBTSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // EN: Place name
                        // KO: 장소 이름
                        if (isLoading)
                          _buildShimmer(isDark)
                        else
                          Text(
                            placeName,
                            style: GBTTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? GBTColors.darkTextPrimary
                                  : GBTColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: GBTSpacing.xxs),

                        // EN: Visit date
                        // KO: 방문 날짜
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: isDark
                                  ? GBTColors.darkTextTertiary
                                  : GBTColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              visit.visitedAtLabel.isNotEmpty
                                  ? visit.visitedAtLabel
                                  : '-',
                              style: GBTTypography.bodySmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextSecondary
                                    : GBTColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        // EN: Location info
                        // KO: 위치 정보
                        if (place != null && place!.address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isDark
                                    ? GBTColors.darkPrimary
                                    : GBTColors.accentTeal,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place!.address,
                                  style: GBTTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? GBTColors.darkTextTertiary
                                        : GBTColors.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // EN: Chevron
                // KO: 화살표
                Padding(
                  padding: const EdgeInsets.only(right: GBTSpacing.sm),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary,
                  ),
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
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        semanticLabel: '${place!.name} 썸네일',
      );
    }
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.primaryLight,
      child: Center(
        child: Icon(
          Icons.place_rounded,
          size: 32,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.primaryMuted,
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return GBTShimmer(
      child: Container(
        height: 16,
        width: 120,
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Empty state
// KO: 빈 상태
// ---------------------------------------------------------------------------

class _VisitEmptyState extends StatelessWidget {
  const _VisitEmptyState({required this.message, this.onRetry});

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
          Icons.explore_outlined,
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
