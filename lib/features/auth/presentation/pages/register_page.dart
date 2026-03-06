/// EN: Register page for creating an account.
/// KO: 계정 생성을 위한 회원가입 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/legal_policy_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/buttons/gbt_button.dart';
import '../../../../core/widgets/inputs/gbt_text_field.dart';
import '../../../../core/widgets/legal/legal_policy_links_section.dart';
import '../../application/auth_controller.dart';
import '../../domain/entities/register_consent.dart';

/// EN: Register page widget.
/// KO: 회원가입 페이지 위젯.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // EN: Live password validation state.
  // KO: 실시간 비밀번호 검증 상태.
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _confirmOver14 = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final value = _passwordController.text;
    setState(() {
      _passwordTouched = true;
      _hasMinLength = value.length >= 6;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigit = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[@$!%*?&]'));
      _passwordsMatch =
          value.isNotEmpty && value == _confirmPasswordController.text;
    });
  }

  void _onConfirmChanged() {
    setState(() {
      _confirmTouched = true;
      _passwordsMatch =
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  bool get _allPasswordConditionsMet =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasDigit &&
      _hasSpecialChar;

  bool get _hasRequiredConsents =>
      _agreeTerms && _agreePrivacy && _confirmOver14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      next.whenOrNull(
        error: (error, _) {
          final message = _toSafeRegisterErrorMessage(error);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n(ko: '회원가입', en: 'Sign up', ja: '会員登録')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: GBTSpacing.paddingPage,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: GBTSpacing.xl),
                Text(
                  context.l10n(
                    ko: '새 계정을 만들어보세요',
                    en: 'Create your new account',
                    ja: '新しいアカウントを作成しましょう',
                  ),
                  style: GBTTypography.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: GBTSpacing.lg),

                // EN: Email field.
                // KO: 이메일 필드.
                GBTTextField(
                  controller: _emailController,
                  label: context.l10n(ko: '이메일', en: 'Email', ja: 'メール'),
                  hint: context.l10n(
                    ko: '이메일을 입력하세요',
                    en: 'Enter your email',
                    ja: 'メールアドレスを入力してください',
                  ),
                  prefixIcon: Icons.email_outlined,
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
                    if (!_isValidEmail(value)) {
                      return context.l10n(
                        ko: '올바른 이메일 형식을 입력해주세요',
                        en: 'Please enter a valid email address',
                        ja: '正しいメール形式で入力してください',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GBTSpacing.md),

                // EN: Nickname field.
                // KO: 닉네임 필드.
                GBTTextField(
                  controller: _nicknameController,
                  label: context.l10n(ko: '닉네임', en: 'Nickname', ja: 'ニックネーム'),
                  hint: context.l10n(
                    ko: '표시할 이름',
                    en: 'Display name',
                    ja: '表示名',
                  ),
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n(
                        ko: '닉네임을 입력해주세요',
                        en: 'Please enter a nickname',
                        ja: 'ニックネームを入力してください',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GBTSpacing.md),

                // EN: Password field.
                // KO: 비밀번호 필드.
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
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validatePassword(context, value),
                ),

                // EN: Password requirement checklist.
                // KO: 비밀번호 요구사항 체크리스트.
                const SizedBox(height: GBTSpacing.sm),
                _PasswordConditions(
                  touched: _passwordTouched,
                  hasMinLength: _hasMinLength,
                  hasUppercase: _hasUppercase,
                  hasLowercase: _hasLowercase,
                  hasDigit: _hasDigit,
                  hasSpecialChar: _hasSpecialChar,
                ),
                const SizedBox(height: GBTSpacing.md),

                // EN: Password confirmation field.
                // KO: 비밀번호 확인 필드.
                GBTTextField(
                  controller: _confirmPasswordController,
                  label: context.l10n(
                    ko: '비밀번호 확인',
                    en: 'Confirm password',
                    ja: 'パスワード確認',
                  ),
                  hint: context.l10n(
                    ko: '비밀번호를 다시 입력하세요',
                    en: 'Re-enter your password',
                    ja: 'パスワードを再入力してください',
                  ),
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscureConfirm,
                  suffixIcon: _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n(
                        ko: '비밀번호를 다시 입력해주세요',
                        en: 'Please re-enter your password',
                        ja: 'パスワードを再入力してください',
                      );
                    }
                    if (value != _passwordController.text) {
                      return context.l10n(
                        ko: '비밀번호가 일치하지 않습니다',
                        en: 'Passwords do not match',
                        ja: 'パスワードが一致しません',
                      );
                    }
                    return null;
                  },
                  onSubmitted: (_) => _handleRegister(),
                ),

                // EN: Password match indicator.
                // KO: 비밀번호 일치 표시.
                if (_confirmTouched) ...[
                  const SizedBox(height: GBTSpacing.xs),
                  _ConditionRow(
                    met: _passwordsMatch,
                    touched: true,
                    label: context.l10n(
                      ko: '비밀번호 일치',
                      en: 'Passwords match',
                      ja: 'パスワード一致',
                    ),
                  ),
                ],

                const SizedBox(height: GBTSpacing.lg),
                _ConsentSection(
                  agreeTerms: _agreeTerms,
                  agreePrivacy: _agreePrivacy,
                  confirmOver14: _confirmOver14,
                  onAgreeTermsChanged: (value) {
                    setState(() => _agreeTerms = value);
                  },
                  onAgreePrivacyChanged: (value) {
                    setState(() => _agreePrivacy = value);
                  },
                  onConfirmOver14Changed: (value) {
                    setState(() => _confirmOver14 = value);
                  },
                ),
                const SizedBox(height: GBTSpacing.md),
                const LegalPolicyLinksSection(showContainer: false),
                const SizedBox(height: GBTSpacing.lg),
                GBTButton(
                  label: context.l10n(ko: '회원가입', en: 'Sign up', ja: '会員登録'),
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading
                      ? null
                      : (_hasRequiredConsents ? _handleRegister : null),
                  semanticLabel: isLoading
                      ? context.l10n(
                          ko: '회원가입 진행 중',
                          en: 'Signing up',
                          ja: '登録中',
                        )
                      : context.l10n(ko: '회원가입', en: 'Sign up', ja: '会員登録'),
                ),
                const SizedBox(height: GBTSpacing.md),
                Semantics(
                  button: true,
                  label: context.l10n(
                    ko: '로그인 페이지로 돌아가기',
                    en: 'Back to login page',
                    ja: 'ログインページに戻る',
                  ),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        GBTSpacing.touchTarget,
                        GBTSpacing.touchTarget,
                      ),
                    ),
                    child: Text(
                      context.l10n(
                        ko: '로그인으로 돌아가기',
                        en: 'Back to login',
                        ja: 'ログインに戻る',
                      ),
                      style: GBTTypography.labelLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasRequiredConsents) {
      _showConsentRequiredMessage();
      return;
    }

    final consentConfirmed = await _showConsentConfirmDialog();
    if (!consentConfirmed || !mounted) return;

    final controller = ref.read(authControllerProvider.notifier);
    final result = await controller.register(
      username: _emailController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
      consents: _buildRegisterConsents(),
    );

    if (result is Success<void> && mounted) {
      await _persistConsentHistory();
      if (!mounted) return;
      context.go('/home');
    }
  }

  Future<void> _persistConsentHistory() async {
    try {
      final storage = await ref.read(localStorageProvider.future);
      final consentRecords = _buildRegisterConsents()
          .map(
            (consent) => {
              'type': consent.type,
              'version': consent.version,
              'agreed': consent.agreed,
              'agreedAt': consent.agreedAt.toIso8601String(),
            },
          )
          .toList(growable: false);
      await storage.setJsonList(LocalStorageKeys.userConsents, consentRecords);
    } catch (_) {
      // EN: Consent history persistence failure must not block successful signup.
      // KO: 동의 이력 저장 실패는 가입 성공 흐름을 막지 않아야 합니다.
    }
  }

  List<RegisterConsent> _buildRegisterConsents() {
    final now = DateTime.now();
    final terms = LegalPolicyConstants.byType(LegalPolicyType.termsOfService);
    final privacy = LegalPolicyConstants.byType(LegalPolicyType.privacyPolicy);
    return [
      RegisterConsent(
        type: 'TERMS_OF_SERVICE',
        version: terms.version,
        agreed: _agreeTerms,
        agreedAt: now,
      ),
      RegisterConsent(
        type: 'PRIVACY_POLICY',
        version: privacy.version,
        agreed: _agreePrivacy,
        agreedAt: now,
      ),
      RegisterConsent(
        type: 'AGE_OVER_14',
        version: terms.version,
        agreed: _confirmOver14,
        agreedAt: now,
      ),
    ];
  }

  String? _validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n(
        ko: '비밀번호를 입력해주세요',
        en: 'Please enter your password',
        ja: 'パスワードを入力してください',
      );
    }
    if (!_allPasswordConditionsMet) {
      return context.l10n(
        ko: '아래 조건을 모두 충족해주세요',
        en: 'Please satisfy all conditions below',
        ja: '下記の条件をすべて満たしてください',
      );
    }
    return null;
  }

  bool _isValidEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  void _showConsentRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '필수 동의 항목을 모두 체크해주세요.',
            en: 'Please check all required consent items.',
            ja: '必須同意項目をすべてチェックしてください。',
          ),
        ),
      ),
    );
  }

  Future<bool> _showConsentConfirmDialog() async {
    final now = DateTime.now().toLocal();
    final terms = LegalPolicyConstants.byType(LegalPolicyType.termsOfService);
    final privacy = LegalPolicyConstants.byType(LegalPolicyType.privacyPolicy);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.l10n(
              ko: '가입 전 최종 확인',
              en: 'Final confirmation',
              ja: '登録前の最終確認',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n(
                  ko: '아래 동의 항목으로 가입을 진행할까요?',
                  en: 'Proceed with the following consents?',
                  ja: '以下の同意内容で登録を進めますか？',
                ),
                style: GBTTypography.bodySmall,
              ),
              const SizedBox(height: GBTSpacing.sm),
              _ConfirmLine(
                text: '${terms.type.label(context)} ${terms.version}',
              ),
              _ConfirmLine(
                text: '${privacy.type.label(context)} ${privacy.version}',
              ),
              _ConfirmLine(
                text: context.l10n(
                  ko: '만 14세 이상 확인',
                  en: 'Confirmed age 14 or older',
                  ja: '14歳以上確認',
                ),
              ),
              const SizedBox(height: GBTSpacing.xs),
              Text(
                context.l10n(
                  ko: '동의 시각: ${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}',
                  en: 'Consent time: ${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}',
                  ja: '同意時刻: ${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")} ${now.hour.toString().padLeft(2, "0")}:${now.minute.toString().padLeft(2, "0")}',
                ),
                style: GBTTypography.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n(ko: '취소', en: 'Cancel', ja: 'キャンセル')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.l10n(
                  ko: '동의 후 가입',
                  en: 'Agree and sign up',
                  ja: '同意して登録',
                ),
              ),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  String _toSafeRegisterErrorMessage(Object error) {
    if (error is NetworkFailure) {
      return context.l10n(
        ko: '네트워크 상태를 확인한 뒤 다시 시도해주세요.',
        en: 'Check your network and try again.',
        ja: 'ネットワーク状態を確認して再試行してください。',
      );
    }
    return context.l10n(
      ko: '회원가입 처리 중 문제가 발생했습니다. 입력값을 확인하고 다시 시도해주세요.',
      en: 'Sign-up failed. Please verify your input and try again.',
      ja: '会員登録に失敗しました。入力内容を確認して再試行してください。',
    );
  }
}

