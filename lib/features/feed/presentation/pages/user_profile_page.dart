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
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/domain/entities/user_profile.dart';
import '../../application/community_moderation_controller.dart';
import '../../application/user_follow_controller.dart';
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
    final displayName = profile?.displayName ?? '사용자';
    final avatarUrl = profile?.avatarUrl;
    final coverUrl = profile?.coverImageUrl;
    final bio = profile?.bio?.trim();
    final bioLabel = (bio != null && bio.isNotEmpty) ? bio : '소개가 아직 없습니다.';
    final blockState = !isMyProfile && isAuthenticated
        ? ref.watch(blockStatusControllerProvider(userId))
        : const AsyncValue<BlockStatus>.loading();
    final blockStatus = blockState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final followState = !isMyProfile && isAuthenticated
        ? ref.watch(userFollowControllerProvider(userId))
        : const AsyncValue<UserFollowStatus>.loading();
    final followStatus = followState.maybeWhen(
      data: (status) => status,
      orElse: () => null,
    );
    final isFollowed = followState.maybeWhen(
      data: (status) => status.following,
      orElse: () => false,
    );
    final followerCount = followStatus?.targetFollowerCount;
    final followingCount = followStatus?.targetFollowingCount;
    final isBlockedProfile =
        blockStatus?.blockedByMe == true ||
        blockStatus?.blockedMe == true ||
        blockStatus?.blockedByAdmin == true;
    final isBlockActionBusy = blockStatus == null;
    final isFollowActionBusy = followState.isLoading;
    final canFollow = !isBlockedProfile && !isFollowActionBusy;
    final followLabel = isFollowed ? '팔로우 취소' : '팔로우';
    final blockLabel = blockStatus?.blockedByMe == true ? '차단 해제' : '차단';
    Widget? headerAction;
    if (isMyProfile) {
      headerAction = OutlinedButton(
        onPressed: () => context.pushNamed(AppRoutes.profileEdit),
        child: const Text('프로필 수정'),
      );
    } else if (isAuthenticated) {
      headerAction = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FilledButton.tonal(
            onPressed: canFollow
                ? () async {
                    final result = await ref
                        .read(userFollowControllerProvider(userId).notifier)
                        .toggleFollow();
                    if (!context.mounted) return;
                    if (result is Success<bool>) {
                      _showSnackBar(
                        context,
                        result.data ? '사용자를 팔로우했어요' : '팔로우를 취소했어요',
                      );
                    } else {
                      _showSnackBar(context, '팔로우 상태를 변경하지 못했어요');
                    }
                  }
                : null,
            child: Text(isBlockedProfile ? '차단됨' : followLabel),
          ),
          const SizedBox(height: GBTSpacing.xs),
          OutlinedButton(
            onPressed: isBlockActionBusy
                ? null
                : () async {
                    final result = await ref
                        .read(blockStatusControllerProvider(userId).notifier)
                        .toggleBlock();
                    if (result is Err<void> && context.mounted) {
                      _showSnackBar(context, '차단 상태를 변경하지 못했어요');
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
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('프로필'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: GBTSegmentedTabBar(
              height: 44,
              margin: EdgeInsets.symmetric(horizontal: GBTSpacing.md2),
              tabs: [
                Tab(text: '작성한 글'),
                Tab(text: '작성한 댓글'),
              ],
            ),
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
              followerCount: followerCount,
              followingCount: followingCount,
              onOpenFollowers: () => context.goToUserFollowers(userId),
              onOpenFollowing: () => context.goToUserFollowing(userId),
              action: headerAction,
            ),
            const Divider(height: 1),
            Expanded(
              child: isBlockedProfile && !isMyProfile
                  ? _BlockedProfileState(
                      blockedByMe: blockStatus?.blockedByMe == true,
                      blockedMe: blockStatus?.blockedMe == true,
                      blockedByAdmin: blockStatus?.blockedByAdmin == true,
                    )
                  : activityState.when(
                      loading: () => const GBTLoading(message: '활동을 불러오는 중...'),
                      error: (error, _) {
                        final message = error is Failure
                            ? error.userMessage
                            : '활동을 불러오지 못했어요';
                        return GBTErrorState(
                          message: message,
                          onRetry: () {
                            ref
                                .read(
                                  userActivityControllerProvider(
                                    userId,
                                  ).notifier,
                                )
                                .load(forceRefresh: true);
                          },
                        );
                      },
                      data: (activity) => TabBarView(
                        children: [
                          _PostsTab(
                            posts: activity.posts,
                            onRefresh: () => ref
                                .read(
                                  userActivityControllerProvider(
                                    userId,
                                  ).notifier,
                                )
                                .load(forceRefresh: true),
                          ),
                          _CommentsTab(
                            comments: activity.comments,
                            onRefresh: () => ref
                                .read(
                                  userActivityControllerProvider(
                                    userId,
                                  ).notifier,
                                )
                                .load(forceRefresh: true),
                          ),
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

class _BlockedProfileState extends StatelessWidget {
  const _BlockedProfileState({
    required this.blockedByMe,
    required this.blockedMe,
    required this.blockedByAdmin,
  });

  final bool blockedByMe;
  final bool blockedMe;
  final bool blockedByAdmin;

  @override
  Widget build(BuildContext context) {
    final message = blockedByAdmin
        ? '관리자 정책으로 이 사용자의 활동을 볼 수 없습니다.'
        : blockedByMe
        ? '차단한 사용자의 활동은 숨겨집니다.'
        : blockedMe
        ? '이 사용자가 나를 차단해 활동을 볼 수 없습니다.'
        : '활동을 표시할 수 없습니다.';

    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 40),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              message,
              style: GBTTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Profile avatar widget with dark-mode-aware placeholder.
/// KO: 다크 모드 인식 플레이스홀더를 가진 프로필 아바타 위젯.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url, this.radius = 28});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // EN: Use theme-aware placeholder colors.
    // KO: 테마 인식 플레이스홀더 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
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

/// EN: Profile header widget with cover image, avatar, and bio.
/// KO: 커버 이미지, 아바타, 소개를 포함한 프로필 헤더 위젯.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.coverUrl,
    required this.avatarUrl,
    required this.displayName,
    required this.bioLabel,
    required this.summaryLabel,
    required this.onOpenFollowers,
    required this.onOpenFollowing,
    this.followerCount,
    this.followingCount,
    this.action,
  });

  final String? coverUrl;
  final String? avatarUrl;
  final String displayName;
  final String bioLabel;
  final String? summaryLabel;
  final int? followerCount;
  final int? followingCount;
  final VoidCallback onOpenFollowers;
  final VoidCallback onOpenFollowing;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final labelColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return Semantics(
      label: '프로필: $displayName. $bioLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 148,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: coverUrl == null || coverUrl!.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      GBTColors.darkSurfaceVariant,
                                      GBTColors.darkBackground,
                                    ]
                                  : [GBTColors.surfaceAlternate, Colors.white],
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
                  bottom: -24,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? GBTColors.darkBackground : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _ProfileAvatar(url: avatarUrl, radius: 34),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: GBTSpacing.paddingPage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: GBTTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: GBTSpacing.sm),
                      action!,
                    ],
                  ],
                ),
                if (summaryLabel != null &&
                    summaryLabel!.trim().isNotEmpty) ...[
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    summaryLabel!,
                    style: GBTTypography.labelSmall.copyWith(color: labelColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: GBTSpacing.sm),
                Text(
                  bioLabel,
                  style: GBTTypography.bodySmall.copyWith(
                    color: secondaryColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: GBTSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _ConnectionStatTile(
                        label: '팔로워',
                        value: followerCount == null
                            ? '-'
                            : '${followerCount!}',
                        onTap: onOpenFollowers,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Expanded(
                      child: _ConnectionStatTile(
                        label: '팔로잉',
                        value: followingCount == null
                            ? '-'
                            : '${followingCount!}',
                        onTap: onOpenFollowing,
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

class _ConnectionStatTile extends StatelessWidget {
  const _ConnectionStatTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.sm,
          vertical: GBTSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          border: Border.all(
            color: isDark ? GBTColors.darkBorder : GBTColors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: GBTTypography.bodyMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: GBTSpacing.xs),
            Text(label, style: GBTTypography.labelSmall),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Posts tab showing user's authored posts.
/// KO: 사용자가 작성한 게시글을 보여주는 탭.
class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.posts, required this.onRefresh});

  final List<PostSummary> posts;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            GBTEmptyState(message: '작성한 글이 없습니다'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: GBTSpacing.paddingPage,
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: GBTSpacing.sm),
        itemBuilder: (context, index) {
          final post = posts[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final tertiaryColor = isDark
              ? GBTColors.darkTextTertiary
              : GBTColors.textTertiary;
          final surfaceColor = isDark
              ? GBTColors.darkSurface
              : GBTColors.surface;

          return InkWell(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
            onTap: () => context.goToPostDetail(post.id),
            child: Ink(
              padding: const EdgeInsets.all(GBTSpacing.sm),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
                border: Border.all(
                  color: isDark ? GBTColors.darkBorder : GBTColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: GBTTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.content != null &&
                      post.content!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      post.content!.trim(),
                      style: GBTTypography.bodySmall.copyWith(
                        color: tertiaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    post.timeAgoLabel,
                    style: GBTTypography.labelSmall.copyWith(
                      color: tertiaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// EN: Comments tab showing user's authored comments.
/// KO: 사용자가 작성한 댓글을 보여주는 탭.
class _CommentsTab extends StatelessWidget {
  const _CommentsTab({required this.comments, required this.onRefresh});

  final List<PostComment> comments;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            GBTEmptyState(message: '작성한 댓글이 없습니다'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: GBTSpacing.paddingPage,
        itemCount: comments.length,
        separatorBuilder: (_, __) => const SizedBox(height: GBTSpacing.sm),
        itemBuilder: (context, index) {
          final comment = comments[index];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final tertiaryColor = isDark
              ? GBTColors.darkTextTertiary
              : GBTColors.textTertiary;
          final surfaceColor = isDark
              ? GBTColors.darkSurface
              : GBTColors.surface;

          return InkWell(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
            onTap: () => context.goToPostDetail(comment.postId),
            child: Ink(
              padding: const EdgeInsets.all(GBTSpacing.sm),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
                border: Border.all(
                  color: isDark ? GBTColors.darkBorder : GBTColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.content,
                    style: GBTTypography.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment.timeAgoLabel,
                    style: GBTTypography.labelSmall.copyWith(
                      color: tertiaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
