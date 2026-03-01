/// EN: Settings page with iOS-style grouped sections and modern profile card.
/// KO: iOS 스타일 그룹화된 섹션과 모던 프로필 카드를 포함한 설정 페이지.
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
import '../../../admin_ops/domain/entities/admin_ops_entities.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/settings_controller.dart';
import '../../domain/entities/user_profile.dart';

/// EN: Settings page widget with iOS-style grouped layout.
/// KO: iOS 스타일 그룹화된 레이아웃의 설정 페이지 위젯.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final themeMode = ref.watch(themeModeProvider);
    final profileState = isAuthenticated
        ? ref.watch(userProfileControllerProvider)
        : null;
    final userRole = profileState?.valueOrNull?.role;
    final canAccessAdminOps = hasAdminOpsAccessRole(userRole);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // EN: Explicit back button for settings overlay route
        // KO: 설정 오버레이 라우트를 위한 명시적 뒤로가기 버튼
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로 가기',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            final from = GoRouterState.of(context).uri.queryParameters['from'];
            if (from != null && from.isNotEmpty) {
              context.go(from);
              return;
            }
            context.go('/home');
          },
        ),
        title: const Text('설정'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!isAuthenticated) return;
          await ref
              .read(userProfileControllerProvider.notifier)
              .load(forceRefresh: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.md,
            vertical: GBTSpacing.sm,
          ),
          children: [
            // EN: Profile card — prominent header section
            // KO: 프로필 카드 — 눈에 띄는 헤더 섹션
            _ProfileCard(
              isAuthenticated: isAuthenticated,
              profileState: profileState,
              onLoginTap: () => context.push('/login'),
              onEditTap: () => context.push('/settings/profile'),
              onRetry: () => ref
                  .read(userProfileControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
            const SizedBox(height: GBTSpacing.lg),

            // EN: My activity section
            // KO: 나의 활동 섹션
            _SettingsGroup(
              title: '나의 활동',
              children: [
                _SettingsRow(
                  icon: Icons.favorite_rounded,
                  iconBgColor: const Color(0xFFEF4444),
                  title: '즐겨찾기',
                  subtitle: '저장한 장소와 이벤트',
                  onTap: () => context.push('/favorites'),
                ),
                _SettingsRow(
                  icon: Icons.check_circle_rounded,
                  iconBgColor: const Color(0xFF10B981),
                  title: '방문 기록',
                  subtitle: '인증한 장소 확인',
                  onTap: () => context.push('/settings/visits'),
                ),
                _SettingsRow(
                  icon: Icons.bar_chart_rounded,
                  iconBgColor: const Color(0xFF3B82F6),
                  title: '통계',
                  subtitle: '나의 성지순례 통계',
                  onTap: () => context.push('/settings/stats'),
                  isLast: true,
                ),
              ],
            ),

            // EN: Account section — only shown when authenticated
            // KO: 계정 섹션 — 로그인 상태에서만 표시
            if (isAuthenticated) ...[
              const SizedBox(height: GBTSpacing.lg),
              _SettingsGroup(
                title: '계정',
                children: [
                  _SettingsRow(
                    icon: Icons.person_rounded,
                    iconBgColor: const Color(0xFF8B5CF6),
                    title: '프로필 수정',
                    subtitle: '표시 이름/프로필 관리',
                    onTap: () => context.push('/settings/profile'),
                  ),
                  if (canAccessAdminOps)
                    _SettingsRow(
                      icon: Icons.admin_panel_settings_rounded,
                      iconBgColor: const Color(0xFF1D4ED8),
                      title: '운영 센터',
                      subtitle: '신고/운영 지표 관리',
                      onTap: () => context.push('/settings/admin'),
                    ),
                  _SettingsRow(
                    icon: Icons.build_circle_rounded,
                    iconBgColor: const Color(0xFF6366F1),
                    title: '계정 도구',
                    subtitle: '차단/권한요청/이의제기 관리',
                    onTap: () => context.push('/settings/account-tools'),
                  ),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    iconBgColor: const Color(0xFFEF4444),
                    title: '로그아웃',
                    onTap: () async {
                      final confirm = await _showLogoutConfirm(context);
                      if (confirm != true) return;
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그아웃되었습니다')),
                        );
                      }
                    },
                    isLast: true,
                  ),
                ],
              ),
            ],

            // EN: Notifications — only shown when authenticated
            // KO: 알림 — 로그인 상태에서만 표시
            if (isAuthenticated) ...[
              const SizedBox(height: GBTSpacing.lg),
              _SettingsGroup(
                title: '알림',
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    iconBgColor: const Color(0xFFF59E0B),
                    title: '알림 설정',
                    subtitle: '푸시/이메일 알림 관리',
                    onTap: () => context.push('/settings/notifications'),
                    isLast: true,
                  ),
                ],
              ),
            ],

            // EN: App environment section
            // KO: 앱 환경 섹션
            const SizedBox(height: GBTSpacing.lg),
            _SettingsGroup(
              title: '앱 환경',
              children: [
                _SettingsRow(
                  icon: Icons.dark_mode_rounded,
                  iconBgColor: const Color(0xFF6366F1),
                  title: '테마',
                  trailing: Text(
                    _themeLabel(themeMode),
                    style: GBTTypography.bodySmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  onTap: () => _showThemePicker(context, ref, themeMode),
                ),
                _SettingsRow(
                  icon: Icons.language_rounded,
                  iconBgColor: const Color(0xFF0D9488),
                  title: '언어',
                  trailing: Text(
                    '한국어',
                    style: GBTTypography.bodySmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  onTap: () => _showComingSoon(context, '언어 설정은 준비 중입니다.'),
                  isLast: true,
                ),
              ],
            ),

            // EN: Support section
            // KO: 지원 섹션
            const SizedBox(height: GBTSpacing.lg),
            _SettingsGroup(
              title: '지원',
              children: [
                _SettingsRow(
                  icon: Icons.help_rounded,
                  iconBgColor: const Color(0xFF3B82F6),
                  title: '도움말',
                  onTap: () => _showComingSoon(context, '도움말은 준비 중입니다.'),
                ),
                _SettingsRow(
                  icon: Icons.feedback_rounded,
                  iconBgColor: const Color(0xFFEC4899),
                  title: '피드백 보내기',
                  onTap: () => _showComingSoon(context, '피드백 기능은 준비 중입니다.'),
                ),
                _SettingsRow(
                  icon: Icons.description_rounded,
                  title: '이용약관',
                  onTap: () => _showComingSoon(context, '이용약관은 준비 중입니다.'),
                ),
                _SettingsRow(
                  icon: Icons.privacy_tip_rounded,
                  title: '개인정보 처리방침',
                  onTap: () => _showComingSoon(context, '개인정보 처리방침은 준비 중입니다.'),
                  isLast: true,
                ),
              ],
            ),

            // EN: App version footer
            // KO: 앱 버전 푸터
            const SizedBox(height: GBTSpacing.xl),
            Center(
              child: Column(
                children: [
                  Text(
                    'Girls Band Tabi',
                    style: GBTTypography.labelMedium.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.xxs),
                  Text(
                    '버전 1.0.0 (1)',
                    style: GBTTypography.labelSmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: GBTSpacing.xl + MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Profile Card — modern, prominent header
// KO: 프로필 카드 — 모던, 눈에 띄는 헤더
// ========================================

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(GBTSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
          border: Border.all(
            color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
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
                fontWeight: FontWeight.w600,
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
              ),
            ),
            const SizedBox(height: GBTSpacing.xxs),
            Text(
              '로그인하여 모든 기능을 사용하세요',
              style: GBTTypography.bodySmall.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
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
          ],
        ),
      );
    }

    return profileState?.when(
          loading: () => Container(
            padding: const EdgeInsets.all(GBTSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
              border: Border.all(
                color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
                width: 0.5,
              ),
            ),
            child: const GBTLoading(message: '프로필을 불러오는 중...'),
          ),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(GBTSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
              border: Border.all(
                color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark
                      ? GBTColors.darkSurfaceVariant
                      : GBTColors.surfaceVariant,
                  child: Icon(
                    Icons.person,
                    size: 28,
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
                        style: GBTTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? GBTColors.darkTextPrimary
                              : GBTColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '잠시 후 다시 시도해주세요',
                        style: GBTTypography.bodySmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextSecondary
                              : GBTColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: onRetry,
                  tooltip: '프로필 다시 불러오기',
                ),
              ],
            ),
          ),
          data: (profile) {
            if (profile == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(GBTSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? GBTColors.darkSurfaceElevated
                    : GBTColors.surface,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
                border: Border.all(
                  color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
                  width: 0.5,
                ),
              ),
              child: InkWell(
                onTap: onEditTap,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
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
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? GBTColors.darkTextPrimary
                                  : GBTColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.summaryLabel,
                            style: GBTTypography.bodySmall.copyWith(
                              color: isDark
                                  ? GBTColors.darkTextSecondary
                                  : GBTColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            style: GBTTypography.labelSmall.copyWith(
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
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ],
                ),
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
        radius: 28,
        backgroundColor: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          size: 28,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          semanticLabel: '기본 프로필 이미지',
        ),
      );
    }

    return ClipOval(
      child: GBTImage(
        imageUrl: avatarUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        semanticLabel: '프로필 이미지',
      ),
    );
  }
}

// ========================================
// EN: Settings Group — iOS-style card container
// KO: 설정 그룹 — iOS 스타일 카드 컨테이너
// ========================================

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EN: Section title — uppercase-style label
        // KO: 섹션 제목 — 대문자 스타일 라벨
        Padding(
          padding: const EdgeInsets.only(
            left: GBTSpacing.sm,
            bottom: GBTSpacing.xs,
          ),
          child: Text(
            title,
            style: GBTTypography.labelSmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // EN: Card container with rounded corners
        // KO: 둥근 모서리가 있는 카드 컨테이너
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

// ========================================
// EN: Settings Row — single item within a group
// KO: 설정 행 — 그룹 내 단일 항목
// ========================================

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.iconBgColor,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconBgColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedIconColor =
        iconBgColor ??
        (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);

    return Column(
      children: [
        Semantics(
          button: true,
          label: subtitle != null ? '$title - $subtitle' : title,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.md,
                vertical: GBTSpacing.sm + 4,
              ),
              child: Row(
                children: [
                  // EN: Icon with colored background
                  // KO: 색상 배경이 있는 아이콘
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: resolvedIconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                    ),
                    child: Icon(icon, color: resolvedIconColor, size: 18),
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  // EN: Title and optional subtitle
                  // KO: 제목 및 선택적 부제
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GBTTypography.bodyMedium.copyWith(
                            color: isDark
                                ? GBTColors.darkTextPrimary
                                : GBTColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            subtitle!,
                            style: GBTTypography.labelSmall.copyWith(
                              color: isDark
                                  ? GBTColors.darkTextTertiary
                                  : GBTColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // EN: Trailing widget or chevron
                  // KO: 트레일링 위젯 또는 쉐브론
                  trailing ??
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary,
                      ),
                ],
              ),
            ),
          ),
        ),
        // EN: Divider between rows (skip for last item)
        // KO: 행 사이 구분선 (마지막 항목은 건너뛰기)
        if (!isLast)
          Divider(
            height: 1,
            indent: GBTSpacing.md + 32 + GBTSpacing.md,
            endIndent: GBTSpacing.md,
            color: isDark ? GBTColors.darkBorderSubtle : GBTColors.divider,
          ),
      ],
    );
  }
}

