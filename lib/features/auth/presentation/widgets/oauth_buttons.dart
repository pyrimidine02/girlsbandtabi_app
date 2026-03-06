/// EN: OAuth social login buttons section with official brand guidelines.
/// KO: 공식 브랜드 가이드라인을 반영한 OAuth 소셜 로그인 버튼 섹션.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';

/// EN: OAuth buttons group with official brand styling.
/// KO: 공식 브랜드 스타일이 적용된 OAuth 버튼 그룹.
class OAuthButtonsSection extends ConsumerWidget {
  const OAuthButtonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
              child: Text(
                context.l10n(ko: '소셜 로그인', en: 'Social login', ja: 'ソーシャルログイン'),
                style: GBTTypography.labelMedium.copyWith(
                  color: GBTColors.textTertiary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: GBTSpacing.md),
        _GoogleSignInButton(onPressed: () => _showInfo(context)),
        const SizedBox(height: GBTSpacing.sm),
        _AppleSignInButton(onPressed: () => _showInfo(context)),
        const SizedBox(height: GBTSpacing.sm),
        _XSignInButton(onPressed: () => _showInfo(context)),
        const SizedBox(height: GBTSpacing.sm),
        Text(
          context.l10n(
            ko: '소셜 로그인은 준비 중입니다.',
            en: 'Social login is coming soon.',
            ja: 'ソーシャルログインは準備中です。',
          ),
          textAlign: TextAlign.center,
          style: GBTTypography.bodySmall.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '소셜 로그인은 준비 중입니다',
            en: 'Social login is coming soon',
            ja: 'ソーシャルログインは準備中です',
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Google Sign-In Button
// KO: Google 로그인 버튼
// ========================================

/// EN: Google sign-in button following official brand guidelines.
/// KO: 공식 브랜드 가이드라인을 따르는 Google 로그인 버튼.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF131314) : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF8E918F)
        : const Color(0xFF747775);
    final textColor = isDark
        ? const Color(0xFFE3E3E3)
        : const Color(0xFF1F1F1F);

    return Semantics(
      button: true,
      label: context.l10n(
        ko: 'Google로 계속하기',
        en: 'Continue with Google',
        ja: 'Googleで続行',
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          child: Container(
            height: GBTSpacing.xxl,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // EN: Multi-color Google "G" logo (required by brand)
                // KO: 멀티컬러 Google "G" 로고 (브랜드 필수)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(painter: const _GoogleLogoPainter()),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n(
                    ko: 'Google로 계속하기',
                    en: 'Continue with Google',
                    ja: 'Googleで続行',
                  ),
                  style: GBTTypography.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Apple Sign-In Button
// KO: Apple 로그인 버튼
// ========================================

/// EN: Apple sign-in button following official brand guidelines.
/// KO: 공식 브랜드 가이드라인을 따르는 Apple 로그인 버튼.
class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EN: Apple: black filled (light) / white filled (dark)
    // KO: Apple: 검정 채움 (라이트) / 흰색 채움 (다크)
    final bgColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.black : Colors.white;

    return Semantics(
      button: true,
      label: context.l10n(
        ko: 'Apple로 로그인',
        en: 'Sign in with Apple',
        ja: 'Appleでログイン',
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          child: SizedBox(
            height: GBTSpacing.xxl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, color: textColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  context.l10n(
                    ko: 'Apple로 로그인',
                    en: 'Sign in with Apple',
                    ja: 'Appleでログイン',
                  ),
                  style: GBTTypography.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: X (Twitter) Sign-In Button
// KO: X (Twitter) 로그인 버튼
// ========================================

/// EN: X sign-in button following official brand guidelines.
/// KO: 공식 브랜드 가이드라인을 따르는 X 로그인 버튼.
class _XSignInButton extends StatelessWidget {
  const _XSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EN: X: black filled (light) / white filled (dark)
    // KO: X: 검정 채움 (라이트) / 흰색 채움 (다크)
    final bgColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.black : Colors.white;

    return Semantics(
      button: true,
      label: context.l10n(ko: 'X로 로그인', en: 'Sign in with X', ja: 'Xでログイン'),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          child: SizedBox(
            height: GBTSpacing.xxl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // EN: X logo painted via CustomPainter (black/white only)
                // KO: CustomPainter로 그린 X 로고 (흑/백만 허용)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(painter: _XLogoPainter(color: textColor)),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n(
                    ko: 'X로 로그인',
                    en: 'Sign in with X',
                    ja: 'Xでログイン',
                  ),
                  style: GBTTypography.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Custom Painters
// KO: 커스텀 페인터
// ========================================

/// EN: Paints the multi-color Google "G" logo (4 arcs).
/// KO: 멀티컬러 Google "G" 로고를 그립니다 (4개 아크).
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.7);

    // EN: Blue arc (right portion, 315° to 45°)
    // KO: 파란색 아크 (오른쪽, 315°~45°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, _degToRad(-45), _degToRad(90), false, paint);

    // EN: Green arc (bottom-right, 45° to 135°)
    // KO: 초록색 아크 (우하단, 45°~135°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, _degToRad(45), _degToRad(90), false, paint);

    // EN: Yellow arc (bottom-left, 135° to 225°)
    // KO: 노란색 아크 (좌하단, 135°~225°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, _degToRad(135), _degToRad(90), false, paint);

    // EN: Red arc (top-left, 225° to 315°)
    // KO: 빨간색 아크 (좌상단, 225°~315°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, _degToRad(225), _degToRad(90), false, paint);

    // EN: Horizontal bar of the "G" (blue)
    // KO: "G"의 가로 바 (파란색)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barLeft = center.dx;
    final barTop = center.dy - strokeWidth / 2;
    canvas.drawRect(
      Rect.fromLTWH(barLeft, barTop, radius * 0.7, strokeWidth),
      barPaint,
    );
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}

/// EN: Paints the X (Twitter) logo — two diagonal lines forming an "X".
/// KO: X (Twitter) 로고를 그립니다 — "X"를 이루는 두 대각선.
class _XLogoPainter extends CustomPainter {
  const _XLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    // EN: Top-left to bottom-right diagonal
    // KO: 좌상단에서 우하단 대각선
    final margin = size.width * 0.15;
    canvas.drawLine(
      Offset(margin, margin),
      Offset(size.width - margin, size.height - margin),
      paint,
    );

    // EN: Top-right to bottom-left diagonal
    // KO: 우상단에서 좌하단 대각선
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(margin, size.height - margin),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _XLogoPainter oldDelegate) =>
      color != oldDelegate.color;
}
