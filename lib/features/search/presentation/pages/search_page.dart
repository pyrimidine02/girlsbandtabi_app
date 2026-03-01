/// EN: Search page with unified search across all content.
/// KO: 모든 콘텐츠를 통합 검색하는 검색 페이지.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/layout/gbt_page_intro_card.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
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
  bool _scopedToCurrentProject = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _query = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(searchControllerProvider.notifier)
            .search(_query, scopedToCurrentProject: _scopedToCurrentProject);
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
      ref
          .read(searchControllerProvider.notifier)
          .search(value, scopedToCurrentProject: _scopedToCurrentProject);
    });
  }

  Future<void> _onSubmit(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    await ref.read(searchHistoryControllerProvider.notifier).addSearch(trimmed);
  }

  Future<void> _onRefresh() async {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;
    await ref
        .read(searchControllerProvider.notifier)
        .search(
          trimmed,
          forceRefresh: true,
          scopedToCurrentProject: _scopedToCurrentProject,
        );
  }

  void _toggleProjectScope(bool enabled) {
    if (_scopedToCurrentProject == enabled) return;
    setState(() => _scopedToCurrentProject = enabled);
    final trimmed = _query.trim();
    if (trimmed.isEmpty) return;
    unawaited(
      ref
          .read(searchControllerProvider.notifier)
          .search(trimmed, forceRefresh: true, scopedToCurrentProject: enabled),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryControllerProvider);
    final resultsState = ref.watch(searchControllerProvider);
    final selectedProjectKey = ref.watch(selectedProjectKeyProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final projectScopeLabel = selectedProjectKey?.isNotEmpty == true
        ? selectedProjectKey!
        : (selectedProjectId?.isNotEmpty == true ? selectedProjectId! : null);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Semantics(
          label: '검색어 입력',
          child: TextField(
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
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: '검색어 지우기',
              onPressed: () {
                _searchController.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.xs,
            ),
            child: _SearchIntroCard(query: _query),
          ),
          _SearchScopeHeader(
            scopedToCurrentProject: _scopedToCurrentProject,
            projectScopeLabel: projectScopeLabel,
            onChanged: _toggleProjectScope,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _query.isEmpty
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
                      onClear: () => ref
                          .read(searchHistoryControllerProvider.notifier)
                          .clear(),
                    )
                  : _SearchResults(
                      query: _query,
                      state: resultsState,
                      scopedToCurrentProject: _scopedToCurrentProject,
                      projectScopeLabel: projectScopeLabel,
                      onRetry: () => ref
                          .read(searchControllerProvider.notifier)
                          .search(
                            _query,
                            forceRefresh: true,
                            scopedToCurrentProject: _scopedToCurrentProject,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchScopeHeader extends StatelessWidget {
  const _SearchScopeHeader({
    required this.scopedToCurrentProject,
    required this.projectScopeLabel,
    required this.onChanged,
  });

  final bool scopedToCurrentProject;
  final String? projectScopeLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final scopeText = scopedToCurrentProject
        ? (projectScopeLabel != null
              ? '현재 프로젝트 검색: $projectScopeLabel'
              : '현재 프로젝트 검색')
        : '전체 프로젝트 검색';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.md,
        GBTSpacing.xs,
        GBTSpacing.md,
        GBTSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scopeText,
            style: GBTTypography.labelSmall.copyWith(color: secondaryColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: GBTSpacing.xs),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<bool>(value: true, label: Text('현재 프로젝트')),
              ButtonSegment<bool>(value: false, label: Text('전체 프로젝트')),
            ],
            selected: <bool>{scopedToCurrentProject},
            onSelectionChanged: (selection) {
              onChanged(selection.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                GBTTypography.labelSmall.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchIntroCard extends StatelessWidget {
  const _SearchIntroCard({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    return GBTPageIntroCard(
      icon: Icons.manage_search_rounded,
      title: '통합 검색',
      description: hasQuery
          ? '“${query.trim()}” 결과를 카테고리별로 확인하세요.'
          : '장소, 이벤트, 뉴스, 커뮤니티를 한 번에 검색하세요.',
      trailing: hasQuery ? const _ActiveSearchBadge() : null,
    );
  }
}

class _ActiveSearchBadge extends StatelessWidget {
  const _ActiveSearchBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurface : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        '검색 중',
        style: GBTTypography.labelSmall.copyWith(
          color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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
            style: GBTTypography.bodySmall.copyWith(color: secondaryColor),
          )
        else
          ...items.map(
            (item) => Semantics(
              label: '최근 검색어: $item',
              child: ListTile(
                leading: Icon(Icons.history, color: tertiaryColor),
                title: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: GBTSpacing.iconSm,
                    color: tertiaryColor,
                  ),
                  tooltip: '$item 검색어 삭제',
                  onPressed: () => onRemove(item),
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () => onSelect(item),
              ),
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
                (tag) => Semantics(
                  label: '인기 검색어: $tag',
                  child: ActionChip(
                    label: Text(tag),
                    onPressed: () => onSelect(tag),
                  ),
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
    required this.scopedToCurrentProject,
    required this.projectScopeLabel,
    required this.onRetry,
  });

  final String query;
  final AsyncValue<List<SearchItem>> state;
  final bool scopedToCurrentProject;
  final String? projectScopeLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          if (scopedToCurrentProject)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                0,
                GBTSpacing.md,
                GBTSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  projectScopeLabel != null
                      ? '$projectScopeLabel 범위 결과'
                      : '현재 프로젝트 범위 결과',
                  style: GBTTypography.labelSmall.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                ),
              ),
            ),
          const GBTSegmentedTabBar(
            margin: EdgeInsets.symmetric(horizontal: GBTSpacing.md),
            isScrollable: true,
            tabs: [
              Tab(text: '전체'),
              Tab(text: '장소'),
              Tab(text: '이벤트'),
              Tab(text: '뉴스'),
            ],
          ),
          Expanded(
            child: state.when(
              loading: () => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                  physics: const AlwaysScrollableScrollPhysics(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: GBTSpacing.paddingPage,
        children: [
          Text(
            '"$query" 검색 결과',
            style: GBTTypography.labelMedium.copyWith(color: secondaryColor),
          ),
          const SizedBox(height: GBTSpacing.md),
          const GBTEmptyState(
            icon: Icons.search_off,
            message: '검색 결과가 없습니다.\n다른 키워드로 검색해보세요.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: GBTSpacing.paddingPage,
      children: [
        Text(
          '"$query" 검색 결과',
          style: GBTTypography.labelMedium.copyWith(color: secondaryColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeLabel = _typeLabel(item.type);
    final color = _typeColor(item.type, isDark: isDark);

    return Semantics(
      label: '$typeLabel: ${item.title}',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
        child: ListTile(
          leading: _SearchLeading(
            imageUrl: item.imageUrl,
            fallbackIcon: _typeIcon(item.type),
            color: color,
          ),
          title: Text(
            item.title,
            style: GBTTypography.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _subtitleText(item),
            style: GBTTypography.bodySmall.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
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

/// EN: Returns neutral color for type badge — decorative only, no brand colors.
/// KO: 타입 배지용 뉴트럴 색상 반환 — 장식용이므로 브랜드 색상을 사용하지 않습니다.
Color _typeColor(SearchItemType type, {required bool isDark}) {
  return isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
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
