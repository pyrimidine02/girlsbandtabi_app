/// EN: Info page with tabbed sections — news, units, members, songs.
/// KO: 탭 구조의 정보 페이지 — 소식, 유닛, 멤버, 악곡.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Info page widget with pill-style segmented tab bar.
/// KO: 필 스타일 세그먼트 탭바가 있는 정보 페이지 위젯.
class InfoPage extends ConsumerStatefulWidget {
  const InfoPage({super.key});

  @override
  ConsumerState<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends ConsumerState<InfoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshCurrentTab() async {
    switch (_tabController.index) {
      case 0:
        await ref
            .read(newsListControllerProvider.notifier)
            .load(forceRefresh: true);
        return;
      case 1:
        final selection = ref.read(projectSelectionControllerProvider);
        final projectKey = selection.projectKey;
        if (projectKey == null || projectKey.isEmpty) return;
        await ref
            .read(projectUnitsControllerProvider(projectKey).notifier)
            .load(forceRefresh: true);
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보'),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.refresh,
            tooltip: '새로고침',
            onPressed: _refreshCurrentTab,
          ),
          const GBTProfileAction(),
        ],
        // EN: Scrollable tab bar with modern styling
        // KO: 모던 스타일의 스크롤 가능한 탭바
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.md,
                ),
                children: List.generate(4, (index) {
                  const labels = ['소식', '유닛', '멤버', '악곡'];
                  const icons = [
                    Icons.newspaper_outlined,
                    Icons.groups_outlined,
                    Icons.person_outlined,
                    Icons.music_note_outlined,
                  ];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < 3 ? GBTSpacing.sm : 0,
                    ),
                    child: _InfoTabChip(
                      icon: icons[index],
                      label: labels[index],
                      isSelected: _tabController.index == index,
                      onTap: () {
                        _tabController.animateTo(index);
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // EN: Project selector — compact, consistent with other pages
          // KO: 프로젝트 선택기 — 컴팩트, 다른 페이지와 일관
          const Padding(
            padding: EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              0,
            ),
            child: ProjectSelectorCompact(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCurrentTab,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _NewsTab(),
                  _UnitsTab(),
                  _MembersTab(),
                  _SongsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Info tab chip — modern pill-style filter button.
/// KO: 정보 탭 칩 — 모던 필 스타일 필터 버튼.
class _InfoTabChip extends StatelessWidget {
  const _InfoTabChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? (isDark ? GBTColors.darkPrimary : GBTColors.primary)
        : Colors.transparent;
    final fgColor = isSelected
        ? Colors.white
        : (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);
    final borderColor = isSelected
        ? Colors.transparent
        : (isDark
            ? GBTColors.darkTextTertiary.withValues(alpha: 0.3)
            : GBTColors.textTertiary.withValues(alpha: 0.3));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: GBTSpacing.xs),
            Text(
              label,
              style: GBTTypography.labelMedium.copyWith(
                color: fgColor,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: News tab — divider-separated, borderless
// KO: 소식 탭 — 구분선 분리, 무테두리
// ========================================

class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsListControllerProvider);

    return newsState.when(
      loading: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: GBTSpacing.paddingPage,
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTLoading(message: '뉴스를 불러오는 중...'),
        ],
      ),
      error: (error, _) {
        final message =
            error is Failure ? error.userMessage : '뉴스를 불러오지 못했어요';
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(
              message: message,
              onRetry: () => ref
                  .read(newsListControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
          ],
        );
      },
      data: (newsList) {
        if (newsList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(message: '표시할 뉴스가 없습니다'),
            ],
          );
        }

        // EN: Divider-separated news list — consistent with feed & board pages
        // KO: 구분선 분리 뉴스 리스트 — 피드 & 게시판 페이지와 일관
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
          itemCount: newsList.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            indent: GBTSpacing.pageHorizontal,
            endIndent: GBTSpacing.pageHorizontal,
          ),
          itemBuilder: (context, index) {
            final news = newsList[index];
            return _NewsCardBorderless(news: news);
          },
        );
      },
    );
  }
}

