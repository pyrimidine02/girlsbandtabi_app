/// EN: Visit history page.
/// KO: 방문 기록 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../places/domain/entities/place_entities.dart';
import '../../application/visits_controller.dart';
import '../../domain/entities/visit_entities.dart';

/// EN: Visit history page widget.
/// KO: 방문 기록 페이지 위젯.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final visitsState = ref.watch(userVisitsControllerProvider);
    final placesMapState = ref.watch(visitPlacesMapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('방문 기록')),
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
                message: '아직 방문 기록이 없습니다.\n장소를 방문하고 인증해보세요.',
              );
            }

            final sorted = [...visits]..sort((a, b) => _compareVisitedAt(b, a));
            final placesLoading = _isPlacesLoading(placesMapState);
            final placeMap =
                placesMapState.valueOrNull ?? const <String, PlaceSummary>{};

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final visit = sorted[index];
                final placeFound = placeMap.containsKey(visit.placeId);
                final placeName = _resolvePlaceName(placeMap, visit.placeId);
                // EN: Show shimmer while places map is loading and name is unresolved.
                // KO: 장소 맵 로딩 중이고 이름이 아직 없으면 shimmer를 표시합니다.
                final showLoading = placesLoading && !placeFound;
                return Semantics(
                  label: showLoading
                      ? '방문 기록: 장소 이름 로딩 중, ${visit.visitedAtLabel}'
                      : '방문 기록: $placeName, ${visit.visitedAtLabel}',
                  button: true,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: showLoading
                        ? _PlaceNameShimmer(isDark: isDark)
                        : Text(
                            placeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    subtitle: Text(
                      visit.visitedAtLabel,
                      style: GBTTypography.bodySmall.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.goToVisitDetail(
                      visitId: visit.id,
                      placeId: visit.placeId,
                      visitedAt: visit.visitedAt?.toIso8601String(),
                      latitude: visit.latitude,
                      longitude: visit.longitude,
                    ),
                  ),
                );
              },
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

  /// EN: Returns true when the places map is still loading.
  /// KO: 장소 맵이 아직 로딩 중이면 true를 반환합니다.
  bool _isPlacesLoading(AsyncValue<Map<String, PlaceSummary>> state) {
    return state is AsyncLoading;
  }

  String _resolvePlaceName(Map<String, PlaceSummary> placeMap, String placeId) {
    final place = placeMap[placeId];
    if (place == null) return '장소 정보 없음';
    return place.name;
  }
}

/// EN: Shimmer placeholder for place name while loading.
/// KO: 장소 이름 로딩 중 shimmer 플레이스홀더.
class _PlaceNameShimmer extends StatelessWidget {
  const _PlaceNameShimmer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: 120,
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
      ),
    );
  }
}

/// EN: Visit empty/error state widget.
/// KO: 방문 빈 상태/오류 상태 위젯.
class _VisitEmptyState extends StatelessWidget {
  const _VisitEmptyState({required this.message, this.onRetry});

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
        Icon(Icons.check_circle_outline, size: 48, color: tertiaryColor),
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
