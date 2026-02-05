/// EN: Community user profile page showing posts and comments.
/// KO: 게시글/댓글을 보여주는 커뮤니티 사용자 프로필 페이지.
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
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/domain/entities/user_profile.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/user_activity_controller.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: User profile page for community activity.
/// KO: 커뮤니티 활동 사용자 프로필 페이지.
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProfileState = ref.watch(userProfileControllerProvider);
    final myProfile = myProfileState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final publicProfileState = userId == myProfile?.id
        ? const AsyncValue<UserProfile?>.data(null)
        : ref.watch(userProfileByIdProvider(userId));
    final activityState = ref.watch(userActivityControllerProvider(userId));

    final publicProfile = publicProfileState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final isMyProfile = myProfile?.id == userId;
    final profile = isMyProfile ? myProfile : publicProfile;
    final displayName = profile?.displayName ?? userId;
    final avatarUrl = profile?.avatarUrl;
    final coverUrl = profile?.coverImageUrl;
    final bio = profile?.bio?.trim();
    final bioLabel = (bio != null && bio.isNotEmpty)
        ? bio
        : '소개가 아직 없습니다.';
    final blockState = !isMyProfile && isAuthenticated
        ? ref.watch(blockStatusControllerProvider(userId))
        : const AsyncValue<BlockStatus>.loading();
    final blockStatus = blockState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final blockLabel = blockStatus?.blockedByMe == true ? '차단 해제' : '차단';
    Widget? headerAction;
    if (isMyProfile) {
      headerAction = OutlinedButton(
        onPressed: () => context.goNamed(AppRoutes.profileEdit),
        child: const Text('프로필 수정'),
      );
    } else if (isAuthenticated) {
      headerAction = OutlinedButton(
        onPressed: blockStatus == null
            ? null
            : () async {
                final result = await ref
                    .read(
                      blockStatusControllerProvider(userId).notifier,
                    )
                    .toggleBlock();
                if (result is Err<void> && context.mounted) {
                  _showSnackBar(
                    context,
                    '차단 상태를 변경하지 못했어요',
                  );
                  return;
                }
                final updated = ref
                    .read(blockStatusControllerProvider(userId))
                    .maybeWhen(
                      data: (value) => value.blockedByMe,
                      orElse: () => false,
                    );
                if (context.mounted) {
                  _showSnackBar(
                    context,
                    updated ? '사용자를 차단했어요' : '차단을 해제했어요',
                  );
                }
              },
        child: Text(blockLabel),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('프로필'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '작성한 글'),
              Tab(text: '작성한 댓글'),
            ],
          ),
        ),
        body: Column(
          children: [
            _ProfileHeader(
              coverUrl: coverUrl,
              avatarUrl: avatarUrl,
              displayName: displayName,
              bioLabel: bioLabel,
              summaryLabel: profile?.summaryLabel,
              action: headerAction,
            ),
            const Divider(height: 1),
            Expanded(
              child: activityState.when(
                loading: () => const GBTLoading(message: '활동을 불러오는 중...'),
                error: (error, _) {
                  final message = error is Failure
                      ? error.userMessage
                      : '활동을 불러오지 못했어요';
                  return GBTErrorState(message: message);
                },
                data: (activity) => TabBarView(
                  children: [
                    _PostsTab(posts: activity.posts),
                    _CommentsTab(comments: activity.comments),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url, this.radius = 28});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          color: GBTColors.textTertiary,
          size: radius,
        ),
      );
    }

    return ClipOval(
      child: GBTImage(
        imageUrl: url!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        semanticLabel: '프로필 사진',
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.coverUrl,
    required this.avatarUrl,
    required this.displayName,
    required this.bioLabel,
    required this.summaryLabel,
    this.action,
  });

  final String? coverUrl;
  final String? avatarUrl;
  final String displayName;
  final String bioLabel;
  final String? summaryLabel;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            children: [
              Positioned.fill(
                child: coverUrl == null || coverUrl!.isEmpty
                    ? Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2F3C4F),
                              Color(0xFF1C2330),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      )
                    : GBTImage(
                        imageUrl: coverUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        semanticLabel: '프로필 배경 이미지',
                      ),
              ),
              Positioned(
                left: GBTSpacing.md,
                bottom: -28,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: _ProfileAvatar(url: avatarUrl, radius: 36),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: GBTSpacing.paddingPage,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GBTTypography.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (summaryLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        summaryLabel!,
                        style: GBTTypography.labelSmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      bioLabel,
                      style: GBTTypography.bodySmall.copyWith(
                        color: GBTColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
        ),
      ],
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.posts});

  final List<PostSummary> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const GBTEmptyState(message: '작성한 글이 없습니다');
    }

    return ListView.separated(
      padding: GBTSpacing.paddingPage,
      itemCount: posts.length,
      separatorBuilder: (_, __) => const Divider(height: GBTSpacing.md),
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(post.title, style: GBTTypography.bodyMedium),
          subtitle: Text(
            post.timeAgoLabel,
            style: GBTTypography.labelSmall.copyWith(
              color: GBTColors.textTertiary,
            ),
          ),
          onTap: () => context.goToPostDetail(post.id),
        );
      },
    );
  }
}

class _CommentsTab extends StatelessWidget {
  const _CommentsTab({required this.comments});

  final List<PostComment> comments;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const GBTEmptyState(message: '작성한 댓글이 없습니다');
    }

    return ListView.separated(
      padding: GBTSpacing.paddingPage,
      itemCount: comments.length,
      separatorBuilder: (_, __) => const Divider(height: GBTSpacing.md),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(comment.content, style: GBTTypography.bodyMedium),
          subtitle: Text(
            comment.timeAgoLabel,
            style: GBTTypography.labelSmall.copyWith(
              color: GBTColors.textTertiary,
            ),
          ),
          onTap: () => context.goToPostDetail(comment.postId),
        );
      },
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
