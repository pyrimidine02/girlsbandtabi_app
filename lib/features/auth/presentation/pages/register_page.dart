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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    color: GBTColors.textPrimary,
                  ),
                ),
                const SizedBox(height: GBTSpacing.lg),
                GBTTextField(
                  controller: _usernameController,
                  label: '사용자명',
                  hint: '아이디를 입력하세요',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '사용자명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GBTSpacing.md),
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
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                  onSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: GBTSpacing.lg),
                GBTButton(
                  label: '회원가입',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: GBTSpacing.md),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    '로그인으로 돌아가기',
                    style: GBTTypography.labelLarge.copyWith(
                      color: GBTColors.textSecondary,
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
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
    );

    if (result is Success<void> && mounted) {
      context.go('/home');
    }
  }
}