/// EN: Borderless news card for info page — consistent with feed_page.
/// KO: 정보 페이지용 무테두리 뉴스 카드 — feed_page와 일관.
class _NewsCardBorderless extends StatelessWidget {
  const _NewsCardBorderless({required this.news});

  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final thumbnail = news.thumbnailUrl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return InkWell(
      onTap: () => context.goToNewsDetail(news.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.pageHorizontal,
          vertical: GBTSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Square thumbnail — 80x80
            // KO: 정사각 썸네일 — 80x80
            _InfoNewsThumbnail(imageUrl: thumbnail),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: GBTTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? GBTColors.darkTextPrimary
                          : GBTColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    news.dateLabel,
                    style: GBTTypography.labelSmall.copyWith(
                      color: tertiaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: News thumbnail widget for info page.
/// KO: 정보 페이지용 뉴스 썸네일 위젯.
class _InfoNewsThumbnail extends StatelessWidget {
  const _InfoNewsThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
        child: Icon(
          Icons.article_outlined,
          color:
              isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          size: 28,
        ),
      );
    }

    return GBTImage(
      imageUrl: imageUrl!,
      width: 80,
      height: 80,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      semanticLabel: '뉴스 썸네일',
    );
  }
}

// ========================================
// EN: Units tab — Fandom wiki-style 2-column grid
// KO: 유닛 탭 — Fandom 위키 스타일 2컬럼 그리드
// ========================================

/// EN: Deterministic palette for unit avatar backgrounds.
/// KO: 유닛 아바타 배경을 위한 결정적 팔레트.
const _avatarPalette = [
  Color(0xFF6366F1), // indigo
  Color(0xFF3B82F6), // blue
  Color(0xFFEC4899), // pink
  Color(0xFFF59E0B), // amber
  Color(0xFF10B981), // emerald
  Color(0xFF8B5CF6), // violet
];

class _UnitsTab extends ConsumerWidget {
  const _UnitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(projectSelectionControllerProvider);
    final projectKey = selection.projectKey;

    if (projectKey == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTEmptyState(
            icon: Icons.groups_outlined,
            message: '프로젝트를 먼저 선택해주세요',
          ),
        ],
      );
    }

    final unitsState = ref.watch(projectUnitsControllerProvider(projectKey));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return unitsState.when(
      loading: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: GBTSpacing.paddingPage,
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTLoading(message: '유닛을 불러오는 중...'),
        ],
      ),
      error: (error, _) {
        final message =
            error is Failure ? error.userMessage : '유닛을 불러오지 못했어요';
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(
              message: message,
              onRetry: () => ref
                  .read(
                      projectUnitsControllerProvider(projectKey).notifier)
                  .load(forceRefresh: true),
            ),
          ],
        );
      },
      data: (units) {
        if (units.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(
                icon: Icons.groups_outlined,
                message: '등록된 유닛이 없습니다',
              ),
            ],
          );
        }

        // EN: Fandom wiki-style 2-column grid — each cell has a colored avatar
        //     and unit info. paletteColor is derived deterministically from
        //     the unit's display name hash to ensure consistency across rebuilds.
        // KO: Fandom 위키 스타일 2컬럼 그리드 — 각 셀에 컬러 아바타와 유닛 정보 표시.
        //     paletteColor는 유닛 displayName 해시로 결정적으로 선택되어
        //     재빌드 시에도 동일한 색상이 유지됩니다.
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(GBTSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: GBTSpacing.sm,
            mainAxisSpacing: GBTSpacing.sm,
          ),
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            final paletteColor = _avatarPalette[
                unit.displayName.hashCode.abs() % _avatarPalette.length];

            return _UnitGridCell(
              unit: unit,
              paletteColor: paletteColor,
              isDark: isDark,
            );
          },
        );
      },
    );
  }
}

/// EN: Single grid cell for the units 2-column Fandom-style grid.
///     Displays a large circular initial avatar, the unit name, and its code.
/// KO: 유닛 2컬럼 Fandom 스타일 그리드의 단일 셀.
///     큰 원형 이니셜 아바타, 유닛 이름, 코드를 표시합니다.
class _UnitGridCell extends StatelessWidget {
  const _UnitGridCell({
    required this.unit,
    required this.paletteColor,
    required this.isDark,
  });

