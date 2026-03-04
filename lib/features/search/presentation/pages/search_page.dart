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
import '../../../../core/widgets/inputs/gbt_search_bar.dart';
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
        // EN: Search bar fills available AppBar title space with right margin.
        // KO: 검색바가 우측 여백과 함께 AppBar 타이틀 영역을 채움.
        title: Padding(
          padding: const EdgeInsets.only(right: GBTSpacing.md),
          child: GBTSearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            hint: '장소, 이벤트, 밴드 검색...',
            autofocus: true,
            onChanged: _onQueryChanged,
            onSubmitted: _onSubmit,
            onClear: () => _onQueryChanged(''),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN: Compact scope toggle — two pill buttons (Naver/Twitter style)
          // KO: 컴팩트 스코프 토글 — 두 개의 필 버튼 (네이버/트위터 스타일)
          _ScopeToggleRow(
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

// ============================================================
// EN: Scope Toggle Row — compact pill pair (현재 프로젝트 / 전체)
// KO: 스코프 토글 행 — 컴팩트 필 쌍
// ============================================================

class _ScopeToggleRow extends StatelessWidget {
  const _ScopeToggleRow({
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
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.md,
        GBTSpacing.sm,
        GBTSpacing.md,
        GBTSpacing.xs,
      ),
      child: Row(
        children: [
          _ScopePill(
            label: projectScopeLabel ?? '현재 프로젝트',
            isSelected: scopedToCurrentProject,
            onTap: () => onChanged(true),
            primaryColor: primaryColor,
            isDark: isDark,
          ),
          const SizedBox(width: GBTSpacing.xs),
          _ScopePill(
            label: '전체 검색',
            isSelected: !scopedToCurrentProject,
            onTap: () => onChanged(false),
            primaryColor: primaryColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  const _ScopePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label 검색 범위 ${isSelected ? '선택됨' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? GBTColors.darkBorder : GBTColors.border),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: primaryColor,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(
                    color: isSelected
                        ? primaryColor
                        : (isDark
                              ? GBTColors.darkTextSecondary
                              : GBTColors.textSecondary),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EN: Recent searches — horizontal chip row + trending tags
// KO: 최근 검색 — 수평 칩 행 + 트렌딩 태그
// ============================================================

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

  static const _trending = ['도쿄', '라이브', '2026', '신곡', '콘서트', '앨범'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // EN: Recent search history section
        // KO: 최근 검색 기록 섹션
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.sm,
            GBTSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색어',
                style: GBTTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? GBTColors.darkTextSecondary
                      : GBTColors.textSecondary,
                ),
              ),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.sm,
                      vertical: GBTSpacing.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '전체 삭제',
                    style: GBTTypography.labelSmall.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
            child: Text(
              '최근 검색어가 없습니다.',
              style: GBTTypography.bodySmall.copyWith(color: secondaryColor),
            ),
          )
        else
          // EN: Horizontal scrollable recent chip row
          // KO: 수평 스크롤 최근 검색어 칩 행
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: GBTSpacing.xs),
              itemBuilder: (context, index) {
                final item = items[index];
                return Semantics(
                  label: '최근 검색어: $item. 탭하여 검색',
                  button: true,
                  child: _RecentChip(
                    label: item,
                    onTap: () => onSelect(item),
                    onRemove: () => onRemove(item),
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
        // EN: Section divider
        // KO: 섹션 구분선
        Padding(
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.lg),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: isDark
                ? GBTColors.darkBorder.withValues(alpha: 0.5)
                : GBTColors.border.withValues(alpha: 0.5),
            indent: GBTSpacing.md,
            endIndent: GBTSpacing.md,
          ),
        ),
        // EN: Trending searches section
        // KO: 인기 검색어 섹션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: GBTSpacing.xs),
              Text(
                '인기 검색어',
                style: GBTTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // EN: Numbered trending list — Naver/Kakao/Melon style rank rows
        // KO: 번호 순위 목록 — 네이버/카카오/멜론 스타일 순위 행
        ..._trending.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final keyword = entry.value;
          final isTop3 = rank <= 3;
          final rankColor = isTop3
              ? primaryColor
              : (isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary);

          return Semantics(
            label: '인기 검색어 $rank위: $keyword',
            button: true,
            child: InkWell(
              onTap: () => onSelect(keyword),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.md,
                  vertical: GBTSpacing.sm2,
                ),
                child: Row(
                  children: [
                    // EN: Rank number — 24px fixed width, top-3 in primary color
                    // KO: 순위 번호 — 24px 고정 너비, 상위 3위는 primary 색상
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$rank',
                        textAlign: TextAlign.center,
                        style: GBTTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: rankColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    Expanded(
                      child: Text(
                        keyword,
                        style: GBTTypography.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: GBTSpacing.xl),
      ],
    );
  }
}

/// EN: Recent search chip with history icon and delete button.
/// KO: 히스토리 아이콘과 삭제 버튼이 있는 최근 검색 칩.
class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
    required this.isDark,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;
    final textColor = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final iconColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          left: GBTSpacing.sm,
          right: GBTSpacing.xs,
          top: GBTSpacing.xs,
          bottom: GBTSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 14,
              color: iconColor,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GBTTypography.labelMedium.copyWith(color: textColor),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EN: Search results with tab filter
// KO: 탭 필터가 있는 검색 결과
// ============================================================

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
          const SizedBox(height: GBTSpacing.xs),
          Expanded(
            child: state.when(
              loading: () => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
                children: [
                  GBTListSkeleton(
                    itemCount: 5,
                    padding: EdgeInsets.zero,
                    spacing: GBTSpacing.sm,
                    itemBuilder: (_) => const GBTNewsCardSkeleton(),
                  ),
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

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: GBTSpacing.paddingPage,
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTEmptyState(
            icon: Icons.search_off_rounded,
            message: '검색 결과가 없습니다.\n다른 키워드로 검색해보세요.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: GBTSpacing.xxl),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        // EN: Indent aligns with text content start (thumbnail 48 + gap 12 + horizontal 16)
        // KO: 들여쓰기가 텍스트 시작점과 정렬됨 (썸네일 48 + 간격 12 + 수평 16)
        indent: GBTSpacing.md + 48 + GBTSpacing.md,
        endIndent: GBTSpacing.md,
        color: isDark
            ? GBTColors.darkBorder.withValues(alpha: 0.4)
            : GBTColors.border.withValues(alpha: 0.4),
      ),
      itemBuilder: (context, index) => _SearchResultItem(item: items[index]),
    );
  }
}

/// EN: Search result item — clean row without Card, thumbnail + text + type badge.
/// KO: 검색 결과 아이템 — Card 없는 클린 행, 썸네일 + 텍스트 + 타입 배지.
class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.item});

  final SearchItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeLabel = _typeLabel(item.type);
    final accentColor = _typeAccentColor(item.type, isDark: isDark);
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Semantics(
      label: '$typeLabel: ${item.title}',
      button: true,
      child: InkWell(
        onTap: () => _handleTap(context, item),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.md,
            vertical: GBTSpacing.sm + 2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // EN: Thumbnail — image or tinted icon box
              // KO: 썸네일 — 이미지 또는 틴트 아이콘 박스
              _SearchThumbnail(
                imageUrl: item.imageUrl,
                fallbackIcon: _typeIcon(item.type),
                accentColor: accentColor,
                isDark: isDark,
              ),
              const SizedBox(width: GBTSpacing.md),
              // EN: Title + subtitle stack
              // KO: 제목 + 부제목 스택
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GBTTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleText(item),
                      style: GBTTypography.bodySmall.copyWith(
                        color: secondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GBTSpacing.sm),
              // EN: Type badge pill
              // KO: 타입 배지 필
              _TypeBadge(
                label: typeLabel,
                accentColor: accentColor,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: 48×48 thumbnail widget for search result rows.
/// KO: 검색 결과 행용 48×48 썸네일 위젯.
class _SearchThumbnail extends StatelessWidget {
  const _SearchThumbnail({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.accentColor,
    required this.isDark,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: GBTImage(
          imageUrl: imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          semanticLabel: '검색 결과 이미지',
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: Icon(fallbackIcon, color: accentColor, size: 22),
    );
  }
}

/// EN: Pill-shaped type badge for search result items.
/// KO: 검색 결과 아이템용 필 형태의 타입 배지.
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  final String label;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: GBTTypography.labelSmall.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// EN: Helper functions
// KO: 헬퍼 함수
// ============================================================

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
    SearchItemType.place => Icons.place_rounded,
    SearchItemType.liveEvent => Icons.event_rounded,
    SearchItemType.news => Icons.article_rounded,
    SearchItemType.post => Icons.forum_rounded,
    SearchItemType.unit => Icons.group_rounded,
    SearchItemType.project => Icons.folder_rounded,
    SearchItemType.unknown => Icons.search_rounded,
  };
}

/// EN: Accent color per search item type — distinct, accessible colors.
/// KO: 검색 아이템 타입별 강조 색상 — 구분 가능하고 접근성 있는 색상.
Color _typeAccentColor(SearchItemType type, {required bool isDark}) {
  return switch (type) {
    SearchItemType.place => isDark
        ? const Color(0xFF2DD4BF)
        : GBTColors.accentTeal,     // teal — location
    SearchItemType.liveEvent => isDark
        ? GBTColors.darkSecondary
        : GBTColors.secondary,      // pink — live event
    SearchItemType.news => isDark
        ? const Color(0xFF60A5FA)
        : GBTColors.accentBlue,     // blue — news
    SearchItemType.post => isDark
        ? GBTColors.darkPrimary
        : GBTColors.primary,        // indigo — community
    SearchItemType.unit => isDark
        ? const Color(0xFFFBBF24)
        : GBTColors.accent,         // amber — unit/band
    SearchItemType.project => isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary,
    SearchItemType.unknown => isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary,
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
