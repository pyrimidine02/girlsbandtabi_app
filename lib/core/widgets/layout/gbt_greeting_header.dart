/// EN: Time-based greeting header with indigo gradient background
/// KO: 시간대별 인사말 + 인디고 그라디언트 배경 헤더
library;

import 'package:flutter/material.dart';

import '../../localization/locale_text.dart';
import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';
import '../common/gbt_image.dart';

/// EN: Greeting header that replaces the hero section.
///     Displays a time-based greeting with indigo gradient background.
///     Height: SafeArea.top + kToolbarHeight + 130px (~230-270px)
/// KO: 히어로 섹션을 대체하는 인사말 헤더.
///     시간대별 인사말을 인디고 그라디언트 배경에 표시합니다.
///     높이: SafeArea.top + kToolbarHeight + 130px (~230-270px)
class GBTGreetingHeader extends StatelessWidget {
  const GBTGreetingHeader({
    super.key,
    this.backgroundImageUrl,
    this.featuredTitle,
    this.featuredDate,
    this.featuredPosterUrl,
    this.onFeaturedTap,
  });

  final String? backgroundImageUrl;
  final String? featuredTitle;
  final String? featuredDate;
  final String? featuredPosterUrl;
  final VoidCallback? onFeaturedTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = _getGreeting(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final hasBackgroundImage =
        backgroundImageUrl != null && backgroundImageUrl!.trim().isNotEmpty;
    final hasFeaturedLive =
        featuredTitle != null && featuredTitle!.trim().isNotEmpty;
    final featuredExtraHeight = hasFeaturedLive ? 56.0 : 0.0;
    final textScaleExtraHeight = ((textScale - 1.0) * 36.0).clamp(0.0, 40.0);
    final headerHeight =
        topPadding +
        kToolbarHeight +
        130 +
        featuredExtraHeight +
        textScaleExtraHeight;

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: BoxDecoration(
        gradient: isDark
            ? GBTColors.darkGreetingGradient
            : GBTColors.greetingGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasBackgroundImage)
            GBTImage(
              imageUrl: backgroundImageUrl!,
              fit: BoxFit.cover,
              useShimmer: false,
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x33000000), Color(0xB3000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: GBTSpacing.xs),
                Text(
                  greeting.subtitle,
                  style: GBTTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasFeaturedLive) ...[
                  const SizedBox(height: GBTSpacing.sm),
                  _FeaturedLiveChip(
                    title: featuredTitle!,
                    dateLabel: featuredDate,
                    posterUrl: featuredPosterUrl,
                    onTap: onFeaturedTap,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedLiveChip extends StatelessWidget {
  const _FeaturedLiveChip({
    required this.title,
    this.dateLabel,
    this.posterUrl,
    this.onTap,
  });

  final String title;
  final String? dateLabel;
  final String? posterUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPoster = posterUrl != null && posterUrl!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Ink(
          padding: const EdgeInsets.all(GBTSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
                    child: hasPoster
                        ? GBTImage(
                            imageUrl: posterUrl!,
                            fit: BoxFit.cover,
                            useShimmer: false,
                          )
                        : const ColoredBox(
                            color: Color(0x55222222),
                            child: Icon(
                              Icons.music_note_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GBTTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dateLabel != null && dateLabel!.trim().isNotEmpty)
                      Text(
                        dateLabel!,
                        style: GBTTypography.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Returns greeting based on current hour
/// KO: 현재 시간에 따른 인사말 반환
_Greeting _getGreeting(BuildContext context) {
  final hour = DateTime.now().hour;
  if (hour >= 6 && hour < 12) {
    return _Greeting(
      title: context.l10n(ko: '좋은 아침이에요', en: 'Good morning', ja: 'おはようございます'),
      subtitle: context.l10n(
        ko: '오늘은 어떤 성지를 방문할까요?',
        en: 'Which sacred place will you visit today?',
        ja: '今日はどの聖地を訪れますか？',
      ),
    );
  } else if (hour >= 12 && hour < 18) {
    return _Greeting(
      title: context.l10n(ko: '좋은 오후예요', en: 'Good afternoon', ja: 'こんにちは'),
      subtitle: context.l10n(
        ko: '새로운 장소를 발견해 보세요',
        en: 'Discover new places',
        ja: '新しい場所を見つけてみましょう',
      ),
    );
  } else if (hour >= 18) {
    return _Greeting(
      title: context.l10n(ko: '좋은 저녁이에요', en: 'Good evening', ja: 'こんばんは'),
      subtitle: context.l10n(
        ko: '오늘의 라이브를 확인해 보세요',
        en: 'Check out today\'s live events',
        ja: '今日のライブをチェックしましょう',
      ),
    );
  } else {
    return _Greeting(
      title: context.l10n(
        ko: '아직 깨어 계시네요',
        en: 'You\'re still awake',
        ja: 'まだ起きているんですね',
      ),
      subtitle: context.l10n(
        ko: '밤에도 음악은 계속됩니다',
        en: 'Music continues through the night',
        ja: '夜も音楽は続きます',
      ),
    );
  }
}

class _Greeting {
  const _Greeting({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}
