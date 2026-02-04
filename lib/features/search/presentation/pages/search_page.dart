/// EN: Search page with unified search across all content.
/// KO: 모든 콘텐츠를 통합 검색하는 검색 페이지.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/search_controller.dart';
import '../../domain/entities/search_entities.dart';

/// EN: Search page widget.
/// KO: 검색 페이지 위젯.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery});

  /// EN: Initial search query from deep link.
  /// KO: 딥링크에서 전달받은 초기 검색어.
  final String? initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _query = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchControllerProvider.notifier).search(_query);
      });
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(searchControllerProvider.notifier).search('');
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchControllerProvider.notifier).search(value);
    });
  }

  Future<void> _onSubmit(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await ref.read(searchHistoryControllerProvider.notifier).addSearch(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryControllerProvider);
    final resultsState = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '장소, 이벤트, 밴드 검색...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
            ),
          ),
          onChanged: _onQueryChanged,
          onSubmitted: _onSubmit,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _RecentSearches(
              items: history,
              onSelect: (value) {
                _searchController.text = value;
                _onQueryChanged(value);
                _onSubmit(value);
              },
              onRemove: (value) => ref
                  .read(searchHistoryControllerProvider.notifier)
                  .removeSearch(value),
              onClear: () =>
                  ref.read(searchHistoryControllerProvider.notifier).clear(),
            )
          : _SearchResults(
              query: _query,
              state: resultsState,
              onRetry: () => ref
                  .read(searchControllerProvider.notifier)
                  .search(_query, forceRefresh: true),
            ),
    );
  }
}

/// EN: Recent searches widget.
/// KO: 최근 검색 위젯.
class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.items,
    required this.onSelect,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 검색',
              style: GBTTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('전체 삭제')),
          ],
        ),
        const SizedBox(height: GBTSpacing.sm),
        if (items.isEmpty)
          Text(
            '최근 검색어가 없습니다.',
            style: GBTTypography.bodySmall.copyWith(
              color: GBTColors.textSecondary,
            ),
          )
        else
          ...items.map(
            (item) => ListTile(
              leading: Icon(Icons.history, color: GBTColors.textTertiary),
              title: Text(item),
              trailing: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: GBTColors.textTertiary,
                ),
                onPressed: () => onRemove(item),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () => onSelect(item),
            ),
          ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '인기 검색어',
          style: GBTTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: GBTSpacing.md),
        Wrap(
          spacing: GBTSpacing.sm,
          runSpacing: GBTSpacing.sm,
          children: ['도쿄', '라이브', '2026', '신곡', '콘서트', '앨범']
              .map(
                (tag) => ActionChip(
                  label: Text(tag),
                  onPressed: () => onSelect(tag),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// EN: Search results widget.
/// KO: 검색 결과 위젯.
class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.state,
    required this.onRetry,
  });

  final String query;
  final AsyncValue<List<SearchItem>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: '전체'),
              Tab(text: '장소'),
              Tab(text: '이벤트'),
              Tab(text: '뉴스'),
            ],
          ),
          Expanded(
            child: state.when(
              loading: () => ListView(
                padding: GBTSpacing.paddingPage,
                children: const [
                  SizedBox(height: GBTSpacing.lg),
                  GBTLoading(message: '검색 결과를 불러오는 중...'),
                ],
              ),
              error: (error, _) {
                final message = error is Failure
                    ? error.userMessage
                    : '검색 결과를 불러오지 못했어요';
                return ListView(
                  padding: GBTSpacing.paddingPage,
                  children: [
                    const SizedBox(height: GBTSpacing.lg),
                    GBTErrorState(message: message, onRetry: onRetry),
                  ],
                );
              },
              data: (items) => TabBarView(
                children: [
                  _SearchResultList(query: query, items: items),
                  _SearchResultList(
                    query: query,
                    items: _filterByType(items, SearchItemType.place),
                  ),
                  _SearchResultList(
                    query: query,
                    items: _filterByType(items, SearchItemType.liveEvent),
                  ),
                  _SearchResultList(
                    query: query,
                    items: _filterByType(items, SearchItemType.news),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultList extends StatelessWidget {
  const _SearchResultList({required this.query, required this.items});

  final String query;
  final List<SearchItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        padding: GBTSpacing.paddingPage,
        children: [
          Text(
            '"$query" 검색 결과',
            style: GBTTypography.labelMedium.copyWith(
              color: GBTColors.textSecondary,
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          const GBTEmptyState(message: '검색 결과가 없습니다'),
        ],
      );
    }

    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        Text(
          '"$query" 검색 결과',
          style: GBTTypography.labelMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        const SizedBox(height: GBTSpacing.md),
        ...items.map((item) => _SearchResultItem(item: item)),
      ],
    );
  }
}

/// EN: Search result item widget.
/// KO: 검색 결과 아이템 위젯.
class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.item});

  final SearchItem item;

  @override
  Widget build(BuildContext context) {
    final typeLabel = _typeLabel(item.type);
    final color = _typeColor(item.type);

    return Card(
      margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
      child: ListTile(
        leading: _SearchLeading(
          imageUrl: item.imageUrl,
          fallbackIcon: _typeIcon(item.type),
          color: color,
        ),
        title: Text(item.title, style: GBTTypography.bodyMedium),
        subtitle: Text(
          _subtitleText(item),
          style: GBTTypography.bodySmall.copyWith(
            color: GBTColors.textTertiary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
          ),
          child: Text(
            typeLabel,
            style: GBTTypography.labelSmall.copyWith(color: color),
          ),
        ),
        onTap: () => _handleTap(context, item),
      ),
    );
  }
}

