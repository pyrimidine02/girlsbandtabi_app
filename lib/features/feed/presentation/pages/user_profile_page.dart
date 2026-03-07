/// EN: Community user profile page showing posts and comments.
/// KO: 게시글/댓글을 보여주는 커뮤니티 사용자 프로필 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
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
import '../../application/user_follow_list_controller.dart';
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
    final displayName =
        profile?.displayName ?? context.l10n(ko: '사용자', en: 'User', ja: 'ユーザー');
    final avatarUrl = profile?.avatarUrl;
    final coverUrl = profile?.coverImageUrl;
    final bio = profile?.bio?.trim();
    final bioLabel = (bio != null && bio.isNotEmpty)
        ? bio
        : context.l10n(
            ko: '소개가 아직 없습니다.',
            en: 'No bio yet.',
            ja: '紹介はまだありません。',
          );
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
    final followersState = isAuthenticated
        ? ref.watch(userFollowersProvider(userId))
        : const AsyncValue<List<UserFollowSummary>>.data([]);
    final followingState = isAuthenticated
        ? ref.watch(userFollowingProvider(userId))
        : const AsyncValue<List<UserFollowSummary>>.data([]);
    final followerCountFromList = followersState.maybeWhen(
      data: (value) => value.length,
      orElse: () => null,
    );
    final followingCountFromList = followingState.maybeWhen(
      data: (value) => value.length,
      orElse: () => null,
    );
    final followerCount =
        followStatus?.targetFollowerCount ?? followerCountFromList;
    final followingCount =
        followStatus?.targetFollowingCount ?? followingCountFromList;
    final isBlockedProfile =
        blockStatus?.blockedByMe == true ||
        blockStatus?.blockedMe == true ||
        blockStatus?.blockedByAdmin == true;
    final isBlockActionBusy = blockStatus == null;
    final isFollowActionBusy = followState.isLoading;
    final canFollow = !isBlockedProfile && !isFollowActionBusy;
    final followLabel = isFollowed
        ? context.l10n(ko: '팔로우 취소', en: 'Unfollow', ja: 'フォロー解除')
        : context.l10n(ko: '팔로우', en: 'Follow', ja: 'フォロー');
    final blockLabel = blockStatus?.blockedByMe == true
        ? context.l10n(ko: '차단 해제', en: 'Unblock', ja: 'ブロック解除')
        : context.l10n(ko: '차단', en: 'Block', ja: 'ブロック');
    Widget? headerAction;
    if (isMyProfile) {
      headerAction = OutlinedButton(
        onPressed: () => context.pushNamed(AppRoutes.profileEdit),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(
          context.l10n(ko: '프로필 수정', en: 'Edit profile', ja: 'プロフィール編集'),
          style: GBTTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    } else if (isAuthenticated) {
      headerAction = Wrap(
        spacing: GBTSpacing.xs,
        runSpacing: GBTSpacing.xs,
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
                        result.data
                            ? context.l10n(
                                ko: '사용자를 팔로우했어요',
                                en: 'You followed this user',
                                ja: 'このユーザーをフォローしました',
                              )
                            : context.l10n(
                                ko: '팔로우를 취소했어요',
                                en: 'Unfollowed',
                                ja: 'フォローを解除しました',
                              ),
                      );
                    } else {
                      _showSnackBar(
                        context,
                        context.l10n(
                          ko: '팔로우 상태를 변경하지 못했어요',
                          en: 'Failed to update follow status',
                          ja: 'フォロー状態を変更できませんでした',
                        ),
                      );
                    }
                  }
                : null,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              isBlockedProfile
                  ? context.l10n(ko: '차단됨', en: 'Blocked', ja: 'ブロック済み')
                  : followLabel,
              style: GBTTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: isBlockActionBusy
                ? null
                : () async {
                    final result = await ref
                        .read(blockStatusControllerProvider(userId).notifier)
                        .toggleBlock();
                    if (result is Err<void> && context.mounted) {
                      _showSnackBar(
                        context,
                        context.l10n(
                          ko: '차단 상태를 변경하지 못했어요',
                          en: 'Failed to update block status',
                          ja: 'ブロック状態を変更できませんでした',
                        ),
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
                        updated
                            ? context.l10n(
                                ko: '사용자를 차단했어요',
                                en: 'User blocked',
                                ja: 'ユーザーをブロックしました',
                              )
                            : context.l10n(
                                ko: '차단을 해제했어요',
                                en: 'User unblocked',
                                ja: 'ブロックを解除しました',
                              ),
                      );
                    }
                  },
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              blockLabel,
              style: GBTTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
    Widget buildProfileHeader() => _ProfileHeader(
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
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isMyProfile
                ? context.l10n(ko: '내 프로필', en: 'My Profile', ja: 'マイプロフィール')
                : displayName,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: GBTSegmentedTabBar(
              height: 44,
              margin: EdgeInsets.symmetric(horizontal: GBTSpacing.md2),
              tabs: [
                Tab(
                  text: context.l10n(ko: '작성한 글', en: 'Posts', ja: '投稿'),
                ),
                Tab(
                  text: context.l10n(ko: '작성한 댓글', en: 'Comments', ja: 'コメント'),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: isBlockedProfile && !isMyProfile
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        buildProfileHeader(),
                        const Divider(height: 1),
                        _BlockedProfileState(
                          blockedByMe: blockStatus?.blockedByMe == true,
                          blockedMe: blockStatus?.blockedMe == true,
                          blockedByAdmin: blockStatus?.blockedByAdmin == true,
                        ),
                      ],
                    )
                  : activityState.when(
                      loading: () => ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          buildProfileHeader(),
                          const Divider(height: 1),
                          Padding(
                            padding: GBTSpacing.paddingPage,
                            child: GBTLoading(
                              message: context.l10n(
                                ko: '활동을 불러오는 중...',
                                en: 'Loading activity...',
                                ja: 'アクティビティを読み込み中...',
                              ),
                            ),
                          ),
                        ],
                      ),
                      error: (error, _) {
                        final message = error is Failure
                            ? error.userMessage
                            : context.l10n(
                                ko: '활동을 불러오지 못했어요',
                                en: 'Failed to load activity',
                                ja: 'アクティビティを読み込めませんでした',
                              );
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            buildProfileHeader(),
                            const Divider(height: 1),
                            Padding(
                              padding: GBTSpacing.paddingPage,
                              child: GBTErrorState(
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
                              ),
                            ),
                          ],
                        );
                      },
                      data: (activity) => TabBarView(
                        children: [
                          _PostsTab(
                            headerBuilder: buildProfileHeader,
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
                            headerBuilder: buildProfileHeader,
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
        ? context.l10n(
            ko: '관리자 정책으로 이 사용자의 활동을 볼 수 없습니다.',
            en: 'You cannot view this user due to admin policy.',
            ja: '管理者ポリシーによりこのユーザーの活動を表示できません。',
          )
        : blockedByMe
        ? context.l10n(
            ko: '차단한 사용자의 활동은 숨겨집니다.',
            en: 'Blocked user activity is hidden.',
            ja: 'ブロックしたユーザーの活動は非表示です。',
          )
        : blockedMe
        ? context.l10n(
            ko: '이 사용자가 나를 차단해 활동을 볼 수 없습니다.',
            en: 'This user blocked you, activity is unavailable.',
            ja: 'このユーザーにブロックされているため活動を表示できません。',
          )
        : context.l10n(
            ko: '활동을 표시할 수 없습니다.',
            en: 'Cannot display activity.',
            ja: '活動を表示できません。',
          );

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
        semanticLabel: context.l10n(
          ko: '프로필 사진',
          en: 'Profile image',
          ja: 'プロフィール画像',
        ),
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
    final surfaceColor = isDark ? GBTColors.darkSurface : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final labelColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return Semantics(
      label:
          '${context.l10n(ko: "프로필", en: "Profile", ja: "プロフィール")}: $displayName. $bioLabel',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          GBTSpacing.pageHorizontal,
          GBTSpacing.md,
          GBTSpacing.pageHorizontal,
          GBTSpacing.md,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusLg + 2),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(GBTSpacing.radiusLg + 2),
                ),
                child: SizedBox(
                  height: 102,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      coverUrl == null || coverUrl!.isEmpty
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
                                      : [
                                          GBTColors.surfaceAlternate,
                                          Colors.white,
                                        ],
                                ),
                              ),
                            )
                          : GBTImage(
                              imageUrl: coverUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              semanticLabel: context.l10n(
                                ko: '프로필 배경 이미지',
                                en: 'Profile cover image',
                                ja: 'プロフィール背景画像',
                              ),
                            ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              (isDark ? Colors.black : Colors.white).withValues(
                                alpha: 0.18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: _ProfileAvatar(url: avatarUrl, radius: 30),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  GBTSpacing.md,
                  0,
                  GBTSpacing.md,
                  GBTSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GBTTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (summaryLabel != null &&
                        summaryLabel!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        summaryLabel!,
                        style: GBTTypography.labelSmall.copyWith(
                          color: labelColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: GBTSpacing.sm),
                    Text(
                      bioLabel,
                      style: GBTTypography.bodySmall.copyWith(
                        color: secondaryColor,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (action != null) ...[
                      const SizedBox(height: GBTSpacing.sm),
                      action!,
                    ],
                    const SizedBox(height: GBTSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _ConnectionStatTile(
                            label: context.l10n(
                              ko: '팔로워',
                              en: 'Followers',
                              ja: 'フォロワー',
                            ),
                            value: followerCount == null
                                ? '-'
                                : '${followerCount!}',
                            onTap: onOpenFollowers,
                          ),
                        ),
                        const SizedBox(width: GBTSpacing.sm),
                        Expanded(
                          child: _ConnectionStatTile(
                            label: context.l10n(
                              ko: '팔로잉',
                              en: 'Following',
                              ja: 'フォロー中',
                            ),
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
        ),
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
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.sm + 1,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GBTTypography.bodyMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GBTTypography.labelSmall.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
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
  const _PostsTab({
    required this.headerBuilder,
    required this.posts,
    required this.onRefresh,
  });

  final Widget Function() headerBuilder;
  final List<PostSummary> posts;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          headerBuilder(),
          const Divider(height: 1),
          if (posts.isEmpty) ...[
            const SizedBox(height: 80),
            GBTEmptyState(
              message: context.l10n(
                ko: '작성한 글이 없습니다',
                en: 'No posts yet',
                ja: '投稿がありません',
              ),
            ),
          ] else
            Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < posts.length; i++) ...[
                    if (i > 0) const SizedBox(height: GBTSpacing.sm),
                    Builder(
                      builder: (context) {
                        final post = posts[i];
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final tertiaryColor = isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary;
                        final surfaceColor = isDark
                            ? GBTColors.darkSurface
                            : GBTColors.surface;

                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusLg,
                          ),
                          onTap: () => context.goToPostDetail(post.id),
                          child: Ink(
                            padding: const EdgeInsets.all(GBTSpacing.sm),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusLg,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? GBTColors.darkBorder
                                    : GBTColors.border,
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
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// EN: Comments tab showing user's authored comments.
/// KO: 사용자가 작성한 댓글을 보여주는 탭.
class _CommentsTab extends StatelessWidget {
  const _CommentsTab({
    required this.headerBuilder,
    required this.comments,
    required this.onRefresh,
  });

  final Widget Function() headerBuilder;
  final List<PostComment> comments;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          headerBuilder(),
          const Divider(height: 1),
          if (comments.isEmpty) ...[
            const SizedBox(height: 80),
            GBTEmptyState(
              message: context.l10n(
                ko: '작성한 댓글이 없습니다',
                en: 'No comments yet',
                ja: 'コメントがありません',
              ),
            ),
          ] else
            Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < comments.length; i++) ...[
                    if (i > 0) const SizedBox(height: GBTSpacing.sm),
                    Builder(
                      builder: (context) {
                        final comment = comments[i];
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final tertiaryColor = isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary;
                        final surfaceColor = isDark
                            ? GBTColors.darkSurface
                            : GBTColors.surface;

                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusLg,
                          ),
                          onTap: () => context.goToPostDetail(comment.postId),
                          child: Ink(
                            padding: const EdgeInsets.all(GBTSpacing.sm),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusLg,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? GBTColors.darkBorder
                                    : GBTColors.border,
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
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
