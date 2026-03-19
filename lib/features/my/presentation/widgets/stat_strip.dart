/// EN: Stat strip — three equal tiles showing streak, XP, rank.
/// KO: 통계 스트립 — 연속 출석·XP·랭킹을 보여주는 동일 너비 3개 타일.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_decorations.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../fan_level/application/fan_level_controller.dart';

// EN: Format XP with thousands separators.
// KO: XP 값에 천 단위 구분자를 삽입합니다.
String _fmtXp(int xp) => xp.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]},',
);

/// EN: Three-tile stat strip showing streak, total XP, and rank.
/// KO: 연속 출석, XP 합계, 랭킹을 표시하는 3타일 통계 스트립.
class StatStrip extends ConsumerWidget {
  const StatStrip({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(fanLevelControllerProvider).valueOrNull;
    final streak = profile?.consecutiveDays ?? 0;
    final totalXp = profile?.totalXp ?? 0;
    final rank = profile?.rank ?? 0;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '$streak',
            label: context.l10n(ko: '연속 출석', en: 'Day streak', ja: '連続'),
            icon: Icons.local_fire_department_rounded,
            color: isDark ? GBTColors.darkAccent : GBTColors.accent,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _StatTile(
            value: _fmtXp(totalXp),
            label: 'XP',
            icon: Icons.bolt_rounded,
            color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _StatTile(
            value: rank > 0 ? '#$rank' : '—',
            label: context.l10n(ko: '랭킹', en: 'Rank', ja: 'ランク'),
            icon: Icons.emoji_events_outlined,
            color: isDark ? GBTColors.darkSecondary : GBTColors.secondary,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: GBTSpacing.md,
        horizontal: GBTSpacing.sm,
      ),
      decoration: GBTDecorations.card(isDark: isDark),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // EN: Colored icon at top of each tile.
          // KO: 각 타일 상단의 컬러 아이콘.
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(
            value,
            style: GBTTypography.titleSmall.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GBTTypography.labelSmall.copyWith(
              color: textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
