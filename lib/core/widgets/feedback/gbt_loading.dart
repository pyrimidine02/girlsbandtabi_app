/// EN: GBT Loading and state indicator components
/// KO: GBT 로딩 및 상태 표시 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
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
            child: Container(
              color: GBTColors.overlay,
              child: GBTLoading(message: message),
            ),
          ),
      ],
    );
  }
}

/// EN: Empty state widget
/// KO: 빈 상태 위젯
class GBTEmptyState extends StatelessWidget {
  const GBTEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// EN: Message to display
  /// KO: 표시할 메시지
  final String message;

  /// EN: Optional icon
  /// KO: 선택적 아이콘
  final IconData? icon;

  /// EN: Optional action button label
  /// KO: 선택적 액션 버튼 라벨
  final String? actionLabel;

  /// EN: Optional action callback
  /// KO: 선택적 액션 콜백
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 64, color: GBTColors.textTertiary),
              const SizedBox(height: GBTSpacing.md),
            ],
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: GBTSpacing.lg),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// EN: Error state widget
/// KO: 오류 상태 위젯
class GBTErrorState extends StatelessWidget {
  const GBTErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = '다시 시도',
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: GBTColors.error),
            const SizedBox(height: GBTSpacing.md),
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: GBTSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// EN: Shimmer loading placeholder
/// KO: 쉬머 로딩 플레이스홀더
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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? GBTColors.surfaceVariant;
    final highlightColor = widget.highlightColor ?? GBTColors.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [0.0, _animation.value.clamp(0.0, 1.0), 1.0],
              transform: GradientRotation(_animation.value * 3.14),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
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
    return GBTShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(
            borderRadius ?? GBTSpacing.radiusSm,
          ),
        ),
      ),
    );
  }
}
