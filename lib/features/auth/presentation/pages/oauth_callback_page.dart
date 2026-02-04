/// EN: OAuth callback handler page.
/// KO: OAuth 콜백 처리 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/auth_controller.dart';
import '../../domain/entities/oauth_provider.dart';

/// EN: OAuth callback page that exchanges code for tokens.
/// KO: 인가 코드를 토큰으로 교환하는 OAuth 콜백 페이지.
class OAuthCallbackPage extends ConsumerStatefulWidget {
  const OAuthCallbackPage({
    super.key,
    required this.providerId,
    required this.code,
    this.stateParam,
  });

  final String providerId;
  final String code;
  final String? stateParam;

  @override
  ConsumerState<OAuthCallbackPage> createState() => _OAuthCallbackPageState();
}

class _OAuthCallbackPageState extends ConsumerState<OAuthCallbackPage> {
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _exchangeCode();
  }

  Future<void> _exchangeCode() async {
    final provider = OAuthProvider.fromId(widget.providerId);
    if (provider == null) {
      setState(() {
        _failure = const ValidationFailure(
          'Unknown OAuth provider',
          code: 'unknown_provider',
        );
      });
      return;
    }

    if (widget.code.isEmpty) {
      setState(() {
        _failure = const ValidationFailure(
          'OAuth code missing',
          code: 'missing_code',
        );
      });
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final result = await controller.completeOAuthLogin(
      provider: provider,
      code: widget.code,
      stateParam: widget.stateParam,
    );

    if (!mounted) return;

    if (result is Err<void>) {
      setState(() {
        _failure = result.failure;
      });
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_failure != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('로그인 실패')),
        body: Padding(
          padding: GBTSpacing.paddingPage,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _failure!.userMessage,
                textAlign: TextAlign.center,
                style: GBTTypography.bodyMedium,
              ),
              const SizedBox(height: GBTSpacing.lg),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('로그인으로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: GBTLoading(message: '로그인 처리 중...')),
    );
  }
}
