/// EN: Fan level (덕력) page — shows grade badge, XP, progress bar,
///     recent activities, and daily check-in button.
/// KO: 팬 레벨(덕력) 페이지 — 등급 배지, XP, 진행 바,
///     최근 활동 목록, 일일 출석 체크 버튼을 표시합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/fan_level_controller.dart';
import '../../domain/entities/fan_level.dart';

/// EN: Root page widget for the fan level (덕력) feature.
/// KO: 팬 레벨(덕력) 기능의 루트 페이지 위젯.
class FanLevelPage extends ConsumerWidget {
  const FanLevelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(fanLevelControllerProvider);

    return Scaffold(
      backgroundColor:
          isDark ? GBTColors.darkBackground : GBTColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? GBTColors.darkSurface : GBTColors.surface,
        title: Text(
          context.l10n(
            ko: '나의 덕력',
            en: 'Fan Level',
            ja: 'ファンレベル',
          ),
          style: GBTTypography.titleLarge.copyWith(
            color: isDark
                ? GBTColors.darkTextPrimary
                : GBTColors.textPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: state.when(
        loading: () => _buildShimmer(isDark),
        error: (_, __) => GBTErrorState(
          message: context.l10n(
            ko: '덕력 정보를 불러오지 못했어요',
            en: 'Could not load fan level',
            ja: 'ファンレベルを読み込めませんでした',
          ),
          onRetry: () =>
              ref.read(fanLevelControllerProvider.notifier).refresh(),
        ),
        data: (profile) => profile == null
            ? GBTEmptyState(
                message: context.l10n(
                  ko: '아직 덕력 정보가 없어요',
                  en: 'No fan level data yet',
                  ja: 'ファンレベルデータはまだありません',
                ),
              )
            : _FanLevelContent(profile: profile),
      ),
    );
  }

  /// EN: Builds a shimmer skeleton while profile data is loading.
  /// KO: 프로필 데이터 로딩 중에 쉬머 스켈레톤을 구성합니다.
  Widget _buildShimmer(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
      child: Column(
        children: [
          GBTShimmer(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: isDark
                    ? GBTColors.darkSurfaceVariant
                    : GBTColors.surfaceVariant,
                borderRadius:
                    BorderRadius.circular(GBTSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          GBTShimmer(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? GBTColors.darkSurfaceVariant
                    : GBTColors.surfaceVariant,
                borderRadius:
                    BorderRadius.circular(GBTSpacing.radiusSm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EN: Main content — shown once profile data is available.
// KO: 메인 콘텐츠 — 프로필 데이터가 준비되면 표시됩니다.
// =============================================================================

class _FanLevelContent extends ConsumerStatefulWidget {
  const _FanLevelContent({required this.profile});

  final FanLevelProfile profile;

  @override
  ConsumerState<_FanLevelContent> createState() =>
      _FanLevelContentState();
}

class _FanLevelContentState extends ConsumerState<_FanLevelContent> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.profile;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(fanLevelControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
        children: [
          _GradeCard(profile: profile),
          if (profile.recentActivities.isNotEmpty) ...[
            const SizedBox(height: GBTSpacing.lg),
            Text(
              context.l10n(
                ko: '최근 활동',
                en: 'Recent Activities',
                ja: '最近のアクティビティ',
              ),
              style: GBTTypography.titleMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            ...profile.recentActivities.map(
              (activity) => _ActivityTile(activity: activity),
            ),
          ],
          const SizedBox(height: GBTSpacing.xl),
        ],
      ),
    );
  }
}

// =============================================================================
// EN: Grade card — shows badge, total XP, and progress bar.
// KO: 등급 카드 — 배지, 총 XP, 진행 바를 표시합니다.
// =============================================================================

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.profile});

  final FanLevelProfile profile;

  // EN: Returns the accent color for the given grade and brightness.
  // KO: 주어진 등급과 밝기에 맞는 강조 색상을 반환합니다.
  Color _gradeColor(FanGrade grade, bool isDark) {
    return switch (grade) {
      FanGrade.newbie => isDark
          ? const Color(0xFF9CA3AF)
          : const Color(0xFF6B7280),
      FanGrade.beginner => isDark
          ? const Color(0xFF34D399)
          : const Color(0xFF059669),
      FanGrade.enthusiast => isDark
          ? const Color(0xFF60A5FA)
          : const Color(0xFF2563EB),
      FanGrade.devotee => isDark
          ? const Color(0xFFA78BFA)
          : const Color(0xFF7C3AED),
      FanGrade.master => isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706),
      FanGrade.legend => isDark
          ? const Color(0xFFF87171)
          : const Color(0xFFDC2626),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradeColor = _gradeColor(profile.grade, isDark);
    final gradeLabel = context.l10n(
      ko: profile.grade.koLabel,
      en: profile.grade.enLabel,
      ja: profile.grade.enLabel,
    );

    return Semantics(
      label: context.l10n(
        ko: '팬 레벨: $gradeLabel, 총 XP: ${profile.totalXp}',
        en: 'Fan level: $gradeLabel, Total XP: ${profile.totalXp}',
        ja: 'ファンレベル: $gradeLabel, 合計XP: ${profile.totalXp}',
      ),
      child: Container(
        padding: const EdgeInsets.all(GBTSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurface : GBTColors.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          border: Border.all(
            color: gradeColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // EN: Grade badge chip
                // KO: 등급 배지 칩
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.sm,
                    vertical: GBTSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(GBTSpacing.radiusXs),
                  ),
                  child: Text(
                    gradeLabel,
                    style: GBTTypography.labelMedium.copyWith(
                      color: gradeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n(
                    ko: '순위 #${profile.rank}',
                    en: 'Rank #${profile.rank}',
                    ja: 'ランク #${profile.rank}',
                  ),
                  style: GBTTypography.bodySmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.md),
            // EN: Total XP display
            // KO: 총 XP 표시
            Text(
              '${profile.totalXp} XP',
              style: GBTTypography.displayMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            if (profile.grade != FanGrade.legend) ...[
              // EN: XP progress bar toward the next level
              // KO: 다음 레벨까지의 XP 진행 바
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: profile.progressRatio,
                  backgroundColor: isDark
                      ? GBTColors.darkSurfaceVariant
                      : GBTColors.surfaceVariant,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(gradeColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: GBTSpacing.xs),
              Text(
                '${profile.currentLevelXp} / ${profile.nextLevelXp} XP',
                style: GBTTypography.bodySmall.copyWith(
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                ),
              ),
            ] else
              Text(
                context.l10n(
                  ko: '최고 등급 달성!',
                  en: 'Max level reached!',
                  ja: '最高レベル達成!',
                ),
                style: GBTTypography.bodySmall.copyWith(
                  color: gradeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EN: Activity tile — single row in the recent activities list.
// KO: 활동 타일 — 최근 활동 목록의 단일 행.
// =============================================================================

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final FanActivity activity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateLabel = DateFormat('MM.dd').format(activity.earnedAt);

    return Semantics(
      label: context.l10n(
        ko:
            '${activity.type.koLabel}, +${activity.xpEarned} XP, $dateLabel',
        en:
            '${activity.type.koLabel}, +${activity.xpEarned} XP, $dateLabel',
        ja:
            '${activity.type.koLabel}, +${activity.xpEarned} XP, $dateLabel',
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
        child: Row(
          children: [
            // EN: Activity type icon badge
            // KO: 활동 유형 아이콘 배지
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? GBTColors.darkSurfaceVariant
                    : GBTColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bolt_outlined,
                size: 18,
                color: isDark
                    ? GBTColors.darkPrimary
                    : GBTColors.primary,
              ),
            ),
            const SizedBox(width: GBTSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.type.koLabel,
                    style: GBTTypography.bodySmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextPrimary
                          : GBTColors.textPrimary,
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: GBTTypography.labelSmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // EN: XP earned label
            // KO: 획득 XP 라벨
            Text(
              '+${activity.xpEarned} XP',
              style: GBTTypography.labelMedium.copyWith(
                color: isDark
                    ? GBTColors.darkPrimary
                    : GBTColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
