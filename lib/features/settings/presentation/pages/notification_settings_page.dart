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
      children: [
        const _SectionHeader(title: '수신 채널'),
        _SettingsSwitchTile(
          title: '푸시 알림',
          subtitle: '앱 푸시 알림 수신',
          value: settings.pushEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(pushEnabled: value)),
        ),
        _SettingsSwitchTile(
          title: '이메일 알림',
          subtitle: '이메일로 알림 수신',
          value: settings.emailEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(emailEnabled: value)),
        ),
        const Divider(),
        const _SectionHeader(title: '콘텐츠 알림'),
        _SettingsSwitchTile(
          title: '라이브 이벤트',
          subtitle: '다가오는 공연 소식',
          value: settings.liveEventsEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(liveEventsEnabled: value)),
        ),
        _SettingsSwitchTile(
          title: '즐겨찾기',
          subtitle: '즐겨찾기한 장소/콘텐츠 소식',
          value: settings.favoritesEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(favoritesEnabled: value)),
        ),
        _SettingsSwitchTile(
          title: '댓글',
          subtitle: '댓글/후기 알림',
          value: settings.commentsEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(commentsEnabled: value)),
        ),
        const SizedBox(height: GBTSpacing.lg),
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: GBTTypography.bodyMedium),
      subtitle: Text(
        subtitle,
        style: GBTTypography.bodySmall.copyWith(color: GBTColors.textTertiary),
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

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: GBTColors.textTertiary),
            const SizedBox(height: GBTSpacing.md),
            Text('로그인이 필요합니다', style: GBTTypography.titleSmall),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '알림 설정을 변경하려면 로그인해주세요.',
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.lg),
            ElevatedButton(onPressed: onLogin, child: const Text('로그인')),
          ],
        ),
      ),
    );
  }
}
