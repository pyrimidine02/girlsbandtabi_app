/// EN: GBT Loading, state indicators, shimmer, and skeleton components
/// KO: GBT 로딩, 상태 표시, 쉬머, 스켈레톤 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_decorations.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: Loading indicator widget
/// KO: 로딩 인디케이터 위젯
class GBTLoading extends StatelessWidget {
  const GBTLoading({super.key, this.message, this.size = 40, this.color});

  /// EN: Optional loading message
  /// KO: 선택적 로딩 메시지
  final String? message;

  /// EN: Size of the loading indicator
  /// KO: 로딩 인디케이터 크기
  final double size;

  /// EN: Color of the loading indicator
  /// KO: 로딩 인디케이터 색상
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message ?? '로딩 중',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? GBTColors.accent,
                ),
                strokeWidth: 3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: GBTSpacing.md),
              Text(
                message!,
                style: GBTTypography.bodyMedium.copyWith(
                  color: GBTColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// EN: Full screen loading overlay
/// KO: 전체 화면 로딩 오버레이
class GBTLoadingOverlay extends StatelessWidget {
  const GBTLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  /// EN: Whether the loading overlay is visible
  /// KO: 로딩 오버레이가 표시되는지 여부
  final bool isLoading;

  /// EN: Child widget
  /// KO: 자식 위젯
  final Widget child;

  /// EN: Optional loading message
  /// KO: 선택적 로딩 메시지
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: GBTAnimations.normal,
              child: Container(
                color: GBTColors.overlay,
                child: GBTLoading(message: message),
              ),
            ),
          ),
      ],
    );
  }
}

/// EN: Empty state widget with visual illustration
/// KO: 시각적 일러스트를 포함한 빈 상태 위젯
class GBTEmptyState extends StatelessWidget {
  const GBTEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  /// EN: Message to display
  /// KO: 표시할 메시지
  final String message;

  /// EN: Optional icon
  /// KO: 선택적 아이콘
  final IconData? icon;

  /// EN: Optional title above the message
  /// KO: 메시지 위의 선택적 제목
  final String? title;

  /// EN: Optional action button label
  /// KO: 선택적 액션 버튼 라벨
  final String? actionLabel;

  /// EN: Optional action callback
  /// KO: 선택적 액션 콜백
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EN: Circular icon container with subtle background
            // KO: 미세한 배경이 있는 원형 아이콘 컨테이너
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? GBTColors.darkSurfaceElevated
                    : GBTColors.surfaceAlternate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 36,
                color: isDark
                    ? GBTColors.darkTextTertiary
                    : GBTColors.textTertiary,
              ),
            ),
            const SizedBox(height: GBTSpacing.lg),
            if (title != null) ...[
              Text(
                title!,
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GBTSpacing.xs),
            ],
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: GBTSpacing.lg),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// EN: Error state widget with visual illustration
/// KO: 시각적 일러스트를 포함한 오류 상태 위젯
class GBTErrorState extends StatelessWidget {
  const GBTErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = '다시 시도',
    this.title,
  });

  /// EN: Error message to display
  /// KO: 표시할 오류 메시지
  final String message;

  /// EN: Optional retry callback
  /// KO: 선택적 재시도 콜백
  final VoidCallback? onRetry;

  /// EN: Retry button label
  /// KO: 재시도 버튼 라벨
  final String retryLabel;

  /// EN: Optional title above the message
  /// KO: 메시지 위의 선택적 제목
  final String? title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EN: Error icon with tinted background
            // KO: 색조 배경이 있는 오류 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GBTColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: GBTColors.error,
              ),
            ),
            const SizedBox(height: GBTSpacing.lg),
            Text(
              title ?? '문제가 발생했어요',
              style: GBTTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.xs),
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: GBTSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Shimmer & Skeleton Components
// KO: 쉬머 & 스켈레톤 컴포넌트
// ========================================

