import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/home_summary_model.dart';
import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_filter_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/project_band_providers.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/project_band_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final homeSummaryAsync = ref.watch(homeSummaryProvider);
    final summary = homeSummaryAsync.valueOrNull;
    final recommended = summary?.recommendedPlaces ?? const <HomeSummaryPlace>[];
    final trendingLive = summary?.trendingLiveEvents ?? const <HomeSummaryLive>[];
    final latestNews = summary?.latestNews ?? const <HomeSummaryNews>[];
    final stats = summary?.stats;
    final isLoading = homeSummaryAsync is AsyncLoading<HomeSummary>;
    final hasError = homeSummaryAsync.hasError;

    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final selectedBandName = ref.watch(selectedBandNameProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        heroLayer: true,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: () async {
              ref.invalidate(homeSummaryProvider);
              await ref.read(homeSummaryProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _HomeHero(
                      displayName: authState.currentUser?.displayName ?? '게스트',
                      projectLabel: selectedProjectName ?? '전체 프로젝트',
                      bandLabel: selectedBandName,
                      projectsAsync: projectsAsync,
                      onProjectTap: () => showProjectBandSelector(
                        context,
                        ref,
                        onApplied: () {
                          ref.invalidate(homeSummaryProvider);
                        },
                      ),
                      onSearchTap: () => context.push('/search'),
                      onFavoritesTap: () => context.push('/favorites'),
                    ),
                  ),
                ),
                if (stats != null || isLoading) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _StatsRow(
                        stats: stats,
                        isLoading: isLoading,
                      ),
                    ),
                  ),
                ],
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: FlowSectionHeader(
                      title: '추천 성지',
                      subtitle: '여정과 어울리는 오늘의 장소',
                      actionLabel: '전체 보기',
                      onActionTap: () => context.go('/pilgrimage'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 250,
                    child: _PlaceCarousel(
                      places: recommended,
                      isLoading: isLoading,
                      hasError: hasError,
                      onRetry: () => ref.invalidate(homeSummaryProvider),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: FlowSectionHeader(
                      title: '지금 뜨는 라이브',
                      subtitle: '열기를 놓치지 마세요',
                      actionLabel: '라이브 모두 보기',
                      onActionTap: () => context.go('/live'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: _LiveStrip(
                      liveEvents: trendingLive,
                      isLoading: isLoading,
                      hasError: hasError,
                      onRetry: () => ref.invalidate(homeSummaryProvider),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: FlowSectionHeader(
                      title: '공지 & 뉴스',
                      subtitle: '밴드의 최신 소식을 모았습니다',
                      actionLabel: '정보 탭으로 이동',
                      onActionTap: () => context.go('/info'),
                    ),
                  ),
                ),
                if (latestNews.isEmpty && !isLoading && !hasError)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _EmptyState(message: '표시할 뉴스가 없습니다.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) {
                        if (index >= latestNews.length) {
                          return const _ShimmerCard(height: 120);
                        }
                        final news = latestNews[index];
                        return _NewsArticleCard(news: news);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemCount: isLoading
                          ? (latestNews.isEmpty ? 3 : latestNews.length)
                          : latestNews.length,
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

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.displayName,
    required this.projectLabel,
    required this.projectsAsync,
    required this.onProjectTap,
    required this.onSearchTap,
    required this.onFavoritesTap,
    this.bandLabel,
  });

  final String displayName;
  final String projectLabel;
  final String? bandLabel;
  final AsyncValue<List<Project>> projectsAsync;
  final VoidCallback onProjectTap;
  final VoidCallback onSearchTap;
  final VoidCallback onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _greetingText();

    return FlowCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.18),
          theme.colorScheme.secondary.withValues(alpha: 0.15),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FlowPill(
                label: projectLabel,
                leading: const Icon(Icons.layers_outlined, size: 16),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                onTap: onProjectTap,
                backgroundColor:
                    theme.colorScheme.surface.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 8),
              projectsAsync.when(
                data: (projects) => FlowPill(
                  label: '${projects.length} 프로젝트',
                  leading: const Icon(Icons.auto_awesome, size: 16),
                  backgroundColor:
                      theme.colorScheme.surface.withValues(alpha: 0.48),
                ),
                loading: () => FlowPill(
                  label: '로드 중',
                  leading: const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  backgroundColor:
                      theme.colorScheme.surface.withValues(alpha: 0.48),
                ),
                error: (_, __) => FlowPill(
                  label: '프로젝트 로드 실패',
                  leading: const Icon(Icons.error_outline, size: 16),
                  backgroundColor: theme.colorScheme.error.withValues(alpha: 0.18),
                ),
              ),
            ],
          ),
          if (bandLabel != null) ...[
            const SizedBox(height: 12),
            FlowPill(
              label: bandLabel!,
              leading: const Icon(Icons.music_note_outlined, size: 16),
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.16),
              onTap: onProjectTap,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '$greeting, $displayName',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '여정의 흐름을 깨지 않는 Seamless Flow와 함께하세요.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '성지, 라이브, 뉴스 검색',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '⌘K',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onFavoritesTap,
                  icon: const Icon(Icons.favorite_border_rounded),
                  label: const Text('즐겨찾기'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.12),
                    foregroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/uploads/my'),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('내 업로드'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '깊은 밤에도';
    if (hour < 12) return '좋은 아침';
    if (hour < 18) return '반가워요';
    return '따뜻한 저녁';
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.isLoading});

  final HomeSummaryStats? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _StatData(
        label: '방문한 성지',
        value: stats?.visits?.toString() ?? '-',
        icon: Icons.location_on_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
      _StatData(
        label: '참석 라이브',
        value: stats?.liveEvents?.toString() ?? '-',
        icon: Icons.event_available_rounded,
        color: Theme.of(context).colorScheme.secondary,
      ),
      _StatData(
        label: '즐겨찾기',
        value: stats?.favorites?.toString() ?? '-',
        icon: Icons.favorite_rounded,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      _StatData(
        label: '읽은 뉴스',
        value: stats?.news?.toString() ?? '-',
        icon: Icons.article_rounded,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      ),
    ];

    if (isLoading && stats == null) {
      return const SizedBox(
        height: 120,
        child: Row(
          children: [
            Expanded(child: _ShimmerCard()),
            SizedBox(width: 12),
            Expanded(child: _ShimmerCard()),
            SizedBox(width: 12),
            Expanded(child: _ShimmerCard()),
          ],
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return SizedBox(
            width: 180,
            child: FlowMetricTile(
              label: metric.label,
              value: metric.value,
              icon: metric.icon,
              accentColor: metric.color,
            ),
          );
        },
      ),
    );
  }
}

