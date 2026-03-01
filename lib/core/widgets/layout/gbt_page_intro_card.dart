/// EN: Standard intro card shown at the top of feature pages.
/// KO: 기능 페이지 상단에 표시하는 표준 인트로 카드입니다.
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: Intro card that provides page context and optional trailing widget.
/// KO: 페이지 맥락과 선택적 우측 위젯을 제공하는 인트로 카드입니다.
class GBTPageIntroCard extends StatelessWidget {
  const GBTPageIntroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final iconBg = iconColor.withValues(alpha: isDark ? 0.24 : 0.16);
    final descColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GBTSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: GBTSpacing.xl,
              height: GBTSpacing.xl,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: GBTSpacing.iconMd),
            ),
            const SizedBox(width: GBTSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    description,
                    style: GBTTypography.bodySmall.copyWith(color: descColor),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: GBTSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
