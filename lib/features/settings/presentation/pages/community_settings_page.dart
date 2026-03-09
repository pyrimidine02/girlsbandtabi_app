/// EN: Community-focused settings page with profile-first actions.
/// KO: 프로필 중심 액션을 제공하는 커뮤니티 전용 설정 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/sensitive_text_utils.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/domain/entities/user_profile.dart';

/// EN: Community settings page.
/// KO: 커뮤니티 설정 페이지.
class CommunitySettingsPage extends ConsumerWidget {
  const CommunitySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final profileState = isAuthenticated
        ? ref.watch(userProfileControllerProvider)
        : null;
    final profile = profileState?.valueOrNull;
    final currentUserId = profile?.id;
    final canAccessAdminOps = profile?.canAccessAdminOps ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: GBTAppBarIconButton(
          icon: Icons.arrow_back,
          tooltip: context.l10n(ko: '뒤로 가기', en: 'Back', ja: '戻る'),
          onPressed: () => context.go('/board'),
        ),
        title: Text(
          context.l10n(ko: '커뮤니티 설정', en: 'Community Settings', ja: 'コミュニティ設定'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!isAuthenticated) return;
          await ref
              .read(userProfileControllerProvider.notifier)
              .load(forceRefresh: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.md,
            vertical: GBTSpacing.sm,
          ),
          children: [
            _CommunityProfileCard(
              isAuthenticated: isAuthenticated,
              profileState: profileState,
              onLoginTap: () => context.push('/login'),
              onMyProfileTap: currentUserId == null
                  ? null
                  : () => context.goToUserProfile(currentUserId),
              onEditProfileTap: () => context.push('/settings/profile'),
            ),
            const SizedBox(height: GBTSpacing.lg),
            _CommunitySettingsGroup(
              title: context.l10n(ko: '프로필', en: 'Profile', ja: 'プロフィール'),
              children: [
                _CommunitySettingsRow(
                  icon: Icons.person_rounded,
                  iconBgColor: const Color(0xFF3B82F6),
                  title: context.l10n(
                    ko: '내 프로필',
                    en: 'My profile',
                    ja: 'マイプロフィール',
                  ),
                  subtitle: context.l10n(
                    ko: '작성한 글/댓글 활동 보기',
                    en: 'View my posts and comments',
                    ja: '自分の投稿・コメントを見る',
                  ),
                  enabled: isAuthenticated && currentUserId != null,
                  onTap: currentUserId == null
                      ? null
                      : () => context.goToUserProfile(currentUserId),
                ),
                _CommunitySettingsRow(
                  icon: Icons.group_rounded,
                  iconBgColor: const Color(0xFF8B5CF6),
                  title: context.l10n(ko: '팔로워', en: 'Followers', ja: 'フォロワー'),
                  subtitle: context.l10n(
                    ko: '나를 팔로우한 사용자',
                    en: 'People following me',
                    ja: '自分をフォローしているユーザー',
                  ),
                  enabled: isAuthenticated && currentUserId != null,
                  onTap: currentUserId == null
                      ? null
                      : () => context.pushNamed(
                          AppRoutes.userFollowers,
                          pathParameters: {'userId': currentUserId},
                        ),
                ),
                _CommunitySettingsRow(
                  icon: Icons.person_add_alt_1_rounded,
                  iconBgColor: const Color(0xFF14B8A6),
                  title: context.l10n(ko: '팔로잉', en: 'Following', ja: 'フォロー中'),
                  subtitle: context.l10n(
                    ko: '내가 팔로우한 사용자',
                    en: 'People I follow',
                    ja: '自分がフォローしているユーザー',
                  ),
                  enabled: isAuthenticated && currentUserId != null,
                  onTap: currentUserId == null
                      ? null
                      : () => context.pushNamed(
                          AppRoutes.userFollowing,
                          pathParameters: {'userId': currentUserId},
                        ),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.lg),
            _CommunitySettingsGroup(
              title: context.l10n(ko: '커뮤니티', en: 'Community', ja: 'コミュニティ'),
              children: [
                _CommunitySettingsRow(
                  icon: Icons.notifications_active_rounded,
                  iconBgColor: const Color(0xFFF59E0B),
                  title: context.l10n(
                    ko: '알림함',
                    en: 'Notifications inbox',
                    ja: '通知受信箱',
                  ),
                  subtitle: context.l10n(
                    ko: '댓글/좋아요/팔로우 알림 확인',
                    en: 'Check comments/likes/follow alerts',
                    ja: 'コメント・いいね・フォロー通知を確認',
                  ),
                  enabled: isAuthenticated,
                  onTap: isAuthenticated
                      ? () => context.push('/notifications')
                      : null,
                ),
                _CommunitySettingsRow(
                  icon: Icons.favorite_rounded,
                  iconBgColor: const Color(0xFFEF4444),
                  title: context.l10n(
                    ko: '저장한 글',
                    en: 'Saved posts',
                    ja: '保存した投稿',
                  ),
                  subtitle: context.l10n(
                    ko: '북마크한 커뮤니티 글 모아보기',
                    en: 'View bookmarked community posts',
                    ja: 'ブックマークした投稿を見る',
                  ),
                  enabled: isAuthenticated,
                  onTap: isAuthenticated
                      ? () => context.push('/favorites')
                      : null,
                ),
                _CommunitySettingsRow(
                  icon: Icons.edit_note_rounded,
                  iconBgColor: const Color(0xFF2563EB),
                  title: context.l10n(
                    ko: '게시글 작성',
                    en: 'Write a post',
                    ja: '投稿作成',
                  ),
                  subtitle: context.l10n(
                    ko: '커뮤니티 새 글 작성하기',
                    en: 'Create a new community post',
                    ja: 'コミュニティに新規投稿',
                  ),
                  enabled: isAuthenticated,
                  onTap: isAuthenticated ? context.goToPostCreate : null,
                ),
                _CommunitySettingsRow(
                  icon: Icons.tune_rounded,
                  iconBgColor: const Color(0xFF6366F1),
                  title: context.l10n(
                    ko: '알림 설정',
                    en: 'Notification settings',
                    ja: '通知設定',
                  ),
                  subtitle: context.l10n(
                    ko: '푸시/이메일 알림 관리',
                    en: 'Manage push/email preferences',
                    ja: 'プッシュ・メール通知管理',
                  ),
                  enabled: isAuthenticated,
                  onTap: isAuthenticated
                      ? () => context.push('/settings/notifications')
                      : null,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: GBTSpacing.lg),
            _CommunitySettingsGroup(
              title: context.l10n(
                ko: '계정 및 운영',
                en: 'Account & Operations',
                ja: 'アカウントと運営',
              ),
              children: [
                _CommunitySettingsRow(
                  icon: Icons.build_circle_rounded,
                  iconBgColor: const Color(0xFF6366F1),
                  title: context.l10n(
                    ko: '계정 도구',
                    en: 'Account tools',
                    ja: 'アカウントツール',
                  ),
                  subtitle: context.l10n(
                    ko: '차단/접근레벨/이의제기 관리',
                    en: 'Manage blocks/access/appeals',
                    ja: 'ブロック・アクセスレベル・異議申立て管理',
                  ),
                  enabled: isAuthenticated,
                  onTap: isAuthenticated
                      ? () => context.push('/settings/account-tools')
                      : null,
                ),
                if (canAccessAdminOps)
                  _CommunitySettingsRow(
                    icon: Icons.admin_panel_settings_rounded,
                    iconBgColor: const Color(0xFF1D4ED8),
                    title: context.l10n(
                      ko: '운영 센터',
                      en: 'Operations center',
                      ja: '運営センター',
                    ),
                    subtitle: context.l10n(
                      ko: '신고/운영 지표 관리',
                      en: 'Manage reports/ops metrics',
                      ja: '通報・運営指標管理',
                    ),
                    onTap: () => context.push('/settings/admin'),
                    isLast: true,
                  )
                else
                  _CommunitySettingsRow(
                    icon: Icons.settings_rounded,
                    iconBgColor: const Color(0xFF334155),
                    title: context.l10n(
                      ko: '전체 설정',
                      en: 'All settings',
                      ja: '全体設定',
                    ),
                    subtitle: context.l10n(
                      ko: '앱 환경/개인정보/지원 메뉴로 이동',
                      en: 'Open full app settings page',
                      ja: 'アプリ全体設定へ移動',
                    ),
                    onTap: () => context.push('/settings'),
                    isLast: true,
                  ),
              ],
            ),
            const SizedBox(height: GBTSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _CommunityProfileCard extends StatelessWidget {
  const _CommunityProfileCard({
    required this.isAuthenticated,
    required this.profileState,
    required this.onLoginTap,
    required this.onMyProfileTap,
    required this.onEditProfileTap,
  });

  final bool isAuthenticated;
  final AsyncValue<UserProfile?>? profileState;
  final VoidCallback onLoginTap;
  final VoidCallback? onMyProfileTap;
  final VoidCallback onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;

    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(GBTSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              context.l10n(
                ko: '로그인하면 커뮤니티 기능을 사용할 수 있습니다',
                en: 'Log in to use community features',
                ja: 'ログインするとコミュニティ機能を利用できます',
              ),
              style: GBTTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.md),
            FilledButton(
              onPressed: onLoginTap,
              child: Text(context.l10n(ko: '로그인', en: 'Log in', ja: 'ログイン')),
            ),
          ],
        ),
      );
    }

    return profileState!.when(
      loading: () => Container(
        height: 132,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: const Center(child: GBTLoading(size: 20)),
      ),
      error: (_, _) => Container(
        padding: const EdgeInsets.all(GBTSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Text(
          context.l10n(
            ko: '프로필 정보를 불러오지 못했습니다',
            en: 'Failed to load profile',
            ja: 'プロフィールを読み込めませんでした',
          ),
          style: GBTTypography.bodyMedium,
        ),
      ),
      data: (profile) {
        final displayName = (profile?.displayName ?? '').trim();
        final email = (profile?.email ?? '').trim();
        final safeName = displayName.isEmpty
            ? context.l10n(ko: '사용자', en: 'User', ja: 'ユーザー')
            : displayName;

        return Container(
          padding: const EdgeInsets.all(GBTSpacing.lg),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _CommunityProfileAvatar(avatarUrl: profile?.avatarUrl),
                  const SizedBox(width: GBTSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          safeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GBTTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: GBTSpacing.xxs),
                            child: Text(
                              maskEmail(email),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GBTTypography.bodySmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextSecondary
                                    : GBTColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onMyProfileTap,
                      child: Text(
                        context.l10n(
                          ko: '내 프로필',
                          en: 'My profile',
                          ja: 'マイプロフィール',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: GBTSpacing.sm),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: onEditProfileTap,
                      child: Text(
                        context.l10n(
                          ko: '프로필 수정',
                          en: 'Edit profile',
                          ja: 'プロフィール編集',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommunityProfileAvatar extends StatelessWidget {
  const _CommunityProfileAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          size: 28,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
      );
    }

    return ClipOval(
      child: GBTImage(
        imageUrl: avatarUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        semanticLabel: context.l10n(
          ko: '프로필 이미지',
          en: 'Profile image',
          ja: 'プロフィール画像',
        ),
      ),
    );
  }
}

class _CommunitySettingsGroup extends StatelessWidget {
  const _CommunitySettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: GBTSpacing.sm,
            bottom: GBTSpacing.xs,
          ),
          child: Text(
            title,
            style: GBTTypography.labelLarge.copyWith(
              color: isDark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            border: Border.all(
              color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
              width: 0.5,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _CommunitySettingsRow extends StatelessWidget {
  const _CommunitySettingsRow({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? GBTColors.darkBorderSubtle.withValues(alpha: 0.8)
        : GBTColors.border.withValues(alpha: 0.9);
    final titleColor = enabled
        ? (isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary)
        : (isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary);
    final subtitleColor = enabled
        ? (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary)
        : (isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary);

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(isLast ? GBTSpacing.radiusMd : 0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
              vertical: GBTSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconBgColor, size: 18),
                ),
                const SizedBox(width: GBTSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GBTTypography.bodyMedium.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: GBTTypography.bodySmall.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: subtitleColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
