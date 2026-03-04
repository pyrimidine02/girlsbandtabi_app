/// EN: Notification settings page with card-grouped toggle rows.
/// KO: 카드 그룹 토글 행이 있는 알림 설정 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/settings_controller.dart';
import '../../domain/entities/notification_settings.dart';

/// EN: Notification settings page widget.
/// KO: 알림 설정 페이지 위젯.
class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('알림 설정')),
        body: _LoginRequired(onLogin: () => context.push('/login')),
      );
    }

    final state = ref.watch(notificationSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body: state.when(
        loading: () => const GBTLoading(message: '알림 설정을 불러오는 중...'),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '알림 설정을 불러오지 못했어요';
          return GBTErrorState(
            message: message,
            onRetry: () => ref
                .read(notificationSettingsControllerProvider.notifier)
                .load(forceRefresh: true),
          );
        },
        data: (settings) => _NotificationSettingsView(
          settings: settings,
          onChanged: (updated) async {
            final result = await ref
                .read(notificationSettingsControllerProvider.notifier)
                .updateSettings(updated);
            if (result is Err<NotificationSettings>) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('설정을 저장하지 못했어요')));
              }
            }
          },
        ),
      ),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView({
    required this.settings,
    required this.onChanged,
  });

  final NotificationSettings settings;
  final ValueChanged<NotificationSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.md,
        vertical: GBTSpacing.md,
      ),
      children: [
        // EN: Summary badge showing how many notifications are active
        // KO: 활성화된 알림 수를 보여주는 요약 배지
        _SummaryHeader(settings: settings, isDark: isDark),
        const SizedBox(height: GBTSpacing.lg),

        // EN: Channel group — push/email
        // KO: 채널 그룹 — 푸시/이메일
        _NotifGroupCard(
          title: '수신 채널',
          isDark: isDark,
          children: [
            _NotifToggleRow(
              icon: Icons.notifications_active_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: '푸시 알림',
              subtitle: '앱 푸시 알림 수신',
              value: settings.pushEnabled,
              semanticLabel: '푸시 알림 ${settings.pushEnabled ? "켜짐" : "꺼짐"}',
              onChanged: (v) => onChanged(settings.copyWith(pushEnabled: v)),
              isDark: isDark,
            ),
            _NotifToggleRow(
              icon: Icons.email_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: '이메일 알림',
              subtitle: '이메일로 알림 수신',
              value: settings.emailEnabled,
              semanticLabel: '이메일 알림 ${settings.emailEnabled ? "켜짐" : "꺼짐"}',
              onChanged: (v) => onChanged(settings.copyWith(emailEnabled: v)),
              isDark: isDark,
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: GBTSpacing.lg),

        // EN: Content group — live/favorites/comments
        // KO: 콘텐츠 그룹 — 라이브/즐겨찾기/댓글
        _NotifGroupCard(
          title: '콘텐츠 알림',
          isDark: isDark,
          children: [
            _NotifToggleRow(
              icon: Icons.event_rounded,
              iconColor: const Color(0xFF6366F1),
              title: '라이브 이벤트',
              subtitle: '다가오는 공연 소식',
              value: settings.liveEventsEnabled,
              semanticLabel:
                  '라이브 이벤트 알림 ${settings.liveEventsEnabled ? "켜짐" : "꺼짐"}',
              onChanged: (v) =>
                  onChanged(settings.copyWith(liveEventsEnabled: v)),
              isDark: isDark,
            ),
            _NotifToggleRow(
              icon: Icons.favorite_rounded,
              iconColor: const Color(0xFFEF4444),
              title: '즐겨찾기',
              subtitle: '즐겨찾기한 장소/콘텐츠 소식',
              value: settings.favoritesEnabled,
              semanticLabel:
                  '즐겨찾기 알림 ${settings.favoritesEnabled ? "켜짐" : "꺼짐"}',
              onChanged: (v) =>
                  onChanged(settings.copyWith(favoritesEnabled: v)),
              isDark: isDark,
            ),
            _NotifToggleRow(
              icon: Icons.chat_bubble_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: '댓글',
              subtitle: '댓글/후기 알림',
              value: settings.commentsEnabled,
              semanticLabel: '댓글 알림 ${settings.commentsEnabled ? "켜짐" : "꺼짐"}',
              onChanged: (v) =>
                  onChanged(settings.copyWith(commentsEnabled: v)),
              isDark: isDark,
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: GBTSpacing.xl),
      ],
    );
  }
}

// ========================================
// EN: Summary header with active count badge
// KO: 활성 수 배지가 있는 요약 헤더
// ========================================

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.settings, required this.isDark});

  final NotificationSettings settings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final enabledCount = [
      settings.pushEnabled,
      settings.emailEnabled,
      settings.liveEventsEnabled,
      settings.favoritesEnabled,
      settings.commentsEnabled,
    ].where((e) => e).length;

    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final surfaceColor =
        isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: GBTSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알림 환경 설정',
                  style: GBTTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '원하는 채널과 콘텐츠 알림만 선택하세요',
                  style: GBTTypography.labelSmall.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            ),
            child: Text(
              '활성 $enabledCount',
              style: GBTTypography.labelSmall.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// EN: Notification group card — section container
// KO: 알림 그룹 카드 — 섹션 컨테이너
// ========================================

class _NotifGroupCard extends StatelessWidget {
  const _NotifGroupCard({
    required this.title,
    required this.children,
    required this.isDark,
  });

  final String title;
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
            style: GBTTypography.labelSmall.copyWith(
              color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
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

// ========================================
// EN: Notification toggle row with icon
// KO: 아이콘이 있는 알림 토글 행
// ========================================

class _NotifToggleRow extends StatelessWidget {
  const _NotifToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
    this.semanticLabel,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final String? semanticLabel;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return Column(
      children: [
        Semantics(
          toggled: value,
          label: semanticLabel ?? '$title - $subtitle',
          child: InkWell(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.md,
                vertical: GBTSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  // EN: Icon container
                  // KO: 아이콘 컨테이너
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  // EN: Title + subtitle
                  // KO: 제목 + 부제목
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GBTTypography.bodyMedium.copyWith(
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          style: GBTTypography.labelSmall.copyWith(
                            color: textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // EN: Custom switch with primary color
                  // KO: 기본 색상 커스텀 스위치
                  Switch(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: primaryColor,
                    activeTrackColor: primaryColor.withValues(alpha: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ),
        ),
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

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;

    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: GBTSpacing.touchTarget,
              color: textTertiary,
              semanticLabel: '잠금 아이콘',
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              '로그인이 필요합니다',
              style: GBTTypography.titleSmall.copyWith(color: textPrimary),
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '알림 설정을 변경하려면 로그인해주세요.',
              style: GBTTypography.bodySmall.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.lg),
            Semantics(
              button: true,
              label: '로그인 페이지로 이동',
              child: FilledButton(
                onPressed: onLogin,
                child: const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
