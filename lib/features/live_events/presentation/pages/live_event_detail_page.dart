/// EN: Live event detail page with info and verification
/// KO: 정보 및 인증을 포함한 라이브 이벤트 상세 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_animations.dart';
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
    // EN: Expand header height so portrait posters can be shown without crop.
    // KO: 세로형 포스터를 잘리지 않게 보여주기 위해 헤더 높이를 늘립니다.
    final posterExpandedHeight = (MediaQuery.sizeOf(context).width * 1.45)
        .clamp(300.0, 620.0);
    final topInset = MediaQuery.paddingOf(context).top;
    // EN: Push poster down slightly so status-bar area remains visually clean.
    // KO: 상태바 영역이 덜 가려지도록 포스터를 약간 아래로 내립니다.
    final posterTopOffset = topInset + GBTSpacing.lg2;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final surfaceVariantColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final posterBackgroundTop = isDark
        ? const Color(0xFF1A1D22)
        : const Color(0xFFF2F4F7);
    final posterBackgroundBottom = isDark
        ? const Color(0xFF121418)
        : const Color(0xFFE8ECF3);
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
        expandedHeight: posterExpandedHeight,
        pinned: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: GBTSpacing.xs),
          child: _OverlayIconButton(
            tooltip: '뒤로 가기',
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: event.bannerUrl != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // EN: Neutral gradient background for letterbox area.
                    // KO: 레터박스 영역은 중립 그라데이션 배경으로 처리합니다.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [posterBackgroundTop, posterBackgroundBottom],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        GBTSpacing.md,
                        posterTopOffset,
                        GBTSpacing.md,
                        GBTSpacing.lg,
                      ),
                      child: Hero(
                        tag: GBTHeroTags.eventPoster(event.id),
                        child: GBTImage(
                          imageUrl: event.bannerUrl!,
                          fit: BoxFit.contain,
                          semanticLabel: '${event.title} 포스터',
                        ),
                      ),
                    ),
                    // EN: Keep top controls readable on bright posters.
                    // KO: 밝은 포스터에서도 상단 컨트롤 가독성을 유지합니다.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Color(0x66000000),
                            Color(0x22000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: surfaceVariantColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          // EN: Neutral icon color for placeholder
                          // KO: 플레이스홀더용 뉴트럴 아이콘 색상
                          color: isDark
                              ? GBTColors.darkTextTertiary
                              : GBTColors.textTertiary,
                        ),
                        const SizedBox(height: GBTSpacing.md),
                        Text(
                          '이벤트 포스터',
                          style: GBTTypography.bodyMedium.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        actions: [
          _OverlayIconButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            tooltip: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
            onPressed: () => ref
                .read(favoritesControllerProvider.notifier)
                .toggleFavorite(
                  entityId: event.id,
                  type: FavoriteType.liveEvent,
                  isCurrentlyFavorite: isFavorite,
                ),
          ),
          _OverlayIconButton(
            icon: Icons.share,
            tooltip: '이벤트 공유',
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
              Text(
                event.title,
                style: GBTTypography.headlineSmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: GBTSpacing.xs),
              Text(
                event.status,
                style: GBTTypography.titleMedium.copyWith(
                  // EN: Neutral secondary color for status text
                  // KO: 상태 텍스트에 뉴트럴 보조 색상
                  color: secondaryColor,
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
                style: GBTTypography.bodyMedium.copyWith(color: secondaryColor),
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
                  color: surfaceVariantColor,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
                child: Text(
                  event.ticketUrl ?? '티켓 정보가 없습니다',
                  style: GBTTypography.bodyMedium.copyWith(
                    color: secondaryColor,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
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

/// EN: Header icon button with readability backdrop.
/// KO: 가독성 배경이 있는 헤더 아이콘 버튼.
class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0x5C000000),
        minimumSize: const Size(38, 38),
        padding: const EdgeInsets.all(8),
      ),
      icon: Icon(icon),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final surfaceVariantColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;

    return Semantics(
      label: '$label: $value',
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: surfaceVariantColor,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
            child: Icon(icon, color: secondaryColor, size: 20),
          ),
          const SizedBox(width: GBTSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(
                    color: tertiaryColor,
                  ),
                ),
                Text(
                  value,
                  style: GBTTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
