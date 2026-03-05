/// EN: Board page showing community posts with Toss-style minimal design.
/// KO: 토스 스타일 미니멀 디자인의 커뮤니티 게시글을 표시하는 게시판 페이지.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/image_url_extractor.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_action_icons.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_ban_view_helper.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../application/report_rate_limiter.dart';
import '../../application/user_follow_list_controller.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../widgets/community_report_sheet.dart';

// ========================================
// EN: Board Page — section-driven by sub bottom nav, Toss minimal
// KO: 게시판 페이지 — 서브 하단바로 섹션 결정, 토스 미니멀
// ========================================

/// EN: Board page widget — section content driven by initialTabIndex (from sub bottom nav).
/// KO: 게시판 페이지 위젯 — 서브 하단바의 initialTabIndex로 섹션 콘텐츠를 결정.
class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key, this.initialTabIndex = 0});

  /// EN: Section index — 0: Feed (추천/팔로잉/프로젝트), 1: Discover, 2: Travel Review.
  /// KO: 섹션 인덱스 — 0: 피드(추천/팔로잉/프로젝트), 1: 발견, 2: 여행후기.
  final int initialTabIndex;

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  bool _isFabMenuExpanded = false;

  Future<void> _showMyReportsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _MyReportsSheet(),
    );
  }

  Future<void> _showCommunityBanSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _CommunityBanSheet(),
    );
  }

  void _toggleFabMenu() {
    if (!mounted) return;
    setState(() {
      _isFabMenuExpanded = !_isFabMenuExpanded;
    });
  }

  void _closeFabMenu() {
    if (!_isFabMenuExpanded || !mounted) return;
    setState(() {
      _isFabMenuExpanded = false;
    });
  }

  Future<void> _openSearchSheet(BuildContext context) async {
    final feedState = ref.read(communityFeedControllerProvider);
    final notifier = ref.read(communityFeedControllerProvider.notifier);
    final query = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CommunitySearchSheet(initialQuery: feedState.searchQuery),
    );
    if (!mounted || query == null) return;
    if (query.isEmpty) {
      notifier.clearSearch();
      return;
    }
    notifier.applySearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profileState = ref.watch(userProfileControllerProvider);
    final isAdmin = profileState.maybeWhen(
      data: (profile) => _isAdminRole(profile?.role),
      orElse: () => false,
    );
    final avatarUrl = profileState.valueOrNull?.avatarUrl;

    // EN: Section index determines which content to show (controlled by sub bottom nav).
    // KO: 섹션 인덱스가 표시할 콘텐츠를 결정합니다 (서브 하단바로 제어).
    final sectionIndex = widget.initialTabIndex.clamp(0, 2);
    final sectionTitle = switch (sectionIndex) {
      0 => '피드',
      1 => '발견',
      _ => '여행후기',
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: GBTSpacing.md),
            Text(
              sectionTitle,
              style: GBTTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          // EN: Search icon — hidden on travel review section.
          // KO: 검색 아이콘 — 여행후기 섹션에서는 숨김.
          if (sectionIndex != 2)
            GBTAppBarIconButton(
              icon: Icons.search_rounded,
              tooltip: '검색',
              onPressed: () => _openSearchSheet(context),
            ),
          GBTProfileAction(avatarUrl: avatarUrl),
        ],
      ),
      body: switch (sectionIndex) {
        0 => const _FeedSection(),
        1 => const _CommunityTab(isDiscoverSection: true),
        _ => const _TravelReviewTab(),
      },
      floatingActionButton: _ExpandableActionFab(
        isExpanded: _isFabMenuExpanded,
        onToggle: _toggleFabMenu,
        mainHeroTag: 'board-fab-main',
        actions: [
          if (sectionIndex != 2)
            _FabMenuAction(
              id: 'create-post',
              icon: Icons.edit_outlined,
              label: '게시글 작성',
              onPressed: () {
                _closeFabMenu();
                context.goToPostCreate();
              },
            ),
          if (sectionIndex == 2)
            _FabMenuAction(
              id: 'create-review',
              icon: Icons.rate_review_outlined,
              label: '여행후기 작성',
              onPressed: () {
                _closeFabMenu();
                context.pushNamed(AppRoutes.travelReviewCreate);
              },
            ),
          if (sectionIndex != 2 && isAuthenticated)
            _FabMenuAction(
              id: 'my-reports',
              icon: Icons.flag_outlined,
              label: '내 신고 내역',
              onPressed: () {
                _closeFabMenu();
                _showMyReportsSheet(context);
              },
            ),
          if (sectionIndex != 2 && isAdmin)
            _FabMenuAction(
              id: 'ban',
              icon: Icons.gavel_outlined,
              label: '커뮤니티 제재 관리',
              onPressed: () {
                _closeFabMenu();
                _showCommunityBanSheet(context);
              },
            ),
        ],
      ),
    );
  }
}

// ========================================
// EN: Motion spec constants
// KO: 모션 사양 상수
// ========================================

class _BoardMotionSpec {
  static const Duration micro = Duration(milliseconds: 180);
}

// ========================================
// EN: FAB components
// KO: FAB 컴포넌트
// ========================================

class _FabMenuAction {
  const _FabMenuAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _ExpandableActionFab extends StatelessWidget {
  const _ExpandableActionFab({
    required this.isExpanded,
    required this.onToggle,
    required this.mainHeroTag,
    required this.actions,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final String mainHeroTag;
  final List<_FabMenuAction> actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelBg = isDark
        ? GBTColors.darkSurfaceVariant.withValues(alpha: 0.94)
        : GBTColors.background;
    final labelBorder = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: _BoardMotionSpec.micro,
          child: !isExpanded || actions.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                  child: Column(
                    key: ValueKey(actions.length),
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: actions.reversed.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: GBTSpacing.sm,
                                vertical: GBTSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: labelBg,
                                borderRadius: BorderRadius.circular(
                                  GBTSpacing.radiusFull,
                                ),
                                border: Border.all(color: labelBorder),
                              ),
                              child: Text(
                                action.label,
                                style: GBTTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: GBTSpacing.sm),
                            FloatingActionButton.small(
                              heroTag: 'board-fab-${action.id}',
                              onPressed: action.onPressed,
                              child: Icon(action.icon, size: 18),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        FloatingActionButton(
          heroTag: mainHeroTag,
          onPressed: onToggle,
          tooltip: isExpanded ? '메뉴 닫기' : '작성 메뉴 열기',
          child: Icon(isExpanded ? Icons.close : Icons.edit_outlined),
        ),
      ],
    );
  }
}

// ========================================
// EN: Feed Section — Toss-style top tabs (추천/팔로잉/프로젝트)
// KO: 피드 섹션 — 토스 스타일 상단 탭 (추천/팔로잉/프로젝트)
// ========================================

/// EN: Top tab for feed section: recommended, following, or project-specific.
/// KO: 피드 섹션 상단 탭: 추천 / 팔로잉 / 프로젝트별.
enum _FeedTopTab { recommended, following, project }

/// EN: Feed section with Toss-style top tab selector (추천/팔로잉/프로젝트).
/// KO: 토스 스타일 상단 탭 선택기(추천/팔로잉/프로젝트)를 포함한 피드 섹션.
class _FeedSection extends ConsumerStatefulWidget {
  const _FeedSection();

