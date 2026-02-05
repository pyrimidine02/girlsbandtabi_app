/// EN: GBT Place Card component for displaying place information
/// KO: 장소 정보를 표시하기 위한 GBT 장소 카드 컴포넌트
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_decorations.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';
import '../common/gbt_image.dart';

/// EN: Place card widget for list/grid display with press animation
/// KO: 프레스 애니메이션을 포함한 리스트/그리드 표시용 장소 카드 위젯
class GBTPlaceCard extends StatefulWidget {
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
  State<GBTPlaceCard> createState() => _GBTPlaceCardState();
}

class _GBTPlaceCardState extends State<GBTPlaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: GBTAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: GBTAnimations.pressedScale,
    ).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label:
          '${widget.name}, ${widget.location}${widget.distance != null ? ', ${widget.distance}' : ''}',
      button: widget.onTap != null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? _onTapDown : null,
          onTapUp: widget.onTap != null ? _onTapUp : null,
          onTapCancel: widget.onTap != null ? _onTapCancel : null,
          onTap: widget.onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  _pressController.reverse();
                  widget.onTap!();
                }
              : null,
          child: AnimatedContainer(
            duration: GBTAnimations.normal,
            curve: GBTAnimations.defaultCurve,
            decoration: GBTDecorations.card(isDark: isDark),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EN: Image section with overlay gradient
                // KO: 오버레이 그라디언트가 있는 이미지 섹션
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: _buildImage(isDark),
                    ),
                    // EN: Bottom gradient for depth
                    // KO: 깊이감을 위한 하단 그라디언트
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.04),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // EN: Verified badge
                    // KO: 인증 배지
                    if (widget.isVerified)
                      Positioned(
                        top: GBTSpacing.sm,
                        left: GBTSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: GBTDecorations.verifiedBadge(),
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
                    if (widget.onFavoriteToggle != null)
                      Positioned(
                        top: GBTSpacing.sm,
                        right: GBTSpacing.sm,
                        child: _FavoriteButton(
                          isFavorite: widget.isFavorite,
                          onToggle: widget.onFavoriteToggle!,
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
                        widget.name,
                        style: GBTTypography.titleSmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextPrimary
                              : GBTColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: GBTSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.location,
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
                      const SizedBox(height: GBTSpacing.xs),
                      Row(
                        children: [
                          if (widget.distance != null) ...[
                            Text(
                              widget.distance!,
                              style: GBTTypography.labelSmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextTertiary
                                    : GBTColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: GBTSpacing.sm),
                          ],
                          if (widget.rating != null) ...[
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: GBTColors.rating,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.rating!.toStringAsFixed(1),
                              style: GBTTypography.labelSmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextSecondary
                                    : GBTColors.textSecondary,
                                fontWeight: FontWeight.w500,
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
      ),
    );
  }

  /// EN: Build image widget with dark mode placeholder
  /// KO: 다크 모드 플레이스홀더가 있는 이미지 위젯 빌드
  Widget _buildImage(bool isDark) {
    if (widget.imageUrl != null) {
      return GBTImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        semanticLabel: '${widget.name} 이미지',
      );
    }
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
      ),
    );
  }
}

/// EN: Animated favorite button with heart scale effect
/// KO: 하트 스케일 효과가 있는 애니메이션 즐겨찾기 버튼
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.isFavorite, required this.onToggle});

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: GBTAnimations.normal,
      vsync: this,
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite && !oldWidget.isFavorite) {
      _heartController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
      button: true,
      child: Material(
        color: Colors.black.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onToggle();
          },
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(GBTSpacing.xs),
            child: ScaleTransition(
              scale: _heartScale,
              child: AnimatedSwitcher(
                duration: GBTAnimations.fast,
                child: Icon(
                  widget.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(widget.isFavorite),
                  color: widget.isFavorite ? GBTColors.favorite : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Horizontal place card for list display with press animation
/// KO: 프레스 애니메이션을 포함한 리스트 표시용 가로 장소 카드
class GBTPlaceCardHorizontal extends StatefulWidget {
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
  State<GBTPlaceCardHorizontal> createState() =>
      _GBTPlaceCardHorizontalState();
}

class _GBTPlaceCardHorizontalState extends State<GBTPlaceCardHorizontal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: GBTAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: GBTAnimations.pressedScale,
    ).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '${widget.name}, ${widget.location}',
      button: widget.onTap != null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? _onTapDown : null,
          onTapUp: widget.onTap != null ? _onTapUp : null,
          onTapCancel: widget.onTap != null ? _onTapCancel : null,
          onTap: widget.onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  _pressController.reverse();
                  widget.onTap!();
                }
              : null,
          child: AnimatedContainer(
            duration: GBTAnimations.normal,
            curve: GBTAnimations.defaultCurve,
            decoration: GBTDecorations.card(isDark: isDark),
            child: Padding(
              padding: GBTSpacing.paddingMd,
              child: Row(
                children: [
                  // EN: Image with rounded corners
                  // KO: 둥근 모서리 이미지
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? GBTColors.darkSurfaceElevated
                          : GBTColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(GBTSpacing.radiusSm),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.imageUrl != null
                        ? GBTImage(
                            imageUrl: widget.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            semanticLabel: '${widget.name} 이미지',
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                          ),
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
                                widget.name,
                                style: GBTTypography.titleSmall.copyWith(
                                  color: isDark
                                      ? GBTColors.darkTextPrimary
                                      : GBTColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isVerified)
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: GBTColors.verified,
                              ),
                          ],
                        ),
                        const SizedBox(height: GBTSpacing.xxs),
                        Text(
                          widget.location,
                          style: GBTTypography.bodySmall.copyWith(
                            color: isDark
                                ? GBTColors.darkTextSecondary
                                : GBTColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.distance != null) ...[
                          const SizedBox(height: GBTSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.near_me_outlined,
                                size: 14,
                                color: isDark
                                    ? GBTColors.darkTextTertiary
                                    : GBTColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.distance!,
                                style: GBTTypography.labelSmall.copyWith(
                                  color: isDark
                                      ? GBTColors.darkTextTertiary
                                      : GBTColors.textTertiary,
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
                  if (widget.onFavoriteToggle != null)
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: GBTAnimations.fast,
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          key: ValueKey(widget.isFavorite),
                          color: widget.isFavorite
                              ? GBTColors.favorite
                              : (isDark
                                  ? GBTColors.darkTextTertiary
                                  : GBTColors.textTertiary),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onFavoriteToggle!();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
