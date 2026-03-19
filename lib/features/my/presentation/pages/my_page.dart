/// EN: "유저" tab — visual-first hub with XP ring, stat strip, 2-column action grid.
/// KO: "유저" 탭 — XP 링, 통계 스트립, 2열 액션 그리드의 시각적 허브.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../fan_level/application/fan_level_controller.dart';
import '../../../settings/application/settings_controller.dart';
import '../widgets/action_cell.dart';
import '../widgets/check_in_card.dart';
import '../widgets/settings_card.dart';
import '../widgets/stat_strip.dart';
import '../widgets/user_hero_card.dart';

// ===========================================================================
// EN: Page root
// KO: 페이지 루트
// ===========================================================================

/// EN: Root widget for the "유저" tab.
/// KO: "유저" 탭의 루트 위젯.
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EN: Derive dark mode once and pass down to avoid repeated Theme.of calls.
    // KO: 다크 모드를 한 번 계산해 하위 위젯에 전달, 반복 Theme.of 호출 방지.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarUrl =
        ref.watch(userProfileControllerProvider).valueOrNull?.avatarUrl;

    return Scaffold(
      backgroundColor:
          isDark ? GBTColors.darkBackground : GBTColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? GBTColors.darkSurface : GBTColors.surface,
        titleSpacing: GBTSpacing.md,
        title: Text(
          context.l10n(ko: '유저', en: 'My', ja: 'マイ'),
          style: GBTTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
          ),
        ),
        actions: [GBTProfileAction(avatarUrl: avatarUrl)],
      ),
      body: RefreshIndicator(
        color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
        onRefresh: () async {
          await ref.read(fanLevelControllerProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.pageHorizontal,
            vertical: GBTSpacing.md,
          ),
          children: [
            // EN: Hero fan-level card with XP ring + grade info.
            // KO: XP 링과 등급 정보가 있는 히어로 팬레벨 카드.
            UserHeroCard(isDark: isDark),
            const SizedBox(height: GBTSpacing.sm),

            // EN: Three-tile stat strip — streak, XP, rank.
            // KO: 3개 통계 타일 스트립 — 연속 출석, XP, 랭킹.
            StatStrip(isDark: isDark),
            const SizedBox(height: GBTSpacing.sm),

            // EN: Daily check-in button — below XP section.
            // KO: 일일 출석 체크 버튼 — XP 섹션 아래 배치.
            CheckInCard(isDark: isDark),
            const SizedBox(height: GBTSpacing.lg),

            // EN: Section: Explore & Plan
            // KO: 탐색 & 계획 섹션
            _SectionLabel(
              label: context.l10n(
                ko: '탐방 & 계획',
                en: 'Explore & Plan',
                ja: '探索 & 計画',
              ),
              isDark: isDark,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ActionCell(
                    icon: Icons.calendar_month_outlined,
                    label: context.l10n(
                      ko: '이벤트 달력',
                      en: 'Calendar',
                      ja: 'カレンダー',
                    ),
                    subtitle: context.l10n(
                      ko: '라이브 & 이벤트 일정',
                      en: 'Lives & events',
                      ja: 'ライブ・イベント',
                    ),
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                    isDark: isDark,
                    onTap: () => context.pushNamed(AppRoutes.calendar),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),
                Expanded(
                  child: ActionCell(
                    icon: Icons.pin_drop_outlined,
                    label: context.l10n(
                      ko: '방문 기록',
                      en: 'Visit Log',
                      ja: '訪問記録',
                    ),
                    subtitle: context.l10n(
                      ko: '성지순례 기록',
                      en: 'Pilgrimage log',
                      ja: '巡礼記録',
                    ),
                    color: isDark
                        ? const Color(0xFF2DD4BF)
                        : GBTColors.accentTeal,
                    isDark: isDark,
                    onTap: () => context.goToVisitHistory(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.lg),

            // EN: Section: My Collection
            // KO: 나의 컬렉션 섹션
            _SectionLabel(
              label: context.l10n(
                ko: '나의 컬렉션',
                en: 'My Collection',
                ja: 'マイコレクション',
              ),
              isDark: isDark,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ActionCell(
                    icon: Icons.star_outline_rounded,
                    label: context.l10n(
                      ko: '즐겨찾기',
                      en: 'Favorites',
                      ja: 'お気に入り',
                    ),
                    subtitle: context.l10n(
                      ko: '저장한 장소',
                      en: 'Saved places',
                      ja: '保存した場所',
                    ),
                    color: isDark ? GBTColors.darkAccent : GBTColors.accent,
                    isDark: isDark,
                    onTap: () => context.pushNamed(AppRoutes.favorites),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),
                Expanded(
                  child: ActionCell(
                    icon: Icons.bookmark_outline_rounded,
                    label: context.l10n(
                      ko: '북마크',
                      en: 'Bookmarks',
                      ja: 'ブックマーク',
                    ),
                    subtitle: context.l10n(
                      ko: '저장한 게시글',
                      en: 'Saved posts',
                      ja: '保存した投稿',
                    ),
                    color: isDark
                        ? GBTColors.darkSecondary
                        : GBTColors.secondary,
                    isDark: isDark,
                    onTap: () => context.goToPostBookmarks(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.lg),

            // EN: Settings entry — neutral, at the bottom.
            // KO: 설정 진입 — 중립 색상, 하단 배치.
            SettingsCard(
              isDark: isDark,
              onTap: () => context.goToSettings(),
            ),
            const SizedBox(height: GBTSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// EN: Section label widget.
// KO: 섹션 라벨 위젯.
// ===========================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GBTTypography.labelMedium.copyWith(
        color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}
