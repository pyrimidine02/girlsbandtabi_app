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
    final colorScheme = Theme.of(context).colorScheme;

    if (_failure != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('로그인 실패')),
        body: Center(
          child: Padding(
            padding: GBTSpacing.paddingPage,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // EN: Error icon for visual clarity
                // KO: 시각적 명확성을 위한 오류 아이콘
                Icon(
                  Icons.error_outline,
                  size: GBTSpacing.xxxl,
                  color: colorScheme.error,
                  semanticLabel: '로그인 오류',
                ),
                const SizedBox(height: GBTSpacing.md),
                Text(
                  '로그인에 실패했습니다',
                  style: GBTTypography.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GBTSpacing.sm),
                Text(
                  _failure!.userMessage,
                  textAlign: TextAlign.center,
                  style: GBTTypography.bodyMedium.copyWith(
                    // EN: Use theme-aware text color for dark mode
                    // KO: 다크 모드를 위해 테마 인식 텍스트 색상 사용
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: GBTSpacing.lg),
                Semantics(
                  button: true,
                  label: '로그인 페이지로 돌아가기',
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('로그인으로 돌아가기'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        GBTSpacing.touchTarget,
                        GBTSpacing.touchTarget,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: GBTLoading(message: '로그인 처리 중...')),
    );
  }
}
