/// EN: Register page for creating an account.
/// KO: 계정 생성을 위한 회원가입 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/buttons/gbt_button.dart';
import '../../../../core/widgets/inputs/gbt_text_field.dart';
import '../../application/auth_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      next.whenOrNull(
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : error.toString();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
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
                  '새 계정을 만들어보세요',
                  style: GBTTypography.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: GBTSpacing.lg),

                // EN: Email field.
                // KO: 이메일 필드.
                GBTTextField(
                  controller: _emailController,
                  label: '이메일',
                  hint: '이메일을 입력하세요',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!_isValidEmail(value)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GBTSpacing.md),

                // EN: Nickname field.
                // KO: 닉네임 필드.
                GBTTextField(
                  controller: _nicknameController,
                  label: '닉네임',
                  hint: '표시할 이름',
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GBTSpacing.md),

                // EN: Password field.
                // KO: 비밀번호 필드.
                GBTTextField(
                  controller: _passwordController,
                  label: '비밀번호',
                  hint: '비밀번호를 입력하세요',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
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
                  label: '비밀번호 확인',
                  hint: '비밀번호를 다시 입력하세요',
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
                      return '비밀번호를 다시 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
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
                    label: '비밀번호 일치',
                  ),
                ],

                const SizedBox(height: GBTSpacing.lg),
                GBTButton(
                  label: '회원가입',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading ? null : _handleRegister,
                  semanticLabel: isLoading ? '회원가입 진행 중' : '회원가입',
                ),
                const SizedBox(height: GBTSpacing.md),
                Semantics(
                  button: true,
                  label: '로그인 페이지로 돌아가기',
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        GBTSpacing.touchTarget,
                        GBTSpacing.touchTarget,
                      ),
                    ),
                    child: Text(
                      '로그인으로 돌아가기',
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

    final controller = ref.read(authControllerProvider.notifier);
    final result = await controller.register(
      username: _emailController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
    );

    if (result is Success<void> && mounted) {
      context.go('/home');
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (!_allPasswordConditionsMet) {
      return '아래 조건을 모두 충족해주세요';
    }
    return null;
  }

  bool _isValidEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
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
        _ConditionRow(met: hasMinLength, touched: touched, label: '6자 이상'),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasUppercase,
          touched: touched,
          label: '대문자 포함 (A-Z)',
        ),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasLowercase,
          touched: touched,
          label: '소문자 포함 (a-z)',
        ),
        const SizedBox(height: 2),
        _ConditionRow(met: hasDigit, touched: touched, label: '숫자 포함 (0-9)'),
        const SizedBox(height: 2),
        _ConditionRow(
          met: hasSpecialChar,
          touched: touched,
          label: '특수문자 포함 (@\$!%*?&)',
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
      label: '$label, ${met ? "충족" : "미충족"}',
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
