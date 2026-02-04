/// EN: Home page with summary content and quick access
/// KO: 요약 콘텐츠와 빠른 접근을 제공하는 홈 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/cards/gbt_event_card.dart';
import '../../../../core/widgets/cards/gbt_place_card.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/home_controller.dart';
import '../../domain/entities/home_summary.dart';

/// EN: Home page widget
/// KO: 홈 페이지 위젯
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Girls Band Tabi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: '검색',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
            tooltip: '알림',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeControllerProvider.notifier).load(forceRefresh: true),
        child: state.when(
          loading: () => _buildLoading(),
          error: (error, _) => _buildError(error),
          data: (summary) => _buildContent(summary),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: GBTSpacing.paddingPage,
      children: const [
        _WelcomeSection(),
        SizedBox(height: GBTSpacing.md),
        ProjectSelector(),
        SizedBox(height: GBTSpacing.lg),
        GBTLoading(message: '홈 정보를 불러오는 중...'),
      ],
    );
  }

  Widget _buildError(Object error) {
    final message = error is Failure ? error.userMessage : '홈 정보를 불러오지 못했어요';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: GBTSpacing.paddingPage,
      children: [
        const SizedBox(height: GBTSpacing.xl),
        GBTErrorState(
          message: message,
          onRetry: () => ref
              .read(homeControllerProvider.notifier)
              .load(forceRefresh: true),
        ),
      ],
    );
  }

  Widget _buildContent(HomeSummary summary) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const _WelcomeSection(),
        const SizedBox(height: GBTSpacing.md),
        const ProjectSelector(),
        const SizedBox(height: GBTSpacing.lg),
        const _QuickAccessSection(),
        const SizedBox(height: GBTSpacing.lg),
        if (summary.isEmpty) const GBTEmptyState(message: '표시할 홈 콘텐츠가 없습니다'),
        if (summary.recommendedPlaces.isNotEmpty) ...[
          _SectionHeader(
            title: '추천 장소',
            onSeeAll: () => context.go('/places'),
          ),
          const SizedBox(height: GBTSpacing.sm),
          ...summary.recommendedPlaces
              .take(3)
              .map(
                (place) => Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                  child: GBTPlaceCardHorizontal(
                    name: place.name,
                    location: place.location,
                    imageUrl: place.imageUrl,
                    distance: place.distanceLabel,
                    isVerified: place.isVerified,
                    isFavorite: place.isFavorite,
                    onTap: () => context.goToPlaceDetail(place.id),
                  ),
                ),
              ),
          const SizedBox(height: GBTSpacing.lg),
        ],
        if (summary.trendingLiveEvents.isNotEmpty) ...[
          _SectionHeader(
            title: '트렌딩 라이브',
            onSeeAll: () => context.go('/live'),
          ),
          const SizedBox(height: GBTSpacing.sm),
          ...summary.trendingLiveEvents
              .take(2)
              .map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                  child: GBTEventCard(
                    title: event.title,
                    subtitle: event.artistName,
                    meta: event.venue,
                    date: event.dateLabel,
                    posterUrl: event.posterUrl,
                    isLive: event.isLive,
                    onTap: () => context.goToLiveDetail(event.id),
                  ),
                ),
              ),
          const SizedBox(height: GBTSpacing.lg),
        ],
        if (summary.latestNews.isNotEmpty) ...[
          _SectionHeader(title: '최신 소식', onSeeAll: () => context.go('/feed')),
          const SizedBox(height: GBTSpacing.sm),
          ...summary.latestNews
              .take(3)
              .map((news) => _NewsListTile(item: news)),
          const SizedBox(height: GBTSpacing.xl),
        ],
      ],
    );
  }
}

/// EN: Welcome section widget
/// KO: 환영 섹션 위젯
class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GBTSpacing.paddingMd,
      decoration: BoxDecoration(
        gradient: GBTColors.accentGradient,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '성지순례를 시작하세요!',
            style: GBTTypography.titleLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(
            '좋아하는 밴드의 발자취를 따라가보세요',
            style: GBTTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Quick access section widget
/// KO: 빠른 접근 섹션 위젯
class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.place,
            label: '근처 장소',
            color: GBTColors.accentBlue,
            onTap: () => context.go('/places'),
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.calendar_today,
            label: '이벤트',
            color: GBTColors.accentPink,
            onTap: () => context.go('/live'),
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _QuickAccessCard(
            icon: Icons.favorite,
            label: '즐겨찾기',
            color: GBTColors.error,
            onTap: () => context.push('/favorites'),
          ),
        ),
      ],
    );
  }
}

/// EN: Quick access card widget
/// KO: 빠른 접근 카드 위젯
class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Padding(
          padding: GBTSpacing.paddingMd,
          child: Column(
            children: [
              Icon(icon, color: color, size: GBTSpacing.iconLg),
              const SizedBox(height: GBTSpacing.xs),
              Text(
                label,
                style: GBTTypography.labelMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Section header widget
/// KO: 섹션 헤더 위젯
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GBTTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('전체보기')),
      ],
    );
  }
}

/// EN: Placeholder list widget for development
/// KO: 개발용 플레이스홀더 리스트 위젯
class _NewsListTile extends StatelessWidget {
  const _NewsListTile({required this.item});

  final HomeNewsItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
      child: ListTile(
        onTap: () => context.goToNewsDetail(item.id),
        leading: item.imageUrl != null
            ? GBTImage(
                imageUrl: item.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                semanticLabel: item.title,
                useShimmer: false,
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: GBTColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                ),
                child: const Icon(Icons.article_outlined),
              ),
        title: Text(
          item.title,
          style: GBTTypography.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: item.summary != null
            ? Text(
                item.summary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GBTTypography.bodySmall.copyWith(
                  color: GBTColors.textSecondary,
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