  @override
  ConsumerState<_FeedSection> createState() => _FeedSectionState();
}

class _FeedSectionState extends ConsumerState<_FeedSection>
    with WidgetsBindingObserver {
  _FeedTopTab _tab = _FeedTopTab.recommended;
  final ScrollController _scrollController = ScrollController();
  Timer? _foregroundRefreshTimer;
  bool _isAppResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _foregroundRefreshTimer = Timer.periodic(
      const Duration(seconds: 35),
      (_) => _refreshFeedIfVisible(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(communityFeedControllerProvider.notifier)
            .setMode(CommunityFeedMode.recommended);
      }
    });
  }

  @override
  void dispose() {
    _foregroundRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed) _refreshFeedIfVisible();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 180) {
      ref.read(communityFeedControllerProvider.notifier).loadMore();
    }
  }

  void _refreshFeedIfVisible() {
    if (!mounted || !_isAppResumed) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    ref.read(communityFeedControllerProvider.notifier).refreshInBackground();
  }

  void _onTabChanged(_FeedTopTab tab) {
    HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _tab = tab);
    if (tab == _FeedTopTab.recommended) {
      ref
          .read(communityFeedControllerProvider.notifier)
          .setMode(CommunityFeedMode.recommended);
    } else if (tab == _FeedTopTab.following) {
      ref
          .read(communityFeedControllerProvider.notifier)
          .setMode(CommunityFeedMode.following);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(communityFeedControllerProvider);
    final notifier = ref.read(communityFeedControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final tertiaryColor =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return Column(
      children: [
        // EN: Toss-style top tab row — 추천/팔로잉/프로젝트
        // KO: 토스 스타일 상단 탭 행 — 추천/팔로잉/프로젝트
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.xs,
            GBTSpacing.md,
            0,
          ),
          child: Row(
            children: _FeedTopTab.values.map((tab) {
              final isSelected = tab == _tab;
              final label = switch (tab) {
                _FeedTopTab.recommended => '추천',
                _FeedTopTab.following => '팔로잉',
                _FeedTopTab.project => '프로젝트',
              };
              return Padding(
                padding: const EdgeInsets.only(right: GBTSpacing.lg),
                child: GestureDetector(
                  onTap: () => _onTabChanged(tab),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOutCubic,
                        style: GBTTypography.labelMedium.copyWith(
                          color: isSelected ? primaryColor : tertiaryColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: GBTSpacing.sm,
                          ),
                          child: Text(label),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 2,
                        width: isSelected ? 20.0 : 0.0,
                        decoration: BoxDecoration(
                          color:
                              isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // EN: Project selector — project tab only.
        // KO: 프로젝트 선택기 — 프로젝트 탭에서만 표시.
        if (_tab == _FeedTopTab.project) ...[
          const SizedBox(height: GBTSpacing.xs),
          const SizedBox(
            height: 40,
            child: ProjectSelectorCompact(),
          ),
          const SizedBox(height: GBTSpacing.xs),
          const Expanded(child: _ProjectPostList()),
        ],

        // EN: Community feed — recommended/following tabs.
        // KO: 커뮤니티 피드 — 추천/팔로잉 탭.
        if (_tab != _FeedTopTab.project)
          Expanded(
            child: _CommunityList(
              state: feedState,
              scrollController: _scrollController,
              onRefresh: () => notifier.reload(forceRefresh: true),
              onRetry: () => notifier.reload(forceRefresh: true),
            ),
          ),
      ],
    );
  }
}

// ========================================
// EN: Project post list — shows posts for the selected project.
// KO: 프로젝트 게시글 목록 — 선택된 프로젝트의 게시글을 표시.
// ========================================

/// EN: Post list driven by the selected project key via postListControllerProvider.
/// KO: postListControllerProvider를 통해 선택된 프로젝트의 게시글 목록을 표시.
class _ProjectPostList extends ConsumerWidget {
  const _ProjectPostList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postListControllerProvider);

    return postState.when(
      loading: () => ListView(
        padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
        children: [
          GBTListSkeleton(
            itemCount: 5,
            padding: EdgeInsets.zero,
            spacing: GBTSpacing.none,
            itemBuilder: (_) => const GBTCommunityPostSkeleton(),
          ),
        ],
      ),
      error: (err, _) {
        final message = err is Failure ? err.userMessage : '게시글을 불러오지 못했어요';
        return ListView(
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(
              message: message,
              onRetry: () =>
                  ref.read(postListControllerProvider.notifier).load(
                    forceRefresh: true,
                  ),
            ),
          ],
        );
      },
      data: (posts) {
        if (posts.isEmpty) {
          return ListView(
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(message: '이 프로젝트에 아직 게시글이 없습니다'),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(postListControllerProvider.notifier).load(
                forceRefresh: true,
              ),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: posts.length,
            itemBuilder: (context, index) =>
                _CommunityPostCard(post: posts[index]),
          ),
        );
      },
    );
  }
}

// ========================================
// EN: Community Tab (Discover only — feed section replaced by _FeedSection)
// KO: 커뮤니티 탭 (발견 전용 — 피드 섹션은 _FeedSection으로 대체됨)
// ========================================

/// EN: Community tab used for the discover section.
/// KO: 발견 섹션에 사용되는 커뮤니티 탭.
class _CommunityTab extends ConsumerStatefulWidget {
  const _CommunityTab({required this.isDiscoverSection});

  final bool isDiscoverSection;

  @override
  ConsumerState<_CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<_CommunityTab>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  Timer? _foregroundRefreshTimer;
  bool _isAppResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    _foregroundRefreshTimer = Timer.periodic(
      const Duration(seconds: 35),
      (_) => _refreshFeedIfVisible(),
    );
    _syncSectionMode();
  }

  @override
  void dispose() {
    _foregroundRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CommunityTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDiscoverSection != widget.isDiscoverSection) {
      _syncSectionMode(previousWasDiscover: oldWidget.isDiscoverSection);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed) {
      _refreshFeedIfVisible();
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 180) {
      ref.read(communityFeedControllerProvider.notifier).loadMore();
    }
  }

  void _refreshFeedIfVisible() {
    if (!mounted || !_isAppResumed) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    ref.read(communityFeedControllerProvider.notifier).refreshInBackground();
  }

  void _syncSectionMode({bool? previousWasDiscover}) {
    final notifier = ref.read(communityFeedControllerProvider.notifier);
    final state = ref.read(communityFeedControllerProvider);
    if (widget.isDiscoverSection) {
      if (state.mode != CommunityFeedMode.trending) {
        unawaited(notifier.setMode(CommunityFeedMode.trending));
      }
      return;
    }
    if (!widget.isDiscoverSection &&
        (previousWasDiscover ?? false) &&
        state.mode == CommunityFeedMode.trending) {
      unawaited(notifier.setMode(CommunityFeedMode.recommended));
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(communityFeedControllerProvider);
    final notifier = ref.read(communityFeedControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EN: Map current mode to primary three-way selection (recommended/following/latest).
    // KO: 현재 모드를 3방향 선택(추천/팔로잉/최신)으로 매핑합니다.
    final primaryMode = switch (feedState.mode) {
      CommunityFeedMode.following => CommunityFeedMode.following,
      CommunityFeedMode.latest => CommunityFeedMode.latest,
      _ => CommunityFeedMode.recommended,
    };

    // EN: Current user ID for following users lookup.
    // KO: 팔로잉 유저 조회를 위한 현재 유저 ID.
    final profileState = ref.watch(userProfileControllerProvider);
    final currentUserId = profileState.maybeWhen(
      data: (profile) => profile?.id,
      orElse: () => null,
    );

    // EN: Watch following users only in following mode with valid user ID.
    // KO: 팔로잉 모드 + 유효한 유저 ID일 때만 팔로잉 유저 목록 감시.
    final AsyncValue<List<UserFollowSummary>>? followingUsersAsync =
        (!feedState.isSearching &&
                !widget.isDiscoverSection &&
                primaryMode == CommunityFeedMode.following &&
                currentUserId != null)
            ? ref.watch(userFollowingProvider(currentUserId))
            : null;

    return Column(
      children: [
        // EN: Mode selector — only for feed section, hidden during search.
        // KO: 모드 선택기 — 피드 섹션 전용, 검색 중 숨김.
        if (!widget.isDiscoverSection && !feedState.isSearching) ...[
          const SizedBox(height: GBTSpacing.xs),
          _FeedModeTabRow(
            selectedMode: primaryMode,
            onChanged: notifier.setMode,
          ),
        ],

        // EN: Search scope filter chips — visible only while searching.
        // KO: 검색 범위 필터 칩 — 검색 중에만 표시.
        if (feedState.isSearching) ...[
          const SizedBox(height: GBTSpacing.xs),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
              children: const [
                CommunitySearchScope.all,
                CommunitySearchScope.title,
                CommunitySearchScope.author,
                CommunitySearchScope.content,
                CommunitySearchScope.media,
              ].map((scope) {
                return Padding(
                  padding: const EdgeInsets.only(right: GBTSpacing.sm),
                  child: _FilterChipModern(
                    label: scope.label,
                    icon: _searchScopeIcon(scope),
                    isSelected: feedState.searchScope == scope,
                    onTap: () => notifier.setSearchScope(scope),
                  ),
                );
              }).toList(),
            ),
          ),
          _FeedSearchSummary(
            query: feedState.searchQuery,
            scopeLabel: feedState.searchScope.label,
            resultCount: feedState.posts.length,
          ),
        ],

        // EN: Following users pills — following mode only, shows users the current user follows.
        // KO: 팔로잉 유저 필 — 팔로잉 모드 전용, 현재 유저가 팔로우한 사람 목록.
        if (!feedState.isSearching &&
            !widget.isDiscoverSection &&
            primaryMode == CommunityFeedMode.following) ...[
          const SizedBox(height: GBTSpacing.xs),
          SizedBox(
            height: 34,
            child: followingUsersAsync?.when(
                  loading: () => const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (users) => users.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.md,
                            vertical: 8,
                          ),
                          child: Text(
                            '팔로우한 유저가 없습니다',
                            style: GBTTypography.caption.copyWith(
                              color: isDark
                                  ? GBTColors.darkTextTertiary
                                  : GBTColors.textTertiary,
                            ),
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.md,
                          ),
                          children: users
                              .map(
                                (user) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: GBTSpacing.xs,
                                  ),
                                  child: _FollowingUserPill(user: user),
                                ),
                              )
                              .toList(),
                        ),
                ) ??
                const SizedBox.shrink(),
          ),
        ],

        // EN: Main content list.
        // KO: 메인 콘텐츠 목록.
        Expanded(
          child: _CommunityList(
            state: feedState,
            scrollController: _scrollController,
            onRefresh: () => notifier.reload(forceRefresh: true),
            onRetry: () => notifier.reload(forceRefresh: true),
          ),
        ),
      ],
    );
  }
}