class _ConfirmLine extends StatelessWidget {
  const _ConfirmLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded, size: 14),
          ),
          const SizedBox(width: GBTSpacing.xs),
          Expanded(child: Text(text, style: GBTTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _ConsentSection extends StatelessWidget {
  const _ConsentSection({
    required this.agreeTerms,
    required this.agreePrivacy,
    required this.confirmOver14,
    required this.onAgreeTermsChanged,
    required this.onAgreePrivacyChanged,
    required this.onConfirmOver14Changed,
  });

  final bool agreeTerms;
  final bool agreePrivacy;
  final bool confirmOver14;
  final ValueChanged<bool> onAgreeTermsChanged;
  final ValueChanged<bool> onAgreePrivacyChanged;
  final ValueChanged<bool> onConfirmOver14Changed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n(ko: '필수 동의', en: 'Required consents', ja: '必須同意'),
          style: GBTTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: GBTSpacing.xs),
        _ConsentCheckTile(
          value: agreeTerms,
          label: context.l10n(
            ko: '이용약관 동의 (필수)',
            en: 'Agree to Terms (Required)',
            ja: '利用規約に同意 (必須)',
          ),
          onChanged: onAgreeTermsChanged,
        ),
        _ConsentCheckTile(
          value: agreePrivacy,
          label: context.l10n(
            ko: '개인정보 처리방침 동의 (필수)',
            en: 'Agree to Privacy Policy (Required)',
            ja: 'プライバシーポリシーに同意 (必須)',
          ),
          onChanged: onAgreePrivacyChanged,
        ),
        _ConsentCheckTile(
          value: confirmOver14,
          label: context.l10n(
            ko: '만 14세 이상입니다 (필수)',
            en: 'I am 14 years old or older (Required)',
            ja: '14歳以上です (必須)',
          ),
          onChanged: onConfirmOver14Changed,
        ),
      ],
    );
  }
}

