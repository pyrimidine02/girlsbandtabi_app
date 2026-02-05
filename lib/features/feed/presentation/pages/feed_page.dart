/// EN: Feed page with news and community tabs.
/// KO: 뉴스 및 커뮤니티 탭을 포함한 피드 페이지.
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
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Feed page widget.
/// KO: 피드 페이지 위젯.
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCommunityFab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _showCommunityFab = _tabController.index == 1;
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) return;
    final shouldShow = _tabController.index == 1;
    if (shouldShow == _showCommunityFab) return;
    setState(() => _showCommunityFab = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsListControllerProvider);
    final postState = ref.watch(postListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('소식'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '뉴스'),
            Tab(text: '커뮤니티'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.goToSearch(),
            tooltip: '검색',
          ),
        ],
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
              children: [
                _NewsList(
                  state: newsState,
                  onRetry: () => ref
                      .read(newsListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
                _CommunityList(
                  state: postState,
                  onRetry: () => ref
                      .read(postListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showCommunityFab
          ? FloatingActionButton(
              onPressed: () => context.goToPostCreate(),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }
}

/// EN: News list widget.
/// KO: 뉴스 리스트 위젯.
class _NewsList extends StatelessWidget {
  const _NewsList({required this.state, required this.onRetry});

  final AsyncValue<List<NewsSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => ListView(
        padding: GBTSpacing.paddingPage,
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTLoading(message: '뉴스를 불러오는 중...'),
        ],
      ),
      error: (error, _) {
        final message = error is Failure ? error.userMessage : '뉴스를 불러오지 못했어요';
        return ListView(
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(message: message, onRetry: onRetry),
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

/// EN: News card widget.
/// KO: 뉴스 카드 위젯.
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final thumbnail = news.thumbnailUrl;

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
                    Row(
                      children: [
                        Text(
                          news.dateLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textTertiary,
                          ),
                        ),
                      ],
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
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: Icon(Icons.image, color: GBTColors.textTertiary),
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

/// EN: Community list widget.
/// KO: 커뮤니티 리스트 위젯.
class _CommunityList extends StatelessWidget {
  const _CommunityList({required this.state, required this.onRetry});

  final AsyncValue<List<PostSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => ListView(
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
            padding: GBTSpacing.paddingPage,
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(message: '아직 커뮤니티 글이 없습니다'),
            ],
          );
        }

        return ListView.builder(
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
    );
  }
}

/// EN: Community post card widget.
/// KO: 커뮤니티 게시글 카드 위젯.
class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({required this.post});

  final PostSummary post;

  @override
  Widget build(BuildContext context) {
    final authorLabel = post.authorName?.isNotEmpty == true
        ? post.authorName!
        : post.authorId;
    final avatarUrl =
        post.authorAvatarUrl?.isNotEmpty == true ? post.authorAvatarUrl : null;
    final commentCount = post.commentCount ?? 0;
    final likeCount = post.likeCount ?? 0;

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
                    onTap: () => context.goToUserProfile(post.authorId),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '작성자: $authorLabel',
                          style: GBTTypography.labelMedium,
                        ),
                        Text(
                          post.timeAgoLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                post.title,
                style: GBTTypography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                '프로젝트: ${post.projectId}',
                style: GBTTypography.labelSmall.copyWith(
                  color: GBTColors.textSecondary,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: GBTColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    likeCount.toString(),
                    style: GBTTypography.labelSmall.copyWith(
                      color: GBTColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: GBTColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    commentCount.toString(),
                    style: GBTTypography.labelSmall.copyWith(
                      color: GBTColors.textTertiary,
                    ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.radius,
    this.onTap,
  });

  final String? url;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: GBTColors.surfaceVariant,
      child: Icon(
        Icons.person,
        size: radius,
        color: GBTColors.textTertiary,
      ),
    );

    final content = (url == null || url!.isEmpty)
        ? fallback
        : ClipOval(
            child: GBTImage(
              imageUrl: url!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              semanticLabel: '프로필 사진',
            ),
          );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