class _SearchLeading extends StatelessWidget {
  const _SearchLeading({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.color,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: Icon(fallbackIcon, color: color, size: 20),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      child: GBTImage(
        imageUrl: imageUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        semanticLabel: '검색 결과 이미지',
      ),
    );
  }
}

List<SearchItem> _filterByType(List<SearchItem> items, SearchItemType type) {
  return items.where((item) => item.type == type).toList();
}

String _typeLabel(SearchItemType type) {
  return switch (type) {
    SearchItemType.place => '장소',
    SearchItemType.liveEvent => '이벤트',
    SearchItemType.news => '뉴스',
    SearchItemType.post => '커뮤니티',
    SearchItemType.unit => '유닛',
    SearchItemType.project => '프로젝트',
    SearchItemType.unknown => '기타',
  };
}

IconData _typeIcon(SearchItemType type) {
  return switch (type) {
    SearchItemType.place => Icons.place,
    SearchItemType.liveEvent => Icons.event,
    SearchItemType.news => Icons.article,
    SearchItemType.post => Icons.forum,
    SearchItemType.unit => Icons.group,
    SearchItemType.project => Icons.folder,
    SearchItemType.unknown => Icons.search,
  };
}

Color _typeColor(SearchItemType type) {
  return switch (type) {
    SearchItemType.place => GBTColors.accentBlue,
    SearchItemType.liveEvent => GBTColors.accentPink,
    SearchItemType.news => GBTColors.accent,
    SearchItemType.post => GBTColors.secondary,
    SearchItemType.unit => GBTColors.success,
    SearchItemType.project => GBTColors.warning,
    SearchItemType.unknown => GBTColors.textSecondary,
  };
}

String _subtitleText(SearchItem item) {
  if (item.subtitle != null && item.subtitle!.isNotEmpty) {
    return item.subtitle!;
  }
  if (item.category != null && item.category!.isNotEmpty) {
    return item.category!;
  }
  if (item.dateLabel.isNotEmpty) {
    return item.dateLabel;
  }
  return '상세 정보를 확인해보세요';
}

void _handleTap(BuildContext context, SearchItem item) {
  switch (item.type) {
    case SearchItemType.place:
      context.goToPlaceDetail(item.id);
      break;
    case SearchItemType.liveEvent:
      context.goToLiveDetail(item.id);
      break;
    case SearchItemType.news:
      context.goToNewsDetail(item.id);
      break;
    case SearchItemType.post:
      context.goToPostDetail(item.id);
      break;
    case SearchItemType.unit:
    case SearchItemType.project:
    case SearchItemType.unknown:
      break;
  }
}
