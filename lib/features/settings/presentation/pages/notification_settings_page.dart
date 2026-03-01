/// EN: Notification settings page.
/// KO: 알림 설정 페이지.
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
import '../../../../core/widgets/layout/gbt_page_intro_card.dart';
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
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        GBTPageIntroCard(
          icon: Icons.notifications_active_rounded,
          title: '알림 환경 설정',
          description: '원하는 채널과 콘텐츠 유형만 선택해 필요한 알림만 받으세요.',
          trailing: _NotificationEnabledBadge(settings: settings),
        ),
        const SizedBox(height: GBTSpacing.md),
        const _SectionHeader(title: '수신 채널'),
        _SettingsSwitchTile(
          title: '푸시 알림',
          subtitle: '앱 푸시 알림 수신',
          value: settings.pushEnabled,
          semanticLabel: '푸시 알림 ${settings.pushEnabled ? "켜짐" : "꺼짐"}',
          onChanged: (value) =>
              onChanged(settings.copyWith(pushEnabled: value)),
        ),
        _SettingsSwitchTile(
          title: '이메일 알림',
          subtitle: '이메일로 알림 수신',
          value: settings.emailEnabled,
          semanticLabel: '이메일 알림 ${settings.emailEnabled ? "켜짐" : "꺼짐"}',
          onChanged: (value) =>
              onChanged(settings.copyWith(emailEnabled: value)),
        ),
        const Divider(),
        const _SectionHeader(title: '콘텐츠 알림'),
        _SettingsSwitchTile(
          title: '라이브 이벤트',
          subtitle: '다가오는 공연 소식',
          value: settings.liveEventsEnabled,
          semanticLabel:
              '라이브 이벤트 알림 ${settings.liveEventsEnabled ? "켜짐" : "꺼짐"}',
          onChanged: (value) =>
              onChanged(settings.copyWith(liveEventsEnabled: value)),
        ),
        _SettingsSwitchTile(
          title: '즐겨찾기',
          subtitle: '즐겨찾기한 장소/콘텐츠 소식',
          value: settings.favoritesEnabled,
          semanticLabel: '즐겨찾기 알림 ${settings.favoritesEnabled ? "켜짐" : "꺼짐"}',
          onChanged: (value) =>
              onChanged(settings.copyWith(favoritesEnabled: value)),
        ),
        _SettingsSwitchTile(
          title: '댓글',
          subtitle: '댓글/후기 알림',
          value: settings.commentsEnabled,
          semanticLabel: '댓글 알림 ${settings.commentsEnabled ? "켜짐" : "꺼짐"}',
          onChanged: (value) =>
              onChanged(settings.copyWith(commentsEnabled: value)),
        ),
        const SizedBox(height: GBTSpacing.lg),
      ],
    );
  }
}

class _NotificationEnabledBadge extends StatelessWidget {
  const _NotificationEnabledBadge({required this.settings});

  final NotificationSettings settings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabledCount = [
      settings.pushEnabled,
      settings.emailEnabled,
      settings.liveEventsEnabled,
      settings.favoritesEnabled,
      settings.commentsEnabled,
    ].where((enabled) => enabled).length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurface : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        '활성 $enabledCount',
        style: GBTTypography.labelSmall.copyWith(
          color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      toggled: value,
      label: semanticLabel ?? '$title - $subtitle',
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: GBTTypography.bodyMedium.copyWith(
            // EN: Use theme-aware text color for dark mode
            // KO: 다크 모드를 위해 테마 인식 텍스트 색상 사용
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GBTTypography.bodySmall.copyWith(
            // EN: Use theme-aware tertiary text color
            // KO: 테마 인식 3차 텍스트 색상 사용
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.none,
        GBTSpacing.md,
        GBTSpacing.none,
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

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: GBTSpacing.touchTarget,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              semanticLabel: '잠금 아이콘',
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              '로그인이 필요합니다',
              style: GBTTypography.titleSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '알림 설정을 변경하려면 로그인해주세요.',
              style: GBTTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.lg),
            Semantics(
              button: true,
              label: '로그인 페이지로 이동',
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    GBTSpacing.touchTarget,
                    GBTSpacing.touchTarget,
                  ),
                ),
                child: const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