class _ConsentCheckTile extends StatelessWidget {
  const _ConsentCheckTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
            ),
            Expanded(child: Text(label, style: GBTTypography.bodySmall)),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Password condition checklist widget
// KO: 비밀번호 조건 체크리스트 위젯
// ========================================

class _PasswordConditions extends StatelessWidget {
  const _PasswordConditions({
    required this.touched,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecialChar,
  });

  final bool touched;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConditionRow(
          met: hasMinLength,
          touched: touched,
          label: context.l10n(
            ko: '6자 이상',
            en: 'At least 6 characters',
            ja: '6文字以上',
          ),
        ),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasUppercase,
          touched: touched,
          label: context.l10n(
            ko: '대문자 포함 (A-Z)',
            en: 'Contains uppercase (A-Z)',
            ja: '大文字を含む (A-Z)',
          ),
        ),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasLowercase,
          touched: touched,
          label: context.l10n(
            ko: '소문자 포함 (a-z)',
            en: 'Contains lowercase (a-z)',
            ja: '小文字を含む (a-z)',
          ),
        ),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasDigit,
          touched: touched,
          label: context.l10n(
            ko: '숫자 포함 (0-9)',
            en: 'Contains number (0-9)',
            ja: '数字を含む (0-9)',
          ),
        ),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasSpecialChar,
          touched: touched,
          label: context.l10n(
            ko: '특수문자 포함 (@\$!%*?&)',
            en: 'Contains special char (@\$!%*?&)',
            ja: '記号を含む (@\$!%*?&)',
          ),
        ),
      ],
    );
  }
}

// ========================================
// EN: Single condition row with icon + label
// KO: 아이콘 + 라벨이 있는 단일 조건 행
// ========================================

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
    required this.met,
    required this.touched,
    required this.label,
  });

  final bool met;
  final bool touched;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EN: Not touched yet → neutral grey. Touched → green (met) / red (not met).
    // KO: 미입력 → 중립 회색. 입력 후 → 초록 (충족) / 빨강 (미충족).
    final Color iconColor;
    final Color textColor;
    final IconData icon;

    if (!touched) {
      iconColor = isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
      textColor = isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
      icon = Icons.circle_outlined;
    } else if (met) {
      iconColor = GBTColors.success;
      textColor = GBTColors.success;
      icon = Icons.check_circle;
    } else {
      iconColor = isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
      textColor = isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
      icon = Icons.circle_outlined;
    }

    return Semantics(
      label:
          '$label, ${met ? context.l10n(ko: "충족", en: "met", ja: "満たす") : context.l10n(ko: "미충족", en: "not met", ja: "未達成")}',
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: GBTSpacing.xs),
          Text(
            label,
            style: GBTTypography.labelSmall.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
