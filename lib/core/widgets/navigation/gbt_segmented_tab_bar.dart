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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final resolvedLabelStyle = (labelStyle ?? GBTTypography.labelLarge)
        .copyWith(fontWeight: FontWeight.w600);
    final resolvedUnselectedLabelStyle =
        unselectedLabelStyle ?? labelStyle ?? GBTTypography.labelLarge;

    final segmented = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: GBTSpacing.minTouchTarget),
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
        padding: padding,
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark
                ? GBTColors.darkBorder
                : GBTColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: isScrollable,
          indicator: BoxDecoration(
            color: activeColor.withValues(alpha: isDark ? 0.22 : 0.14),
            borderRadius: BorderRadius.circular(indicatorBorderRadius),
            border: Border.all(
              color: activeColor.withValues(alpha: isDark ? 0.5 : 0.32),
              width: 1,
            ),
            boxShadow: indicatorShadow
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
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
          labelPadding: labelPadding,
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
