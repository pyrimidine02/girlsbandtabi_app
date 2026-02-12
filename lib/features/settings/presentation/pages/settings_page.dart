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
      appBar: AppBar(
        // EN: Explicit back button for settings overlay route
        // KO: 설정 오버레이 라우트를 위한 명시적 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로 가기',
          onPressed: () {
            // EN: Avoid GoRouter pop when there is no back stack.
            // KO: 뒤로갈 스택이 없을 때 GoRouter pop을 막습니다.
            if (context.canPop()) {
              context.pop();
              return;
            }

            // EN: Fallback to the recorded previous route when available.
            // KO: 이전 경로가 있으면 해당 경로로 이동합니다.
            final from = GoRouterState.of(context).uri.queryParameters['from'];
            if (from != null && from.isNotEmpty) {
              context.go(from);
              return;
            }

            // EN: If no previous route is available, return to home.
            // KO: 이전 경로가 없으면 홈으로 이동합니다.
            context.go('/home');
          },
        ),
        title: const Text('설정'),
      ),
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
            iconColor: const Color(0xFFEF4444),
            title: '즐겨찾기',
            subtitle: '저장한 장소와 이벤트',
            semanticLabel: '즐겨찾기 - 저장한 장소와 이벤트',
            onTap: () => context.push('/favorites'),
          ),
          _SettingsItem(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF10B981),
            title: '방문 기록',
            subtitle: '인증한 장소 확인',
            semanticLabel: '방문 기록 - 인증한 장소 확인',
            onTap: () => context.push('/settings/visits'),
          ),
          _SettingsItem(
            icon: Icons.bar_chart,
            iconColor: const Color(0xFF3B82F6),
            title: '통계',
            subtitle: '나의 성지순례 통계',
            semanticLabel: '통계 - 나의 성지순례 통계',
            onTap: () => context.push('/settings/stats'),
          ),
          // EN: Account section -- only shown when authenticated.
          // KO: 계정 섹션 -- 로그인 상태에서만 표시.
          if (isAuthenticated) ...[
            const Divider(),
            _SectionHeader(title: '계정'),
            _SettingsItem(
              icon: Icons.person,
              iconColor: const Color(0xFF8B5CF6),
              title: '프로필 수정',
              subtitle: '표시 이름/프로필 관리',
              semanticLabel: '프로필 수정 - 표시 이름 및 프로필 관리',
              onTap: () => context.push('/settings/profile'),
            ),
            _SettingsItem(
              icon: Icons.logout,
              iconColor: const Color(0xFFEF4444),
              title: '로그아웃',
              subtitle: '계정에서 로그아웃',
              semanticLabel: '로그아웃 - 계정에서 로그아웃합니다',
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
          // EN: Notifications section -- only shown when authenticated.
          // KO: 알림 섹션 -- 로그인 상태에서만 표시.
          if (isAuthenticated) ...[
            const Divider(),
            _SectionHeader(title: '알림'),
            _SettingsItem(
              icon: Icons.notifications,
              iconColor: const Color(0xFFF59E0B),
              title: '알림 설정',
              subtitle: '푸시/이메일 알림 관리',
              semanticLabel: '알림 설정 - 푸시 및 이메일 알림 관리',
              onTap: () => context.push('/settings/notifications'),
            ),
          ],
          const Divider(),
          _SectionHeader(title: '앱 환경'),
          _SettingsItem(
            icon: Icons.dark_mode,
            iconColor: const Color(0xFF6366F1),
            title: '테마',
            subtitle: _themeLabel(themeMode),
            semanticLabel: '테마 설정 - 현재 ${_themeLabel(themeMode)}',
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),
          _SettingsItem(
            icon: Icons.language,
            iconColor: const Color(0xFF0D9488),
            title: '언어',
            subtitle: '한국어',
            semanticLabel: '언어 설정 - 현재 한국어',
            onTap: () => _showComingSoon(context, '언어 설정은 준비 중입니다.'),
          ),
          const Divider(),
          _SectionHeader(title: '지원'),
          _SettingsItem(
            icon: Icons.help,
            iconColor: const Color(0xFF3B82F6),
            title: '도움말',
            semanticLabel: '도움말',
            onTap: () {
              // EN: TODO: Navigate to help.
              // KO: TODO: 도움말로 이동.
            },
          ),
          _SettingsItem(
            icon: Icons.feedback,
            iconColor: const Color(0xFFEC4899),
            title: '피드백 보내기',
            semanticLabel: '피드백 보내기',
            onTap: () {
              // EN: TODO: Show feedback form.
              // KO: TODO: 피드백 폼 표시.
            },
          ),
          _SettingsItem(
            icon: Icons.description,
            title: '이용약관',
            semanticLabel: '이용약관',
            onTap: () {
              // EN: TODO: Navigate to terms.
              // KO: TODO: 이용약관으로 이동.
            },
          ),
          _SettingsItem(
            icon: Icons.privacy_tip,
            title: '개인정보 처리방침',
            semanticLabel: '개인정보 처리방침',
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
                Text(
                  'Girls Band Tabi',
                  style: GBTTypography.titleSmall.copyWith(
                    // EN: Use theme-aware text color
                    // KO: 테마 인식 텍스트 색상 사용
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                Text(
                  '버전 1.0.0 (1)',
                  style: GBTTypography.bodySmall.copyWith(
                    // EN: Use theme-aware tertiary text color
                    // KO: 테마 인식 3차 텍스트 색상 사용
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isAuthenticated) {
      return Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          children: [
            const SizedBox(height: GBTSpacing.sm),
            CircleAvatar(
              radius: 36,
              backgroundColor: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: isDark
                    ? GBTColors.darkTextTertiary
                    : GBTColors.textTertiary,
                semanticLabel: '프로필 아이콘',
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              '로그인이 필요합니다',
              style: GBTTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            Text(
              '로그인하여 모든 기능을 사용하세요',
              style: GBTTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: '로그인 페이지로 이동',
                child: FilledButton(
                  onPressed: onLoginTap,
                  child: const Text('로그인'),
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
          ],
        ),
      );
    }

    return profileState?.when(
          loading: () => const Padding(
            padding: GBTSpacing.paddingPage,
            child: GBTLoading(message: '프로필을 불러오는 중...'),
          ),
          error: (error, _) => Padding(
            padding: GBTSpacing.paddingPage,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: isDark
                      ? GBTColors.darkSurfaceVariant
                      : GBTColors.surfaceVariant,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary,
                  ),
                ),
                const SizedBox(width: GBTSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '프로필을 불러오지 못했어요',
                        style: GBTTypography.titleMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: GBTSpacing.xs),
                      Text(
                        '잠시 후 다시 시도해주세요',
                        style: GBTTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRetry,
                  tooltip: '프로필 다시 불러오기',
                  // EN: Ensure min 48dp touch target
                  // KO: 최소 48dp 터치 타겟 보장
                  iconSize: GBTSpacing.iconMd,
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
                          style: GBTTypography.titleMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          // EN: Prevent overflow on long display names
                          // KO: 긴 표시 이름에서 오버플로 방지
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: GBTSpacing.xxs),
                        Text(
                          profile.summaryLabel,
                          style: GBTTypography.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: GBTSpacing.xxs),
                        Text(
                          profile.email,
                          style: GBTTypography.bodySmall.copyWith(
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditTap,
                    tooltip: '프로필 수정',
                    // EN: Ensure min 48dp touch target (default for IconButton)
                    // KO: 최소 48dp 터치 타겟 보장 (IconButton 기본값)
                    iconSize: GBTSpacing.iconMd,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: 32,
        backgroundColor: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          size: 36,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          semanticLabel: '기본 프로필 이미지',
        ),
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
          // EN: Use theme-aware secondary text color
          // KO: 테마 인식 보조 텍스트 색상 사용
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// EN: Settings item widget with accessibility support.
/// KO: 접근성을 지원하는 설정 아이템 위젯.
class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.semanticLabel,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? semanticLabel;

  /// EN: Optional individual icon color — falls back to neutral if null.
  /// KO: 선택적 개별 아이콘 색상 — null이면 뉴트럴 폴백.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final resolvedIconColor =
        iconColor ??
        (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);

    return Semantics(
      button: true,
      label: semanticLabel ?? title,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? GBTColors.darkSurfaceVariant
                : GBTColors.surfaceVariant,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          ),
          child: Icon(icon, color: resolvedIconColor, size: GBTSpacing.iconSm),
        ),
        title: Text(
          title,
          style: GBTTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: GBTTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: GBTSpacing.iconXs,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
        onTap: onTap,
      ),
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
          Semantics(
            selected: currentMode == 'system',
            child: ListTile(
              title: const Text('시스템 설정'),
              trailing: currentMode == 'system'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'system';
                Navigator.of(context).pop();
              },
            ),
          ),
          Semantics(
            selected: currentMode == 'light',
            child: ListTile(
              title: const Text('라이트 모드'),
              trailing: currentMode == 'light' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'light';
                Navigator.of(context).pop();
              },
            ),
          ),
          Semantics(
            selected: currentMode == 'dark',
            child: ListTile(
              title: const Text('다크 모드'),
              trailing: currentMode == 'dark' ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'dark';
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
