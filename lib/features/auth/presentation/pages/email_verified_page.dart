/// EN: Email verified success page shown when the user taps the verification deeplink.
/// KO: 사용자가 인증 딥링크를 탭했을 때 표시되는 이메일 인증 완료 페이지.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/buttons/gbt_button.dart';

/// EN: Success screen displayed after email verification is completed via deeplink.
/// KO: 딥링크를 통해 이메일 인증이 완료된 후 표시되는 성공 화면.
class EmailVerifiedPage extends StatelessWidget {
  const EmailVerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: GBTSpacing.paddingPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EN: Success icon
              // KO: 성공 아이콘
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? GBTColors.darkSurfaceVariant
                        : GBTColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),

              // EN: Headline
              // KO: 헤드라인
              Text(
                context.l10n(
                  ko: '이메일 인증이 완료되었습니다',
                  en: 'Email verified!',
                  ja: 'メール認証が完了しました',
                ),
                style: GBTTypography.headlineSmall.copyWith(
                  color: isDark
                      ? GBTColors.darkTextPrimary
                      : GBTColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GBTSpacing.sm),

              // EN: Description
              // KO: 설명
              Text(
                context.l10n(
                  ko: '이제 로그인하여 서비스를 이용할 수 있습니다.',
                  en: 'You can now log in and start using the app.',
                  ja: 'ログインしてサービスをご利用いただけます。',
                ),
                style: GBTTypography.bodyMedium.copyWith(
                  color: isDark
                      ? GBTColors.darkTextSecondary
                      : GBTColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GBTSpacing.xl2),

              // EN: Go to login button
              // KO: 로그인 버튼
              GBTButton(
                label: context.l10n(
                  ko: '로그인하러 가기',
                  en: 'Go to login',
                  ja: 'ログインへ',
                ),
                isFullWidth: true,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
