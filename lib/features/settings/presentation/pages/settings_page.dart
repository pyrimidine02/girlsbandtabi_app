/// EN: Settings page with gradient profile hero, quick actions grid, and grouped sections.
/// KO: 그래디언트 프로필 히어로, 퀵 액션 그리드, 그룹 섹션이 있는 설정 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/legal_policy_constants.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/sensitive_text_utils.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/dialogs/gbt_adaptive_dialog.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../auth/application/auth_controller.dart';
import '../../application/settings_controller.dart';
import '../../domain/entities/user_profile.dart';

/// EN: Settings page widget with grouped layout and profile hero.
/// KO: 그룹 레이아웃과 프로필 히어로가 있는 설정 페이지 위젯.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(localeProvider);
    final profileState = isAuthenticated
        ? ref.watch(userProfileControllerProvider)
        : null;
    final canAccessAdminOps =
        profileState?.valueOrNull?.canAccessAdminOps ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appVersionState = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        // EN: Explicit back button for settings overlay route
        // KO: 설정 오버레이 라우트를 위한 명시적 뒤로가기 버튼
        leading: GBTAppBarIconButton(
          icon: Icons.arrow_back,
          tooltip: context.l10n(ko: '뒤로 가기', en: 'Back', ja: '戻る'),
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
        title: Text(context.l10n(ko: '설정', en: 'Settings', ja: '設定')),
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
            // EN: Profile hero card
            // KO: 프로필 히어로 카드
            _ProfileCard(
              isAuthenticated: isAuthenticated,
              profileState: profileState,
              onLoginTap: () => context.push('/login'),
              onEditTap: () => context.push('/settings/profile'),
              onProfileTap: () {
                final profile = profileState?.valueOrNull;
                if (profile == null) return;
                context.goToUserProfile(profile.id);
              },
              onRetry: () => ref
                  .read(userProfileControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
            const SizedBox(height: GBTSpacing.lg),

            // EN: Quick actions grid — activity shortcuts
            // KO: 퀵 액션 그리드 — 활동 바로가기
            _QuickActionsGrid(
              onFavoritesTap: () => context.push('/favorites'),
              onVisitsTap: () => context.push('/visits'),
              onStatsTap: () => context.push('/visit-stats'),
              isDark: isDark,
            ),

            // EN: Account section — only shown when authenticated
            // KO: 계정 섹션 — 로그인 상태에서만 표시
            if (isAuthenticated) ...[
              const SizedBox(height: GBTSpacing.lg),
              _SettingsGroup(
                title: context.l10n(ko: '계정', en: 'Account', ja: 'アカウント'),
                children: [
                  _SettingsRow(
                    icon: Icons.person_rounded,
                    iconBgColor: const Color(0xFF8B5CF6),
                    title: context.l10n(
                      ko: '프로필 수정',
                      en: 'Edit profile',
                      ja: 'プロフィール編集',
                    ),
                    subtitle: context.l10n(
                      ko: '표시 이름/프로필 관리',
                      en: 'Manage display name/profile',
                      ja: '表示名・プロフィール管理',
                    ),
                    onTap: () => context.push('/settings/profile'),
                  ),
                  _SettingsRow(
                    icon: Icons.palette_rounded,
                    iconBgColor: const Color(0xFFEC4899),
                    title: context.l10n(
                      ko: '홈 배너 꾸미기',
                      en: 'Customize home banner',
                      ja: 'ホームバナーをカスタマイズ',
                    ),
                    subtitle: context.l10n(
                      ko: '칭호·티어 달성으로 배너 해금',
                      en: 'Unlock banners with titles & tiers',
                      ja: '称号・ティア達成でバナー解放',
                    ),
                    onTap: () => context.push('/banner-picker'),
                  ),
                  _SettingsRow(
                    icon: Icons.workspace_premium_rounded,
                    iconBgColor: const Color(0xFF6366F1),
                    title: context.l10n(
                      ko: '칭호 관리',
                      en: 'Manage titles',
                      ja: '称号管理',
                    ),
                    subtitle: context.l10n(
                      ko: '획득한 칭호 확인 및 활성 칭호 설정',
                      en: 'View earned titles & set active title',
                      ja: '取得した称号の確認と称号の設定',
                    ),
                    onTap: () => context.push('/title-picker'),
                  ),
                  if (canAccessAdminOps)
                    _SettingsRow(
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
                    ),
                  _SettingsRow(
                    icon: Icons.build_circle_rounded,
                    iconBgColor: const Color(0xFF6366F1),
                    title: context.l10n(
                      ko: '계정 도구',
                      en: 'Account tools',
                      ja: 'アカウントツール',
                    ),
                    subtitle: context.l10n(
                      ko: '차단/권한요청/이의제기 관리',
                      en: 'Manage blocks/role requests/appeals',
                      ja: 'ブロック・権限申請・異議申立て管理',
                    ),
                    onTap: () => context.push('/settings/account-tools'),
                  ),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    iconBgColor: const Color(0xFFEF4444),
                    title: context.l10n(ko: '로그아웃', en: 'Log out', ja: 'ログアウト'),
                    onTap: () async {
                      final confirm = await _showLogoutConfirm(context);
                      if (confirm != true) return;
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n(
                                ko: '로그아웃되었습니다',
                                en: 'Logged out',
                                ja: 'ログアウトしました',
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    isLast: true,
                  ),
                ],
              ),
            ],

            // EN: Legal/privacy self-service section for authenticated users.
            // KO: 로그인 사용자를 위한 법률/개인정보 셀프서비스 섹션.
            if (isAuthenticated) ...[
              const SizedBox(height: GBTSpacing.lg),
              _SettingsGroup(
                title: context.l10n(ko: '개인정보', en: 'Privacy', ja: 'プライバシー'),
                children: [
                  _SettingsRow(
                    icon: Icons.gpp_good_rounded,
                    iconBgColor: const Color(0xFF0EA5E9),
                    title: context.l10n(
                      ko: '개인정보 및 권리행사',
                      en: 'Privacy and rights',
                      ja: 'プライバシーと権利行使',
                    ),
                    subtitle: context.l10n(
                      ko: '자동번역/처리정지/회원탈퇴',
                      en: 'Translation/restriction/account deletion',
                      ja: '翻訳・処理停止・退会',
                    ),
                    onTap: () => context.push('/settings/privacy-rights'),
                  ),
                  _SettingsRow(
                    icon: Icons.fact_check_rounded,
                    iconBgColor: const Color(0xFF2563EB),
                    title: context.l10n(
                      ko: '동의 이력',
                      en: 'Consent history',
                      ja: '同意履歴',
                    ),
                    subtitle: context.l10n(
                      ko: '약관/개인정보 동의 내역 확인',
                      en: 'Check terms/privacy consent records',
                      ja: '規約・同意履歴の確認',
                    ),
                    onTap: () => context.push('/settings/consents'),
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
                title: context.l10n(ko: '알림', en: 'Notifications', ja: '通知'),
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    iconBgColor: const Color(0xFFF59E0B),
                    title: context.l10n(
                      ko: '알림 설정',
                      en: 'Notification settings',
                      ja: '通知設定',
                    ),
                    subtitle: context.l10n(
                      ko: '푸시/이메일 알림 관리',
                      en: 'Manage push/email notifications',
                      ja: 'プッシュ・メール通知管理',
                    ),
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
              title: context.l10n(
                ko: '앱 환경',
                en: 'App preferences',
                ja: 'アプリ環境',
              ),
              children: [
                _SettingsRow(
                  icon: Icons.dark_mode_rounded,
                  iconBgColor: const Color(0xFF6366F1),
                  title: context.l10n(ko: '테마', en: 'Theme', ja: 'テーマ'),
                  trailing: Text(
                    _themeLabel(context, themeMode),
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
                  title: context.l10n(ko: '언어', en: 'Language', ja: '言語'),
                  trailing: Text(
                    _languageLabel(context, appLocale),
                    style: GBTTypography.bodySmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextTertiary
                          : GBTColors.textTertiary,
                    ),
                  ),
                  onTap: () => _showLanguagePicker(context, ref, appLocale),
                  isLast: true,
                ),
              ],
            ),

            // EN: Support section
            // KO: 지원 섹션
            const SizedBox(height: GBTSpacing.lg),
            _SettingsGroup(
              title: context.l10n(ko: '지원', en: 'Support', ja: 'サポート'),
              children: [
                _SettingsRow(
                  icon: Icons.help_rounded,
                  iconBgColor: const Color(0xFF3B82F6),
                  title: context.l10n(ko: '도움말', en: 'Help', ja: 'ヘルプ'),
                  onTap: () => _showComingSoon(
                    context,
                    context.l10n(
                      ko: '도움말은 준비 중입니다.',
                      en: 'Help is coming soon.',
                      ja: 'ヘルプは準備中です。',
                    ),
                  ),
                ),
                _SettingsRow(
                  icon: Icons.feedback_rounded,
                  iconBgColor: const Color(0xFFEC4899),
                  title: context.l10n(
                    ko: '피드백 보내기',
                    en: 'Send feedback',
                    ja: 'フィードバックを送る',
                  ),
                  onTap: () => _showComingSoon(
                    context,
                    context.l10n(
                      ko: '피드백 기능은 준비 중입니다.',
                      en: 'Feedback is coming soon.',
                      ja: 'フィードバック機能は準備中です。',
                    ),
                  ),
                ),
                _SettingsRow(
                  icon: Icons.description_rounded,
                  title: context.l10n(
                    ko: '이용약관',
                    en: 'Terms of service',
                    ja: '利用規約',
                  ),
                  subtitle: LegalPolicyConstants.byType(
                    LegalPolicyType.termsOfService,
                  ).version,
                  onTap: () => _openPolicy(
                    context,
                    LegalPolicyConstants.byType(
                      LegalPolicyType.termsOfService,
                    ).url,
                  ),
                ),
                _SettingsRow(
                  icon: Icons.privacy_tip_rounded,
                  title: context.l10n(
                    ko: '개인정보 처리방침',
                    en: 'Privacy policy',
                    ja: 'プライバシーポリシー',
                  ),
                  subtitle: LegalPolicyConstants.byType(
                    LegalPolicyType.privacyPolicy,
                  ).version,
                  onTap: () => _openPolicy(
                    context,
                    LegalPolicyConstants.byType(
                      LegalPolicyType.privacyPolicy,
                    ).url,
                  ),
                ),
                _SettingsRow(
                  icon: Icons.location_on_rounded,
                  title: context.l10n(
                    ko: '위치정보 이용약관',
                    en: 'Location terms',
                    ja: '位置情報利用規約',
                  ),
                  subtitle: LegalPolicyConstants.byType(
                    LegalPolicyType.locationTerms,
                  ).version,
                  onTap: () => _openPolicy(
                    context,
                    LegalPolicyConstants.byType(
                      LegalPolicyType.locationTerms,
                    ).url,
                  ),
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
                    appVersionState.when(
                      data: (version) => context.l10n(
                        ko: '버전 $version',
                        en: 'Version $version',
                        ja: 'バージョン $version',
                      ),
                      loading: () => context.l10n(
                        ko: '버전 확인 중',
                        en: 'Loading version',
                        ja: 'バージョン確認中',
                      ),
                      error: (_, _) => context.l10n(
                        ko: '버전 정보 없음',
                        en: 'Version unavailable',
                        ja: 'バージョン情報なし',
                      ),
                    ),
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

  Future<void> _openPolicy(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '정책 문서를 열 수 없습니다.',
            en: 'Unable to open policy document.',
            ja: 'ポリシー文書を開けません。',
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Profile Card — gradient hero header
// KO: 프로필 카드 — 그래디언트 히어로 헤더
// ========================================

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.isAuthenticated,
    required this.profileState,
    required this.onLoginTap,
    required this.onEditTap,
    required this.onProfileTap,
    required this.onRetry,
  });

  final bool isAuthenticated;
  final AsyncValue<UserProfile?>? profileState;
  final VoidCallback onLoginTap;
  final VoidCallback onEditTap;
  final VoidCallback onProfileTap;
  final VoidCallback onRetry;

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
                semanticLabel: context.l10n(
                  ko: '프로필 아이콘',
                  en: 'Profile icon',
                  ja: 'プロフィールアイコン',
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              context.l10n(
                ko: '로그인이 필요합니다',
                en: 'Login required',
                ja: 'ログインが必要です',
              ),
              style: GBTTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
              ),
            ),
            const SizedBox(height: GBTSpacing.xxs),
            Text(
              context.l10n(
                ko: '로그인하여 모든 기능을 사용하세요',
                en: 'Log in to use all features',
                ja: 'ログインしてすべての機能を利用してください',
              ),
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
                label: context.l10n(
                  ko: '로그인 페이지로 이동',
                  en: 'Go to login page',
                  ja: 'ログインページへ移動',
                ),
                child: FilledButton(
                  onPressed: onLoginTap,
                  child: Text(
                    context.l10n(ko: '로그인', en: 'Log in', ja: 'ログイン'),
                  ),
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: GBTLoading(
              message: context.l10n(
                ko: '프로필을 불러오는 중...',
                en: 'Loading profile...',
                ja: 'プロフィールを読み込み中...',
              ),
            ),
          ),
          error: (error, _) => Container(
            padding: const EdgeInsets.all(GBTSpacing.lg),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
              border: Border.all(color: borderColor, width: 0.5),
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
                        context.l10n(
                          ko: '프로필을 불러오지 못했어요',
                          en: 'Could not load profile',
                          ja: 'プロフィールを読み込めませんでした',
                        ),
                        style: GBTTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? GBTColors.darkTextPrimary
                              : GBTColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n(
                          ko: '잠시 후 다시 시도해주세요',
                          en: 'Please try again shortly',
                          ja: 'しばらくしてから再試行してください',
                        ),
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
                  tooltip: context.l10n(
                    ko: '프로필 다시 불러오기',
                    en: 'Reload profile',
                    ja: 'プロフィール再読み込み',
                  ),
                ),
              ],
            ),
          ),
          data: (profile) {
            if (profile == null) return const SizedBox.shrink();

            final primaryColor = isDark
                ? GBTColors.darkPrimary
                : GBTColors.primary;
            final textPrimary = isDark
                ? GBTColors.darkTextPrimary
                : GBTColors.textPrimary;
            final textSecondary = isDark
                ? GBTColors.darkTextSecondary
                : GBTColors.textSecondary;
            final textTertiary = isDark
                ? GBTColors.darkTextTertiary
                : GBTColors.textTertiary;
            final dividerColor = isDark
                ? GBTColors.darkBorderSubtle
                : GBTColors.divider;

            return Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // EN: Avatar + name row
                  // KO: 아바타 + 이름 행
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onProfileTap,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(GBTSpacing.radiusLg),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          GBTSpacing.md,
                          GBTSpacing.md,
                          GBTSpacing.md,
                          GBTSpacing.sm,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (profile.summaryLabel.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.summaryLabel,
                                      style: GBTTypography.bodySmall.copyWith(
                                        color: textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    maskEmail(profile.email),
                                    style: GBTTypography.labelSmall.copyWith(
                                      color: textTertiary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // EN: Edit shortcut button — subtle tinted footer, no harsh divider
                  // KO: 수정 바로가기 버튼 — 딱딱한 구분선 대신 미묘한 하단 틴트
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(GBTSpacing.radiusMd),
                      bottomRight: Radius.circular(GBTSpacing.radiusMd),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: dividerColor, width: 0.5),
                        ),
                        color: isDark
                            ? GBTColors.darkSurfaceVariant.withValues(
                                alpha: 0.4,
                              )
                            : GBTColors.surfaceVariant.withValues(alpha: 0.6),
                      ),
                      child: InkWell(
                        onTap: onEditTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: GBTSpacing.sm + 2,
                            horizontal: GBTSpacing.md,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: primaryColor,
                              ),
                              const SizedBox(width: GBTSpacing.xs),
                              Text(
                                context.l10n(
                                  ko: '프로필 수정',
                                  en: 'Edit profile',
                                  ja: 'プロフィール編集',
                                ),
                                style: GBTTypography.labelMedium.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
        radius: 30,
        backgroundColor: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          size: 30,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          semanticLabel: context.l10n(
            ko: '기본 프로필 이미지',
            en: 'Default profile image',
            ja: 'デフォルトプロフィール画像',
          ),
        ),
      );
    }

    return ClipOval(
      child: GBTImage(
        imageUrl: avatarUrl!,
        width: 60,
        height: 60,
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

// ========================================
// EN: Quick Actions Grid — activity shortcuts (3-tile)
// KO: 퀵 액션 그리드 — 활동 바로가기 (3타일)
// ========================================

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.onFavoritesTap,
    required this.onVisitsTap,
    required this.onStatsTap,
    required this.isDark,
  });

  final VoidCallback onFavoritesTap;
  final VoidCallback onVisitsTap;
  final VoidCallback onStatsTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickTile(
          icon: Icons.favorite_rounded,
          color: const Color(0xFFEF4444),
          label: context.l10n(ko: '즐겨찾기', en: 'Favorites', ja: 'お気に入り'),
          onTap: onFavoritesTap,
          isDark: isDark,
        ),
        const SizedBox(width: GBTSpacing.sm),
        _QuickTile(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          label: context.l10n(ko: '방문 기록', en: 'Visit history', ja: '訪問履歴'),
          onTap: onVisitsTap,
          isDark: isDark,
        ),
        const SizedBox(width: GBTSpacing.sm),
        _QuickTile(
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF3B82F6),
          label: context.l10n(ko: '통계', en: 'Stats', ja: '統計'),
          onTap: onStatsTap,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;

    return Expanded(
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: GBTSpacing.md,
              horizontal: GBTSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: GBTSpacing.xs),
                Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
        // EN: Section title label
        // KO: 섹션 제목 라벨
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
                  // EN: Icon with colored background (36px)
                  // KO: 색상 배경이 있는 아이콘 (36px)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: resolvedIconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                    ),
                    child: Icon(icon, color: resolvedIconColor, size: 20),
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
            indent: GBTSpacing.md + 36 + GBTSpacing.md,
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

String _themeLabel(BuildContext context, String mode) {
  return switch (mode) {
    'light' => context.l10n(ko: '라이트 모드', en: 'Light mode', ja: 'ライトモード'),
    'dark' => context.l10n(ko: '다크 모드', en: 'Dark mode', ja: 'ダークモード'),
    _ => context.l10n(ko: '시스템 설정', en: 'System', ja: 'システム'),
  };
}

String _languageLabel(BuildContext context, Locale? locale) {
  if (locale == null) {
    return context.l10n(ko: '시스템 설정', en: 'System', ja: 'システム');
  }
  return switch (locale.languageCode) {
    'en' => 'English',
    'ja' => '日本語',
    _ => context.l10n(ko: '한국어', en: 'Korean', ja: '韓国語'),
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
                context.l10n(ko: '테마 설정', en: 'Theme', ja: 'テーマ設定'),
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            _ThemeOption(
              icon: Icons.settings_suggest_rounded,
              label: context.l10n(ko: '시스템 설정', en: 'System', ja: 'システム'),
              description: context.l10n(
                ko: '기기 설정에 따라 자동 변경',
                en: 'Follow device setting',
                ja: '端末設定に合わせる',
              ),
              isSelected: currentMode == 'system',
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'system';
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: context.l10n(ko: '라이트 모드', en: 'Light mode', ja: 'ライトモード'),
              description: context.l10n(
                ko: '항상 밝은 테마 사용',
                en: 'Always use light theme',
                ja: '常にライトテーマを使用',
              ),
              isSelected: currentMode == 'light',
              onTap: () {
                ref.read(themeModeProvider.notifier).state = 'light';
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: context.l10n(ko: '다크 모드', en: 'Dark mode', ja: 'ダークモード'),
              description: context.l10n(
                ko: '항상 어두운 테마 사용',
                en: 'Always use dark theme',
                ja: '常にダークテーマを使用',
              ),
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

void _showLanguagePicker(BuildContext context, WidgetRef ref, Locale? current) {
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
                context.l10n(ko: '언어 설정', en: 'Language', ja: '言語設定'),
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            _ThemeOption(
              icon: Icons.settings_suggest_rounded,
              label: context.l10n(ko: '시스템 설정', en: 'System', ja: 'システム'),
              description: context.l10n(
                ko: '기기 언어 설정을 따릅니다',
                en: 'Use device language',
                ja: '端末の言語設定を使用',
              ),
              isSelected: current == null,
              onTap: () async {
                await ref.read(localeProvider.notifier).setLocale(null);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.translate_rounded,
              label: context.l10n(ko: '한국어', en: 'Korean', ja: '韓国語'),
              description: context.l10n(
                ko: '한국어로 표시합니다',
                en: 'Display in Korean',
                ja: '韓国語で表示します',
              ),
              isSelected: current?.languageCode == 'ko',
              onTap: () async {
                await ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('ko', 'KR'));
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.translate_rounded,
              label: 'English',
              description: context.l10n(
                ko: '영어로 표시합니다',
                en: 'Display in English',
                ja: '英語で表示します',
              ),
              isSelected: current?.languageCode == 'en',
              onTap: () async {
                await ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('en', 'US'));
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.translate_rounded,
              label: '日本語',
              description: context.l10n(
                ko: '일본어로 표시합니다',
                en: 'Display in Japanese',
                ja: '日本語で表示します',
              ),
              isSelected: current?.languageCode == 'ja',
              onTap: () async {
                await ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('ja', 'JP'));
                if (context.mounted) Navigator.of(context).pop();
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
  return showGBTAdaptiveConfirmDialog(
    context: context,
    title: context.l10n(ko: '로그아웃', en: 'Log out', ja: 'ログアウト'),
    message: context.l10n(
      ko: '정말로 로그아웃하시겠어요?',
      en: 'Are you sure you want to log out?',
      ja: '本当にログアウトしますか？',
    ),
    confirmLabel: context.l10n(ko: '로그아웃', en: 'Log out', ja: 'ログアウト'),
    cancelLabel: context.l10n(ko: '취소', en: 'Cancel', ja: 'キャンセル'),
  );
}

void _showComingSoon(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
