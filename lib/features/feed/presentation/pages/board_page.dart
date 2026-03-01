/// EN: Board page showing community posts.
/// KO: 커뮤니티 게시글을 표시하는 게시판 페이지.
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

/// EN: Board page widget displaying tabs.
/// KO: 탭을 표시하는 게시판 페이지 위젯.
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
    // EN: Rebuild AppBar when tab changes so the refresh button reflects current tab state.
    // KO: 탭 변경 시 AppBar를 다시 빌드하여 새로고침 버튼이 현재 탭 상태를 반영하도록 합니다.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시판'),
        actions: [
          // EN: Refresh community posts — only active on community tab (index 0).
          // KO: 커뮤니티 게시글 새로고침 — 커뮤니티 탭(인덱스 0)에서만 활성화됩니다.
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
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GBTTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GBTTypography.titleSmall,
          tabs: const [
            Tab(text: '커뮤니티'),
            Tab(text: '여행후기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // EN: Tab 1: Community
          // KO: 첫 번째 탭: 커뮤니티
          const _CommunityTab(),

          // EN: Tab 2: Travel Review
          // KO: 두 번째 탭: 여행후기
          const _TravelReviewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            context.goToPostCreate();
          } else {
            // EN: Go to travel review create
            // KO: 여행후기 작성 페이지로 이동
            context.pushNamed(AppRoutes.travelReviewCreate);
          }
        },
        tooltip: '새 글 작성',
        child: const Icon(Icons.edit),
      ),
    );
  }
}

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
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.sm,
          ),
          child: const ProjectSelectorCompact(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            0,
            GBTSpacing.md,
            GBTSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              notifier.applySearch(value);
            },
            decoration: InputDecoration(
              hintText: '게시글 검색 (제목/내용)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: feedState.searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        notifier.clearSearch();
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              ),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
            children: CommunityFeedMode.values
                .map(
                  (mode) => Padding(
                    padding: const EdgeInsets.only(right: GBTSpacing.xs),
                    child: ChoiceChip(
                      label: Text(mode.label),
                      selected: feedState.mode == mode,
                      onSelected: (_) => notifier.setMode(mode),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
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
        Divider(height: 1, color: borderColor),
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

class _TravelReviewTab extends ConsumerWidget {
  const _TravelReviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EN: Dummy mockup data for Travel Reviews
    // KO: 여행 후기를 위한 더미 목업 데이터
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
      padding: GBTSpacing.paddingPage,
      itemCount: mockReviews.length,
      itemBuilder: (context, index) {
        final review = mockReviews[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final places = review['places'] as List<String>;

        return Card(
          margin: const EdgeInsets.only(bottom: GBTSpacing.md),
          child: InkWell(
            onTap: () {
              // EN: Navigate to mock detail
              // KO: 목업 상세 페이지로 이동
              context.pushNamed(
                AppRoutes.travelReviewDetail,
                pathParameters: {'reviewId': review['id'] as String},
              );
            },
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            child: Padding(
              padding: GBTSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isDark
                            ? GBTColors.darkSurfaceVariant
                            : GBTColors.surfaceVariant,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: isDark
                              ? GBTColors.darkTextTertiary
                              : GBTColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['authorName'] as String,
                              style: GBTTypography.labelMedium,
                            ),
                            Text(
                              review['timeAgo'] as String,
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
                  const SizedBox(height: GBTSpacing.sm),
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark
                          ? GBTColors.darkSurfaceVariant
                          : GBTColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < places.length; i++) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${i + 1}. ${places[i]}',
                              style: GBTTypography.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (i < places.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Text(
                    review['title'] as String,
                    style: GBTTypography.titleMedium,
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
                  const SizedBox(height: GBTSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary,
                      ),
                      const SizedBox(width: GBTSpacing.xs),
                      Text(
                        '${review['likeCount']}',
                        style: GBTTypography.labelSmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextTertiary
                              : GBTColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.md),
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary,
                      ),
                      const SizedBox(width: GBTSpacing.xs),
                      Text(
                        '${review['commentCount']}',
                        style: GBTTypography.labelSmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextTertiary
                              : GBTColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// EN: Community list widget.
/// KO: 커뮤니티 리스트 위젯.
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

          return ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
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
              return Padding(
                padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                child: _CommunityPostCard(post: post),
              );
            },
          );
        },
      ),
    );
  }
}

/// EN: Possible actions for the post action sheet.
/// KO: 게시글 액션시트에서 선택 가능한 동작 열거형.
enum _PostCardAction { edit, delete, ban }

/// EN: Community post card widget with context-aware actions.
/// KO: 사용자 역할에 따른 액션을 제공하는 커뮤니티 게시글 카드 위젯.
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
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    // EN: Resolve first image URL for thumbnail.
    // KO: 썸네일용 첫 번째 이미지 URL을 해석합니다.
    // EN: Priority: imageUrls → content extraction → thumbnailUrl.
    // KO: 우선순위: imageUrls → 콘텐츠 추출 → thumbnailUrl.
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

    // EN: Determine current user identity and admin status.
    // KO: 현재 사용자 ID와 관리자 여부를 확인합니다.
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
    // EN: Show the more button only for the author or admin.
    // KO: 작성자 또는 관리자에게만 더보기 버튼을 표시합니다.
    final showMoreButton = isAuthenticated && (isAuthor || isAdmin);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.goToPostDetail(post.id),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Padding(
          padding: GBTSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text(
                          authorLabel,
                          style: GBTTypography.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.timeAgoLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: tertiaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showMoreButton)
                    PopupMenuButton<_PostCardAction>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      tooltip: '더 보기',
                      padding: EdgeInsets.zero,
                      onSelected: (action) {
                        switch (action) {
                          case _PostCardAction.edit:
                            // EN: Navigate to detail page for editing.
                            // KO: 수정을 위해 상세 페이지로 이동합니다.
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
              const SizedBox(height: GBTSpacing.sm),
              // EN: Title row with optional thumbnail on the right.
              // KO: 오른쪽에 선택적 썸네일이 있는 제목 행.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: GBTTypography.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (firstImageUrl != null) ...[
                    const SizedBox(width: GBTSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                      child: GBTImage(
                        imageUrl: firstImageUrl,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        semanticLabel: '${post.title} 첨부 이미지',
                      ),
                    ),
                  ],
                ],
              ),
              // EN: Content snippet below the title row, images stripped.
              // KO: 이미지 제거 후 제목 하단에 내용 스니펫 표시.
              Builder(
                builder: (context) {
                  if (post.content == null || post.content!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final raw = stripImageMarkdown(post.content!);
                  if (raw.isEmpty) return const SizedBox.shrink();
                  final snippet = raw.length > 80
                      ? '${raw.substring(0, 80)}…'
                      : raw;
                  return Padding(
                    padding: const EdgeInsets.only(top: GBTSpacing.xs),
                    child: Text(
                      snippet,
                      style: GBTTypography.bodySmall.copyWith(
                        color: isDark
                            ? GBTColors.darkTextSecondary
                            : GBTColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
              const SizedBox(height: GBTSpacing.sm),
              Semantics(
                label: '좋아요 $likeCount개, 댓글 $commentCount개',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: tertiaryColor),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      likeCount.toString(),
                      style: GBTTypography.labelSmall.copyWith(
                        color: tertiaryColor,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: tertiaryColor,
                    ),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      commentCount.toString(),
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

  /// EN: Show delete confirmation dialog and delete the post.
  /// KO: 삭제 확인 다이얼로그를 표시하고 게시글을 삭제합니다.
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

  /// EN: Show ban confirmation dialog and ban the post author.
  /// KO: 차단 확인 다이얼로그를 표시하고 게시글 작성자를 차단합니다.
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

/// EN: Returns true when a role has admin/moderator privileges.
/// KO: 관리자/모더레이터 권한이 있는 역할인지 반환합니다.
bool _isAdminRole(String? role) {
  if (role == null) return false;
  final normalized = role.toUpperCase();
  return normalized.contains('ADMIN') || normalized.contains('MODERATOR');
}

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
    // EN: Use theme-aware placeholder colors.
    // KO: 테마 인식 플레이스홀더 색상을 사용합니다.
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

    // EN: Ensure minimum 48x48 touch target for accessibility.
    // KO: 접근성을 위해 최소 48x48 터치 타겟을 보장합니다.
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
