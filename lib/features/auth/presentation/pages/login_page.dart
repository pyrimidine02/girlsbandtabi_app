/// EN: Login page for user authentication
/// KO: 사용자 인증을 위한 로그인 페이지
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
import '../widgets/oauth_buttons.dart';

/// EN: Login page widget
/// KO: 로그인 페이지 위젯
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      next.whenOrNull(
        error: (error, _) {
          final message = _buildSafeLoginErrorMessage(context, error);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading || _isSubmitting;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: GBTSpacing.paddingPage,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: GBTSpacing.xxxl),

                // EN: App logo and title
                // KO: 앱 로고 및 제목
                Center(
                  child: Semantics(
                    // EN: Group logo and title for screen readers
                    // KO: 스크린 리더를 위해 로고와 제목을 그룹화
                    label: context.l10n(
                      ko: 'Girls Band Tabi - 성지순례의 시작',
                      en: 'Girls Band Tabi - The start of your pilgrimage',
                      ja: 'Girls Band Tabi - 聖地巡礼のはじまり',
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: colorScheme.primary,
                          semanticLabel: context.l10n(
                            ko: 'Girls Band Tabi 로고',
                            en: 'Girls Band Tabi logo',
                            ja: 'Girls Band Tabi ロゴ',
                          ),
                        ),
                        const SizedBox(height: GBTSpacing.md),
                        Text(
                          'Girls Band Tabi',
                          style: GBTTypography.headlineMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: GBTSpacing.xs),
                        Text(
                          context.l10n(
                            ko: '성지순례의 시작',
                            en: 'The start of your pilgrimage',
                            ja: '聖地巡礼のはじまり',
                          ),
                          style: GBTTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: GBTSpacing.xxxl),

                // EN: Email input mapped to username contract field.
                // KO: username 계약 필드에 매핑되는 이메일 입력 필드.
                GBTTextField(
                  controller: _usernameController,
                  label: context.l10n(ko: '이메일', en: 'Email', ja: 'メールアドレス'),
                  hint: context.l10n(
                    ko: '이메일을 입력하세요',
                    en: 'Enter your email',
                    ja: 'メールアドレスを入力してください',
                  ),
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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

                // EN: Password field
                // KO: 비밀번호 필드
                GBTTextField(
                  controller: _passwordController,
                  label: context.l10n(ko: '비밀번호', en: 'Password', ja: 'パスワード'),
                  hint: context.l10n(
                    ko: '비밀번호를 입력하세요',
                    en: 'Enter your password',
                    ja: 'パスワードを入力してください',
                  ),
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n(
                        ko: '비밀번호를 입력해주세요',
                        en: 'Please enter your password',
                        ja: 'パスワードを入力してください',
                      );
                    }
                    if (value.length < 6) {
                      return context.l10n(
                        ko: '비밀번호는 6자 이상이어야 합니다',
                        en: 'Password must be at least 6 characters',
                        ja: 'パスワードは6文字以上で入力してください',
                      );
                    }
                    return null;
                  },
                  onSubmitted: (_) => isLoading ? null : _handleLogin(),
                ),

                const SizedBox(height: GBTSpacing.lg),

                // EN: Login button
                // KO: 로그인 버튼
                GBTButton(
                  label: context.l10n(ko: '로그인', en: 'Login', ja: 'ログイン'),
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading ? null : _handleLogin,
                  semanticLabel: isLoading
                      ? context.l10n(
                          ko: '로그인 진행 중',
                          en: 'Logging in',
                          ja: 'ログイン中',
                        )
                      : context.l10n(ko: '로그인', en: 'Login', ja: 'ログイン'),
                ),

                const SizedBox(height: GBTSpacing.xxl),

                const OAuthButtonsSection(),

                const SizedBox(height: GBTSpacing.xxl),

                // EN: Register link
                // KO: 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n(
                          ko: '계정이 없으신가요?',
                          en: "Don't have an account?",
                          ja: 'アカウントをお持ちでないですか？',
                        ),
                        style: GBTTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: context.l10n(
                        ko: '회원가입 페이지로 이동',
                        en: 'Go to register page',
                        ja: '会員登録ページへ移動',
                      ),
                      child: TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(
                            GBTSpacing.touchTarget,
                            GBTSpacing.touchTarget,
                          ),
                        ),
                        child: Text(
                          context.l10n(ko: '회원가입', en: 'Sign up', ja: '会員登録'),
                          style: GBTTypography.labelLarge.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: GBTSpacing.md),

                // EN: Browse without login
                // KO: 로그인 없이 둘러보기
                Center(
                  child: Semantics(
                    button: true,
                    label: context.l10n(
                      ko: '로그인 없이 앱 둘러보기',
                      en: 'Browse app without login',
                      ja: 'ログインせずにアプリを見る',
                    ),
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          GBTSpacing.touchTarget,
                          GBTSpacing.touchTarget,
                        ),
                      ),
                      child: Text(
                        context.l10n(
                          ko: '로그인 없이 둘러보기',
                          en: 'Continue without login',
                          ja: 'ログインせずに続ける',
                        ),
                        style: GBTTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
    });
    final controller = ref.read(authControllerProvider.notifier);
    try {
      final result = await controller.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (result is Success<void>) {
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

String _buildSafeLoginErrorMessage(BuildContext context, Object error) {
  if (error is NetworkFailure) {
    return context.l10n(
      ko: '네트워크 연결을 확인한 뒤 다시 시도해주세요.',
      en: 'Check your network connection and try again.',
      ja: 'ネットワーク接続を確認して再試行してください。',
    );
  }

  if (error is ValidationFailure ||
      (error is ServerFailure && error.code == '400')) {
    return context.l10n(
      ko: '요청 형식 또는 입력값을 다시 확인해주세요.',
      en: 'Please check the request format or input values.',
      ja: 'リクエスト形式または入力値を確認してください。',
    );
  }

  if (error is AuthFailure && error.code == '401') {
    return context.l10n(
      ko: '이메일 또는 비밀번호를 확인해주세요.',
      en: 'Please check your email or password.',
      ja: 'メールアドレスまたはパスワードを確認してください。',
    );
  }

  if (error is AuthFailure && error.code == '403') {
    return context.l10n(
      ko: '계정 상태를 확인해주세요. 이메일 인증 또는 계정 활성화가 필요할 수 있습니다.',
      en: 'Please check your account status. Email verification or activation may be required.',
      ja: 'アカウント状態を確認してください。メール認証または有効化が必要な場合があります。',
    );
  }

  if (error is ServerFailure && error.code == '409') {
    return context.l10n(
      ko: '동시 요청이 감지되었습니다. 잠시 후 다시 시도해주세요.',
      en: 'A conflicting login request was detected. Please try again shortly.',
      ja: '競合するログイン要求が検知されました。しばらくしてから再試行してください。',
    );
  }

  if (error is ServerFailure && error.code == '429') {
    final retryAfterSeconds = error.retryAfterMs != null
        ? (error.retryAfterMs! / 1000).ceil()
        : null;
    if (retryAfterSeconds != null && retryAfterSeconds > 0) {
      return context.l10n(
        ko: '$retryAfterSeconds초 후 다시 시도해주세요.',
        en: 'Please try again in $retryAfterSeconds seconds.',
        ja: '$retryAfterSeconds秒後に再試行してください。',
      );
    }
    return context.l10n(
      ko: '요청이 많아 잠시 제한되었습니다. 잠시 후 다시 시도해주세요.',
      en: 'Too many attempts. Please try again shortly.',
      ja: '試行回数が多すぎます。しばらくしてから再試行してください。',
    );
  }

  // EN: Keep login failure message generic to prevent account-enumeration hints.
  // KO: 계정 유추를 막기 위해 로그인 실패 문구를 일반화합니다.
  return context.l10n(
    ko: '로그인에 실패했습니다. 입력 정보를 확인하고 다시 시도해주세요.',
    en: 'Login failed. Please check your credentials and try again.',
    ja: 'ログインに失敗しました。入力内容を確認して再試行してください。',
  );
}