// ========================================
// EN: Theme picker and utilities
// KO: 테마 선택기 및 유틸리티
// ========================================

String _themeLabel(String mode) {
  return switch (mode) {
    'light' => '라이트 모드',
    'dark' => '다크 모드',
    _ => '시스템 설정',
  };
}

void _showThemePicker(BuildContext context, WidgetRef ref, String currentMode) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(GBTSpacing.radiusLg),
      ),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Drag handle
            // KO: 드래그 핸들
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: GBTSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
              child: Text(
                '테마 설정',
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            _ThemeOption(
              icon: Icons.settings_suggest_rounded,
              label: '시스템 설정',
              description: '기기 설정에 따라 자동 변경',
              isSelected: currentMode == 'system',
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'system';
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: '라이트 모드',
              description: '항상 밝은 테마 사용',
              isSelected: currentMode == 'light',
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'light';
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: '다크 모드',
              description: '항상 어두운 테마 사용',
              isSelected: currentMode == 'dark',
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'dark';
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// EN: Theme option row with radio indicator.
/// KO: 라디오 인디케이터가 있는 테마 옵션 행.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return Semantics(
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.md,
            vertical: GBTSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? primaryColor
                    : (isDark
                          ? GBTColors.darkTextSecondary
                          : GBTColors.textSecondary),
              ),
              const SizedBox(width: GBTSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GBTTypography.bodyMedium.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isDark
                            ? GBTColors.darkTextPrimary
                            : GBTColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: GBTTypography.labelSmall.copyWith(
                        color: isDark
                            ? GBTColors.darkTextTertiary
                            : GBTColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
              else
                Icon(
                  Icons.circle_outlined,
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> _showLogoutConfirm(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('로그아웃'),
      content: const Text('정말로 로그아웃하시겠어요?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('로그아웃'),
        ),
      ],
    ),
  );
}

void _showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
