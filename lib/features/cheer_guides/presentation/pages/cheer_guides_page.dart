/// EN: Cheer guides list page — browse all available cheer guides.
/// KO: 응원 가이드 목록 페이지 — 모든 응원 가이드 탐색.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/cheer_guides_controller.dart';
import '../../domain/entities/cheer_guide.dart';

/// EN: Displays the cheer guide list screen for the selected project.
/// KO: 선택된 프로젝트의 응원 가이드 목록 화면을 표시합니다.
class CheerGuidesPage extends ConsumerWidget {
  const CheerGuidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectId = ref.watch(selectedProjectKeyProvider);
    final effectiveProjectId =
        projectId?.isNotEmpty == true ? projectId : null;
    final guidesAsync = ref.watch(
      cheerGuidesListProvider(effectiveProjectId),
    );

    return Scaffold(
      backgroundColor:
          isDark ? GBTColors.darkBackground : GBTColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? GBTColors.darkSurface : GBTColors.surface,
        title: Text(
          context.l10n(
            ko: '응원 가이드',
            en: 'Cheer Guide',
            ja: '応援ガイド',
          ),
          style: GBTTypography.titleLarge.copyWith(
            color:
                isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: guidesAsync.when(
        loading: () => _CheerGuidesShimmer(),
        error: (_, __) => Center(
          child: GBTEmptyState(
            icon: Icons.wifi_off_rounded,
            message: context.l10n(
              ko: '응원 가이드를 불러오지 못했어요',
              en: 'Could not load cheer guides',
              ja: '応援ガイドを読み込めませんでした',
            ),
            actionLabel: context.l10n(
              ko: '다시 시도',
              en: 'Retry',
              ja: '再試行',
            ),
            onAction: () => ref.refresh(
              cheerGuidesListProvider(effectiveProjectId),
            ),
          ),
        ),
        data: (guides) => guides.isEmpty
            ? Center(
                child: GBTEmptyState(
                  message: context.l10n(
                    ko: '아직 응원 가이드가 없어요',
                    en: 'No cheer guides yet',
                    ja: '応援ガイドはまだありません',
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
                itemCount: guides.length,
                itemBuilder: (context, index) {
                  final guide = guides[index];
                  return _CheerGuideTile(
                    guide: guide,
                    onTap: () => context.pushNamed(
                      AppRoutes.cheerGuideDetail,
                      pathParameters: {'guideId': guide.id},
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// EN: Shimmer skeleton shown while the guide list is loading.
/// KO: 가이드 목록 로딩 중 표시되는 쉬머 스켈레톤.
class _CheerGuidesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
        child: GBTShimmer(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: List tile for a single cheer guide summary.
/// KO: 단일 응원 가이드 요약을 위한 목록 타일.
class _CheerGuideTile extends StatelessWidget {
  const _CheerGuideTile({required this.guide, required this.onTap});

  final CheerGuideSummary guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: guide.songTitle,
      child: Padding(
        padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? GBTColors.darkSurface : GBTColors.surface,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
            child: Row(
              children: [
                // EN: Music icon avatar
                // KO: 음악 아이콘 아바타
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? GBTColors.darkPrimary.withValues(alpha: 0.15)
                        : GBTColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      GBTSpacing.radiusXs,
                    ),
                  ),
                  child: Icon(
                    Icons.music_note_outlined,
                    color: isDark
                        ? GBTColors.darkPrimary
                        : GBTColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: GBTSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        guide.songTitle,
                        style: GBTTypography.bodyMedium.copyWith(
                          color: isDark
                              ? GBTColors.darkTextPrimary
                              : GBTColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (guide.artistName != null) ...[
                        const SizedBox(height: GBTSpacing.xxs),
                        Text(
                          guide.artistName!,
                          style: GBTTypography.bodySmall.copyWith(
                            color: isDark
                                ? GBTColors.darkTextSecondary
                                : GBTColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // EN: Difficulty stars (1–5)
                // KO: 난이도 별점 (1–5)
                if (guide.difficulty != null)
                  Padding(
                    padding: const EdgeInsets.only(right: GBTSpacing.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (i) {
                        final filled = i < guide.difficulty!;
                        return Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: filled
                              ? (isDark
                                  ? GBTColors.darkPrimary
                                  : GBTColors.primary)
                              : (isDark
                                  ? GBTColors.darkSurfaceVariant
                                  : GBTColors.surfaceVariant),
                        );
                      }),
                    ),
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: GBTSpacing.iconSm,
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
