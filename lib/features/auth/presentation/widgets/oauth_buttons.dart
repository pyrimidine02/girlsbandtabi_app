/// EN: OAuth social login buttons section.
/// KO: OAuth 소셜 로그인 버튼 섹션.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/buttons/gbt_button.dart';
import '../../domain/entities/oauth_provider.dart';

/// EN: OAuth buttons group.
/// KO: OAuth 버튼 그룹.
class OAuthButtonsSection extends ConsumerWidget {
  const OAuthButtonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = OAuthProvider.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
              child: Text(
                '소셜 로그인',
                style: GBTTypography.labelMedium.copyWith(
                  color: GBTColors.textTertiary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: GBTSpacing.md),
        ...providers.map(
          (provider) => Padding(
            padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
            child: _OAuthButton(provider: provider),
          ),
        ),
        Text(
          '소셜 로그인은 준비 중입니다.',
          textAlign: TextAlign.center,
          style: GBTTypography.bodySmall.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OAuthButton extends ConsumerWidget {
  const _OAuthButton({required this.provider});

  final OAuthProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GBTButton(
      label: '${provider.displayName}로 로그인',
      variant: GBTButtonVariant.secondary,
      icon: _iconFor(provider),
      onPressed: () => _showInfo(context),
    );
  }

  void _showInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('소셜 로그인은 준비 중입니다')),
    );
  }

  IconData _iconFor(OAuthProvider provider) {
    return switch (provider) {
      OAuthProvider.google => Icons.g_mobiledata,
      OAuthProvider.apple => Icons.apple,
      OAuthProvider.twitter => Icons.alternate_email,
    };
  }
}
