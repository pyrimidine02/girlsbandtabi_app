/// EN: Visit history page — Timeline-style cards with image previews.
/// KO: 방문 기록 페이지 — 이미지 프리뷰가 있는 타임라인 스타일 카드.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../places/domain/entities/place_entities.dart';
import '../../../live_events/presentation/pages/live_attendance_history_page.dart';
import '../../application/visits_controller.dart';
import '../../domain/entities/visit_entities.dart';

/// EN: Visit history page widget — premium timeline design.
/// KO: 방문 기록 페이지 위젯 — 프리미엄 타임라인 디자인.
enum VisitHistoryTab { places, live }

class VisitHistoryPage extends ConsumerStatefulWidget {
  const VisitHistoryPage({super.key, this.initialTab = VisitHistoryTab.places});

  final VisitHistoryTab initialTab;

  @override
  ConsumerState<VisitHistoryPage> createState() => _VisitHistoryPageState();
}

class _VisitHistoryPageState extends ConsumerState<VisitHistoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userVisitsControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitsState = ref.watch(userVisitsControllerProvider);
    final placesMapState = ref.watch(visitPlacesMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n(ko: '방문 기록', en: 'Visit history', ja: '訪問履歴')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: context.l10n(ko: '장소', en: 'Places', ja: '場所'),
            ),
            Tab(
              text: context.l10n(ko: '라이브', en: 'Live', ja: 'ライブ'),
            ),
          ],
        ),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.bar_chart_rounded,
            tooltip: context.l10n(ko: '통계', en: 'Stats', ja: '統計'),
            onPressed: () => context.goToVisitStats(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlaceHistoryBody(context, visitsState, placesMapState),
          const LiveAttendanceHistoryBody(),
        ],
      ),
    );
  }

  Widget _buildPlaceHistoryBody(
    BuildContext context,
    AsyncValue<List<VisitEvent>> visitsState,
    AsyncValue<Map<String, PlaceSummary>> placesMapState,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref
          .read(userVisitsControllerProvider.notifier)
          .load(forceRefresh: true),
      child: visitsState.when(
        loading: () => Center(
          child: GBTLoading(
            message: context.l10n(
              ko: '방문 기록을 불러오는 중...',
              en: 'Loading visit history...',
              ja: '訪問履歴を読み込み中...',
            ),
          ),
        ),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : context.l10n(
                  ko: '방문 기록을 불러오지 못했습니다.',
                  en: 'Could not load visit history.',
                  ja: '訪問履歴を読み込めませんでした。',
                );
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
            return _VisitEmptyState(
              message: context.l10n(
                ko: '아직 방문 기록이 없습니다.\n장소를 방문하고 인증해보세요!',
                en: 'No visit history yet.\nVisit a place and verify your visit!',
                ja: 'まだ訪問履歴がありません。\n場所を訪問して認証してみましょう！',
              ),
            );
          }

          final sorted = [...visits]..sort((a, b) => _compareVisitedAt(b, a));
          final placesLoading = placesMapState is AsyncLoading;
          final placeMap =
              placesMapState.valueOrNull ?? const <String, PlaceSummary>{};

          // EN: Group visits by month for timeline sections.
          // KO: 타임라인 섹션을 위해 방문을 월별로 그룹화합니다.
          final grouped = _groupByMonth(sorted, context);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
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
                  height: MediaQuery.of(context).padding.bottom + GBTSpacing.lg,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _compareVisitedAt(VisitEvent a, VisitEvent b) {
    final aDate = a.visitedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.visitedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aDate.compareTo(bDate);
  }

  Map<String, List<VisitEvent>> _groupByMonth(
    List<VisitEvent> visits,
    BuildContext context,
  ) {
    final grouped = <String, List<VisitEvent>>{};
    for (final visit in visits) {
      final dt = visit.visitedAt;
      final key = dt != null
          ? context.l10n(
              ko: '${dt.year}년 ${dt.month}월',
              en: '${dt.year}-${dt.month.toString().padLeft(2, '0')}',
              ja: '${dt.year}年${dt.month}月',
            )
          : context.l10n(ko: '날짜 미상', en: 'Unknown date', ja: '日付不明');
      grouped.putIfAbsent(key, () => []).add(visit);
    }
    return grouped;
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
        color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
        border: Border.all(
          color: isDark ? GBTColors.darkBorder : GBTColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.check_circle_rounded,
              label: context.l10n(ko: '총 방문', en: 'Total visits', ja: '総訪問'),
              value: context.l10n(
                ko: '$totalVisits회',
                en: '$totalVisits',
                ja: '$totalVisits回',
              ),
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
              label: context.l10n(
                ko: '방문 장소',
                en: 'Visited places',
                ja: '訪問場所',
              ),
              value: context.l10n(
                ko: '$uniquePlaces곳',
                en: '$uniquePlaces',
                ja: '$uniquePlacesか所',
              ),
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
        GBTSpacing.md,
        GBTSpacing.pageHorizontal,
        GBTSpacing.xs,
      ),
      child: Text(
        label,
        style: GBTTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
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
    final placeName =
        place?.name ??
        context.l10n(ko: '장소 정보 없음', en: 'No place info', ja: '場所情報なし');
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Semantics(
      label: isLoading
          ? context.l10n(
              ko: '방문 기록: 장소 이름 로딩 중, ${visit.visitedAtLabel}',
              en: 'Visit record: loading place name, ${visit.visitedAtLabel}',
              ja: '訪問記録: 場所名読み込み中, ${visit.visitedAtLabel}',
            )
          : context.l10n(
              ko: '방문 기록: $placeName, ${visit.visitedAtLabel}',
              en: 'Visit record: $placeName, ${visit.visitedAtLabel}',
              ja: '訪問記録: $placeName, ${visit.visitedAtLabel}',
            ),
      button: true,
      child: Material(
        color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
            child: Row(
              children: [
                // EN: Place thumbnail
                // KO: 장소 썸네일
                SizedBox(
                  width: 88,
                  height: 88,
                  child: _buildThumbnail(context, isDark),
                ),

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
                                    ? GBTColors.darkTextTertiary
                                    : GBTColors.textTertiary,
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

  Widget _buildThumbnail(BuildContext context, bool isDark) {
    if (place?.imageUrl != null && place!.imageUrl!.isNotEmpty) {
      return GBTImage(
        imageUrl: place!.imageUrl!,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        semanticLabel: context.l10n(
          ko: '${place!.name} 썸네일',
          en: '${place!.name} thumbnail',
          ja: '${place!.name} サムネイル',
        ),
      );
    }
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.place_rounded,
          size: 32,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
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
              child: Text(context.l10n(ko: '다시 시도', en: 'Retry', ja: '再試行')),
            ),
          ),
        ],
      ],
    );
  }
}
