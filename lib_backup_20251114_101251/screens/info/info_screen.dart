import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/news_provider.dart';
import '../../models/news_model.dart';
import '../../widgets/flow_components.dart';

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: FlowCard(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.18),
                      theme.colorScheme.tertiary.withValues(alpha: 0.16),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlowPill(
                        label: 'Seamless Flow Insight',
                        leading: const Icon(Icons.auto_awesome, size: 16),
                        backgroundColor:
                            theme.colorScheme.surface.withValues(alpha: 0.72),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '밴드의 맥박을 한 곳에서',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '뉴스, 공식 정보, 커뮤니티 흐름을 놓치지 마세요.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () => context.push('/notifications'),
                              icon: const Icon(Icons.notifications_active_outlined),
                              label: const Text('알림함 열기'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.push('/favorites'),
                              icon: const Icon(Icons.favorite_border_rounded),
                              label: const Text('즐겨찾기'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FlowCard(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tabs: const [
                      Tab(text: '뉴스'),
                      Tab(text: '밴드 정보'),
                      Tab(text: '공식 채널'),
                      Tab(text: '커뮤니티'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _NewsTab(),
                    _BandInfoTab(),
                    _OfficialTab(),
                    _CommunityTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider);
    final theme = Theme.of(context);
    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        ref.invalidate(newsListProvider);
        await ref.read(newsListProvider.future);
      },
      child: newsAsync.when(
        data: (page) {
          if (page.items.isEmpty) {
            return const Center(
              child: _EmptyState(message: '표시할 뉴스가 없습니다.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemBuilder: (context, index) {
              final news = page.items[index];
              return FlowCard(
                onTap: () => context.push('/news/${news.id}'),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlowPill(
                      label: news.status == NewsStatus.draft
                          ? 'Draft'
                          : 'Published',
                      leading: const Icon(Icons.article_rounded, size: 16),
                      backgroundColor:
                          theme.colorScheme.secondary.withValues(alpha: 0.14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.body ?? '상세 내용을 확인해 보세요.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (news.publishedAt != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _formatNewsDate(news.publishedAt!),
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: page.items.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: '뉴스 정보를 불러오지 못했습니다.\n$e',
          onRetry: () => ref.invalidate(newsListProvider),
        ),
      ),
    );
  }
}

class _BandInfoTab extends StatelessWidget {
  const _BandInfoTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bands = [
      ('MyGO!!!!!', '도쿄 기반의 5인조 밴드, 감정선이 돋보이는 음악'),
      ('Ave Mujica', '신비로운 콘셉트의 프로젝트 밴드, 다층적 사운드'),
      ('CRYCHIC', '버서스 프로젝트에서 합류한 청춘 밴드'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemBuilder: (context, index) {
        final band = bands[index];
        return FlowCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                band.$1,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                band.$2,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {},
                child: const Text('프로필 보기'),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: bands.length,
    );
  }
}

class _OfficialTab extends StatelessWidget {
  const _OfficialTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channels = [
      ('공식 사이트', 'https://bang-dream.com', Icons.language_rounded),
      ('YouTube', 'BanG Dream! 채널', Icons.play_circle_outline),
      ('X (Twitter)', '@bang_dream_info', Icons.alternate_email_rounded),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return FlowCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Row(
            children: [
              Icon(channel.$3, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.$1,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.$2,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: channels.length,
    );
  }
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = [
      ('밴드덕후', '시부야 O-EAST 인증 후기', '어제 다녀왔는데 사운드가 압도적이었어요!'),
      ('MyGO!!!!!최고', '도쿄역 기타샵 꿀팁', '오차노미즈 쪽 상점 리스트 공유합니다.'),
      ('Ave 팬', '뮤지카 세트리스트 예상', '다음 라이브 예상 세트리스트 공유해요.'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemBuilder: (context, index) {
        final post = posts[index];
        return FlowCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.$1,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text(
                post.$2,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                post.$3,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('상세 보기'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: posts.length,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
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

String _formatNewsDate(DateTime dateTime) {
  return '${dateTime.month}월 ${dateTime.day}일 ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
