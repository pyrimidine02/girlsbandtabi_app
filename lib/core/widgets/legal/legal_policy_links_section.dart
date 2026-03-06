/// EN: Reusable legal policy links section with version metadata.
/// KO: 버전 메타데이터를 포함한 재사용 가능한 정책 링크 섹션입니다.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/legal_policy_constants.dart';
import '../../localization/locale_text.dart';
import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

class LegalPolicyLinksSection extends StatelessWidget {
  const LegalPolicyLinksSection({
    super.key,
    this.title,
    this.showContainer = true,
  });

  final String? title;
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final header =
        title ??
        context.l10n(ko: '약관 및 정책', en: 'Terms and policies', ja: '規約とポリシー');

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: GBTTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
          ),
        ),
        const SizedBox(height: GBTSpacing.sm),
        ...LegalPolicyConstants.policies.map(
          (policy) => Padding(
            padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
            child: _PolicyRow(policy: policy),
          ),
        ),
      ],
    );

    if (!showContainer) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
          width: 0.5,
        ),
      ),
      child: content,
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.policy});

  final LegalPolicyInfo policy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final tertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return InkWell(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      onTap: () => _openPolicy(context, policy.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.xs,
          vertical: GBTSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                policy.type.label(context),
                style: GBTTypography.bodySmall.copyWith(
                  color: isDark
                      ? GBTColors.darkTextPrimary
                      : GBTColors.textPrimary,
                ),
              ),
            ),
            Text(
              policy.version,
              style: GBTTypography.labelSmall.copyWith(color: tertiary),
            ),
            const SizedBox(width: GBTSpacing.xs),
            Icon(Icons.open_in_new_rounded, size: 16, color: primary),
          ],
        ),
      ),
    );
  }

  Future<void> _openPolicy(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
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
