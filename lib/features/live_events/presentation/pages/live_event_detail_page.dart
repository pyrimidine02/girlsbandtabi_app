/// EN: Live event detail page with info and verification
/// KO: 정보 및 인증을 포함한 라이브 이벤트 상세 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../favorites/application/favorites_controller.dart';
import '../../../favorites/domain/entities/favorite_entities.dart';
import '../../../verification/application/verification_controller.dart';
import '../../../verification/presentation/widgets/verification_sheet.dart';
import '../../application/live_events_controller.dart';
import '../../domain/entities/live_event_entities.dart';

/// EN: Live event detail page widget
/// KO: 라이브 이벤트 상세 페이지 위젯
class LiveEventDetailPage extends ConsumerWidget {
  const LiveEventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveEventDetailControllerProvider(eventId));

    return Scaffold(
      body: CustomScrollView(
        slivers: state.when(
          loading: () => [
            const SliverFillRemaining(
              child: Center(child: GBTLoading(message: '라이브 정보를 불러오는 중...')),
            ),
          ],
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : '라이브 정보를 불러오지 못했어요';
            return [
              SliverFillRemaining(
                child: Center(
                  child: GBTErrorState(
                    message: message,
                    onRetry: () => ref
                        .read(
                          liveEventDetailControllerProvider(eventId).notifier,
                        )
                        .load(forceRefresh: true),
                  ),
                ),
              ),
            ];
          },
          data: (event) => _buildContent(context, ref, event),
        ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    WidgetRef ref,
    LiveEventDetail event,
  ) {
    final favoritesState = ref.watch(favoritesControllerProvider);
    final isFavorite = favoritesState.maybeWhen(
      data: (items) => items.any(
        (item) =>
            item.entityId == event.id && item.type == FavoriteType.liveEvent,
      ),
      orElse: () => false,
    );

    return [
      SliverAppBar(
        expandedHeight: 300,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: event.bannerUrl != null
              ? GBTImage(
                  imageUrl: event.bannerUrl!,
                  fit: BoxFit.cover,
                  semanticLabel: event.title,
                )
              : Container(
                  color: GBTColors.surfaceVariant,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: GBTColors.accent,
                        ),
                        const SizedBox(height: GBTSpacing.md),
                        Text(
                          '이벤트 포스터',
                          style: GBTTypography.bodyMedium.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => ref
                .read(favoritesControllerProvider.notifier)
                .toggleFavorite(
                  entityId: event.id,
                  type: FavoriteType.liveEvent,
                  isCurrentlyFavorite: isFavorite,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // EN: TODO: Share event
              // KO: TODO: 이벤트 공유
            },
          ),
        ],
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: GBTSpacing.paddingPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: GBTTypography.headlineSmall),
              const SizedBox(height: GBTSpacing.xs),
              Text(
                event.status,
                style: GBTTypography.titleMedium.copyWith(
                  color: GBTColors.accent,
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              _InfoRow(
                icon: Icons.calendar_today,
                label: '날짜',
                value: '${event.dateLabel} · ${event.dDayLabel}',
              ),
              const SizedBox(height: GBTSpacing.sm),
              _InfoRow(
                icon: Icons.access_time,
                label: '시간',
                value: '개장 ${event.doorTimeLabel} / 시작 ${event.timeLabel}',
              ),
              const SizedBox(height: GBTSpacing.sm),
              _InfoRow(
                icon: Icons.info_outline,
                label: '대상',
                value: event.metaLabel,
              ),
              const SizedBox(height: GBTSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    _showVerificationSheet(context, ref, event.id);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('참석 인증하기'),
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              const Divider(),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '공연 정보',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                event.description ?? '공연 정보가 없습니다.',
                style: GBTTypography.bodyMedium.copyWith(
                  color: GBTColors.textSecondary,
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '티켓',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Container(
                padding: GBTSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: GBTColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
                child: Text(
                  event.ticketUrl ?? '티켓 정보가 없습니다',
                  style: GBTTypography.bodyMedium.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: GBTSpacing.xxl),
            ],
          ),
        ),
      ),
    ];
  }
}

/// EN: Info row widget
/// KO: 정보 행 위젯
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: GBTColors.surfaceVariant,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          ),
          child: Icon(icon, color: GBTColors.textSecondary, size: 20),
        ),
        const SizedBox(width: GBTSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GBTTypography.labelSmall.copyWith(
                  color: GBTColors.textTertiary,
                ),
              ),
              Text(value, style: GBTTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

void _showVerificationSheet(
  BuildContext context,
  WidgetRef ref,
  String eventId,
) {
  ref.read(verificationControllerProvider.notifier).reset();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => VerificationSheet(
      title: '참석 인증',
      description: '현장에 도착했는지 확인하여 참석 인증을 진행합니다.',
      onVerify: () => ref
          .read(verificationControllerProvider.notifier)
          .verifyLiveEvent(eventId, verificationMethod: 'MANUAL'),
    ),
  );
}
