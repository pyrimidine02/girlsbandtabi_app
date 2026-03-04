/// EN: Live event detail page with info and verification
/// KO: 정보 및 인증을 포함한 라이브 이벤트 상세 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariantColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;

    return Scaffold(
      body: CustomScrollView(
        slivers: state.when(
          loading: () {
            // EN: Skeleton loading — matches poster + info card layout.
            // KO: 스켈레톤 로딩 — 포스터 + 정보 카드 레이아웃에 맞춤.
            final posterH = (MediaQuery.sizeOf(context).width * 1.45)
                .clamp(300.0, 620.0);
            return [
              SliverAppBar(
                expandedHeight: posterH,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: GBTSpacing.xs),
                  child: _OverlayIconButton(
                    tooltip: '뒤로 가기',
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: GBTShimmer(
                    child: Container(color: surfaceVariantColor),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: GBTShimmer(
                  child: Padding(
                    padding: GBTSpacing.paddingPage,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GBTShimmerContainer(height: 28, width: 220),
                        const SizedBox(height: GBTSpacing.xs),
                        GBTShimmerContainer(height: 20, width: 80),
                        const SizedBox(height: GBTSpacing.lg),
                        // EN: Info card row skeleton
                        // KO: 정보 카드 행 스켈레톤
                        SizedBox(
                          height: 88,
                          child: Row(
                            children: [
                              Expanded(child: GBTShimmerContainer(height: 88, width: double.infinity)),
                              const SizedBox(width: GBTSpacing.sm),
                              Expanded(child: GBTShimmerContainer(height: 88, width: double.infinity)),
                              const SizedBox(width: GBTSpacing.sm),
                              Expanded(child: GBTShimmerContainer(height: 88, width: double.infinity)),
                            ],
                          ),
                        ),
                        const SizedBox(height: GBTSpacing.lg),
                        GBTShimmerContainer(height: 52, width: double.infinity),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
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
    final posterExpandedHeight = (MediaQuery.sizeOf(context).width * 1.45)
        .clamp(300.0, 620.0);
    final topInset = MediaQuery.paddingOf(context).top;
    final posterTopOffset = topInset + GBTSpacing.lg2;
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

    final isLive = event.status.toLowerCase() == 'live';
    final isUpcoming = event.showStartTime.isAfter(DateTime.now());
    final isDDay = event.dDayLabel == 'D-day';

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
                    // KO: 레터박스 영역은 중립 그라데이션 배경으로 처리.
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
                    // EN: Top gradient for button readability.
                    // KO: 버튼 가독성을 위한 상단 그라데이션.
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
                    // EN: LIVE badge — bottom-left corner, red glow.
                    // KO: LIVE 배지 — 좌하단 모서리, 빨간 글로우.
                    if (isLive)
                      Positioned(
                        bottom: GBTSpacing.md,
                        left: GBTSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.sm,
                            vertical: GBTSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: GBTColors.live,
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusXs,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GBTColors.live.withValues(alpha: 0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PulsingDot(),
                              const SizedBox(width: GBTSpacing.xs),
                              Text(
                                'LIVE',
                                style: GBTTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // EN: D-day badge — bottom-right, secondary accent.
                    // KO: D-day 배지 — 우하단, 보조 색상 강조.
                    if (isUpcoming && !isLive)
                      Positioned(
                        bottom: GBTSpacing.md,
                        right: GBTSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.sm,
                            vertical: GBTSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isDDay
                                ? GBTColors.secondary
                                : Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusXs,
                            ),
                            boxShadow: isDDay
                                ? [
                                    BoxShadow(
                                      color: GBTColors.secondary.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            isDDay ? 'D-DAY' : event.dDayLabel,
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
              : Container(
                  color: surfaceVariantColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
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
            icon: Icons.share_outlined,
            tooltip: '이벤트 공유',
            onPressed: () {
              // EN: TODO: Share event
              // KO: TODO: 이벤트 공유
            },
          ),
          // EN: Trailing gap — aligns last button away from screen edge.
          // KO: 우측 끝 여백 — 마지막 버튼을 화면 가장자리에서 띄움.
          const SizedBox(width: GBTSpacing.xs),
        ],
      ),
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                  // EN: Status chip — color-coded per status.
                  // KO: 상태 칩 — 상태별 색상 코딩.
                  _StatusChip(status: event.status, isDark: isDark),
                  const SizedBox(height: GBTSpacing.lg),
                ],
              ),
            ),
            // EN: Horizontally scrollable info cards.
            // KO: 가로 스크롤 정보 카드.
            SizedBox(
              height: 92,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.md,
                ),
                children: [
                  _InfoCard(
                    icon: Icons.calendar_today_rounded,
                    label: '날짜',
                    value: event.dateLabel,
                    accent: isDDay
                        ? (isDark
                              ? GBTColors.darkSecondary
                              : GBTColors.secondary)
                        : null,
                    isDark: isDark,
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  _InfoCard(
                    icon: Icons.access_time_rounded,
                    label: '시간',
                    value: '개장 ${event.doorTimeLabel}\n시작 ${event.timeLabel}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  _InfoCard(
                    icon: Icons.people_outline_rounded,
                    label: '대상',
                    value: event.metaLabel,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: GBTSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        _showVerificationSheet(context, ref, event.id);
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
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
                  // EN: Expandable description — collapses to 3 lines with "더 보기" toggle.
                  // KO: 접힘 가능한 설명 — 3줄로 축약하고 "더 보기" 토글 제공.
                  _ExpandableDescription(
                    text: event.description ?? '공연 정보가 없습니다.',
                  ),
                  const SizedBox(height: GBTSpacing.lg),
                  Text(
                    '티켓',
                    style: GBTTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  // EN: Ticket section — button if URL exists, message if not.
                  // KO: 티켓 섹션 — URL이 있으면 버튼, 없으면 안내 메시지.
                  if (event.ticketUrl != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl(event.ticketUrl!),
                        icon: const Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                        ),
                        label: const Text('티켓 구매하기'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.xs),
                    Text(
                      event.ticketUrl!,
                      style: GBTTypography.bodySmall.copyWith(
                        color: tertiaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: GBTSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: surfaceVariantColor,
                        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                      ),
                      child: Text(
                        '티켓 정보가 없습니다',
                        style: GBTTypography.bodyMedium.copyWith(
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: GBTSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// EN: Status chip — color-coded by event status.
/// KO: 이벤트 상태별 색상 코딩 상태 칩.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.isDark});

  final String status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    final Color chipColor;
    if (lower == 'live') {
      chipColor = GBTColors.live;
    } else if (lower.contains('예정') || lower.contains('upcoming')) {
      chipColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    } else {
      chipColor = isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        border: Border.all(color: chipColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status,
        style: GBTTypography.labelSmall.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// EN: Horizontal info card — icon + label + value in compact card.
/// KO: 가로 정보 카드 — 아이콘 + 라벨 + 값 콤팩트 카드.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final labelColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final valueColor = accent ??
        (isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary);
    final iconColor = accent ??
        (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: GBTSpacing.xs),
              Text(
                label,
                style: GBTTypography.labelSmall.copyWith(color: labelColor),
              ),
            ],
          ),
          const SizedBox(height: GBTSpacing.xs),
          Expanded(
            child: Text(
              value,
              style: GBTTypography.bodySmall.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Circular overlay icon button — 40px circle, 48px tap target.
/// Semi-transparent dark backdrop ensures readability on any poster.
/// KO: 원형 오버레이 아이콘 버튼 — 40px 원, 48px 터치 타겟.
/// 반투명 어두운 배경으로 어떤 포스터에서도 가독성 보장.
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
      // EN: iconSm (20px) matches design system icon scale.
      // KO: iconSm(20px)은 디자인 시스템 아이콘 크기 기준과 일치.
      icon: Icon(icon, size: GBTSpacing.iconSm),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        // EN: 45% black — readable on bright and dark posters.
        // KO: 45% 검정 — 밝은/어두운 포스터 모두에서 가독성 확보.
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        // EN: 40px visual circle; Material pads tap target to 48px.
        // KO: 40px 시각 원형; Material이 터치 타겟을 48px로 자동 패딩.
        fixedSize: const Size(40, 40),
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// EN: Pulsing dot for LIVE badge animation.
/// KO: LIVE 배지 애니메이션용 펄싱 도트.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// EN: Expandable description — collapses to 3 lines; shows "더 보기 / 접기" toggle
/// for long text. Uses AnimatedCrossFade for smooth height transition.
/// KO: 접힘 가능한 설명 — 3줄로 축약; 긴 텍스트에서 "더 보기 / 접기" 토글 표시.
/// 부드러운 높이 전환을 위해 AnimatedCrossFade 사용.
class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({required this.text});

  final String text;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final primaryColor =
        isDark ? GBTColors.darkPrimary : GBTColors.primary;

    // EN: Show toggle only when text is long enough to overflow 3 lines.
    //     ~100 chars is a reliable heuristic for most body text sizes.
    // KO: 텍스트가 3줄을 넘길 만큼 긴 경우에만 토글 표시.
    //     ~100자는 대부분의 본문 텍스트 크기에서 신뢰할 수 있는 기준값.
    final isLong = widget.text.length > 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: GBTAnimations.normal,
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Text(
            widget.text,
            style: GBTTypography.bodyMedium.copyWith(
              color: secondaryColor,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            widget.text,
            style: GBTTypography.bodyMedium.copyWith(
              color: secondaryColor,
              height: 1.6,
            ),
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: GBTSpacing.xs),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? '접기' : '더 보기',
              style: GBTTypography.labelMedium.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
