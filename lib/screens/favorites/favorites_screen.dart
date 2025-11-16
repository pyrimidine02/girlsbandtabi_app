import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/favorite_model.dart';
import '../../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  static const Map<FavoriteEntityType?, String> _filterLabels = {
    null: '전체',
    FavoriteEntityType.place: '성지',
    FavoriteEntityType.live: '라이브',
    FavoriteEntityType.news: '뉴스',
  };

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels < 200) {
      ref.read(favoritesListProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(favoritesListProvider.notifier).loadInitial();
  }

  Future<void> _removeFavorite(
    FavoriteController controller,
    FavoriteItem item,
  ) async {
    try {
      await controller.toggle(item.entityType, item.entityId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('즐겨찾기에서 제거했습니다.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('즐겨찾기 삭제 실패: $e')),
      );
    }
  }

  Widget _buildFilterBar(
    BuildContext context,
    FavoriteEntityType? selected,
    int totalCount,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '총 ${totalCount.toString()}개 즐겨찾기',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filterLabels.entries.map((entry) {
              final isSelected = selected == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (value) {
                  if (!value) return;
                  ref.read(favoriteFilterProvider.notifier).state = entry.key;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    FavoriteItem item,
    FavoriteController controller,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleFavoriteNavigation(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context, item),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _FavoriteBadge(
                          icon: _iconForType(item.entityType),
                          label: _labelForType(item.entityType),
                        ),
                        if (item.createdAt != null)
                          _FavoriteBadge(
                            icon: Icons.schedule_rounded,
                            label: _formatDate(item.createdAt!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title ?? item.entityId,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((item.subtitle ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if ((item.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined),
                tooltip: '즐겨찾기 삭제',
                onPressed: () => _removeFavorite(controller, item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, FavoriteItem item) {
    const size = 72.0;
    final theme = Theme.of(context);
    Widget placeholder() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _iconForType(item.entityType),
          color: theme.colorScheme.primary,
        ),
      );
    }

    final imageUrl = item.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder(),
      ),
    );
  }

  String _labelForType(FavoriteEntityType type) {
    return _filterLabels[type] ?? '기타';
  }

  IconData _iconForType(FavoriteEntityType type) {
    switch (type) {
      case FavoriteEntityType.place:
        return Icons.place_rounded;
      case FavoriteEntityType.live:
        return Icons.event_available_rounded;
      case FavoriteEntityType.news:
        return Icons.article_rounded;
      case FavoriteEntityType.unknown:
        return Icons.bookmark_border_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(favoritesBootstrapProvider);
    final filter = ref.watch(favoriteFilterProvider);
    final state = ref.watch(favoritesListProvider);
    final controller = ref.read(favoriteControllerProvider);
    final theme = Theme.of(context);

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: _buildFilterBar(context, filter, state.total),
      ),
    ];

    if (state.isLoading && state.items.isEmpty) {
      slivers.add(
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (state.error != null && state.items.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '즐겨찾기를 불러오지 못했습니다.',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error ?? '알 수 없는 오류가 발생했습니다.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => ref
                        .read(favoritesListProvider.notifier)
                        .loadInitial(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (state.items.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_add_outlined,
                    color: theme.colorScheme.secondary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '즐겨찾기한 항목이 없습니다.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '관심있는 라이브, 성지, 뉴스를 즐겨찾기에 추가하고 빠르게 찾아보세요.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = state.items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == state.items.length - 1 ? 0 : 12,
                  ),
                  child: _buildFavoriteCard(context, item, controller),
                );
              },
              childCount: state.items.length,
            ),
          ),
        ),
      );

      if (state.isLoadingMore) {
        slivers.add(
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      }

      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 32)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          displacement: 48,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: slivers,
          ),
        ),
      ),
    );
  }
}

void _handleFavoriteNavigation(BuildContext context, FavoriteItem item) {
  switch (item.entityType) {
    case FavoriteEntityType.place:
      context.push('/places/${item.entityId}');
      return;
    case FavoriteEntityType.live:
      context.push('/live/${item.entityId}');
      return;
    case FavoriteEntityType.news:
      context.push('/news/${item.entityId}');
      return;
    case FavoriteEntityType.unknown:
      break;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('연결된 상세 화면이 없습니다.')));
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
