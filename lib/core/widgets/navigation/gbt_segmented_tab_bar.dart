/// EN: Unified segmented tab bar used across pages.
/// KO: 페이지 전반에서 사용하는 통합 세그먼트 탭바입니다.
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: Pill-style segmented tab bar wrapper for consistent page UI.
/// KO: 일관된 페이지 UI를 위한 필 스타일 세그먼트 탭바 래퍼입니다.
class GBTSegmentedTabBar extends StatelessWidget {
  const GBTSegmentedTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.margin,
    this.padding = const EdgeInsets.all(3),
    this.isScrollable = false,
    this.height,
    this.borderRadius = GBTSpacing.radiusMd,
    this.indicatorBorderRadius = GBTSpacing.radiusSm + 1,
    this.indicatorShadow = true,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.labelPadding,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final double? height;
  final double borderRadius;
  final double indicatorBorderRadius;
  final bool indicatorShadow;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final EdgeInsetsGeometry? labelPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAndroid = theme.platform == TargetPlatform.android;
    final activeColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final resolvedLabelStyle = (labelStyle ?? GBTTypography.labelLarge)
        .copyWith(fontWeight: FontWeight.w600, fontSize: isAndroid ? 15 : null);
    final resolvedUnselectedLabelStyle =
        (unselectedLabelStyle ?? labelStyle ?? GBTTypography.labelLarge)
            .copyWith(fontSize: isAndroid ? 15 : null);
    final resolvedPadding = isAndroid
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
        : padding;
    final resolvedLabelPadding = isAndroid
        ? const EdgeInsets.symmetric(horizontal: GBTSpacing.md)
        : labelPadding;
    final containerRadius = isAndroid ? borderRadius + 4 : borderRadius;
    final indicatorRadius = isAndroid
        ? indicatorBorderRadius + 2
        : indicatorBorderRadius;

    final segmented = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: GBTSpacing.minTouchTarget),
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
        padding: resolvedPadding,
        decoration: BoxDecoration(
          color: isAndroid
              ? (isDark
                    ? GBTColors.darkSurfaceElevated
                    : GBTColors.surface.withValues(alpha: 0.95))
              : (isDark
                    ? GBTColors.darkSurfaceVariant
                    : GBTColors.surfaceVariant),
          borderRadius: BorderRadius.circular(containerRadius),
          border: Border.all(
            color: isDark
                ? GBTColors.darkBorder
                : GBTColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: isAndroid
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: TabBar(
          controller: controller,
          isScrollable: isScrollable,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (!isAndroid) return null;
            if (states.contains(WidgetState.pressed)) {
              return activeColor.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return activeColor.withValues(alpha: 0.08);
            }
            return null;
          }),
          indicator: BoxDecoration(
            color: activeColor.withValues(
              alpha: isAndroid ? (isDark ? 0.28 : 0.2) : (isDark ? 0.22 : 0.14),
            ),
            borderRadius: BorderRadius.circular(indicatorRadius),
            border: Border.all(
              color: activeColor.withValues(
                alpha: isAndroid
                    ? (isDark ? 0.58 : 0.36)
                    : (isDark ? 0.5 : 0.32),
              ),
              width: 1,
            ),
            boxShadow: indicatorShadow
                ? [
                    BoxShadow(
                      color: activeColor.withValues(
                        alpha: isAndroid ? 0.22 : 0.18,
                      ),
                      blurRadius: isAndroid ? 12 : 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: activeColor,
          unselectedLabelColor: isDark
              ? GBTColors.darkTextTertiary
              : GBTColors.textTertiary,
          labelStyle: resolvedLabelStyle,
          unselectedLabelStyle: resolvedUnselectedLabelStyle,
          labelPadding: resolvedLabelPadding,
          tabs: tabs,
        ),
      ),
    );

    if (height == null) {
      return segmented;
    }
    return SizedBox(height: height, child: segmented);
  }
}