class _PlaceCarousel extends StatelessWidget {
  const _PlaceCarousel({
    required this.places,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final List<HomeSummaryPlace> places;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && places.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => const SizedBox(
          width: 260,
          child: _ShimmerCard(height: 220),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: 3,
      );
    }

    if (hasError && places.isEmpty) {
      return Center(
        child: _ErrorState(
          message: '추천 성지를 불러오지 못했습니다.',
          onRetry: onRetry,
        ),
      );
    }

    if (places.isEmpty) {
      return const Center(
        child: _EmptyState(message: '표시할 추천 성지가 없습니다.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final place = places[index];
        return SizedBox(
          width: 260,
          child: _PlaceCard(place: place),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemCount: places.length,
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  final HomeSummaryPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = place.imageUrl;
    return FlowCard(
      onTap: () => context.push('/places/${place.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: imageUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.25),
                            theme.colorScheme.secondary.withValues(alpha: 0.25),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: theme.colorScheme.surface.withValues(alpha: 0.2),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surface.withValues(alpha: 0.2),
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  place.description ?? '상세 정보를 확인해보세요.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStrip extends StatelessWidget {
  const _LiveStrip({
    required this.liveEvents,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final List<HomeSummaryLive> liveEvents;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading && liveEvents.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, __) => const SizedBox(
          width: 220,
          child: _ShimmerCard(height: 140),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 3,
      );
    }

    if (hasError && liveEvents.isEmpty) {
      return Center(
        child: _ErrorState(
          message: '라이브 정보를 불러오지 못했습니다.',
          onRetry: onRetry,
        ),
      );
    }

    if (liveEvents.isEmpty) {
      return const Center(
        child: _EmptyState(message: '표시할 라이브가 없습니다.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final live = liveEvents[index];
        final date = _formatLiveDate(live.startTime);
        final banner = live.bannerUrl;
        return SizedBox(
          width: 220,
          child: FlowCard(
            onTap: () => context.push('/live/${live.id}'),
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                Container(
                  width: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          live.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                live.unitNames.isEmpty
                                    ? '밴드 정보 준비중'
                                    : live.unitNames.join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (banner != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(24),
                    ),
                    child: Image.network(
                      banner,
                      width: 70,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: theme.colorScheme.surface.withValues(alpha: 0.2),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surface.withValues(alpha: 0.2),
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemCount: liveEvents.length,
    );
  }
}

class _NewsArticleCard extends StatelessWidget {
  const _NewsArticleCard({required this.news});

  final HomeSummaryNews news;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbnail = news.thumbnailUrl;
    return FlowCard(
      onTap: () => context.push('/news/${news.id}'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                thumbnail,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 76,
                    height: 76,
                    color: theme.colorScheme.surface.withValues(alpha: 0.2),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 76,
                  height: 76,
                  color: theme.colorScheme.surface.withValues(alpha: 0.2),
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            )
          else
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.article_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  news.summary ?? '상세 내용을 확인해 보세요.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatNewsDate(news.publishedAt),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('다시 시도'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.blur_on_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.26),
          size: 40,
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({this.height = 110});

  final double height;

  @override
  Widget build(BuildContext context) {
    return FlowCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.2),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

String _formatLiveDate(DateTime? dateTime) {
  if (dateTime == null) return '일정 미정';
  return '${dateTime.month}월 ${dateTime.day}일 · ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}

String _formatNewsDate(DateTime? dateTime) {
  if (dateTime == null) return '발행일 미정';
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inDays >= 1) {
    return '${dateTime.month}월 ${dateTime.day}일 발행';
  }
  if (difference.inHours >= 1) {
    return '${difference.inHours}시간 전';
  }
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}분 전';
  }
  return '방금 전';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

