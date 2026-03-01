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
  });

  final List<Widget> tabs;
  final TabController? controller;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        indicator: BoxDecoration(
          color: isDark ? GBTColors.darkSurface : GBTColors.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm + 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
        unselectedLabelColor: isDark
            ? GBTColors.darkTextTertiary
            : GBTColors.textTertiary,
        labelStyle: GBTTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GBTTypography.labelLarge,
        tabs: tabs,
      ),
    );
  }
}
