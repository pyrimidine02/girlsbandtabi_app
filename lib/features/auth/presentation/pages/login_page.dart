/// EN: Login page for user authentication
/// KO: 사용자 인증을 위한 로그인 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
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
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 64,
                        color: colorScheme.primary,
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
                        '성지순례의 시작',
                        style: GBTTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GBTSpacing.xxxl),

                // EN: Username field
                // KO: 사용자명 필드
                GBTTextField(
                  controller: _usernameController,
                  label: '사용자명',
                  hint: '아이디를 입력하세요',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '사용자명을 입력해주세요';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: GBTSpacing.md),

                // EN: Password field
                // KO: 비밀번호 필드
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
                  onSubmitted: (_) => _handleLogin(),
                ),

                const SizedBox(height: GBTSpacing.lg),

                // EN: Login button
                // KO: 로그인 버튼
                GBTButton(
                  label: '로그인',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading ? null : _handleLogin,
                ),

                const SizedBox(height: GBTSpacing.xxl),

                const OAuthButtonsSection(),

                const SizedBox(height: GBTSpacing.xxl),

                // EN: Register link
                // KO: 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요?',
                      style: GBTTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('회원가입'),
                    ),
                  ],
                ),

                const SizedBox(height: GBTSpacing.md),

                // EN: Browse without login
                // KO: 로그인 없이 둘러보기
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      '로그인 없이 둘러보기',
                      style: GBTTypography.bodyMedium.copyWith(
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    final result = await controller.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (result is Success<void>) {
      context.go('/home');
    }
  }
}
