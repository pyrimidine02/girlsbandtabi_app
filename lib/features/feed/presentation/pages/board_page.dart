/// EN: Board page showing community posts.
/// KO: 커뮤니티 게시글을 표시하는 게시판 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failure.dart';
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
import '../../application/community_moderation_controller.dart';
import '../../application/feed_controller.dart';
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

  @override
  Widget build(BuildContext context) {
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
                  .read(postListControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
          const GBTProfileAction(),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GBTTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
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

class _CommunityTab extends ConsumerWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postListControllerProvider);

    return Column(
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
          child: _CommunityList(
            state: postState,
            onRefresh: () => ref
                .read(postListControllerProvider.notifier)
                .load(forceRefresh: true),
            onRetry: () => ref
                .read(postListControllerProvider.notifier)
                .load(forceRefresh: true),
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
        'content': '아침 일찍 도쿄역에 도착하자마자 오다이바 먼저 찍고 아키하바라로 넘어갔는데 일정이 좀 빡셌지만 너무 재밌었어.',
        'image': 'https://storage.googleapis.com/girlsbandtabi/thumbnails/placeholder_map1.webp',
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
        'image': 'https://storage.googleapis.com/girlsbandtabi/thumbnails/placeholder_map2.webp',
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
        'image': 'https://storage.googleapis.com/girlsbandtabi/thumbnails/placeholder_map3.webp',
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
              context.pushNamed(AppRoutes.travelReviewDetail, pathParameters: {'reviewId': review['id'] as String});
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
                      backgroundColor: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
                      child: Icon(Icons.person, size: 16, color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary),
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
                              color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
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
                    color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Icon(Icons.map, size: 48, color: Theme.of(context).colorScheme.primary.withAlpha(100)),
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < places.length; i++) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${i + 1}. ${places[i]}',
                            style: GBTTypography.labelSmall.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (i < places.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                          ),
                      ]
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
                    color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: GBTSpacing.md),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      '${review['likeCount']}',
                      style: GBTTypography.labelSmall.copyWith(
                        color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
                    ),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      '${review['commentCount']}',
                      style: GBTTypography.labelSmall.copyWith(
                        color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
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
    required this.onRefresh,
    required this.onRetry,
  });

  final AsyncValue<List<PostSummary>> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: const [
            SizedBox(height: GBTSpacing.lg),
            GBTLoading(message: '커뮤니티 글을 불러오는 중...'),
          ],
        ),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '커뮤니티 글을 불러오지 못했어요';
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: [
              const SizedBox(height: GBTSpacing.lg),
              GBTErrorState(message: message, onRetry: onRetry),
            ],
          );
        },
        data: (posts) {
          if (posts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: const [
                SizedBox(height: GBTSpacing.lg),
                GBTEmptyState(message: '아직 커뮤니티 글이 없습니다'),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
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
    final isAuthor =
        currentUserId != null && currentUserId == post.authorId;
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
                            _confirmDeletePost(context, ref);
                          case _PostCardAction.ban:
                            _confirmBanUser(context, ref);
                        }
                      },
                      itemBuilder: (menuContext) {
                        final cs = Theme.of(menuContext).colorScheme;
                        return [
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
                          const PopupMenuDivider(),
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
                                  '삭제',
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
                                  Icon(
                                    Icons.block,
                                    size: 18,
                                    color: cs.error,
                                  ),
                                  SizedBox(width: GBTSpacing.sm),
                                  Text(
                                    '차단',
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
  Future<void> _confirmDeletePost(BuildContext context, WidgetRef ref) async {
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

    final repository = await ref.read(feedRepositoryProvider.future);
    final result = await repository.deletePost(
      projectCode: projectCode,
      postId: post.id,
    );

    if (!context.mounted) return;
    if (result is Success<void>) {
      await ref
          .read(postListControllerProvider.notifier)
          .load(forceRefresh: true);
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

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사용자 차단'),
        content: Text('$authorLabel 사용자를 차단할까요?\n차단하면 해당 사용자의 글이 보이지 않습니다.'),
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

    final controller = ref.read(
      blockStatusControllerProvider(post.authorId).notifier,
    );
    final result = await controller.blockUser();

    if (!context.mounted) return;
    if (result is Success<void>) {
      await ref
          .read(postListControllerProvider.notifier)
          .load(forceRefresh: true);
      if (context.mounted) {
        _showSnackBar(context, '$authorLabel 사용자를 차단했어요');
      }
    } else if (result is Err<void>) {
      _showSnackBar(context, '차단에 실패했어요');
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

