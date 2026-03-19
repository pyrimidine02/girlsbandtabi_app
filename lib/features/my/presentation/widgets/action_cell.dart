/// EN: 2-column action cell for navigation items.
/// KO: 네비게이션 항목용 2열 액션 셀.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_decorations.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';

/// EN: Tappable action cell with icon, label, and subtitle for 2-column grids.
/// KO: 2열 그리드용 아이콘·라벨·서브타이틀이 있는 탭 가능한 액션 셀.
class ActionCell extends StatelessWidget {
  const ActionCell({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(GBTSpacing.md),
          decoration: GBTDecorations.card(isDark: isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Colored icon container — visual anchor for the action.
              // KO: 색상 아이콘 컨테이너 — 액션의 시각적 앵커.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                label,
                style: GBTTypography.bodyMedium.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GBTTypography.labelSmall.copyWith(
                  color: textTertiary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
