/// EN: Standard app bar helper aligned with the Info/My tab top-bar design.
/// KO: 정보/유저 탭 상단바 디자인 기준에 맞춘 표준 앱바 헬퍼입니다.
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_typography.dart';

/// EN: Builds a flat app bar with the shared top-bar style.
/// KO: 공통 상단바 스타일을 적용한 플랫 앱바를 구성합니다.
AppBar gbtStandardAppBar(
  BuildContext context, {
  String? title,
  Widget? titleWidget,
  Widget? leading,
  bool automaticallyImplyLeading = true,
  double? titleSpacing,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  assert(
    title != null || titleWidget != null,
    'Either title or titleWidget must be provided.',
  );
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final resolvedTitle =
      titleWidget ??
      Text(
        title!,
        style: GBTTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
        ),
      );
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: isDark ? GBTColors.darkSurface : GBTColors.surface,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    titleSpacing: titleSpacing,
    title: resolvedTitle,
    actions: actions,
    bottom: bottom,
  );
}
