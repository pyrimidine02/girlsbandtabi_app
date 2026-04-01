/// EN: Page for managing linked social (OAuth) accounts — connect Google/Apple,
///     disconnect the currently linked provider.
/// KO: 소셜(OAuth) 계정 연결을 관리하는 페이지 — Google/Apple 연결,
///     현재 연결된 제공자 해제.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/dialogs/gbt_adaptive_dialog.dart'
    show showGBTAdaptiveConfirmDialog;
import '../../../auth/application/auth_controller.dart';

/// EN: Displays social account connection management options.
/// KO: 소셜 계정 연결 관리 옵션을 표시합니다.
class LinkedAccountsPage extends ConsumerWidget {
  const LinkedAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n(
            ko: '소셜 계정 연결',
            en: 'Linked Accounts',
            ja: 'ソーシャルアカウント連携',
          ),
        ),
      ),
      body: ListView(
        padding: GBTSpacing.paddingPage,
        children: [
          const SizedBox(height: GBTSpacing.md),
          Text(
            context.l10n(
              ko: '소셜 계정을 연결하면 해당 소셜 로그인으로 앱에 접근할 수 있어요.',
              en: 'Link a social account to sign in to the app using that provider.',
              ja: 'ソーシャルアカウントを連携すると、そのソーシャルログインでアプリにアクセスできます。',
            ),
            style: GBTTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: GBTSpacing.xl),

          // EN: Google connect row
          // KO: Google 연결 행
          _SocialAccountRow(
            icon: Icons.g_mobiledata_rounded,
            iconColor: const Color(0xFF4285F4),
            title: context.l10n(
              ko: 'Google 연결',
              en: 'Connect Google',
              ja: 'Googleと連携',
            ),
            isLoading: isLoading,
            onTap: () => _handleConnectGoogle(context, ref),
          ),

          // EN: Apple connect row — iOS only (Apple guideline requirement).
          // KO: Apple 연결 행 — iOS 전용 (Apple 가이드라인 요구사항).
          if (Platform.isIOS) ...[
            const Divider(height: 1),
            _SocialAccountRow(
              icon: Icons.apple_rounded,
              iconColor: Colors.black,
              title: context.l10n(
                ko: 'Apple 연결',
                en: 'Connect Apple',
                ja: 'Appleと連携',
              ),
              isLoading: isLoading,
              onTap: () => _handleConnectApple(context, ref),
            ),
          ],

          const SizedBox(height: GBTSpacing.xxxl),

          // EN: Disconnect section — detaches whichever provider is currently linked.
          // KO: 연결 해제 섹션 — 현재 연결된 제공자를 해제합니다.
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: GBTSpacing.lg),
          Text(
            context.l10n(
              ko: '연결 해제',
              en: 'Disconnect',
              ja: '連携解除',
            ),
            style: GBTTypography.titleSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          Text(
            context.l10n(
              ko: '비밀번호가 없는 순수 소셜 계정은 연결을 해제할 수 없어요. 먼저 비밀번호를 설정해주세요.',
              en: 'Accounts without a password cannot disconnect. Please set a password first.',
              ja: 'パスワードのない純粋なソーシャルアカウントは連携を解除できません。先にパスワードを設定してください。',
            ),
            style: GBTTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          _SocialAccountRow(
            icon: Icons.link_off_rounded,
            iconColor: const Color(0xFFEF4444),
            title: context.l10n(
              ko: '소셜 계정 연결 해제',
              en: 'Disconnect social account',
              ja: 'ソーシャルアカウントの連携解除',
            ),
            isLoading: isLoading,
            onTap: () => _handleDisconnect(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConnectGoogle(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result =
        await ref.read(authControllerProvider.notifier).connectGoogle();
    if (!context.mounted) return;
    _showResultSnackBar(context, result,
        successMessage: context.l10n(
          ko: 'Google 계정이 연결되었습니다',
          en: 'Google account connected',
          ja: 'Googleアカウントが連携されました',
        ));
  }

  Future<void> _handleConnectApple(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result =
        await ref.read(authControllerProvider.notifier).connectApple();
    if (!context.mounted) return;
    _showResultSnackBar(context, result,
        successMessage: context.l10n(
          ko: 'Apple 계정이 연결되었습니다',
          en: 'Apple account connected',
          ja: 'Appleアカウントが連携されました',
        ));
  }

  Future<void> _handleDisconnect(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await showGBTAdaptiveConfirmDialog(
      context: context,
      title: context.l10n(
        ko: '소셜 계정 연결 해제',
        en: 'Disconnect social account',
        ja: 'ソーシャルアカウントの連携解除',
      ),
      message: context.l10n(
        ko: '소셜 계정 연결을 해제하시겠습니까?',
        en: 'Are you sure you want to disconnect your social account?',
        ja: 'ソーシャルアカウントの連携を解除しますか？',
      ),
      confirmLabel: context.l10n(ko: '해제', en: 'Disconnect', ja: '解除'),
      cancelLabel: context.l10n(ko: '취소', en: 'Cancel', ja: 'キャンセル'),
      isDestructive: true,
    );
    if (confirm != true || !context.mounted) return;

    final result =
        await ref.read(authControllerProvider.notifier).disconnectOAuth();
    if (!context.mounted) return;

    if (result is Err<void>) {
      final failure = result.failure;
      final message = failure.code == 'CANNOT_DISCONNECT_OAUTH'
          ? context.l10n(
              ko: '비밀번호를 먼저 설정하신 후 소셜 계정 연결을 해제할 수 있어요',
              en: 'Please set a password first before disconnecting your social account',
              ja: 'ソーシャルアカウントの連携を解除するには、先にパスワードを設定してください',
            )
          : failure.userMessage;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '소셜 계정 연결이 해제되었습니다',
            en: 'Social account disconnected',
            ja: 'ソーシャルアカウントの連携が解除されました',
          ),
        ),
      ),
    );
  }

  void _showResultSnackBar(
    BuildContext context,
    Result<void> result, {
    required String successMessage,
  }) {
    if (result is Success<void>) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(successMessage)));
      return;
    }
    if (result is Err<void>) {
      final failure = result.failure;
      final message = _buildConnectErrorMessage(context, failure);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _buildConnectErrorMessage(BuildContext context, Failure failure) {
    return switch (failure.code) {
      'OAUTH_ALREADY_LINKED' => context.l10n(
          ko: '이 소셜 계정은 이미 다른 계정에 연결되어 있습니다',
          en: 'This social account is already linked to another account',
          ja: 'このソーシャルアカウントは既に別のアカウントに連携されています',
        ),
      'ACCOUNT_ALREADY_HAS_OAUTH' => context.l10n(
          ko: '이 계정에는 이미 다른 소셜 계정이 연결되어 있습니다',
          en: 'This account already has another social account linked',
          ja: 'このアカウントには既に別のソーシャルアカウントが連携されています',
        ),
      'sign_in_cancelled' => context.l10n(
          ko: '로그인이 취소되었습니다',
          en: 'Sign-in was cancelled',
          ja: 'ログインがキャンセルされました',
        ),
      _ => failure.userMessage,
    };
  }
}

// ---------------------------------------------------------------------------
// EN: Row widget for a single social account action.
// KO: 단일 소셜 계정 액션을 위한 행 위젯.
// ---------------------------------------------------------------------------

class _SocialAccountRow extends StatelessWidget {
  const _SocialAccountRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GBTTypography.bodyMedium.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
      onTap: isLoading ? null : onTap,
    );
  }
}
