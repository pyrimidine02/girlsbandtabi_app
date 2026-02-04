/// EN: Verification bottom sheet widget.
/// KO: 인증 바텀시트 위젯.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/verification_controller.dart';
import '../../domain/entities/verification_entities.dart';

class VerificationSheet extends ConsumerStatefulWidget {
  const VerificationSheet({
    super.key,
    required this.title,
    required this.description,
    required this.onVerify,
    this.onWriteReview,
  });

  final String title;
  final String description;
  final Future<Result<VerificationResult>> Function() onVerify;
  final VoidCallback? onWriteReview;

  @override
  ConsumerState<VerificationSheet> createState() => _VerificationSheetState();
}

class _VerificationSheetState extends ConsumerState<VerificationSheet> {
  bool _didAutoOpenReview = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: GBTSpacing.md,
        right: GBTSpacing.md,
        top: GBTSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + GBTSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GBTColors.border,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          Text(widget.title, style: GBTTypography.titleMedium),
          const SizedBox(height: GBTSpacing.sm),
          Text(
            widget.description,
            style: GBTTypography.bodySmall.copyWith(
              color: GBTColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GBTSpacing.lg),
          state.when(
            loading: () => const GBTLoading(message: '인증 처리 중...'),
            error: (error, _) {
              final message = error is Failure
                  ? _buildVerificationErrorMessage(error)
                  : '인증에 실패했습니다';
              return Column(
                children: [
                  Text(
                    message,
                    style: GBTTypography.bodyMedium.copyWith(
                      color: GBTColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  _PrimaryButton(
                    label: '다시 시도',
                    onPressed: () async {
                      await widget.onVerify();
                    },
                  ),
                ],
              );
            },
            data: (result) {
              if (result != null) {
                _maybeOpenReview(context);
                return Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: GBTColors.success,
                      size: 48,
                    ),
                    const SizedBox(height: GBTSpacing.sm),
                    Text(
                      result.result,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: GBTColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    if (widget.onWriteReview != null)
                      Text(
                        '후기 작성 화면으로 이동합니다',
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      _PrimaryButton(
                        label: '확인',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                );
              }

              return _PrimaryButton(
                label: '인증 시작',
                onPressed: () async {
                  ref.read(verificationControllerProvider.notifier).reset();
                  await widget.onVerify();
                },
              );
            },
          ),
          const SizedBox(height: GBTSpacing.lg),
        ],
      ),
    );
  }

  void _maybeOpenReview(BuildContext context) {
    if (_didAutoOpenReview || widget.onWriteReview == null) {
      return;
    }
    _didAutoOpenReview = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onWriteReview?.call();
    });
  }
}

String _buildVerificationErrorMessage(Failure error) {
  final rawMessage = error.message.trim();
  final shouldUseRaw = error is ValidationFailure &&
      rawMessage.isNotEmpty &&
      rawMessage != 'Bad request';
  final baseMessage = shouldUseRaw ? rawMessage : error.userMessage;
  final localizedMessage = _localizeVerificationMessage(baseMessage);
  return localizedMessage;
}

String _localizeVerificationMessage(String message) {
  const translations = {
    'Too far from place': '현재 위치가 장소에서 너무 멀어요',
  };
  return translations[message] ?? message;
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
