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
    final blockLabel = blockStatus?.blockedByMe == true ? '차단 해제' : '차단';
    Widget? headerAction;
    if (isMyProfile) {
      headerAction = OutlinedButton(
        onPressed: () => context.pushNamed(AppRoutes.profileEdit),
        child: const Text('프로필 수정'),
      );
    } else if (isAuthenticated) {
      headerAction = OutlinedButton(
        onPressed: blockStatus == null
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
                  _showSnackBar(context, updated ? '사용자를 차단했어요' : '차단을 해제했어요');
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
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Semantics(
      label: '프로필: $displayName. $bioLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: coverUrl == null || coverUrl!.isEmpty
                      ? Container(
                          // EN: Use solid neutral surface color instead of deprecated gradient.
                          // KO: 더 이상 사용하지 않는 그라디언트 대신 단색 뉴트럴 표면 색상을 사용합니다.
                          color: isDark
                              ? GBTColors.darkSurfaceVariant
                              : GBTColors.surfaceAlternate,
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: GBTTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: GBTSpacing.sm),
                          // EN: Dummy title (칭호) badges mimicking backend achievements
                          // KO: 백엔드 업적을 모방한 더미 칭호 뱃지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              '도쿄 정복자',
                              style: GBTTypography.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (summaryLabel != null) ...[
                        const SizedBox(height: GBTSpacing.xs),
                        Text(
                          summaryLabel!,
                          style: GBTTypography.labelSmall.copyWith(
                            color: secondaryColor,
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
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: GBTSpacing.md),
                      // EN: Expanded list of titles (칭호) the user has earned
                      // KO: 사용자가 획득한 칭호(업적) 확장 목록
                      Wrap(
                        spacing: GBTSpacing.xs,
                        runSpacing: GBTSpacing.xs,
                        children: [
                          _AchievementBadge(label: '도쿄 정복자', isPrimary: true),
                          _AchievementBadge(label: '장소 10회 방문'),
                          _AchievementBadge(label: '라이브 첫 관람'),
                        ],
                      ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: GBTSpacing.sm),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.label, this.isPrimary = false});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPrimary
            ? colorScheme.primaryContainer.withAlpha(50)
            : (isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        border: Border.all(
          color: isPrimary
              ? colorScheme.primary.withAlpha(100)
              : (isDark ? GBTColors.darkBorder : GBTColors.border),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPrimary) ...[
            Icon(Icons.workspace_premium, size: 12, color: colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GBTTypography.labelSmall.copyWith(
              color: isPrimary
                  ? colorScheme.primary
                  : (isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Posts tab showing user's authored posts.
/// KO: 사용자가 작성한 게시글을 보여주는 탭.
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
        // EN: Use theme-aware colors for dark mode compatibility.
        // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final tertiaryColor = isDark
            ? GBTColors.darkTextTertiary
            : GBTColors.textTertiary;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            post.title,
            style: GBTTypography.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            post.timeAgoLabel,
            style: GBTTypography.labelSmall.copyWith(color: tertiaryColor),
          ),
          onTap: () => context.goToPostDetail(post.id),
        );
      },
    );
  }
}

/// EN: Comments tab showing user's authored comments.
/// KO: 사용자가 작성한 댓글을 보여주는 탭.
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
        // EN: Use theme-aware colors for dark mode compatibility.
        // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final tertiaryColor = isDark
            ? GBTColors.darkTextTertiary
            : GBTColors.textTertiary;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            comment.content,
            style: GBTTypography.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            comment.timeAgoLabel,
            style: GBTTypography.labelSmall.copyWith(color: tertiaryColor),
          ),
          onTap: () => context.goToPostDetail(comment.postId),
        );
      },
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
