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
      appBar: AppBar(title: const Text('방문 기록')),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(userVisitsControllerProvider.notifier)
            .load(forceRefresh: true),
        child: visitsState.when(
          loading: () => const Center(
            child: GBTLoading(message: '방문 기록을 불러오는 중...'),
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : '방문 기록을 불러오지 못했습니다.';
            return _VisitEmptyState(message: message, onRetry: () {
              ref.read(userVisitsControllerProvider.notifier).load(
                    forceRefresh: true,
                  );
            });
          },
          data: (visits) {
            if (visits.isEmpty) {
              return const _VisitEmptyState(
                message: '아직 방문 기록이 없습니다.',
              );
            }

            final sorted = [...visits]
              ..sort((a, b) => _compareVisitedAt(b, a));
            final placeMap =
                placesMapState.valueOrNull ?? const <String, PlaceSummary>{};

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final visit = sorted[index];
                final placeName = _resolvePlaceName(placeMap, visit.placeId);
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(placeName),
                  subtitle: Text(
                    visit.visitedAtLabel,
                    style: GBTTypography.bodySmall.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goToPlaceDetail(visit.placeId),
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

  String _resolvePlaceName(Map<String, PlaceSummary> placeMap, String placeId) {
    final place = placeMap[placeId];
    if (place == null) return placeId;
    return place.name;
  }
}

class _VisitEmptyState extends StatelessWidget {
  const _VisitEmptyState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        const SizedBox(height: GBTSpacing.xl),
        Icon(Icons.check_circle, size: 48, color: GBTColors.textTertiary),
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
