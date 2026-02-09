/// EN: GBT Event Card component for displaying live event information
/// KO: 라이브 이벤트 정보를 표시하기 위한 GBT 이벤트 카드 컴포넌트
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_decorations.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';
import '../common/gbt_image.dart';
import '../common/gbt_pressable.dart';

/// EN: Event card widget for list display with press animation
/// KO: 프레스 애니메이션을 포함한 리스트 표시용 이벤트 카드 위젯
class GBTEventCard extends StatelessWidget {
  const GBTEventCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.date,
    this.dDayLabel,
    this.posterUrl,
    this.isLive = false,
    this.isUpcoming = true,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  /// EN: Event title
  /// KO: 이벤트 제목
  final String title;

  /// EN: Artist or band name
  /// KO: 보조 정보(상태 등)
  final String subtitle;

  /// EN: Venue name
  /// KO: 메타 정보(프로젝트/유닛 등)
  final String meta;

  /// EN: Event date display string
  /// KO: 이벤트 날짜 표시 문자열
  final String date;

  /// EN: D-day label (e.g., D-3, D-day)
  /// KO: 디데이 라벨 (예: D-3, D-day)
  final String? dDayLabel;

  /// EN: Event poster image URL
  /// KO: 이벤트 포스터 이미지 URL
  final String? posterUrl;

  /// EN: Whether event is currently live
  /// KO: 이벤트가 현재 진행 중인지 여부
  final bool isLive;

  /// EN: Whether event is upcoming (vs completed)
  /// KO: 이벤트가 예정인지 (완료 대비)
  final bool isUpcoming;

  /// EN: Whether event is favorited
  /// KO: 이벤트가 즐겨찾기인지 여부
  final bool isFavorite;

  /// EN: Callback when card is tapped
  /// KO: 카드가 탭되었을 때 콜백
  final VoidCallback? onTap;

  /// EN: Callback when favorite is toggled
  /// KO: 즐겨찾기가 토글되었을 때 콜백
  final VoidCallback? onFavoriteToggle;

