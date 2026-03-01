/// EN: Board page showing community posts with modern SNS-style design.
/// KO: 모던 SNS 스타일 디자인의 커뮤니티 게시글을 표시하는 게시판 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/image_url_extractor.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/community_ban_view_helper.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Board page widget displaying tabs with refined design.
/// KO: 세련된 디자인의 탭을 표시하는 게시판 페이지 위젯.
class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key});

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profileState = ref.watch(userProfileControllerProvider);
    final isAdmin = profileState.maybeWhen(
      data: (profile) => _isAdminRole(profile?.role),
      orElse: () => false,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '새로고침',
              onPressed: () => ref
                  .read(communityFeedControllerProvider.notifier)
                  .reload(forceRefresh: true),
            ),
          if (_tabController.index == 0 && isAuthenticated)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: '내 신고 내역',
              onPressed: () => _showMyReportsSheet(context),
            ),
          if (_tabController.index == 0 && isAdmin)
            IconButton(
              icon: const Icon(Icons.gavel_outlined),
              tooltip: '커뮤니티 제재 관리',
              onPressed: () => _showCommunityBanSheet(context),
            ),
          const GBTProfileAction(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
            ),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? GBTColors.darkSurface : GBTColors.surface,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm + 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: isDark
                  ? GBTColors.darkTextPrimary
                  : GBTColors.textPrimary,
              unselectedLabelColor: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              labelStyle: GBTTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GBTTypography.labelLarge,
              tabs: const [
                Tab(text: '커뮤니티'),
                Tab(text: '여행후기'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CommunityTab(),
          _TravelReviewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            context.goToPostCreate();
          } else {
            context.pushNamed(AppRoutes.travelReviewCreate);
          }
        },
        icon: const Icon(Icons.edit_outlined),
        label: Text(_tabController.index == 0 ? '글쓰기' : '후기 작성'),
      ),
    );
  }
}

// ========================================
// EN: Community Tab
// KO: 커뮤니티 탭
// ========================================

class _CommunityTab extends ConsumerStatefulWidget {
  const _CommunityTab();

