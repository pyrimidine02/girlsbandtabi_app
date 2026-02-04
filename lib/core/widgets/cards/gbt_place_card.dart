/// EN: GBT Place Card component for displaying place information
/// KO: 장소 정보를 표시하기 위한 GBT 장소 카드 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';
import '../common/gbt_image.dart';

/// EN: Place card widget for list/grid display
/// KO: 리스트/그리드 표시용 장소 카드 위젯
class GBTPlaceCard extends StatelessWidget {
  const GBTPlaceCard({
    super.key,
    required this.name,
    required this.location,
    this.imageUrl,
    this.distance,
    this.isVerified = false,
    this.isFavorite = false,
    this.rating,
    this.onTap,
    this.onFavoriteToggle,
  });

  /// EN: Place name
  /// KO: 장소 이름
  final String name;

  /// EN: Place location description
  /// KO: 장소 위치 설명
  final String location;

  /// EN: Place image URL
  /// KO: 장소 이미지 URL
  final String? imageUrl;

  /// EN: Distance from user
  /// KO: 사용자로부터의 거리
  final String? distance;

  /// EN: Whether place has been verified/visited
  /// KO: 장소가 인증/방문되었는지 여부
  final bool isVerified;

  /// EN: Whether place is favorited
  /// KO: 장소가 즐겨찾기인지 여부
  final bool isFavorite;

  /// EN: Place rating
  /// KO: 장소 평점
  final double? rating;

  /// EN: Callback when card is tapped
  /// KO: 카드가 탭되었을 때 콜백
  final VoidCallback? onTap;

  /// EN: Callback when favorite is toggled
  /// KO: 즐겨찾기가 토글되었을 때 콜백
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name, $location${distance != null ? ', $distance' : ''}',
      button: onTap != null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Image section
              // KO: 이미지 섹션
              Stack(
                children: [
                  AspectRatio(aspectRatio: 16 / 10, child: _buildImage()),
                  // EN: Verified badge
                  // KO: 인증 배지
                  if (isVerified)
                    Positioned(
                      top: GBTSpacing.sm,
                      left: GBTSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: GBTColors.verified,
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusXs,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '방문완료',
                              style: GBTTypography.labelSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // EN: Favorite button
                  // KO: 즐겨찾기 버튼
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: GBTSpacing.sm,
                      right: GBTSpacing.sm,
                      child: _FavoriteButton(
                        isFavorite: isFavorite,
                        onToggle: onFavoriteToggle!,
                      ),
                    ),
                ],
              ),

              // EN: Content section
              // KO: 콘텐츠 섹션
              Padding(
                padding: GBTSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GBTTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GBTSpacing.xxs),
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
                            location,
                            style: GBTTypography.bodySmall.copyWith(
                              color: GBTColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GBTSpacing.xs),
                    Row(
                      children: [
                        if (distance != null) ...[
                          Text(
                            distance!,
                            style: GBTTypography.labelSmall.copyWith(
                              color: GBTColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: GBTSpacing.sm),
                        ],
                        if (rating != null) ...[
                          Icon(Icons.star, size: 14, color: GBTColors.rating),
                          const SizedBox(width: 2),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: GBTTypography.labelSmall.copyWith(
                              color: GBTColors.textSecondary,
                            ),
                          ),
                        ],
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

  /// EN: Build image widget
  /// KO: 이미지 위젯 빌드
  Widget _buildImage() {
    if (imageUrl != null) {
      return GBTImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        semanticLabel: '$name 이미지',
      );
    }
    return _buildPlaceholder();
  }

  /// EN: Build image placeholder
  /// KO: 이미지 플레이스홀더 빌드
  Widget _buildPlaceholder() {
    return Container(
      color: GBTColors.surfaceVariant,
      child: Center(
        child: Icon(Icons.image, size: 48, color: GBTColors.textTertiary),
      ),
    );
  }
}

/// EN: Favorite button widget
/// KO: 즐겨찾기 버튼 위젯
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onToggle});

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
      button: true,
      child: Material(
        color: Colors.black38,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onToggle,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(GBTSpacing.xs),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? GBTColors.favorite : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Horizontal place card for list display
/// KO: 리스트 표시용 가로 장소 카드
class GBTPlaceCardHorizontal extends StatelessWidget {
  const GBTPlaceCardHorizontal({
    super.key,
    required this.name,
    required this.location,
    this.imageUrl,
    this.distance,
    this.isVerified = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  final String name;
  final String location;
  final String? imageUrl;
  final String? distance;
  final bool isVerified;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name, $location',
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: GBTSpacing.paddingMd,
            child: Row(
              children: [
                // EN: Image
                // KO: 이미지
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: GBTColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null
                      ? GBTImage(
                          imageUrl: imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          semanticLabel: '$name 이미지',
                        )
                      : const Icon(Icons.image, color: GBTColors.textTertiary),
                ),

                const SizedBox(width: GBTSpacing.md),

                // EN: Content
                // KO: 콘텐츠
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GBTTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: GBTColors.verified,
                            ),
                        ],
                      ),
                      const SizedBox(height: GBTSpacing.xxs),
                      Text(
                        location,
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (distance != null) ...[
                        const SizedBox(height: GBTSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.near_me,
                              size: 14,
                              color: GBTColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance!,
                              style: GBTTypography.labelSmall.copyWith(
                                color: GBTColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // EN: Favorite button
                // KO: 즐겨찾기 버튼
                if (onFavoriteToggle != null)
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? GBTColors.favorite
                          : GBTColors.textTertiary,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