  /// EN: Build comprehensive semantic label with all event state info
  /// KO: 모든 이벤트 상태 정보를 포함한 포괄적 시맨틱 라벨 빌드
  String get _semanticLabel {
    final parts = <String>[title, subtitle, meta, date];
    if (dDayLabel != null) parts.add(dDayLabel!);
    if (isLive) parts.add('라이브 진행 중');
    if (!isUpcoming) parts.add('종료됨');
    if (isFavorite) parts.add('즐겨찾기됨');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: _semanticLabel,
      hint: onTap != null ? '탭하면 이벤트 상세로 이동합니다' : null,
      button: onTap != null,
      child: GBTPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GBTAnimations.normal,
          curve: GBTAnimations.defaultCurve,
          decoration: GBTDecorations.card(isDark: isDark),
          child: Padding(
            padding: GBTSpacing.paddingMd,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EN: Date badge with dark mode awareness
                // KO: 다크 모드 인식 날짜 배지
                _DateBadge(
                  date: date,
                  isUpcoming: isUpcoming,
                  isDark: isDark,
                  dDayLabel: dDayLabel,
                ),

                const SizedBox(width: GBTSpacing.md),

                // EN: Event info
                // KO: 이벤트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EN: Live badge with glow effect
                      // KO: 글로우 효과가 있는 라이브 배지
                      if (isLive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.xs,
                            vertical: GBTSpacing.xxs,
                          ),
                          decoration: GBTDecorations.liveBadge(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: GBTSpacing.xs),
                              Text(
                                'LIVE',
                                style: GBTTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: GBTSpacing.xs),
                      ],

                      Text(
                        title,
                        style: GBTTypography.titleSmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextPrimary
                              : GBTColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: GBTSpacing.xxs),

                      Text(
                        subtitle,
                        style: GBTTypography.bodySmall.copyWith(
                          color: isDark
                              ? GBTColors.darkAccent
                              : GBTColors.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: GBTSpacing.xs),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                          ),
                          const SizedBox(width: GBTSpacing.xs),
                          Expanded(
                            child: Text(
                              meta,
                              style: GBTTypography.labelSmall.copyWith(
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
                  ),
                ),

                const SizedBox(width: GBTSpacing.sm),

                // EN: Poster or favorite button
                // KO: 포스터 또는 즐겨찾기 버튼
                Column(
                  children: [
                    // EN: Poster with rounded corners
                    // KO: 둥근 모서리 포스터
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? GBTColors.darkSurfaceElevated
                            : GBTColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(GBTSpacing.radiusSm),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: posterUrl != null
                          ? GBTImage(
                              imageUrl: posterUrl!,
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusSm,
                              ),
                              semanticLabel: '$title 포스터',
                            )
                          : _PosterPlaceholder(isDark: isDark),
                    ),

                    // EN: Favorite button with 48dp touch target & tooltip
                    // KO: 48dp 터치 타겟과 툴팁이 있는 즐겨찾기 버튼
                    if (onFavoriteToggle != null) ...[
                      const SizedBox(height: GBTSpacing.xs),
                      Tooltip(
                        message: isFavorite
                            ? '즐겨찾기 해제'
                            : '즐겨찾기 추가',
                        child: Semantics(
                          button: true,
                          label: isFavorite
                              ? '즐겨찾기 해제'
                              : '즐겨찾기 추가',
                          hint: isFavorite
                              ? '탭하면 즐겨찾기에서 제거합니다'
                              : '탭하면 즐겨찾기에 추가합니다',
                          child: SizedBox(
                            width: GBTSpacing.touchTarget,
                            height: GBTSpacing.touchTarget,
                            child: IconButton(
                              icon: AnimatedSwitcher(
                                duration: GBTAnimations.fast,
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(isFavorite),
                                  size: GBTSpacing.iconSm,
                                ),
                              ),
                              color: isFavorite
                                  ? GBTColors.favorite
                                  : (isDark
                                      ? GBTColors.darkTextTertiary
                                      : GBTColors.textTertiary),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                onFavoriteToggle!();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: GBTSpacing.touchTarget,
                                minHeight: GBTSpacing.touchTarget,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Date badge widget with dark mode support
/// KO: 다크 모드를 지원하는 날짜 배지 위젯
class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.date,
    required this.isUpcoming,
    required this.isDark,
    this.dDayLabel,
  });

  final String date;
  final bool isUpcoming;
  final bool isDark;
  final String? dDayLabel;

  @override
  Widget build(BuildContext context) {
    // EN: Parse date for display (expecting format like "2월 15일")
    // KO: 표시를 위한 날짜 파싱 ("2월 15일" 형식 예상)
    final monthDayMatch = RegExp(r'(\d+)\s*월\s*(\d+)').firstMatch(date);
    String month = '';
    String day = '';
    if (monthDayMatch != null) {
      month = monthDayMatch.group(1) ?? '';
      day = monthDayMatch.group(2) ?? '';
    } else {
      final digits = RegExp(r'\d+')
          .allMatches(date)
          .map((match) => match.group(0) ?? '')
          .where((value) => value.isNotEmpty)
          .toList();
      if (digits.isNotEmpty) {
        month = digits[0];
      }
      if (digits.length > 1) {
        day = digits[1];
      }
    }

    // EN: Compute colors based on upcoming state and dark mode
    // KO: 예정 상태와 다크 모드에 따른 색상 계산
    final Color bgColor;
    final Color primaryColor;
    final Color secondaryColor;

    if (isUpcoming) {
      bgColor = isDark
          ? GBTColors.accent.withValues(alpha: 0.15)
          : GBTColors.accent.withValues(alpha: 0.1);
      primaryColor = isDark ? GBTColors.darkAccent : GBTColors.accent;
      secondaryColor = isDark ? GBTColors.darkAccent : GBTColors.accent;
    } else {
      bgColor = isDark
          ? GBTColors.darkSurfaceElevated
          : GBTColors.surfaceVariant;
      primaryColor =
          isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
      secondaryColor =
          isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    }

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            day.isEmpty ? '00' : day.padLeft(2, '0'),
            style: GBTTypography.headlineSmall.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            month.isEmpty ? '월' : '$month월',
            style: GBTTypography.labelSmall.copyWith(
              color: secondaryColor,
            ),
          ),
          if (dDayLabel != null && dDayLabel!.isNotEmpty) ...[
            const SizedBox(height: GBTSpacing.xxs),
            Text(
              dDayLabel!,
              style: GBTTypography.labelSmall.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// EN: Featured event card with larger display and press animation
/// KO: 프레스 애니메이션을 포함한 더 큰 표시의 특집 이벤트 카드
class GBTFeaturedEventCard extends StatelessWidget {
  const GBTFeaturedEventCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.date,
    this.posterUrl,
    this.isLive = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String date;
  final String? posterUrl;
  final bool isLive;
  final VoidCallback? onTap;

  /// EN: Build comprehensive semantic label for featured card
  /// KO: 특집 카드를 위한 포괄적 시맨틱 라벨 빌드
  String get _semanticLabel {
    final parts = <String>['특집 이벤트', title, subtitle, meta, date];
    if (isLive) parts.add('라이브 진행 중');
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: _semanticLabel,
      hint: onTap != null ? '탭하면 이벤트 상세로 이동합니다' : null,
      button: onTap != null,
      child: GBTPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GBTAnimations.normal,
          curve: GBTAnimations.defaultCurve,
          decoration: GBTDecorations.cardElevated(isDark: isDark),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Poster with overlay
              // KO: 오버레이 포스터
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: posterUrl != null
                        ? GBTImage(
                            imageUrl: posterUrl!,
                            fit: BoxFit.cover,
                            semanticLabel: '$title 포스터',
                          )
                        : _FeaturedPosterPlaceholder(isDark: isDark),
                  ),
                  // EN: Live badge with glow
                  // KO: 글로우가 있는 라이브 배지
                  if (isLive)
                    Positioned(
                      top: GBTSpacing.sm,
                      left: GBTSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.sm,
                          vertical: GBTSpacing.xxs,
                        ),
                        decoration: GBTDecorations.liveBadge(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: GBTSpacing.xs),
                            Text(
                              'LIVE',
                              style: GBTTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // EN: Gradient overlay for text readability
                  // KO: 텍스트 가독성을 위한 그라디언트 오버레이
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // EN: Date badge on image
                  // KO: 이미지 위 날짜 배지
                  Positioned(
                    bottom: GBTSpacing.sm,
                    left: GBTSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.sm,
                        vertical: GBTSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius:
                            BorderRadius.circular(GBTSpacing.radiusXs),
                      ),
                      child: Text(
                        date,
                        style: GBTTypography.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // EN: Content with dark mode colors
              // KO: 다크 모드 색상이 적용된 콘텐츠
              Padding(
                padding: GBTSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GBTTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? GBTColors.darkTextPrimary
                            : GBTColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GBTSpacing.xxs),
                    Text(
                      subtitle,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: isDark
                            ? GBTColors.darkAccent
                            : GBTColors.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GBTSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: GBTSpacing.iconXs,
                          color: isDark
                              ? GBTColors.darkTextTertiary
                              : GBTColors.textTertiary,
                        ),
                        const SizedBox(width: GBTSpacing.xs),
                        Expanded(
                          child: Text(
                            meta,
                            style: GBTTypography.bodySmall.copyWith(
                              color: isDark
                                  ? GBTColors.darkTextSecondary
                                  : GBTColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Poster placeholder with dark mode support
/// KO: 다크 모드를 지원하는 포스터 플레이스홀더
class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
      ),
    );
  }
}

/// EN: Featured poster placeholder with dark mode support
/// KO: 다크 모드를 지원하는 특집 포스터 플레이스홀더
class _FeaturedPosterPlaceholder extends StatelessWidget {
  const _FeaturedPosterPlaceholder({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: GBTSpacing.xxxl,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
      ),
    );
  }
}
