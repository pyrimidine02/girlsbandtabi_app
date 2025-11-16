import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/favorite_model.dart';
import '../../models/live_event_model.dart';
import '../../providers/content_filter_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/live_event_provider.dart';
import '../../providers/project_band_providers.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/project_band_sheet.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: LiveTab.values.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      ref.read(liveTabProvider.notifier).state = LiveTab.values[_tabController.index];
      ref.invalidate(liveEventsProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tab = ref.watch(liveTabProvider);
    if (_tabController.index != tab.index) {
      _tabController.index = tab.index;
    }

    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final selectedBandName = ref.watch(selectedBandNameProvider);
    final projectsAsync = ref.watch(projectsProvider);

    final liveEventsAsync = ref.watch(liveEventsProvider);

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
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.secondary.withOpacity(0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlowPill(
                        label: selectedProjectName ?? '전체 프로젝트',
                        leading: const Icon(Icons.layers_outlined, size: 16),
                        trailing:
                            const Icon(Icons.chevron_right_rounded, size: 18),
                        onTap: () => showProjectBandSelector(
                          context,
                          ref,
                          onApplied: () => ref.invalidate(liveEventsProvider),
                        ),
                        backgroundColor:
                            theme.colorScheme.surface.withOpacity(0.72),
                      ),
                      if (selectedBandName != null) ...[
                        const SizedBox(height: 12),
                        FlowPill(
                          label: selectedBandName ?? '전체 밴드',
                          leading:
                              const Icon(Icons.music_note_outlined, size: 16),
                          backgroundColor:
                              theme.colorScheme.secondary.withOpacity(0.18),
                          onTap: () => showProjectBandSelector(
                            context,
                            ref,
                            onApplied: () =>
                                ref.invalidate(liveEventsProvider),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        '라이브 일정',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '행복한 현장의 공기를 그대로 느껴보세요.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      projectsAsync.when(
                        data: (projects) => Text(
                          '${projects.length}개의 프로젝트와 연결되어 있습니다.',
                          style: theme.textTheme.labelMedium,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => Text(
                          '프로젝트 정보를 불러오지 못했습니다.',
                          style: theme.textTheme.labelMedium,
                        ),
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
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    indicator: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tabs: const [
                      Tab(text: '예정'),
                      Tab(text: '진행 중'),
                      Tab(text: '지난 라이브'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  color: theme.colorScheme.primary,
                  onRefresh: () async {
                    ref.invalidate(liveEventsProvider);
                    await ref.read(liveEventsProvider.future);
                  },
                  child: liveEventsAsync.when(
                    data: (page) {
                      if (page.items.isEmpty) {
                        return const Center(
                          child: _EmptyState(
                            message: '해당 분류의 라이브가 없습니다.',
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemBuilder: (context, index) {
                          final live = page.items[index];
                          return _LiveEventCard(live: live);
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemCount: page.items.length,
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => _PilgrimageError(
                      message: '라이브 정보를 불러오지 못했습니다.\n$e',
                      onRetry: () => ref.invalidate(liveEventsProvider),
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
}

class _LiveEventCard extends ConsumerWidget {
  const _LiveEventCard({required this.live});

  final LiveEvent live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteKey = FavoriteKey(FavoriteEntityType.live, live.id);
    final isFavorite = ref.watch(isFavoriteProvider(favoriteKey));
    final favoriteController = ref.watch(favoriteControllerProvider);

    final statusColor = _statusColor(theme, live.realtimeStatus);
    final statusLabel = _statusLabel(live.realtimeStatus);

    return FlowCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FlowPill(
                label: statusLabel,
                leading: const Icon(Icons.bolt_rounded, size: 16),
                backgroundColor: statusColor.withOpacity(0.16),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  final toggled = await favoriteController.toggle(
                    FavoriteEntityType.live,
                    live.id,
                  );
                  final message = toggled
                      ? '라이브를 즐겨찾기에 추가했습니다.'
                      : '즐겨찾기에서 제거했습니다.';
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            live.title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            _formatLiveDate(live.startTime),
            style: theme.textTheme.bodyMedium,
          ),
          if (live.placeId != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  '장소 ID: ${live.placeId}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () => context.push('/live/${live.id}'),
                child: const Text('상세 보기'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => context.push('/places/${live.placeId ?? ''}'),
                child: const Text('관련 장소'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(ThemeData theme, LiveTab status) {
    switch (status) {
      case 'ONGOING':
        return theme.colorScheme.secondary;
      case 'COMPLETED':
        return theme.colorScheme.onSurface.withOpacity(0.5);
      case 'UPCOMING':
      default:
        return theme.colorScheme.primary;
    }
  }

  String _statusLabel(LiveTab status) {
    switch (status) {
      case 'ONGOING':
        return '진행 중';
      case 'COMPLETED':
        return '종료';
      case 'UPCOMING':
      default:
        return '예정';
    }
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
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
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

class _PilgrimageError extends StatelessWidget {
  const _PilgrimageError({required this.message, required this.onRetry});

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

String _formatLiveDate(DateTime? dateTime) {
  if (dateTime == null) return '일정 미정';
  return '${dateTime.month}월 ${dateTime.day}일 · ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