  // EN: The unit entity to display.
  // KO: 표시할 유닛 엔티티.
  final dynamic unit;

  // EN: Deterministic accent color derived from the unit name hash.
  // KO: 유닛 이름 해시로 결정된 악센트 색상.
  final Color paletteColor;

  // EN: Whether the current theme is dark mode.
  // KO: 현재 테마가 다크 모드인지 여부.
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // EN: Alpha values for background and border differ by mode for legibility.
    // KO: 가독성을 위해 배경과 테두리 알파값을 모드별로 다르게 설정.
    final bgAlpha = isDark ? 0.25 : 0.15;
    final borderAlpha = 0.30;

    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    // EN: Initial letter for the avatar — uppercase first character of display name.
    // KO: 아바타에 표시할 이니셜 — displayName의 첫 글자 대문자.
    final initial = unit.displayName.isNotEmpty
        ? unit.displayName[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: paletteColor.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: paletteColor.withValues(alpha: borderAlpha),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(GBTSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EN: Large circular avatar — 56x56, solid paletteColor, white initial text.
              // KO: 큰 원형 아바타 — 56x56, 단색 paletteColor 배경, 흰색 이니셜 텍스트.
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: paletteColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              // EN: Unit display name — semibold body text, max 2 lines.
              // KO: 유닛 표시 이름 — 세미볼드 본문 텍스트, 최대 2줄.
              Text(
                unit.displayName,
                style: GBTTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // EN: Unit code — small tertiary label below the name.
              // KO: 유닛 코드 — 이름 아래에 작은 3차 레이블.
              Text(
                unit.code,
                style: GBTTypography.labelSmall.copyWith(
                  color: textTertiary,
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

// ========================================
// EN: Members tab — visually rich coming-soon placeholder
// KO: 멤버 탭 — 시각적으로 풍부한 준비 중 플레이스홀더
// ========================================

class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EN: Icon and text colors based on current theme brightness.
    // KO: 현재 테마 밝기에 따른 아이콘 및 텍스트 색상.
    final surfaceVariantColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final iconColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: GBTSpacing.xl),
        // EN: Circular icon container — 80x80, surfaceVariant bg, people icon.
        // KO: 원형 아이콘 컨테이너 — 80x80, surfaceVariant 배경, 사람 아이콘.
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: surfaceVariantColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_outlined,
              size: 40,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.md),
        // EN: Section title — semi-bold, primary text color.
        // KO: 섹션 타이틀 — 세미볼드, 기본 텍스트 색상.
        Center(
          child: Text(
            '멤버 소개',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        // EN: Subtitle — tertiary color to indicate upcoming content.
        // KO: 부제목 — 준비 중 콘텐츠를 나타내는 3차 색상.
        Center(
          child: Text(
            '곧 만나볼 수 있어요',
            style: GBTTypography.bodySmall.copyWith(
              color: textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// EN: Songs tab — visually rich coming-soon placeholder
// KO: 악곡 탭 — 시각적으로 풍부한 준비 중 플레이스홀더
// ========================================

class _SongsTab extends StatelessWidget {
  const _SongsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EN: Icon and text colors based on current theme brightness.
    // KO: 현재 테마 밝기에 따른 아이콘 및 텍스트 색상.
    final surfaceVariantColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final iconColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: GBTSpacing.xl),
        // EN: Circular icon container — 80x80, surfaceVariant bg, music queue icon.
        // KO: 원형 아이콘 컨테이너 — 80x80, surfaceVariant 배경, 음악 큐 아이콘.
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: surfaceVariantColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.queue_music_outlined,
              size: 40,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.md),
        // EN: Section title — semi-bold, primary text color.
        // KO: 섹션 타이틀 — 세미볼드, 기본 텍스트 색상.
        Center(
          child: Text(
            '악곡 목록',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        // EN: Subtitle — tertiary color to indicate upcoming content.
        // KO: 부제목 — 준비 중 콘텐츠를 나타내는 3차 색상.
        Center(
          child: Text(
            '준비 중이에요',
            style: GBTTypography.bodySmall.copyWith(
              color: textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
