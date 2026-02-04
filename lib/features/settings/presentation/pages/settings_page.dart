/// EN: Settings page with profile and app settings.
/// KO: 프로필 및 앱 설정을 포함한 설정 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/settings_controller.dart';
import '../../domain/entities/user_profile.dart';

/// EN: Settings page widget.
/// KO: 설정 페이지 위젯.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final themeMode = ref.watch(themeModeProvider);
    final profileState = isAuthenticated
        ? ref.watch(userProfileControllerProvider)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          _ProfileSection(
            isAuthenticated: isAuthenticated,
            profileState: profileState,
            onLoginTap: () => context.push('/login'),
            onEditTap: () => context.push('/settings/profile'),
            onRetry: () => ref
                .read(userProfileControllerProvider.notifier)
                .load(forceRefresh: true),
          ),
          const Divider(),
          _SectionHeader(title: '나의 활동'),
          _SettingsItem(
            icon: Icons.favorite,
            iconColor: GBTColors.error,
            title: '즐겨찾기',
            subtitle: '저장한 장소와 이벤트',
            onTap: () => context.push('/favorites'),
          ),
          _SettingsItem(
            icon: Icons.check_circle,
            iconColor: GBTColors.success,
            title: '방문 기록',
            subtitle: '인증한 장소 확인',
            onTap: () => context.push('/settings/visits'),
          ),
          _SettingsItem(
            icon: Icons.bar_chart,
            iconColor: GBTColors.accentBlue,
            title: '통계',
            subtitle: '나의 성지순례 통계',
            onTap: () => context.push('/settings/stats'),
          ),
          // EN: Account section — only shown when authenticated.
          // KO: 계정 섹션 — 로그인 상태에서만 표시.
          if (isAuthenticated) ...[
            const Divider(),
            _SectionHeader(title: '계정'),
            _SettingsItem(
              icon: Icons.person,
              iconColor: GBTColors.accent,
              title: '프로필 수정',
              subtitle: '표시 이름/프로필 관리',
              onTap: () => context.push('/settings/profile'),
            ),
            _SettingsItem(
              icon: Icons.logout,
              iconColor: GBTColors.textSecondary,
              title: '로그아웃',
              subtitle: '계정에서 로그아웃',
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('로그아웃되었습니다')));
                }
              },
            ),
          ],
          // EN: Notifications section — only shown when authenticated.
          // KO: 알림 섹션 — 로그인 상태에서만 표시.
          if (isAuthenticated) ...[
            const Divider(),
            _SectionHeader(title: '알림'),
            _SettingsItem(
              icon: Icons.notifications,
              iconColor: GBTColors.secondary,
              title: '알림 설정',
              subtitle: '푸시/이메일 알림 관리',
              onTap: () => context.push('/settings/notifications'),
            ),
          ],
          const Divider(),
          _SectionHeader(title: '앱 환경'),
          _SettingsItem(
            icon: Icons.dark_mode,
            iconColor: GBTColors.accent,
            title: '테마',
            subtitle: _themeLabel(themeMode),
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),
          _SettingsItem(
            icon: Icons.language,
            iconColor: GBTColors.accentBlue,
            title: '언어',
            subtitle: '한국어',
            onTap: () => _showComingSoon(context, '언어 설정은 준비 중입니다.'),
          ),
          const Divider(),
          _SectionHeader(title: '지원'),
          _SettingsItem(
            icon: Icons.help,
            iconColor: GBTColors.textSecondary,
            title: '도움말',
            onTap: () {
              // EN: TODO: Navigate to help.
              // KO: TODO: 도움말로 이동.
            },
          ),
          _SettingsItem(
            icon: Icons.feedback,
            iconColor: GBTColors.textSecondary,
            title: '피드백 보내기',
            onTap: () {
              // EN: TODO: Show feedback form.
              // KO: TODO: 피드백 폼 표시.
            },
          ),
          _SettingsItem(
            icon: Icons.description,
            iconColor: GBTColors.textSecondary,
            title: '이용약관',
            onTap: () {
              // EN: TODO: Navigate to terms.
              // KO: TODO: 이용약관으로 이동.
            },
          ),
          _SettingsItem(
            icon: Icons.privacy_tip,
            iconColor: GBTColors.textSecondary,
            title: '개인정보 처리방침',
            onTap: () {
              // EN: TODO: Navigate to privacy policy.
              // KO: TODO: 개인정보 처리방침으로 이동.
            },
          ),
          const Divider(),
          Padding(
            padding: GBTSpacing.paddingPage,
            child: Column(
              children: [
                Text('Girls Band Tabi', style: GBTTypography.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '버전 1.0.0 (1)',
                  style: GBTTypography.bodySmall.copyWith(
                    color: GBTColors.textTertiary,
                  ),
                ),
                const SizedBox(height: GBTSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.isAuthenticated,
    required this.profileState,
    required this.onLoginTap,
    required this.onEditTap,
    required this.onRetry,
  });

  final bool isAuthenticated;
  final AsyncValue<UserProfile?>? profileState;
  final VoidCallback onLoginTap;
  final VoidCallback onEditTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          children: [
            const SizedBox(height: GBTSpacing.sm),
            CircleAvatar(
              radius: 36,
              backgroundColor: GBTColors.surfaceVariant,
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: GBTColors.textTertiary,
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            Text('로그인이 필요합니다', style: GBTTypography.titleMedium),
            const SizedBox(height: 4),
            Text(
              '로그인하여 모든 기능을 사용하세요',
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.textSecondary,
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onLoginTap,
                child: const Text('로그인'),
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
          ],
        ),
      );
    }

    return profileState?.when(
          loading: () => Padding(
            padding: GBTSpacing.paddingPage,
            child: const GBTLoading(message: '프로필을 불러오는 중...'),
          ),
          error: (error, _) => Padding(
            padding: GBTSpacing.paddingPage,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: GBTColors.surfaceVariant,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: GBTColors.textTertiary,
                  ),
                ),
                const SizedBox(width: GBTSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('프로필을 불러오지 못했어요', style: GBTTypography.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '잠시 후 다시 시도해주세요',
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
          data: (profile) {
            if (profile == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: GBTSpacing.paddingPage,
              child: Row(
                children: [
                  _ProfileAvatar(avatarUrl: profile.avatarUrl),
                  const SizedBox(width: GBTSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          style: GBTTypography.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.summaryLabel,
                          style: GBTTypography.bodySmall.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: GBTTypography.bodySmall.copyWith(
                            color: GBTColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEditTap,
                    tooltip: '프로필 수정',
                  ),
                ],
              ),
            );
          },
        ) ??
        const SizedBox.shrink();
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: GBTColors.surfaceVariant,
        child: Icon(Icons.person, size: 36, color: GBTColors.textTertiary),
      );
    }

    return ClipOval(
      child: GBTImage(
        imageUrl: avatarUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        semanticLabel: '프로필 이미지',
      ),
    );
  }
}

/// EN: Section header widget.
/// KO: 섹션 헤더 위젯.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.md,
        GBTSpacing.md,
        GBTSpacing.md,
        GBTSpacing.xs,
      ),
      child: Text(
        title,
        style: GBTTypography.labelMedium.copyWith(
          color: GBTColors.textSecondary,
        ),
      ),
    );
  }
}

/// EN: Settings item widget.
/// KO: 설정 아이템 위젯.
class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? GBTColors.textSecondary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: Icon(
          icon,
          color: iconColor ?? GBTColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(title, style: GBTTypography.bodyMedium),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.textTertiary,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: GBTColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}

String _themeLabel(String mode) {
  return switch (mode) {
    'light' => '라이트 모드',
    'dark' => '다크 모드',
    _ => '시스템 설정',
  };
}

void _showThemePicker(BuildContext context, WidgetRef ref, String currentMode) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('시스템 설정'),
            trailing: currentMode == 'system' ? const Icon(Icons.check) : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = 'system';
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('라이트 모드'),
            trailing: currentMode == 'light' ? const Icon(Icons.check) : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = 'light';
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('다크 모드'),
            trailing: currentMode == 'dark' ? const Icon(Icons.check) : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).state = 'dark';
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );
}

void _showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
