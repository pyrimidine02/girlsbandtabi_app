/// EN: Page shown after a successful OAuth login (200 — new account created),
///     asking the user if they have an existing local account to merge with.
/// KO: OAuth 로그인 성공(200 — 신규 계정 생성) 후 표시하는 페이지.
///     기존 로컬 계정과 합칠지 사용자에게 묻습니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/buttons/gbt_button.dart';
import '../../../../core/widgets/inputs/gbt_text_field.dart';
import '../../application/auth_controller.dart';

/// EN: Prompts the user to merge a new OAuth account with an existing local account.
/// KO: 신규 OAuth 계정을 기존 로컬 계정과 합치도록 사용자에게 안내합니다.
class OAuthMergeExistingPage extends ConsumerStatefulWidget {
  const OAuthMergeExistingPage({super.key});

  @override
  ConsumerState<OAuthMergeExistingPage> createState() =>
      _OAuthMergeExistingPageState();
}

class _OAuthMergeExistingPageState
    extends ConsumerState<OAuthMergeExistingPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _showMergeForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleMerge() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(authControllerProvider.notifier)
        .connectExisting(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result is Success<void>) {
      context.go('/home');
      return;
    }

    if (result is Err<void>) {
      final failure = result.failure;
      final message = _buildErrorMessage(context, failure);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _buildErrorMessage(BuildContext context, Failure failure) {
    return switch (failure.code) {
      '401' => context.l10n(
          ko: '이메일 또는 비밀번호가 올바르지 않습니다',
          en: 'Incorrect email or password',
          ja: 'メールアドレスまたはパスワードが正しくありません',
        ),
      'ACCOUNT_ALREADY_HAS_OAUTH' => context.l10n(
          ko: '해당 계정에는 이미 다른 소셜 계정이 연결되어 있습니다',
          en: 'The account already has another social account linked',
          ja: 'そのアカウントには既に別のソーシャルアカウントが連携されています',
        ),
      '429' => context.l10n(
          ko: '비밀번호를 너무 많이 틀렸습니다. 잠시 후 다시 시도해주세요',
          en: 'Too many attempts. Please try again later',
          ja: '試行回数が多すぎます。しばらくしてからお試しください',
        ),
      _ => failure.userMessage,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading || _isSubmitting;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          context.l10n(ko: '로그인 완료', en: 'Login Complete', ja: 'ログイン完了'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: GBTSpacing.paddingPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: GBTSpacing.xl),
              Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                context.l10n(
                  ko: '혹시 이전에 가입하신\n계정이 있으신가요?',
                  en: 'Do you have\nan existing account?',
                  ja: '以前に登録した\nアカウントはありますか？',
                ),
                style: GBTTypography.headlineMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                context.l10n(
                  ko: '기존 계정과 합치면 이전 활동 내역을 유지할 수 있어요.',
                  en: 'Merging with your existing account preserves your previous activity.',
                  ja: '既存のアカウントと統合すると、以前の活動履歴を保持できます。',
                ),
                style: GBTTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GBTSpacing.xxxl),
              if (!_showMergeForm) ...[
                GBTButton(
                  label: context.l10n(
                    ko: '네, 기존 계정이 있어요',
                    en: 'Yes, I have an existing account',
                    ja: 'はい、既存のアカウントがあります',
                  ),
                  isFullWidth: true,
                  onPressed: () => setState(() => _showMergeForm = true),
                ),
                const SizedBox(height: GBTSpacing.md),
                GBTButton(
                  label: context.l10n(
                    ko: '아니요, 새 계정으로 시작할게요',
                    en: 'No, start with new account',
                    ja: 'いいえ、新しいアカウントで始めます',
                  ),
                  variant: GBTButtonVariant.secondary,
                  isFullWidth: true,
                  onPressed: () => context.go('/home'),
                ),
              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GBTTextField(
                        controller: _emailController,
                        label: context.l10n(
                          ko: '기존 계정 이메일',
                          en: 'Existing Account Email',
                          ja: '既存アカウントのメールアドレス',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n(
                              ko: '이메일을 입력해주세요',
                              en: 'Please enter your email',
                              ja: 'メールアドレスを入力してください',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: GBTSpacing.md),
                      // EN: Password field with visibility toggle via suffixIcon + onSuffixTap.
                      // KO: suffixIcon + onSuffixTap으로 가시성 토글이 있는 비밀번호 필드.
                      GBTTextField(
                        controller: _passwordController,
                        label: context.l10n(
                          ko: '비밀번호',
                          en: 'Password',
                          ja: 'パスワード',
                        ),
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onSubmitted: (_) => isLoading ? null : _handleMerge(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.l10n(
                              ko: '비밀번호를 입력해주세요',
                              en: 'Please enter your password',
                              ja: 'パスワードを入力してください',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: GBTSpacing.xl),
                      GBTButton(
                        label: context.l10n(
                          ko: '계정 합치기',
                          en: 'Merge Accounts',
                          ja: 'アカウントを統合する',
                        ),
                        isFullWidth: true,
                        onPressed: isLoading ? null : _handleMerge,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: GBTSpacing.md),
                      GBTButton(
                        label: context.l10n(
                          ko: '취소',
                          en: 'Cancel',
                          ja: 'キャンセル',
                        ),
                        variant: GBTButtonVariant.secondary,
                        isFullWidth: true,
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _showMergeForm = false),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
