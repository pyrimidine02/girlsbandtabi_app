/// EN: Time-based greeting header with indigo gradient background
/// KO: 시간대별 인사말 + 인디고 그라디언트 배경 헤더
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: Greeting header that replaces the hero section.
///     Displays a time-based greeting with indigo gradient background.
///     Height: SafeArea.top + kToolbarHeight + 130px (~230-270px)
/// KO: 히어로 섹션을 대체하는 인사말 헤더.
///     시간대별 인사말을 인디고 그라디언트 배경에 표시합니다.
///     높이: SafeArea.top + kToolbarHeight + 130px (~230-270px)
class GBTGreetingHeader extends StatelessWidget {
  const GBTGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = _getGreeting();
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: topPadding + kToolbarHeight + 130,
      decoration: BoxDecoration(
        gradient: isDark
            ? GBTColors.darkGreetingGradient
            : GBTColors.greetingGradient,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          GBTSpacing.pageHorizontal,
          topPadding + kToolbarHeight + GBTSpacing.md,
          GBTSpacing.pageHorizontal,
          GBTSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              greeting.title,
              style: GBTTypography.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            Text(
              greeting.subtitle,
              style: GBTTypography.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EN: Returns greeting based on current hour
  /// KO: 현재 시간에 따른 인사말 반환
  static _Greeting _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return const _Greeting(title: '좋은 아침이에요', subtitle: '오늘은 어떤 성지를 방문할까요?');
    } else if (hour >= 12 && hour < 18) {
      return const _Greeting(title: '좋은 오후예요', subtitle: '새로운 장소를 발견해 보세요');
    } else if (hour >= 18) {
      return const _Greeting(title: '좋은 저녁이에요', subtitle: '오늘의 라이브를 확인해 보세요');
    } else {
      return const _Greeting(title: '아직 깨어 계시네요', subtitle: '밤에도 음악은 계속됩니다');
    }
  }
}

class _Greeting {
  const _Greeting({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}
