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

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: visitsState.when(
        loading: () => const Center(
          child: GBTLoading(message: '통계를 불러오는 중...'),
        ),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '통계를 불러오지 못했습니다.';
          return _StatsEmptyState(
            message: message,
            onRetry: () {
              ref.read(userVisitsControllerProvider.notifier).load(
                    forceRefresh: true,
                  );
            },
          );
        },
        data: (visits) {
          if (visits.isEmpty) {
            return const _StatsEmptyState(message: '아직 통계가 없습니다.');
          }

          final stats = _VisitStats.fromVisits(visits);
          final placeMap =
              placesMapState.valueOrNull ?? const <String, PlaceSummary>{};

          return ListView(
            padding: GBTSpacing.paddingPage,
            children: [
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
                    color: GBTColors.textSecondary,
                  ),
                )
              else
                Column(
                  children: stats.topPlaces
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _resolvePlaceName(placeMap, item.placeId),
                          ),
                          subtitle: Text(
                            '방문 ${item.count}회',
                            style: GBTTypography.bodySmall.copyWith(
                              color: GBTColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.goToPlaceDetail(item.placeId),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  String _resolvePlaceName(Map<String, PlaceSummary> placeMap, String placeId) {
    final place = placeMap[placeId];
    if (place == null) return placeId;
    return place.name;
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
      placeCounts.update(visit.placeId, (value) => value + 1, ifAbsent: () => 1);
      final visitedAt = visit.visitedAt;
      if (visitedAt == null) continue;
      if (firstVisit == null || visitedAt.isBefore(firstVisit)) {
        firstVisit = visitedAt;
      }
      if (lastVisit == null || visitedAt.isAfter(lastVisit)) {
        lastVisit = visitedAt;
      }
    }

    final topPlaces = placeCounts.entries
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
    return Container(
      width: (MediaQuery.of(context).size.width - GBTSpacing.lg * 2 -
              GBTSpacing.sm) /
          2,
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: GBTColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GBTColors.accent),
          const SizedBox(height: GBTSpacing.sm),
          Text(
            title,
            style: GBTTypography.bodySmall.copyWith(
              color: GBTColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsEmptyState extends StatelessWidget {
  const _StatsEmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        const SizedBox(height: GBTSpacing.xl),
        Icon(Icons.bar_chart, size: 48, color: GBTColors.textTertiary),
        const SizedBox(height: GBTSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GBTTypography.bodyMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
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
