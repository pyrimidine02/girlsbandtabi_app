/// EN: GBT Event Card component for displaying live event information
/// KO: 라이브 이벤트 정보를 표시하기 위한 GBT 이벤트 카드 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';
import '../common/gbt_image.dart';

/// EN: Event card widget for list display
/// KO: 리스트 표시용 이벤트 카드 위젯
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

  @override
  Widget build(BuildContext context) {
    final dDaySuffix = dDayLabel != null ? ' $dDayLabel' : '';
    return Semantics(
      label: '$title $subtitle $meta $date$dDaySuffix',
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          child: Padding(
            padding: GBTSpacing.paddingMd,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EN: Date badge
                // KO: 날짜 배지
                _DateBadge(
                  date: date,
                  isUpcoming: isUpcoming,
                  dDayLabel: dDayLabel,
                ),

                const SizedBox(width: GBTSpacing.md),

                // EN: Event info
                // KO: 이벤트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EN: Live badge
                      // KO: 라이브 배지
                      if (isLive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: GBTColors.live,
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusXs,
                            ),
                          ),
                          child: Text(
                            'LIVE',
                            style: GBTTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: GBTSpacing.xs),
                      ],

                      Text(
                        title,
                        style: GBTTypography.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: GBTSpacing.xxs),

                      Text(
                        subtitle,
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.accent,
                        ),
                      ),

                      const SizedBox(height: GBTSpacing.xs),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: GBTColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meta,
                              style: GBTTypography.labelSmall.copyWith(
                                color: GBTColors.textTertiary,
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
                    // EN: Poster placeholder
                    // KO: 포스터 플레이스홀더
                    SizedBox(
                      width: 60,
                      height: 80,
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
                          : const _PosterPlaceholder(),
                    ),

                    if (onFavoriteToggle != null) ...[
                      const SizedBox(height: GBTSpacing.xs),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                          ),
                          color: isFavorite
                              ? GBTColors.favorite
                              : GBTColors.textTertiary,
                          onPressed: onFavoriteToggle,
                          padding: EdgeInsets.zero,
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

/// EN: Date badge widget
/// KO: 날짜 배지 위젯
class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.date,
    required this.isUpcoming,
    this.dDayLabel,
  });

  final String date;
  final bool isUpcoming;
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

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
      decoration: BoxDecoration(
        color: isUpcoming
            ? GBTColors.accent.withValues(alpha: 0.1)
            : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            day.isEmpty ? '00' : day.padLeft(2, '0'),
            style: GBTTypography.headlineSmall.copyWith(
              color: isUpcoming ? GBTColors.accent : GBTColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            month.isEmpty ? '월' : '$month' '월',
            style: GBTTypography.labelSmall.copyWith(
              color: isUpcoming ? GBTColors.accent : GBTColors.textTertiary,
            ),
          ),
          if (dDayLabel != null && dDayLabel!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              dDayLabel!,
              style: GBTTypography.labelSmall.copyWith(
                color: isUpcoming ? GBTColors.accent : GBTColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// EN: Featured event card with larger display
/// KO: 더 큰 표시의 특집 이벤트 카드
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Featured: $title $subtitle',
      button: onTap != null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Poster
              // KO: 포스터
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
                        : const _FeaturedPosterPlaceholder(),
                  ),
                  // EN: Live badge
                  // KO: 라이브 배지
                  if (isLive)
                    Positioned(
                      top: GBTSpacing.sm,
                      left: GBTSpacing.sm,
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
                        ),
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
                            const SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: GBTTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // EN: Gradient overlay
                  // KO: 그라데이션 오버레이
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: GBTColors.cardOverlayGradient,
                      ),
                    ),
                  ),
                  // EN: Date badge
                  // KO: 날짜 배지
                  Positioned(
                    bottom: GBTSpacing.sm,
                    left: GBTSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.sm,
                        vertical: GBTSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusXs,
                        ),
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

              // EN: Content
              // KO: 콘텐츠
              Padding(
                padding: GBTSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GBTTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GBTSpacing.xxs),
                    Text(
                      subtitle,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: GBTColors.accent,
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: GBTColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meta,
                          style: GBTTypography.bodySmall.copyWith(
                            color: GBTColors.textSecondary,
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

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Icon(Icons.image, color: GBTColors.textTertiary),
    );
  }
}

class _FeaturedPosterPlaceholder extends StatelessWidget {
  const _FeaturedPosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GBTColors.surfaceVariant,
      child: Icon(Icons.music_note, size: 64, color: GBTColors.textTertiary),
    );
  }
}
