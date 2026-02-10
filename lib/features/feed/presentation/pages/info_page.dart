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
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Info page widget with TabBar for news, units, members, songs.
/// KO: 소식, 유닛, 멤버, 악곡 탭바가 있는 정보 페이지 위젯.
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('정보'),
        actions: const [GBTProfileAction()],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor:
              isDark ? GBTColors.darkPrimary : GBTColors.primary,
          labelColor:
              isDark ? GBTColors.darkPrimary : GBTColors.primary,
          unselectedLabelColor:
              isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
          labelStyle: GBTTypography.labelLarge,
          unselectedLabelStyle: GBTTypography.labelLarge,
          tabs: const [
            Tab(icon: Icon(Icons.newspaper_outlined), text: '소식'),
            Tab(icon: Icon(Icons.groups_outlined), text: '유닛'),
            Tab(icon: Icon(Icons.person_outlined), text: '멤버'),
            Tab(icon: Icon(Icons.music_note_outlined), text: '악곡'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              0,
            ),
            child: const ProjectSelectorCompact(),
          ),
          Expanded(
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
        ],
      ),
    );
  }
}

// ========================================
// EN: News tab — existing news list logic
// KO: 소식 탭 — 기존 뉴스 리스트 로직
// ========================================

class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsListControllerProvider);

    return newsState.when(
      loading: () => ListView(
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
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(message: '표시할 뉴스가 없습니다'),
            ],
          );
        }

        return ListView.builder(
          padding: GBTSpacing.paddingPage,
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: GBTSpacing.md),
              child: _NewsCard(news: news),
            );
          },
        );
      },
    );
  }
}

// ========================================
// EN: Units tab — band/unit list from API
// KO: 유닛 탭 — API에서 밴드/유닛 목록
// ========================================

/// EN: Deterministic palette for unit avatars.
/// KO: 유닛 아바타용 결정적 팔레트.
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
      return const Center(
        child: GBTEmptyState(
          icon: Icons.groups_outlined,
          message: '프로젝트를 먼저 선택해주세요',
        ),
      );
    }

    final unitsState = ref.watch(projectUnitsControllerProvider(projectKey));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return unitsState.when(
      loading: () => ListView(
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
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(
              message: message,
              onRetry: () => ref
                  .read(
                    projectUnitsControllerProvider(projectKey).notifier,
                  )
                  .load(forceRefresh: true),
            ),
          ],
        );
      },
      data: (units) {
        if (units.isEmpty) {
          return ListView(
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

        return ListView.builder(
          padding: GBTSpacing.paddingPage,
          itemCount: units.length,
          itemBuilder: (context, index) {
            final unit = units[index];
            final paletteColor = _avatarPalette[
                unit.displayName.hashCode.abs() % _avatarPalette.length];

            return Card(
              margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: paletteColor,
                  child: Text(
                    unit.displayName.isNotEmpty
                        ? unit.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  unit.displayName,
                  style: GBTTypography.titleSmall,
                ),
                subtitle: Text(
                  unit.code,
                  style: GBTTypography.bodySmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ========================================
// EN: Members tab — coming soon placeholder
// KO: 멤버 탭 — 준비 중 플레이스홀더
// ========================================

class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: GBTEmptyState(
        icon: Icons.person_outlined,
        message: '멤버 소개를 준비 중입니다',
      ),
    );
  }
}

// ========================================
// EN: Songs tab — coming soon placeholder
// KO: 악곡 탭 — 준비 중 플레이스홀더
// ========================================

class _SongsTab extends StatelessWidget {
  const _SongsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: GBTEmptyState(
        icon: Icons.music_note_outlined,
        message: '악곡 소개를 준비 중입니다',
      ),
    );
  }
}

// ========================================
// EN: News card widget
// KO: 뉴스 카드 위젯
// ========================================

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final thumbnail = news.thumbnailUrl;
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.goToNewsDetail(news.id),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Padding(
          padding: GBTSpacing.paddingMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NewsThumbnail(imageUrl: thumbnail),
              const SizedBox(width: GBTSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: GBTTypography.titleSmall,
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
      ),
    );
  }
}

/// EN: News thumbnail widget.
/// KO: 뉴스 썸네일 위젯.
class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    // EN: Use theme-aware placeholder colors.
    // KO: 테마 인식 플레이스홀더 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: Icon(
          Icons.image,
          color:
              isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
      );
    }

    return GBTImage(
      imageUrl: imageUrl!,
      width: 100,
      height: 70,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      semanticLabel: '뉴스 썸네일',
    );
  }
}