  @override
  ConsumerState<_CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<_CommunityTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 180) {
      ref.read(communityFeedControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(communityFeedControllerProvider);
    final notifier = ref.read(communityFeedControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // EN: Project selector
        // KO: 프로젝트 선택기
        const Padding(
          padding: EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.sm,
          ),
          child: ProjectSelectorCompact(),
        ),
        // EN: Search bar — borderless, pill-style
        // KO: 검색바 — 테두리 없는 필 스타일
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            0,
            GBTSpacing.md,
            GBTSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                notifier.applySearch(value);
              },
              decoration: InputDecoration(
                hintText: '게시글 검색',
                hintStyle: GBTTypography.bodyMedium.copyWith(
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                  size: 20,
                ),
                suffixIcon: feedState.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          notifier.clearSearch();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark
                              ? GBTColors.darkTextTertiary
                              : GBTColors.textTertiary,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.md,
                  vertical: GBTSpacing.sm + 2,
                ),
                isDense: true,
              ),
              style: GBTTypography.bodyMedium,
            ),
          ),
        ),
        // EN: Filter chips — horizontal scroll, modern pill style
        // KO: 필터 칩 — 가로 스크롤, 모던 필 스타일
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
            children: CommunityFeedMode.values
                .map(
                  (mode) => Padding(
                    padding: const EdgeInsets.only(right: GBTSpacing.sm),
                    child: _FilterChipModern(
                      label: mode.label,
                      isSelected: feedState.mode == mode,
                      onTap: () => notifier.setMode(mode),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // EN: Following subscriptions row
        // KO: 구독 목록 행
        if (feedState.mode == CommunityFeedMode.following) ...[
          const SizedBox(height: GBTSpacing.xs),
          SizedBox(
            height: 36,
            child: feedState.isSubscriptionsLoading
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.md,
                    ),
                    children: feedState.subscriptions.isEmpty
                        ? [
                            Chip(
                              label: Text(
                                '구독 중인 프로젝트가 없습니다',
                                style: GBTTypography.labelSmall,
                              ),
                            ),
                          ]
                        : feedState.subscriptions
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                    right: GBTSpacing.xs,
                                  ),
                                  child: Chip(
                                    label: Text(
                                      item.projectName,
                                      style: GBTTypography.labelSmall,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                  ),
          ),
        ],
        const SizedBox(height: GBTSpacing.xs),
        // EN: Content list
        // KO: 콘텐츠 리스트
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

/// EN: Modern filter chip with filled/outlined toggle style.
/// KO: 채워진/아웃라인 토글 스타일의 모던 필터 칩.
class _FilterChipModern extends StatelessWidget {
  const _FilterChipModern({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
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
        child: Text(
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
        'content':
            '이번엔 유명한 애니 성지 위주로만 골라서 가봤는데 너무 좋았어!! 다음엔 다른 지역도 가보고 싶다.',
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
            // EN: Map placeholder with gradient overlay
            // KO: 그라디언트 오버레이가 있는 지도 플레이스홀더
            Container(
              width: double.infinity,
              height: 160,
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
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: colorScheme.primary.withValues(alpha: 0.35),
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
                        color: Colors.black.withValues(alpha: 0.5),
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
              padding: GBTSpacing.paddingPage,
              children: const [
                SizedBox(height: GBTSpacing.lg),
                GBTLoading(message: '커뮤니티 글을 불러오는 중...'),
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
                ? '검색 결과가 없습니다'
                : switch (state.mode) {
                    CommunityFeedMode.latest => '아직 커뮤니티 글이 없습니다',
                    CommunityFeedMode.trending => '트렌딩 글이 아직 없습니다',
                    CommunityFeedMode.following => '구독 피드에 표시할 글이 없습니다',
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

          return ListView.separated(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) {
              if (index >= state.posts.length - 1) {
                return const SizedBox.shrink();
              }
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              return Divider(
                height: 1,
                thickness: 0.5,
                color: isDark ? GBTColors.darkBorder : GBTColors.divider,
                indent: GBTSpacing.md,
                endIndent: GBTSpacing.md,
              );
            },
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
          );
        },
      ),
    );
  }
}

// ========================================
// EN: Community Post Card — SNS-style, divider-separated
// KO: 커뮤니티 게시글 카드 — SNS 스타일, 구분선 분리
// ========================================

enum _PostCardAction { edit, delete, ban }

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
    final likeCount = post.likeCount ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

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
    final showMoreButton = isAuthenticated && (isAuthor || isAdmin);

    return InkWell(
      onTap: () => context.goToPostDetail(post.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Author row
            // KO: 작성자 행
            Row(
              children: [
                _Avatar(
                  url: avatarUrl,
                  radius: 18,
                  semanticLabel: '$authorLabel 프로필 사진',
                  onTap: () => context.goToUserProfile(post.authorId),
                ),
                const SizedBox(width: GBTSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorLabel,
                        style: GBTTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        post.timeAgoLabel,
                        style: GBTTypography.caption.copyWith(
                          color: tertiaryColor,
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
                      switch (action) {
                        case _PostCardAction.edit:
                          context.goToPostDetail(post.id);
                        case _PostCardAction.delete:
                          _confirmDeletePost(
                            context,
                            ref,
                            isAuthor: isAuthor,
                            isAdmin: isAdmin,
                          );
                        case _PostCardAction.ban:
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
                        if (isAdmin && !isAuthor)
                          PopupMenuItem(
                            value: _PostCardAction.ban,
                            child: Row(
                              children: [
                                Icon(Icons.block, size: 18, color: cs.error),
                                SizedBox(width: GBTSpacing.sm),
                                Text('차단', style: TextStyle(color: cs.error)),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
              ],
            ),
            const SizedBox(height: GBTSpacing.sm + 2),
            // EN: Title — semi-bold
            // KO: 제목 — 세미볼드
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: GBTTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // EN: Content snippet
                      // KO: 내용 스니펫
                      Builder(
                        builder: (context) {
                          if (post.content == null || post.content!.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final raw = stripImageMarkdown(post.content!);
                          if (raw.isEmpty) return const SizedBox.shrink();
                          final snippet = raw.length > 100
                              ? '${raw.substring(0, 100)}…'
                              : raw;
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: GBTSpacing.xs,
                            ),
                            child: Text(
                              snippet,
                              style: GBTTypography.bodySmall.copyWith(
                                color: secondaryTextColor,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (firstImageUrl != null) ...[
                  const SizedBox(width: GBTSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      GBTSpacing.radiusSm,
                    ),
                    child: GBTImage(
                      imageUrl: firstImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      semanticLabel: '${post.title} 첨부 이미지',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: GBTSpacing.sm + 2),
            // EN: Engagement stats row
            // KO: 인게이지먼트 통계 행
            Semantics(
              label: '좋아요 $likeCount개, 댓글 $commentCount개',
              child: Row(
                children: [
                  _EngagementStat(
                    icon: Icons.favorite_border,
                    count: likeCount,
                    color: tertiaryColor,
                  ),
                  const SizedBox(width: GBTSpacing.lg),
                  _EngagementStat(
                    icon: Icons.chat_bubble_outline,
                    count: commentCount,
                    color: tertiaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

/// EN: Engagement stat — icon + count pair.
/// KO: 인게이지먼트 통계 — 아이콘 + 카운트 쌍.
class _EngagementStat extends StatelessWidget {
  const _EngagementStat({
    required this.icon,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: GBTSpacing.xs),
        Text(
          _formatCount(count),
          style: GBTTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}천';
    return count.toString();
  }
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
    final (Color bg, Color fg) = switch (status) {
      CommunityReportStatus.open => (
        Colors.orange.shade100,
        Colors.orange.shade900,
      ),
      CommunityReportStatus.inReview => (
        Colors.blue.shade100,
        Colors.blue.shade900,
      ),
      CommunityReportStatus.resolved => (
        Colors.green.shade100,
        Colors.green.shade900,
      ),
      CommunityReportStatus.rejected => (
        Colors.red.shade100,
        Colors.red.shade900,
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
    final userId = _userIdController.text.trim();
    if (projectCode == null || projectCode.isEmpty) {
      setState(() => _lookupMessage = '프로젝트를 먼저 선택해주세요');
      return;
    }
    if (userId.isEmpty) {
      setState(() => _lookupMessage = '사용자 ID를 입력해주세요');
      return;
    }

    setState(() {
      _isLookupLoading = true;
      _lookupMessage = null;
      _lookupBan = null;
    });

    final repository = await ref.read(communityRepositoryProvider.future);
    final result = await repository.getProjectBanStatus(
      projectCode: projectCode,
      userId: userId,
    );
    if (!mounted) return;

    if (result is Success<ProjectCommunityBan>) {
      setState(() {
        _lookupBan = result.data;
        _isLookupLoading = false;
      });
    } else if (result is Err<ProjectCommunityBan>) {
      setState(() {
        _lookupBan = null;
        _isLookupLoading = false;
        _lookupMessage = result.failure.userMessage;
      });
    }
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
                  hintText: '사용자 ID로 제재 상태 조회',
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
// EN: Helper functions
// KO: 헬퍼 함수
// ========================================

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
