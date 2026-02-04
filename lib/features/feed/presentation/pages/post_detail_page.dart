/// EN: Community post detail page with comments.
/// KO: 댓글을 포함한 커뮤니티 게시글 상세 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: Post detail page widget.
/// KO: 게시글 상세 페이지 위젯.
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postDetailControllerProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // EN: TODO: Show options.
              // KO: TODO: 옵션 표시.
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => const GBTLoading(message: '게시글을 불러오는 중...'),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '게시글을 불러오지 못했어요';
          return GBTErrorState(
            message: message,
            onRetry: () => ref
                .read(postDetailControllerProvider(postId).notifier)
                .load(forceRefresh: true),
          );
        },
        data: (post) => _PostDetailContent(post: post),
      ),
    );
  }
}

class _PostDetailContent extends StatelessWidget {
  const _PostDetailContent({required this.post});

  final PostDetail post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: GBTSpacing.paddingPage,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: GBTColors.surfaceVariant,
                    child: Icon(Icons.person, color: GBTColors.textTertiary),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.title, style: GBTTypography.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          '작성자: ${post.authorId}',
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textTertiary,
                          ),
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
                  TextButton(
                    onPressed: () {
                      // EN: TODO: Follow user.
                      // KO: TODO: 사용자 팔로우.
                    },
                    child: const Text('팔로우'),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.md),
              Text(
                post.title,
                style: GBTTypography.bodyMedium.copyWith(height: 1.6),
              ),
              if (post.content != null && post.content!.isNotEmpty) ...[
                const SizedBox(height: GBTSpacing.md),
                Text(
                  post.content!,
                  style: GBTTypography.bodyMedium.copyWith(
                    height: 1.6,
                    color: GBTColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: GBTSpacing.md),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  Text(
                    '0',
                    style: GBTTypography.labelMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {},
                  ),
                  Text(
                    '0',
                    style: GBTTypography.labelMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                  IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                ],
              ),
              const Divider(),
              const SizedBox(height: GBTSpacing.md),
              Text(
                '댓글 0개',
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              ...List.generate(3, (index) => _CommentItem(index: index)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(GBTSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: GBTColors.border)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusFull,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.md,
                        vertical: GBTSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // EN: TODO: Send comment.
                    // KO: TODO: 댓글 전송.
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// EN: Comment item widget.
/// KO: 댓글 아이템 위젯.
class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GBTSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: GBTColors.surfaceVariant,
            child: Icon(Icons.person, size: 18, color: GBTColors.textTertiary),
          ),
          const SizedBox(width: GBTSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('댓글작성자${index + 1}', style: GBTTypography.labelMedium),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      '${index + 1}시간 전',
                      style: GBTTypography.labelSmall.copyWith(
                        color: GBTColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('댓글 내용입니다. 좋은 정보 감사합니다!', style: GBTTypography.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: GBTColors.textTertiary,
                      ),
                      label: Text(
                        '${index + 1}',
                        style: GBTTypography.labelSmall.copyWith(
                          color: GBTColors.textTertiary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24),
                      ),
                      child: Text(
                        '답글',
                        style: GBTTypography.labelSmall.copyWith(
                          color: GBTColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
