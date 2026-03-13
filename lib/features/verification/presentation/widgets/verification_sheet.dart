/// EN: Verification bottom sheet widget.
/// KO: 인증 바텀시트 위젯.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/accessibility/a11y_wrapper.dart';
import '../../../../core/constants/legal_policy_constants.dart';
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
  bool _agreedLocationNotice = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationControllerProvider);
    final locationTerms = LegalPolicyConstants.byType(
      LegalPolicyType.locationTerms,
    );

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
              color: Theme.of(context).brightness == Brightness.dark
                  ? GBTColors.darkBorder
                  : GBTColors.border,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          Text(widget.title, style: GBTTypography.titleMedium),
          const SizedBox(height: GBTSpacing.sm),
          Text(
            widget.description,
            style: GBTTypography.bodySmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GBTSpacing.md),
          _LocationNoticeCard(
            agreed: _agreedLocationNotice,
            versionLabel: locationTerms.version,
            onChanged: (value) {
              setState(() => _agreedLocationNotice = value);
            },
          ),
          const SizedBox(height: GBTSpacing.lg),
          state.when(
            loading: () => const GBTLoading(message: '인증 처리 중...'),
            error: (error, _) {
              final message = error is Failure
                  ? _buildVerificationErrorMessage(error)
                  : '인증에 실패했습니다';

              // EN: Announce error to screen reader
              // KO: 스크린 리더에 에러 공지
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  A11yAnnouncer.announceError(context, message);
                }
              });

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
                    onPressed: _handleStartVerification,
                  ),
                ],
              );
            },
            data: (result) {
              if (result != null) {
                // EN: Announce success to screen reader
                // KO: 스크린 리더에 성공 공지
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    A11yAnnouncer.announceSuccess(context, '장소 인증이 완료되었습니다');
                  }
                });

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
                    if (widget.onWriteReview != null) ...[
                      _PrimaryButton(
                        label: '후기 작성',
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onWriteReview?.call();
                        },
                      ),
                      const SizedBox(height: GBTSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('건너뛰기'),
                        ),
                      ),
                    ] else
                      _PrimaryButton(
                        label: '확인',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                );
              }

              return _PrimaryButton(
                label: _agreedLocationNotice ? '동의하고 인증 시작' : '사전 고지 동의 필요',
                onPressed: _agreedLocationNotice
                    ? _handleStartVerification
                    : _showConsentRequired,
              );
            },
          ),
          const SizedBox(height: GBTSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _handleStartVerification() async {
    if (!_agreedLocationNotice) {
      _showConsentRequired();
      return;
    }
    ref.read(verificationControllerProvider.notifier).reset();
    await widget.onVerify();
  }

  void _showConsentRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('위치 수집 사전 고지에 동의해야 인증을 시작할 수 있어요')),
    );
  }

}

class _LocationNoticeCard extends StatelessWidget {
  const _LocationNoticeCard({
    required this.agreed,
    required this.versionLabel,
    required this.onChanged,
  });

  final bool agreed;
  final String versionLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surface,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: isDark ? GBTColors.darkBorderSubtle : GBTColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위치 수집 사전 고지',
            style: GBTTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
            ),
          ),
          const SizedBox(height: GBTSpacing.xxs),
          Text(
            '목적: 방문 인증\n보유기간: 관련 법령 및 운영정책 범위 내\n철회: 설정 > 약관/정책에서 확인 후 철회 요청',
            style: GBTTypography.labelSmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: GBTSpacing.xxs),
          Text(
            '위치정보 이용약관 $versionLabel',
            style: GBTTypography.labelSmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
          ),
          const SizedBox(height: GBTSpacing.xxs),
          InkWell(
            onTap: () => onChanged(!agreed),
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            child: Row(
              children: [
                Checkbox(
                  value: agreed,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                Expanded(
                  child: Text(
                    '위치 수집/이용 고지 내용을 확인했고 동의합니다 (필수)',
                    style: GBTTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _buildVerificationErrorMessage(Failure error) {
  final rawMessage = error.message.trim();
  final mapped = _normalizeVerificationMessage(rawMessage, error.code);
  if (mapped != null) return mapped;

  if (error is ValidationFailure || error is UnknownFailure) {
    return '인증에 실패했습니다';
  }

  final localizedMessage = _localizeVerificationMessage(error.userMessage);
  if (_containsLocationLeak(localizedMessage)) {
    return '현재 위치가 장소에서 너무 멀어요';
  }
  return localizedMessage;
}

String _localizeVerificationMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('too far')) {
    return '현재 위치가 장소에서 너무 멀어요';
  }
  return message;
}

String? _normalizeVerificationMessage(String message, String? code) {
  final raw = message.trim();
  if (raw.isEmpty) return null;
  final codeLower = code?.toLowerCase();
  const tooFarCodes = {
    'too_far',
    'too_far_from_place',
    'distance_too_far',
    'out_of_range',
  };
  if (codeLower != null && tooFarCodes.contains(codeLower)) {
    return '현재 위치가 장소에서 너무 멀어요';
  }
  final lower = raw.toLowerCase();
  if (lower.contains('duplicate verification request') ||
      lower.contains('duplicate request')) {
    return '이미 인증 요청이 처리 중이에요. 잠시 후 다시 시도해 주세요';
  }
  if (lower.contains('simulated locations are not allowed') ||
      lower.contains('simulated location') ||
      lower.contains('mocked location')) {
    return '모의 위치는 사용할 수 없어요. 실제 위치로 시도해 주세요';
  }
  if (lower.contains('invalid location token')) {
    return '인증 정보가 유효하지 않아요. 다시 시도해 주세요';
  }
  if (lower.contains('too far')) {
    return '현재 위치가 장소에서 너무 멀어요';
  }
  if (_containsLocationLeak(raw)) {
    return '현재 위치가 장소에서 너무 멀어요';
  }
  return null;
}

bool _containsLocationLeak(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('latitude') || lower.contains('longitude')) {
    return true;
  }
  if (lower.contains('distance')) {
    return true;
  }
  final distancePattern = RegExp(
    r'\b\d+(\.\d+)?\s*(m|meter|meters)\b',
    caseSensitive: false,
  );
  if (distancePattern.hasMatch(message)) return true;
  final coordinatePattern = RegExp(r'-?\d{1,3}\.\d{4,}');
  return coordinatePattern.hasMatch(message);
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
