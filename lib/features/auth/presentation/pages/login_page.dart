import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kt_colors.dart';
import '../../../../core/theme/kt_spacing.dart';
import '../../../../core/theme/kt_typography.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/kt_button.dart';
import '../widgets/kt_text_field.dart';
import '../../application/controllers/auth_controller.dart';
import '../../application/providers/auth_providers.dart';

/// EN: Login page with KT UXD design system implementation
/// KO: KT UXD 디자인 시스템 구현이 포함된 로그인 페이지
class LoginPage extends ConsumerStatefulWidget {
  /// EN: Creates login page instance
  /// KO: 로그인 페이지 인스턴스 생성
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  /// EN: Form key for validation
  /// KO: 검증을 위한 폼 키
  final _formKey = GlobalKey<FormState>();

  /// EN: Email text controller
  /// KO: 이메일 텍스트 컨트롤러
  final _usernameController = TextEditingController();

  /// EN: Password text controller
  /// KO: 비밀번호 텍스트 컨트롤러
  final _passwordController = TextEditingController();

  /// EN: Password visibility toggle
  /// KO: 비밀번호 가시성 토글
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // EN: Listen to auth state changes
    // KO: 인증 상태 변화 감지
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (user) {
          if (context.mounted) {
            context.go('/home');
          }
        },
        unauthenticated: () {},
        error: (failure) {
          // EN: Show error message
          // KO: 에러 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: KTColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: KTColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KTSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildLoginForm(authState),
                  ),
                ),
              ),
              _buildBottomText(),
            ],
          ),
        ),
      ),
    );
  }

  /// EN: Build the main login form
  /// KO: 메인 로그인 폼 구성
  Widget _buildLoginForm(AuthState authState) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(),
            const SizedBox(height: KTSpacing.xxl),
            _buildTitle(),
            const SizedBox(height: KTSpacing.xl),
            _buildUsernameField(),
            const SizedBox(height: KTSpacing.lg),
            _buildPasswordField(),
            const SizedBox(height: KTSpacing.md),
            _buildForgotPasswordLink(),
            const SizedBox(height: KTSpacing.xl),
            _buildLoginButton(authState),
            const SizedBox(height: KTSpacing.lg),
            _buildDivider(),
            const SizedBox(height: KTSpacing.lg),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  /// EN: Build app logo
  /// KO: 앱 로고 구성
  Widget _buildLogo() {
    return Container(
      height: 80,
      width: 80,
      decoration: const BoxDecoration(
        color: KTColors.primaryText,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.music_note,
        color: KTColors.background,
        size: 40,
      ),
    );
  }

  /// EN: Build page title
  /// KO: 페이지 제목 구성
  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          '걸즈밴드타비',
          style: KTTypography.displaySmall.copyWith(
            color: KTColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KTSpacing.xs),
        Text(
          '로그인하여 성지순례를 시작하세요',
          style: KTTypography.bodyMedium.copyWith(
            color: KTColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// EN: Build username input field
  /// KO: 사용자명 입력 필드 구성
  Widget _buildUsernameField() {
    return KTTextField(
      controller: _usernameController,
      label: '아이디 (이메일)',
      hint: 'username@example.com',
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final failure = Validators.validateEmail(value, fieldName: 'username');
        return failure?.message;
      },
    );
  }

  /// EN: Build password input field
  /// KO: 비밀번호 입력 필드 구성
  Widget _buildPasswordField() {
    return KTTextField(
      controller: _passwordController,
      label: '비밀번호',
      hint: '비밀번호를 입력하세요',
      prefixIcon: Icons.lock_outlined,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: KTColors.secondaryText,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  /// EN: Build forgot password link
  /// KO: 비밀번호 찾기 링크 구성
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Navigate to forgot password screen
          // TODO: 비밀번호 찾기 화면으로 이동
        },
        child: Text(
          '비밀번호를 잊으셨나요?',
          style: KTTypography.labelMedium.copyWith(
            color: KTColors.primaryText,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  /// EN: Build login button
  /// KO: 로그인 버튼 구성
  Widget _buildLoginButton(AuthState authState) {
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return KTButton.primary(
      onPressed: isLoading ? null : _handleLogin,
      loading: isLoading,
      child: const Text('로그인'),
    );
  }

  /// EN: Build divider with "OR" text
  /// KO: "또는" 텍스트가 있는 구분선 구성
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: KTColors.borderColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KTSpacing.md),
          child: Text(
            '또는',
            style: KTTypography.labelMedium.copyWith(
              color: KTColors.secondaryText,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: KTColors.borderColor),
        ),
      ],
    );
  }

  /// EN: Build register button
  /// KO: 회원가입 버튼 구성
  Widget _buildRegisterButton() {
    return KTButton.outlined(
      onPressed: () {
        Navigator.of(context).pushNamed('/register');
      },
      child: const Text('회원가입'),
    );
  }

  /// EN: Build bottom text
  /// KO: 하단 텍스트 구성
  Widget _buildBottomText() {
    return Text(
      '계정을 생성하면 서비스 약관 및 개인정보 처리방침에 동의하는 것으로 간주됩니다.',
      style: KTTypography.labelSmall.copyWith(
        color: KTColors.secondaryText,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// EN: Handle login button tap
  /// KO: 로그인 버튼 탭 처리
  void _handleLogin() {
    // EN: Clear any previous errors
    // KO: 이전 오류 지우기
    ref.read(authControllerProvider.notifier).clearError();

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );
    }
  }
}