// ========================================
// EN: Feed Mode Tab Row — Toss-style plain text selector
// KO: 피드 모드 탭 행 — 토스 스타일 단순 텍스트 선택기
// ========================================

/// EN: Simple text-based feed mode selector — no borders, no backgrounds, Toss-style.
/// KO: 토스 스타일 단순 텍스트 피드 모드 선택기 — 테두리/배경 없음.
class _FeedModeTabRow extends StatelessWidget {
  const _FeedModeTabRow({
    required this.selectedMode,
    required this.onChanged,
  });

  final CommunityFeedMode selectedMode;
  final ValueChanged<CommunityFeedMode> onChanged;

  static const _modes = [
    CommunityFeedMode.recommended,
    CommunityFeedMode.following,
    CommunityFeedMode.latest,
  ];

  static String _label(CommunityFeedMode m) => switch (m) {
    CommunityFeedMode.recommended => '추천',
    CommunityFeedMode.following => '팔로잉',
    CommunityFeedMode.latest => '최신',
    _ => m.label,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
      child: Row(
        children: _modes.map((mode) {
          final isSelected = mode == selectedMode;
          return Padding(
            padding: const EdgeInsets.only(right: GBTSpacing.lg),
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    style: GBTTypography.labelMedium.copyWith(
                      color: isSelected ? primaryColor : tertiaryColor,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: GBTSpacing.sm,
                      ),
                      child: Text(_label(mode)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 2,
                    width: isSelected ? 20.0 : 0.0,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ========================================
// EN: Search Sheet
// KO: 검색 시트
// ========================================

class _CommunitySearchSheet extends StatefulWidget {
  const _CommunitySearchSheet({required this.initialQuery});

  final String initialQuery;

  @override
  State<_CommunitySearchSheet> createState() => _CommunitySearchSheetState();
}

class _CommunitySearchSheetState extends State<_CommunitySearchSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GBTSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('게시글 검색', style: GBTTypography.titleMedium),
              const SizedBox(height: GBTSpacing.sm),
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: '제목/작성자/내용',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onSubmitted: (value) =>
                    Navigator.of(context).pop(value.trim()),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('초기화'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_controller.text.trim()),
                    child: const Text('검색'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Search summary & filter chip
// KO: 검색 요약 & 필터 칩
// ========================================

class _FeedSearchSummary extends StatelessWidget {
  const _FeedSearchSummary({
    required this.query,
    required this.scopeLabel,
    required this.resultCount,
  });

  final String query;
  final String scopeLabel;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.md,
        GBTSpacing.xs,
        GBTSpacing.md,
        GBTSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 14,
            color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          ),
          const SizedBox(width: GBTSpacing.xxs),
          Expanded(
            child: Text(
              '"$query" · $scopeLabel $resultCount건',
              style: GBTTypography.caption.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Modern filter chip with filled/outlined toggle style and optional mode icon.
/// KO: 채워진/아웃라인 토글 스타일 및 선택적 모드 아이콘이 있는 모던 필터 칩.
class _FilterChipModern extends StatelessWidget {
  const _FilterChipModern({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : isDark
                ? GBTColors.darkBorder
                : GBTColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? primaryColor
                    : isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GBTTypography.labelMedium.copyWith(
                color: isSelected
                    ? primaryColor
                    : isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Following User Pill — avatar + display name chip
// KO: 팔로잉 유저 필 — 아바타 + 표시 이름 칩
// ========================================

class _FollowingUserPill extends StatelessWidget {
  const _FollowingUserPill({required this.user});

  final UserFollowSummary user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.goToUserProfile(user.userId),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          border: Border.all(
            color: isDark ? GBTColors.darkBorder : GBTColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.avatarUrl != null) ...[
              ClipOval(
                child: GBTImage(
                  imageUrl: user.avatarUrl!,
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              user.displayName,
              style: GBTTypography.labelSmall.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Travel Review Tab
// KO: 여행 후기 탭
// ========================================

class _TravelReviewTab extends ConsumerWidget {
  const _TravelReviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockReviews = [
      {
        'id': '1',
        'authorName': '타비매니아',
        'title': '도쿄 성지순례 1일차 알차게 다녀왔어!',
        'content':
            '아침 일찍 도쿄역에 도착하자마자 오다이바 먼저 찍고 아키하바라로 넘어갔는데 일정이 좀 빡셌지만 너무 재밌었어.',
        'image':
            'https://storage.googleapis.com/girlsbandtabi/thumbnails/placeholder_map1.webp',
        'likeCount': 42,
        'commentCount': 8,
        'timeAgo': '2시간 전',
        'places': ['도쿄 타워', '시부야 스크램블 교차로', '오다이바 해변공원'],
      },
      {
        'id': '2',
        'authorName': '뉴비리뷰어',
        'title': '3박 4일 일정 공유해봐 (아키하바라 위주)',
        'content': '이번엔 유명한 애니 성지 위주로만 골라서 가봤는데 너무 좋았어!! 다음엔 다른 지역도 가보고 싶다.',
        'image':
            'https://storage.googleapis.com/girlsbandtabi/thumbnails/placeholder_map2.webp',
        'likeCount': 105,
        'commentCount': 23,
        'timeAgo': '1일 전',
        'places': ['아키하바라', '우에노 공원', '센소지'],
      },
      {
        'id': '3',
        'authorName': '여행가고싶다',
        'title': '사진 위주로 올림',
        'content': '그냥 지나가다 찍은 것들이야. 예쁘더라.',
        'image':
            'https://storage.googleapis.com/girlsbandtabi/thumbnails/placeholder_map3.webp',
        'likeCount': 15,
        'commentCount': 2,
        'timeAgo': '3일 전',
        'places': ['신주쿠 코엔', '도쿄 도청'],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: GBTSpacing.md,
        right: GBTSpacing.md,
        top: GBTSpacing.md,
        bottom: 80,
      ),
      itemCount: mockReviews.length,
      itemBuilder: (context, index) {
        final review = mockReviews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: GBTSpacing.md),
          child: _TravelReviewCard(review: review),
        );
      },
    );
  }
}

/// EN: Travel review card with modern design — image header, route badges.
/// KO: 모던 디자인의 여행 후기 카드 — 이미지 헤더, 경로 배지.
class _TravelReviewCard extends StatelessWidget {
  const _TravelReviewCard({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final places = review['places'] as List<String>;
    final likeCount = review['likeCount'] as int;
    final commentCount = review['commentCount'] as int;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surface,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? GBTColors.darkBorderSubtle
              : GBTColors.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            AppRoutes.travelReviewDetail,
            pathParameters: {'reviewId': review['id'] as String},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Cover image with gradient fallback and place count badge
            // KO: 장소 수 배지와 그라디언트 폴백이 있는 커버 이미지
            SizedBox(
              width: double.infinity,
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if ((review['image'] as String?)?.isNotEmpty == true)
                    GBTImage(
                      imageUrl: review['image'] as String,
                      fit: BoxFit.cover,
                      semanticLabel: review['title'] as String,
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  GBTColors.darkSurfaceElevated,
                                  GBTColors.darkSurfaceVariant,
                                ]
                              : [
                                  GBTColors.primaryLight,
                                  GBTColors.primaryMuted.withValues(alpha: 0.5),
                                ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: colorScheme.primary.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  // EN: Route badge count overlay
                  // KO: 경로 배지 카운트 오버레이
                  Positioned(
                    top: GBTSpacing.sm,
                    right: GBTSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${places.length}곳',
                            style: GBTTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // EN: Route badges — horizontal scroll
            // KO: 경로 배지 — 가로 스크롤
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                GBTSpacing.sm + 2,
                GBTSpacing.md,
                0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < places.length; i++) ...[
                      _RouteBadge(index: i + 1, name: places[i]),
                      if (i < places.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            // EN: Content section
            // KO: 콘텐츠 섹션
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                GBTSpacing.sm + 2,
                GBTSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['title'] as String,
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    review['content'] as String,
                    style: GBTTypography.bodySmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextSecondary
                          : GBTColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // EN: Bottom bar — author + engagement
            // KO: 하단 바 — 작성자 + 인게이지먼트
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                GBTSpacing.sm + 2,
                GBTSpacing.md,
                GBTSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isDark
                        ? GBTColors.darkSurfaceElevated
                        : GBTColors.surfaceAlternate,
                    child: Icon(
                      Icons.person,
                      size: 14,
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.xs),
                  Text(
                    review['authorName'] as String,
                    style: GBTTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.xs),
                  Text(
                    review['timeAgo'] as String,
                    style: GBTTypography.labelSmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.favorite_border,
                    size: 14,
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$likeCount',
                    style: GBTTypography.labelSmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$commentCount',
                    style: GBTTypography.labelSmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
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

/// EN: Route badge chip with numbered index and place name.
/// KO: 번호 인덱스와 장소명이 있는 경로 배지 칩.
class _RouteBadge extends StatelessWidget {
  const _RouteBadge({required this.index, required this.name});

  final int index;
  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: GBTTypography.caption.copyWith(
                color: isDark ? GBTColors.darkBackground : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: GBTTypography.labelSmall.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// EN: Community List
// KO: 커뮤니티 리스트
// ========================================

class _CommunityList extends StatelessWidget {
  const _CommunityList({
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onRetry,
  });

  final CommunityFeedViewState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Builder(
        builder: (context) {
          if (state.isInitialLoading) {
            return ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
              children: [
                GBTListSkeleton(
                  itemCount: 5,
                  padding: EdgeInsets.zero,
                  spacing: GBTSpacing.none,
                  itemBuilder: (_) => const GBTCommunityPostSkeleton(),
                ),
              ],
            );
          }

          if (state.failure != null && state.posts.isEmpty) {
            return ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                const SizedBox(height: GBTSpacing.lg),
                GBTErrorState(
                  message: state.failure!.userMessage,
                  onRetry: onRetry,
                ),
              ],
            );
          }

          if (state.posts.isEmpty) {
            final message = state.isSearching
                ? '${state.searchScope.label} 검색 결과가 없습니다'
                : switch (state.mode) {
                    CommunityFeedMode.recommended => '추천 피드에 표시할 글이 없습니다',
                    CommunityFeedMode.following => '팔로우 피드에 표시할 글이 없습니다',
                    CommunityFeedMode.latest => '아직 피드 글이 없습니다',
                    CommunityFeedMode.trending => '인기 글이 아직 없습니다',
                  };
            return ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                const SizedBox(height: GBTSpacing.lg),
                GBTEmptyState(message: message),
              ],
            );
          }

          // EN: AnimatedSwitcher keyed on feed mode — fade+slide transition
          // when the user switches between recommended/following/latest.
          // KO: 피드 모드를 키로 사용하는 AnimatedSwitcher — 추천/팔로잉/최신
          // 전환 시 페이드+슬라이드 전환 애니메이션 적용.
          final reduceMotion =
              MediaQuery.maybeOf(context)?.disableAnimations ?? false;
          return AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnim = Tween<Offset>(
                begin: reduceMotion ? Offset.zero : const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnim, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(state.mode),
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 6, bottom: 88),
                itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: GBTSpacing.md),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final post = state.posts[index];
                  return _CommunityPostCard(post: post);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ========================================
// EN: Community Post Card — rounded card, right-thumbnail layout
// KO: 커뮤니티 게시글 카드 — 둥근 카드, 오른쪽 썸네일 레이아웃
// ========================================

enum _PostCardAction { edit, delete, report, blockToggle, ban }

class _CommunityPostCard extends ConsumerWidget {
  const _CommunityPostCard({required this.post});

  final PostSummary post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : '익명';
    final avatarUrl = post.authorAvatarUrl?.isNotEmpty == true
        ? post.authorAvatarUrl
        : null;
    final commentCount = post.commentCount ?? 0;
    final baseLikeCount = post.likeCount ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final commentActionColor = isDark
        ? GBTColors.darkPrimary
        : GBTColors.accentBlue;

    // EN: Resolve first image URL for thumbnail.
    // KO: 썸네일용 첫 번째 이미지 URL을 해석합니다.
    final String? firstImageUrl;
    if (post.imageUrls.isNotEmpty) {
      firstImageUrl = resolveMediaUrl(post.imageUrls.first);
    } else {
      final contentImages = extractImageUrls(
        post.content,
      ).map(resolveMediaUrl).where((url) => url.isNotEmpty);
      if (contentImages.isNotEmpty) {
        firstImageUrl = contentImages.first;
      } else if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
        firstImageUrl = resolveMediaUrl(post.thumbnailUrl!);
      } else {
        firstImageUrl = null;
      }
    }

    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final likeState = isAuthenticated
        ? ref.watch(postLikeControllerProvider(post.id))
        : null;
    final bookmarkState = isAuthenticated
        ? ref.watch(postBookmarkControllerProvider(post.id))
        : null;
    final isLiked =
        likeState?.maybeWhen(
          data: (value) => value.isLiked,
          orElse: () => false,
        ) ??
        false;
    final likeCount =
        likeState?.maybeWhen(
          data: (value) => value.likeCount,
          orElse: () => baseLikeCount,
        ) ??
        baseLikeCount;
    final isBookmarked =
        bookmarkState?.maybeWhen(
          data: (value) => value.isBookmarked,
          orElse: () => false,
        ) ??
        false;
    final canToggleLike = !isAuthenticated || (likeState?.hasValue ?? false);
    final canToggleBookmark =
        !isAuthenticated || (bookmarkState?.hasValue ?? false);
    final likeActionColor = isLiked ? GBTColors.secondary : tertiaryColor;
    final bookmarkActionColor = isBookmarked
        ? (isDark ? GBTColors.darkPrimary : GBTColors.primary)
        : tertiaryColor;
    final profileState = ref.watch(userProfileControllerProvider);
    final currentUserId = profileState.maybeWhen(
      data: (profile) => profile?.id,
      orElse: () => null,
    );
    final isAdmin = profileState.maybeWhen(
      data: (profile) => _isAdminRole(profile?.role),
      orElse: () => false,
    );
    final isAuthor = currentUserId != null && currentUserId == post.authorId;
    final blockStatusState = isAuthenticated && !isAuthor
        ? ref.watch(blockStatusControllerProvider(post.authorId))
        : null;
    final blockStatus = blockStatusState?.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final blockLabel = blockStatus?.blockedByMe == true ? '차단 해제' : '차단';
    final showMoreButton = isAuthenticated;
    final projectsState = ref.watch(projectsControllerProvider);
    final projectName = projectsState.maybeWhen(
      data: (projects) => _resolveProjectName(projects, post.projectId),
      orElse: () => post.projectId,
    );

    // EN: Card container — rounded border, surface background, no outer divider.
    // KO: 카드 컨테이너 — 둥근 테두리, 표면 배경, 외부 구분선 없음.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: GBTSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurface : GBTColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? GBTColors.darkBorder.withValues(alpha: 0.55)
              : GBTColors.border.withValues(alpha: 0.55),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.goToPostDetail(post.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Card body — author header + content
              // KO: 카드 본문 — 작성자 헤더 + 콘텐츠
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 6, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN: Author row — avatar + name + project pill + time + menu
                    // KO: 작성자 행 — 아바타 + 이름 + 프로젝트 칩 + 시간 + 메뉴
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Avatar(
                          url: avatarUrl,
                          radius: 16,
                          semanticLabel: '$authorLabel 프로필 사진',
                          onTap: () => context.goToUserProfile(post.authorId),
                        ),
                        const SizedBox(width: GBTSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      authorLabel,
                                      style: GBTTypography.labelMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? GBTColors.darkPrimary
                                              : GBTColors.primary)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        GBTSpacing.radiusFull,
                                      ),
                                    ),
                                    child: Text(
                                      projectName,
                                      style: GBTTypography.labelSmall.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? GBTColors.darkPrimary
                                            : GBTColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                post.timeAgoLabel,
                                style: GBTTypography.labelSmall.copyWith(
                                  color: tertiaryColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showMoreButton)
                          PopupMenuButton<_PostCardAction>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 20,
                              color: tertiaryColor,
                            ),
                            tooltip: '더 보기',
                            padding: EdgeInsets.zero,
                            onSelected: (action) {
                              if (action == _PostCardAction.edit) {
                                context.goToPostDetail(post.id);
                                return;
                              }
                              if (action == _PostCardAction.delete) {
                                _confirmDeletePost(
                                  context,
                                  ref,
                                  isAuthor: isAuthor,
                                  isAdmin: isAdmin,
                                );
                                return;
                              }
                              if (action == _PostCardAction.report) {
                                _showReportFlow(context, ref);
                                return;
                              }
                              if (action == _PostCardAction.blockToggle) {
                                _toggleBlockUser(context, ref);
                                return;
                              }
                              if (action == _PostCardAction.ban) {
                                _confirmBanUser(context, ref);
                              }
                            },
                            itemBuilder: (menuContext) {
                              final cs = Theme.of(menuContext).colorScheme;
                              return [
                                if (isAuthor)
                                  const PopupMenuItem(
                                    value: _PostCardAction.edit,
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: GBTSpacing.sm),
                                        Text('수정'),
                                      ],
                                    ),
                                  ),
                                if (isAuthor) const PopupMenuDivider(),
                                if (isAuthor || isAdmin)
                                  PopupMenuItem(
                                    value: _PostCardAction.delete,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: cs.error,
                                        ),
                                        SizedBox(width: GBTSpacing.sm),
                                        Text(
                                          isAuthor ? '삭제' : '관리 삭제',
                                          style: TextStyle(color: cs.error),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (!isAuthor && isAuthenticated)
                                  const PopupMenuItem(
                                    value: _PostCardAction.report,
                                    child: Row(
                                      children: [
                                        Icon(Icons.flag_outlined, size: 18),
                                        SizedBox(width: GBTSpacing.sm),
                                        Text('신고'),
                                      ],
                                    ),
                                  ),
                                if (!isAuthor && isAuthenticated)
                                  PopupMenuItem(
                                    value: _PostCardAction.blockToggle,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.person_off_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: GBTSpacing.sm),
                                        Text(blockLabel),
                                      ],
                                    ),
                                  ),
                                if (isAdmin && !isAuthor)
                                  PopupMenuItem(
                                    value: _PostCardAction.ban,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.block,
                                          size: 18,
                                          color: cs.error,
                                        ),
                                        SizedBox(width: GBTSpacing.sm),
                                        Text(
                                          '커뮤니티 제재',
                                          style: TextStyle(color: cs.error),
                                        ),
                                      ],
                                    ),
                                  ),
                              ];
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // EN: Content area — right thumbnail layout when image exists,
                    //     full-width text layout when no image.
                    // KO: 콘텐츠 영역 — 이미지가 있으면 오른쪽 썸네일,
                    //     없으면 전체 너비 텍스트.
                    if (firstImageUrl != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: GBTTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (post.content != null &&
                                    post.content!.isNotEmpty)
                                  Builder(builder: (context) {
                                    final raw =
                                        stripImageMarkdown(post.content!);
                                    if (raw.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    final snippet = raw.length > 80
                                        ? '${raw.substring(0, 80)}…'
                                        : raw;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4),
                                      child: Text(
                                        snippet,
                                        style: GBTTypography.bodySmall
                                            .copyWith(
                                          color: secondaryTextColor,
                                          height: 1.42,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // EN: Right-side square thumbnail.
                          // KO: 오른쪽 정사각형 썸네일.
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 78,
                                  height: 78,
                                  child: GBTImage(
                                    imageUrl: firstImageUrl,
                                    fit: BoxFit.cover,
                                    semanticLabel: '${post.title} 첨부 이미지',
                                  ),
                                ),
                                if (post.imageUrls.length > 1)
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.65),
                                        borderRadius:
                                            BorderRadius.circular(
                                          GBTSpacing.radiusFull,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.photo_library_outlined,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${post.imageUrls.length}',
                                            style: GBTTypography.labelSmall
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: GBTTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (post.content != null &&
                              post.content!.isNotEmpty)
                            Builder(builder: (context) {
                              final raw =
                                  stripImageMarkdown(post.content!);
                              if (raw.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final snippet = raw.length > 120
                                  ? '${raw.substring(0, 120)}…'
                                  : raw;
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  snippet,
                                  style: GBTTypography.bodySmall.copyWith(
                                    color: secondaryTextColor,
                                    height: 1.45,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                        ],
                      ),
                  ],
                ),
              ),
              // EN: Action bar with subtle top border.
              // KO: 미묘한 상단 테두리가 있는 액션 바.
              Semantics(
                label:
                    '좋아요 $likeCount개, 댓글 $commentCount개, 북마크 ${isBookmarked ? '설정됨' : '해제됨'}',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? GBTColors.darkBorder.withValues(alpha: 0.45)
                            : GBTColors.border.withValues(alpha: 0.45),
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
                  child: Row(
                    children: [
                      _FeedActionButton(
                        icon: GBTActionIcons.comment,
                        label: _formatCount(commentCount),
                        color: commentActionColor,
                        semanticsLabel: '댓글 $commentCount개',
                        onTap: () => context.goToPostDetail(post.id),
                      ),
                      const SizedBox(width: GBTSpacing.md),
                      _AnimatedLikeButton(
                        isLiked: isLiked,
                        likeCount: likeCount,
                        enabled: canToggleLike,
                        onTap: () => _toggleLike(context, ref),
                        activeColor: likeActionColor,
                        inactiveColor: tertiaryColor,
                      ),
                      const SizedBox(width: GBTSpacing.md),
                      _AnimatedBookmarkButton(
                        isBookmarked: isBookmarked,
                        enabled: canToggleBookmark,
                        onTap: () => _toggleBookmark(context, ref),
                        activeColor: bookmarkActionColor,
                        inactiveColor: tertiaryColor,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike(BuildContext context, WidgetRef ref) async {
    if (!ref.read(isAuthenticatedProvider)) {
      _showSnackBar(context, '좋아요는 로그인 후 이용할 수 있어요');
      return;
    }

    final result = await ref
        .read(postLikeControllerProvider(post.id).notifier)
        .toggleLike();
    if (!context.mounted) return;
    if (result is Err<PostLikeStatus>) {
      _showSnackBar(context, '좋아요/좋아요 취소를 반영하지 못했어요');
    }
  }

  Future<void> _toggleBookmark(BuildContext context, WidgetRef ref) async {
    if (!ref.read(isAuthenticatedProvider)) {
      _showSnackBar(context, '북마크는 로그인 후 이용할 수 있어요');
      return;
    }

    final result = await ref
        .read(postBookmarkControllerProvider(post.id).notifier)
        .toggleBookmark();
    if (!context.mounted) return;
    if (result is Err<PostBookmarkStatus>) {
      _showSnackBar(context, '북마크를 반영하지 못했어요');
    }
  }

  Future<void> _confirmDeletePost(
    BuildContext context,
    WidgetRef ref, {
    required bool isAuthor,
    required bool isAdmin,
  }) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      _showSnackBar(context, '프로젝트를 먼저 선택해주세요');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final Result<void> result;
    if (isAdmin && !isAuthor) {
      final repository = await ref.read(communityRepositoryProvider.future);
      result = await repository.moderateDeletePost(
        projectCode: projectCode,
        postId: post.id,
      );
    } else {
      final repository = await ref.read(feedRepositoryProvider.future);
      result = await repository.deletePost(
        projectCode: projectCode,
        postId: post.id,
      );
    }

    if (!context.mounted) return;
    if (result is Success<void>) {
      await ref
          .read(communityFeedControllerProvider.notifier)
          .reload(forceRefresh: true);
      if (context.mounted) {
        _showSnackBar(context, '게시글을 삭제했어요');
      }
    } else if (result is Err<void>) {
      _showSnackBar(context, '게시글을 삭제하지 못했어요');
    }
  }

  Future<void> _showReportFlow(BuildContext context, WidgetRef ref) async {
    final rateLimiter = ref.read(reportRateLimiterProvider);
    if (!rateLimiter.canReport(post.id)) {
      final remaining = rateLimiter.remainingCooldown(post.id);
      final minutes = remaining.inMinutes + 1;
      _showSnackBar(context, '$minutes분 후 다시 신고할 수 있어요');
      return;
    }

    final payload = await showModalBottomSheet<CommunityReportPayload>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const CommunityReportSheet(),
    );
    if (payload == null || !context.mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('신고 접수'),
        content: Text('게시글을 "${payload.reason.label}" 사유로 신고합니다.\n접수하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('신고 접수'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.createReport(
      targetType: CommunityReportTargetType.post,
      targetId: post.id,
      reason: payload.reason,
      description: payload.description,
    );
    if (!context.mounted) {
      return;
    }
    if (result is Success<void>) {
      rateLimiter.recordReport(post.id);
      _showSnackBar(context, '신고가 접수되었어요. 검토 후 조치할게요');
    } else if (result is Err<void>) {
      _showSnackBar(context, '신고를 접수하지 못했어요');
    }
  }

  Future<void> _toggleBlockUser(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(
      blockStatusControllerProvider(post.authorId).notifier,
    );
    final result = await controller.toggleBlock();
    if (result is Err<void> && context.mounted) {
      _showSnackBar(context, '차단 상태를 변경하지 못했어요');
      return;
    }
    if (!context.mounted) {
      return;
    }
    final state = ref.read(blockStatusControllerProvider(post.authorId));
    final blockedByMe = state.maybeWhen(
      data: (value) => value.blockedByMe,
      orElse: () => false,
    );
    _showSnackBar(context, blockedByMe ? '사용자를 차단했어요' : '차단을 해제했어요');
  }

  Future<void> _confirmBanUser(BuildContext context, WidgetRef ref) async {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : '익명';
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      _showSnackBar(context, '프로젝트를 먼저 선택해주세요');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('커뮤니티 제재'),
        content: Text('$authorLabel 사용자를 이 프로젝트 커뮤니티에서 제재할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('차단'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.banProjectUser(
      projectCode: projectCode,
      userId: post.authorId,
      reason: 'COMMUNITY_MODERATION',
    );

    if (!context.mounted) return;
    if (result is Success) {
      await ref
          .read(communityFeedControllerProvider.notifier)
          .reload(forceRefresh: true);
      if (context.mounted) {
        _showSnackBar(context, '$authorLabel 사용자를 커뮤니티 제재했어요');
      }
    } else if (result is Err) {
      _showSnackBar(context, '커뮤니티 제재에 실패했어요');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// ========================================
// EN: Action Buttons — comment, like, bookmark
// KO: 액션 버튼 — 댓글, 좋아요, 북마크
// ========================================

/// EN: Compact feed action button used in timeline-style cards.
/// Used only for the comment action; animated like/bookmark use dedicated widgets.
/// KO: 타임라인형 카드에서 사용하는 컴팩트 액션 버튼.
/// 댓글 액션에만 사용되며, 좋아요/북마크는 전용 애니메이션 위젯을 사용합니다.
class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String? semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.xs,
            vertical: GBTSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Animated like button with scale micro-interaction on toggle.
/// Scale sequence: 0.88 → 1.08 → 1.0 over 180ms with easeOutBack rebound.
/// Icon crossfades between outline/filled via AnimatedSwitcher.
/// KO: 토글 시 스케일 마이크로 인터랙션이 있는 애니메이션 좋아요 버튼.
/// 스케일 시퀀스: 0.88 → 1.08 → 1.0, 180ms, easeOutBack 리바운드.
/// 아이콘은 AnimatedSwitcher로 아웃라인/채움 간 크로스페이드.
class _AnimatedLikeButton extends StatefulWidget {
  const _AnimatedLikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.enabled,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool isLiked;
  final int likeCount;
  final bool enabled;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  static const Duration _duration = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 44,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 28,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled) return;
    unawaited(_controller.forward(from: 0));
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLiked ? widget.activeColor : widget.inactiveColor;
    final label = _formatCount(widget.likeCount);

    return Semantics(
      button: true,
      enabled: widget.enabled,
      toggled: widget.isLiked,
      label: '좋아요 ${widget.likeCount}개',
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        onTap: widget.enabled ? _handleTap : null,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.xs,
              vertical: GBTSpacing.xs,
            ),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: _duration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Icon(
                      widget.isLiked
                          ? GBTActionIcons.likeActive
                          : GBTActionIcons.like,
                      key: ValueKey(widget.isLiked),
                      size: 17,
                      color: color,
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: GBTTypography.labelSmall.copyWith(color: color),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Animated bookmark button with scale micro-interaction on toggle.
/// Scale sequence: 0.88 → 1.08 → 1.0 over 180ms with easeOutBack rebound.
/// Icon crossfades between outline/filled via AnimatedSwitcher.
/// KO: 토글 시 스케일 마이크로 인터랙션이 있는 애니메이션 북마크 버튼.
/// 스케일 시퀀스: 0.88 → 1.08 → 1.0, 180ms, easeOutBack 리바운드.
/// 아이콘은 AnimatedSwitcher로 아웃라인/채움 간 크로스페이드.
class _AnimatedBookmarkButton extends StatefulWidget {
  const _AnimatedBookmarkButton({
    required this.isBookmarked,
    required this.enabled,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool isBookmarked;
  final bool enabled;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<_AnimatedBookmarkButton> createState() =>
      _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<_AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  static const Duration _duration = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 44,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 28,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled) return;
    unawaited(_controller.forward(from: 0));
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isBookmarked ? widget.activeColor : widget.inactiveColor;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      toggled: widget.isBookmarked,
      label: widget.isBookmarked ? '북마크 해제' : '북마크',
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        onTap: widget.enabled ? _handleTap : null,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.xs,
              vertical: GBTSpacing.xs,
            ),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: AnimatedSwitcher(
                duration: _duration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Icon(
                  widget.isBookmarked
                      ? GBTActionIcons.bookmarkActive
                      : GBTActionIcons.bookmark,
                  key: ValueKey(widget.isBookmarked),
                  size: 17,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Helper functions
// KO: 헬퍼 함수
// ========================================

String _formatCount(int count) {
  if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}천';
  return count.toString();
}


/// EN: Returns the icon for a community search scope.
/// KO: 커뮤니티 검색 범위 아이콘을 반환합니다.
IconData _searchScopeIcon(CommunitySearchScope scope) {
  return switch (scope) {
    CommunitySearchScope.all => Icons.grid_view_rounded,
    CommunitySearchScope.title => Icons.title_rounded,
    CommunitySearchScope.author => Icons.person_outline_rounded,
    CommunitySearchScope.content => Icons.subject_rounded,
    CommunitySearchScope.media => Icons.image_outlined,
  };
}

/// EN: Returns true when a role has admin/moderator privileges.
/// KO: 관리자/모더레이터 권한이 있는 역할인지 반환합니다.
bool _isAdminRole(String? role) {
  if (role == null) return false;
  final normalized = role.toUpperCase();
  return normalized.contains('ADMIN') || normalized.contains('MODERATOR');
}

// ========================================
// EN: Bottom Sheets — My Reports & Community Ban
// KO: 바텀 시트 — 내 신고 내역 & 커뮤니티 제재
// ========================================

class _MyReportsSheet extends ConsumerStatefulWidget {
  const _MyReportsSheet();

  @override
  ConsumerState<_MyReportsSheet> createState() => _MyReportsSheetState();
}

class _MyReportsSheetState extends ConsumerState<_MyReportsSheet> {
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _errorMessage;
  List<CommunityReportSummary> _reports = const [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.getMyReports(page: 0, size: 50);
    if (!mounted) return;
    if (result is Success<List<CommunityReportSummary>>) {
      setState(() {
        _reports = result.data;
        _isLoading = false;
      });
    } else if (result is Err<List<CommunityReportSummary>>) {
      setState(() {
        _reports = const [];
        _isLoading = false;
        _errorMessage = result.failure.userMessage;
      });
    }
  }

  Future<void> _openReportDetail(String reportId) async {
    final repository = await ref.read(communityRepositoryProvider.future);
    final detailResult = await repository.getMyReportDetail(reportId: reportId);
    if (!mounted) return;
    if (detailResult is Err<CommunityReportDetail>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고 상세를 불러오지 못했어요')));
      return;
    }
    final detail = (detailResult as Success<CommunityReportDetail>).data;
    final cancellable =
        detail.status == CommunityReportStatus.open ||
        detail.status == CommunityReportStatus.inReview;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('신고 상세'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('대상: ${detail.targetType.label}'),
              Text('사유: ${detail.reason.label}'),
              Text('상태: ${_reportStatusLabel(detail.status)}'),
              Text('우선순위: ${_reportPriorityLabel(detail.priority)}'),
              Text('생성: ${_formatDateTime(detail.createdAt)}'),
              if (detail.description?.isNotEmpty == true) ...[
                const SizedBox(height: GBTSpacing.sm),
                Text('설명: ${detail.description!}'),
              ],
            ],
          ),
        ),
        actions: [
          if (cancellable)
            TextButton(
              onPressed: _isCancelling
                  ? null
                  : () async {
                      setState(() => _isCancelling = true);
                      final cancelResult = await repository.cancelMyReport(
                        reportId: detail.id,
                      );
                      if (!mounted) return;
                      setState(() => _isCancelling = false);
                      if (cancelResult is Success<void>) {
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        await _loadReports();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신고를 취소했어요')),
                        );
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신고 취소에 실패했어요')),
                        );
                      }
                    },
              child: _isCancelling
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('신고 취소'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          GBTSpacing.md,
          GBTSpacing.md,
          GBTSpacing.md,
          GBTSpacing.lg,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('내 신고 내역', style: GBTTypography.titleMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadReports,
                    tooltip: '새로고침',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.sm),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: GBTLoading(message: '신고 내역을 불러오는 중...'),
                      )
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _reports.isEmpty
                    ? const Center(child: Text('신고 내역이 없습니다'))
                    : ListView.separated(
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: GBTSpacing.xs),
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return ListTile(
                            onTap: () => _openReportDetail(report.id),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusMd,
                              ),
                            ),
                            tileColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withAlpha(40),
                            title: Text(
                              '${report.targetType.label} · ${report.reason.label}',
                              style: GBTTypography.bodyMedium,
                            ),
                            subtitle: Text(
                              _formatDateTime(report.createdAt),
                              style: GBTTypography.labelSmall,
                            ),
                            trailing: _ReportStatusChip(status: report.status),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportStatusChip extends StatelessWidget {
  const _ReportStatusChip({required this.status});

  final CommunityReportStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (Color bg, Color fg) = switch (status) {
      CommunityReportStatus.open => (
        isDark
            ? GBTColors.warning.withValues(alpha: 0.22)
            : GBTColors.warningLight,
        isDark ? GBTColors.warningLight : GBTColors.warningDark,
      ),
      CommunityReportStatus.inReview => (
        isDark ? GBTColors.info.withValues(alpha: 0.22) : GBTColors.infoLight,
        isDark ? GBTColors.infoLight : GBTColors.infoDark,
      ),
      CommunityReportStatus.resolved => (
        isDark
            ? GBTColors.success.withValues(alpha: 0.22)
            : GBTColors.successLight,
        isDark ? GBTColors.successLight : GBTColors.successDark,
      ),
      CommunityReportStatus.rejected => (
        isDark ? GBTColors.error.withValues(alpha: 0.22) : GBTColors.errorLight,
        isDark ? GBTColors.errorLight : GBTColors.errorDark,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        _reportStatusLabel(status),
        style: GBTTypography.labelSmall.copyWith(color: fg),
      ),
    );
  }
}

class _CommunityBanSheet extends ConsumerStatefulWidget {
  const _CommunityBanSheet();

  @override
  ConsumerState<_CommunityBanSheet> createState() => _CommunityBanSheetState();
}

class _CommunityBanSheetState extends ConsumerState<_CommunityBanSheet> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isLookupLoading = false;
  String? _errorMessage;
  String? _lookupMessage;
  List<ProjectCommunityBan> _bans = const [];
  ProjectCommunityBan? _lookupBan;
  String _listQuery = '';
  bool _onlyPermanent = false;
  bool _hideExpired = true;
  CommunityBanSortOption _sortOption = CommunityBanSortOption.newest;

  @override
  void initState() {
    super.initState();
    _loadBans();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadBans() async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = '프로젝트를 먼저 선택해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.listProjectBans(
      projectCode: projectCode,
      page: 0,
      size: 100,
    );
    if (!mounted) return;

    if (result is Success<List<ProjectCommunityBan>>) {
      setState(() {
        _bans = result.data;
        _isLoading = false;
      });
    } else if (result is Err<List<ProjectCommunityBan>>) {
      setState(() {
        _bans = const [];
        _isLoading = false;
        _errorMessage = result.failure.userMessage;
      });
    }
  }

  Future<void> _lookupBanStatus() async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    final lookupQuery = _userIdController.text.trim();
    if (projectCode == null || projectCode.isEmpty) {
      setState(() => _lookupMessage = '프로젝트를 먼저 선택해주세요');
      return;
    }
    if (lookupQuery.isEmpty) {
      setState(() => _lookupMessage = '사용자 ID/닉네임/이메일을 입력해주세요');
      return;
    }

    setState(() {
      _isLookupLoading = true;
      _lookupMessage = null;
      _lookupBan = null;
    });

    if (_looksLikeUuid(lookupQuery)) {
      final repository = await ref.read(communityRepositoryProvider.future);
      final result = await repository.getProjectBanStatus(
        projectCode: projectCode,
        userId: lookupQuery,
      );
      if (!mounted) return;

      if (result is Success<ProjectCommunityBan>) {
        setState(() {
          _lookupBan = result.data;
          _isLookupLoading = false;
        });
        return;
      }
      if (result is Err<ProjectCommunityBan>) {
        setState(() {
          _lookupBan = null;
          _isLookupLoading = false;
          _lookupMessage = result.failure.userMessage;
        });
        return;
      }
    }

    if (_bans.isEmpty) {
      await _loadBans();
      if (!mounted) return;
    }

    final normalizedQuery = lookupQuery.toLowerCase();
    final matches = _bans
        .where((ban) {
          final name = ban.bannedUserDisplayName?.toLowerCase() ?? '';
          final email = ban.bannedUserEmail?.toLowerCase() ?? '';
          final userId = ban.bannedUserId.toLowerCase();
          return name.contains(normalizedQuery) ||
              email.contains(normalizedQuery) ||
              userId.contains(normalizedQuery);
        })
        .toList(growable: false);

    if (!mounted) return;
    if (matches.isEmpty) {
      setState(() {
        _lookupBan = null;
        _isLookupLoading = false;
        _lookupMessage = '일치하는 제재 사용자를 찾지 못했어요';
      });
      return;
    }

    if (matches.length == 1) {
      setState(() {
        _lookupBan = matches.first;
        _isLookupLoading = false;
      });
      return;
    }

    setState(() {
      _lookupBan = null;
      _isLookupLoading = false;
      _listQuery = lookupQuery;
      _filterController.text = lookupQuery;
      _lookupMessage = '${matches.length}건이 검색되어 목록 필터에 적용했어요';
    });
  }

  Future<void> _unbanUser(String userId) async {
    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로젝트를 먼저 선택해주세요')));
      return;
    }

    setState(() => _isProcessing = true);
    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.unbanProjectUser(
      projectCode: projectCode,
      userId: userId,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result is Success<void>) {
      if (_lookupBan?.bannedUserId == userId) {
        setState(() {
          _lookupBan = null;
          _lookupMessage = '제재를 해제했습니다';
        });
      }
      await _loadBans();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('커뮤니티 제재를 해제했어요')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제재 해제에 실패했어요')));
    }
  }

  bool _looksLikeUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final visibleBans = filterAndSortCommunityBans(
      bans: _bans,
      query: _listQuery,
      sortOption: _sortOption,
      onlyPermanent: _onlyPermanent,
      hideExpired: _hideExpired,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          GBTSpacing.md,
          GBTSpacing.md,
          GBTSpacing.md,
          GBTSpacing.lg,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('커뮤니티 제재 관리', style: GBTTypography.titleMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: _isProcessing ? null : _loadBans,
                    tooltip: '새로고침',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.sm),
              TextField(
                controller: _userIdController,
                decoration: InputDecoration(
                  hintText: '사용자 ID/닉네임/이메일로 제재 조회',
                  suffixIcon: _isLookupLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _lookupBanStatus,
                          icon: const Icon(Icons.search),
                        ),
                ),
                onSubmitted: (_) => _lookupBanStatus(),
              ),
              if (_lookupMessage != null) ...[
                const SizedBox(height: GBTSpacing.xs),
                Text(_lookupMessage!, style: GBTTypography.labelSmall),
              ],
              if (_lookupBan != null) ...[
                const SizedBox(height: GBTSpacing.sm),
                Card(
                  child: ListTile(
                    title: Text(
                      _lookupBan!.bannedUserDisplayName?.isNotEmpty == true
                          ? _lookupBan!.bannedUserDisplayName!
                          : _lookupBan!.bannedUserId,
                    ),
                    subtitle: Text(
                      _lookupBan!.expiresAt == null
                          ? '무기한 제재'
                          : '만료: ${_formatDateTime(_lookupBan!.expiresAt!)}',
                      style: GBTTypography.labelSmall,
                    ),
                    trailing: TextButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _unbanUser(_lookupBan!.bannedUserId),
                      child: const Text('해제'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: GBTSpacing.md),
              Text('현재 제재 목록', style: GBTTypography.titleSmall),
              const SizedBox(height: GBTSpacing.xs),
              TextField(
                controller: _filterController,
                onChanged: (value) {
                  setState(() => _listQuery = value);
                },
                decoration: InputDecoration(
                  hintText: '목록 필터 (이름/ID/사유)',
                  isDense: true,
                  prefixIcon: const Icon(Icons.filter_list),
                  suffixIcon: _listQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _filterController.clear();
                            setState(() => _listQuery = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: GBTSpacing.xs),
              Wrap(
                spacing: GBTSpacing.sm,
                runSpacing: GBTSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<CommunityBanSortOption>(
                    value: _sortOption,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _sortOption = value);
                    },
                    items: CommunityBanSortOption.values
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(_banSortLabel(option)),
                          ),
                        )
                        .toList(),
                  ),
                  FilterChip(
                    label: const Text('영구 제재만'),
                    selected: _onlyPermanent,
                    onSelected: (selected) {
                      setState(() => _onlyPermanent = selected);
                    },
                  ),
                  FilterChip(
                    label: const Text('만료 제외'),
                    selected: _hideExpired,
                    onSelected: (selected) {
                      setState(() => _hideExpired = selected);
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '표시 ${visibleBans.length} / 전체 ${_bans.length}',
                  style: GBTTypography.labelSmall,
                ),
              ),
              const SizedBox(height: GBTSpacing.xs),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: GBTLoading(message: '제재 목록을 불러오는 중...'),
                      )
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _bans.isEmpty
                    ? const Center(child: Text('현재 제재 중인 사용자가 없습니다'))
                    : visibleBans.isEmpty
                    ? const Center(child: Text('필터 조건에 맞는 제재가 없습니다'))
                    : ListView.separated(
                        itemCount: visibleBans.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: GBTSpacing.xs),
                        itemBuilder: (context, index) {
                          final ban = visibleBans[index];
                          final displayName = ban.bannedUserDisplayName;
                          final subtitleParts = <String>[
                            'ID: ${ban.bannedUserId}',
                            if (ban.reason?.isNotEmpty == true)
                              '사유: ${ban.reason!}',
                            if (ban.bannedUserEmail?.isNotEmpty == true)
                              '이메일: ${ban.bannedUserEmail!}',
                            if (ban.expiresAt != null)
                              '만료: ${_formatDateTime(ban.expiresAt!)}'
                            else
                              '무기한',
                          ];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusMd,
                              ),
                            ),
                            tileColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withAlpha(36),
                            title: Text(
                              displayName?.isNotEmpty == true
                                  ? displayName!
                                  : ban.bannedUserId,
                            ),
                            subtitle: Text(
                              subtitleParts.join(' · '),
                              style: GBTTypography.labelSmall,
                            ),
                            trailing: TextButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _unbanUser(ban.bannedUserId),
                              child: const Text('해제'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Helper functions (continued)
// KO: 헬퍼 함수 (계속)
// ========================================

String _resolveProjectName(List<Project> projects, String projectIdOrCode) {
  for (final project in projects) {
    if (project.id == projectIdOrCode || project.code == projectIdOrCode) {
      return project.name;
    }
  }
  return projectIdOrCode;
}

String _reportStatusLabel(CommunityReportStatus status) {
  switch (status) {
    case CommunityReportStatus.open:
      return '접수';
    case CommunityReportStatus.inReview:
      return '검토중';
    case CommunityReportStatus.resolved:
      return '처리완료';
    case CommunityReportStatus.rejected:
      return '반려';
  }
}

String _reportPriorityLabel(CommunityReportPriority priority) {
  switch (priority) {
    case CommunityReportPriority.low:
      return '낮음';
    case CommunityReportPriority.normal:
      return '보통';
    case CommunityReportPriority.high:
      return '높음';
    case CommunityReportPriority.critical:
      return '긴급';
  }
}

String _banSortLabel(CommunityBanSortOption option) {
  switch (option) {
    case CommunityBanSortOption.newest:
      return '최신순';
    case CommunityBanSortOption.oldest:
      return '오래된순';
    case CommunityBanSortOption.expiresSoon:
      return '만료 임박순';
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}.$month.$day $hour:$minute';
}

/// EN: Avatar widget with accessible touch targets.
/// KO: 접근 가능한 터치 타겟을 가진 아바타 위젯.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.radius,
    this.onTap,
    this.semanticLabel,
  });

  final String? url;
  final double radius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final iconColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(Icons.person, size: radius, color: iconColor),
    );

    final content = (url == null || url!.isEmpty)
        ? fallback
        : ClipOval(
            child: GBTImage(
              imageUrl: url!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              semanticLabel: semanticLabel ?? '프로필 사진',
            ),
          );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      label: semanticLabel ?? '프로필 보기',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: GBTSpacing.touchTarget,
            minHeight: GBTSpacing.touchTarget,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
