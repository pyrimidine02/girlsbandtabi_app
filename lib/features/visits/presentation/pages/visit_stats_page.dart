/// EN: Visit statistics page.
/// KO: 방문 통계 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../places/domain/entities/place_entities.dart';
import '../../application/visits_controller.dart';
import '../../domain/entities/visit_entities.dart';

/// EN: Visit statistics page widget.
/// KO: 방문 통계 페이지 위젯.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final visitsState = ref.watch(userVisitsControllerProvider);
    final placesMapState = ref.watch(visitPlacesMapProvider);
    final rankingState = ref.watch(userRankingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
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
            child: ListView(
              padding: GBTSpacing.paddingPage,
              children: [
                _RankingBanner(rankingState: rankingState),
                const SizedBox(height: GBTSpacing.md),
                Wrap(
                  spacing: GBTSpacing.sm,
                  runSpacing: GBTSpacing.sm,
                  children: [
                    _StatCard(
                      icon: Icons.check_circle,
                      title: '총 방문',
                      value: stats.totalVisits.toString(),
                    ),
                    _StatCard(
                      icon: Icons.place,
                      title: '방문 장소',
                      value: stats.uniquePlaces.toString(),
                    ),
                    _StatCard(
                      icon: Icons.flag,
                      title: '첫 방문',
                      value: stats.firstVisitLabel,
                    ),
                    _StatCard(
                      icon: Icons.update,
                      title: '최근 방문',
                      value: stats.lastVisitLabel,
                    ),
                  ],
                ),
                const SizedBox(height: GBTSpacing.lg),
                Text(
                  '자주 방문한 장소',
                  style: GBTTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                if (stats.topPlaces.isEmpty)
                  Text(
                    '표시할 방문 기록이 없습니다.',
                    style: GBTTypography.bodySmall.copyWith(
                      color: secondaryColor,
                    ),
                  )
                else
                  Column(
                    children: stats.topPlaces.map((item) {
                      final placeFound = placeMap.containsKey(item.placeId);
                      final showLoading = placesLoading && !placeFound;
                      final placeName = _resolvePlaceName(
                        placeMap,
                        item.placeId,
                      );
                      return Semantics(
                        label: showLoading
                            ? '장소 이름 로딩 중, 방문 ${item.count}회'
                            : '$placeName, 방문 ${item.count}회',
                        button: true,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: showLoading
                              ? Container(
                                  height: 16,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? GBTColors.darkSurfaceVariant
                                        : GBTColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(
                                      GBTSpacing.radiusXs,
                                    ),
                                  ),
                                )
                              : Text(
                                  placeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          subtitle: Text(
                            '방문 ${item.count}회',
                            style: GBTTypography.bodySmall.copyWith(
                              color: secondaryColor,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.goToPlaceDetail(item.placeId),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _resolvePlaceName(Map<String, PlaceSummary> placeMap, String placeId) {
    final place = placeMap[placeId];
    if (place == null) return '장소 정보 없음';
    return place.name;
  }
}

/// EN: Ranking banner showing user's rank among all users.
/// KO: 전체 사용자 중 내 순위를 보여주는 랭킹 배너.
class _RankingBanner extends StatelessWidget {
  const _RankingBanner({required this.rankingState});

  final AsyncValue<UserRanking?> rankingState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return rankingState.when(
      loading: () => GBTShimmer(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? GBTColors.darkSurfaceVariant
                : GBTColors.surfaceVariant,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (ranking) {
        if (ranking == null) return const SizedBox.shrink();
        return Semantics(
          label: '내 순위 ${ranking.rank}등, 총 ${ranking.totalUsers}명 중',
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    // EN: Use neutral surface for rank circle background.
                    // KO: 순위 원형 배경에 뉴트럴 표면 색상을 사용합니다.
                    color: isDark
                        ? GBTColors.darkSurfaceElevated
                        : GBTColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${ranking.rank}',
                      style: GBTTypography.headlineMedium.copyWith(
                        // EN: Use primary text color for data-focused rank number.
                        // KO: 데이터 중심 순위 번호에 기본 텍스트 색상을 사용합니다.
                        color: isDark
                            ? GBTColors.darkTextPrimary
                            : GBTColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: GBTSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 순위',
                        style: GBTTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '총 ${ranking.totalUsers}명 중 ${ranking.rank}등',
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
                  Icons.emoji_events,
                  // EN: Use neutral icon color for trophy instead of accent.
                  // KO: 트로피 아이콘에 액센트 대신 뉴트럴 색상을 사용합니다.
                  color: isDark
                      ? GBTColors.darkTextSecondary
                      : GBTColors.textSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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

/// EN: Stat card widget with dark mode support.
/// KO: 다크 모드 지원이 포함된 통계 카드 위젯.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Semantics(
      label: '$title: $value',
      child: Container(
        width:
            (MediaQuery.sizeOf(context).width -
                GBTSpacing.lg * 2 -
                GBTSpacing.sm) /
            2,
        padding: const EdgeInsets.all(GBTSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Use neutral icon color for stat cards instead of accent.
            // KO: 통계 카드 아이콘에 액센트 대신 뉴트럴 색상을 사용합니다.
            Icon(
              icon,
              color: isDark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              title,
              style: GBTTypography.bodySmall.copyWith(color: secondaryColor),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GBTTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Stats empty/error state widget.
/// KO: 통계 빈 상태/오류 상태 위젯.
class _StatsEmptyState extends StatelessWidget {
  const _StatsEmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        const SizedBox(height: GBTSpacing.xl),
        Icon(Icons.bar_chart, size: 48, color: tertiaryColor),
        const SizedBox(height: GBTSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GBTTypography.bodyMedium.copyWith(color: secondaryColor),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: GBTSpacing.md),
          Center(
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ),
        ],
      ],
    );
  }
}