/// EN: Shimmer loading placeholder with proper sweep animation
/// KO: 올바른 스위프 애니메이션을 포함한 쉬머 로딩 플레이스홀더
class GBTShimmer extends StatefulWidget {
  const GBTShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  /// EN: Child widget to shimmer
  /// KO: 쉬머 효과를 적용할 자식 위젯
  final Widget child;

  /// EN: Base color for shimmer
  /// KO: 쉬머 기본 색상
  final Color? baseColor;

  /// EN: Highlight color for shimmer
  /// KO: 쉬머 하이라이트 색상
  final Color? highlightColor;

  @override
  State<GBTShimmer> createState() => _GBTShimmerState();
}

class _GBTShimmerState extends State<GBTShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? GBTColors.darkShimmerBase : GBTColors.shimmerBase);
    final highlightColor = widget.highlightColor ??
        (isDark ? GBTColors.darkShimmerHighlight : GBTColors.shimmerHighlight);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // EN: Sweep from left to right using gradient translation
        // KO: 그라디언트 이동으로 왼쪽에서 오른쪽으로 스위프
        final value = _controller.value;
        final translateX = -1.0 + (3.0 * value);

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(translateX),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// EN: Gradient transform for horizontal shimmer sweep
/// KO: 수평 쉬머 스위프를 위한 그라디언트 변환
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

/// EN: Shimmer loading placeholder container
/// KO: 쉬머 로딩 플레이스홀더 컨테이너
class GBTShimmerContainer extends StatelessWidget {
  const GBTShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GBTShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(
            borderRadius ?? GBTSpacing.radiusSm,
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Skeleton Screen Presets
// KO: 스켈레톤 스크린 프리셋
// ========================================

/// EN: Skeleton for a horizontal place card
/// KO: 가로 장소 카드 스켈레톤
class GBTPlaceCardSkeleton extends StatelessWidget {
  const GBTPlaceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;

    return GBTShimmer(
      child: Container(
        padding: GBTSpacing.paddingMd,
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
        child: Row(
          children: [
            // EN: Image placeholder
            // KO: 이미지 플레이스홀더
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
            ),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    height: 12,
                    width: 140,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Skeleton for an event card
/// KO: 이벤트 카드 스켈레톤
class GBTEventCardSkeleton extends StatelessWidget {
  const GBTEventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;

    return GBTShimmer(
      child: Container(
        padding: GBTSpacing.paddingMd,
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Date badge placeholder
            // KO: 날짜 배지 플레이스홀더
            Container(
              width: 60,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
            ),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    height: 10,
                    width: 160,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: GBTSpacing.sm),
            // EN: Poster placeholder
            // KO: 포스터 플레이스홀더
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Skeleton for a news card
/// KO: 뉴스 카드 스켈레톤
class GBTNewsCardSkeleton extends StatelessWidget {
  const GBTNewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;

    return GBTShimmer(
      child: Container(
        padding: GBTSpacing.paddingMd,
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
            ),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Generic list skeleton with configurable item count
/// KO: 구성 가능한 아이템 수를 가진 일반 리스트 스켈레톤
class GBTListSkeleton extends StatelessWidget {
  const GBTListSkeleton({
    super.key,
    required this.itemBuilder,
    this.itemCount = 3,
    this.padding,
    this.spacing = GBTSpacing.md,
  });

  /// EN: Builder for each skeleton item
  /// KO: 각 스켈레톤 아이템 빌더
  final WidgetBuilder itemBuilder;

  /// EN: Number of skeleton items
  /// KO: 스켈레톤 아이템 수
  final int itemCount;

  /// EN: Optional padding
  /// KO: 선택적 패딩
  final EdgeInsets? padding;

  /// EN: Spacing between items
  /// KO: 아이템 간 간격
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? GBTSpacing.paddingPage,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < itemCount - 1 ? spacing : 0,
            ),
            child: itemBuilder(context),
          ),
        ),
      ),
    );
  }
}
