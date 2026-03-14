/// EN: Favorites page with saved items.
/// KO: 저장된 즐겨찾기 목록 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../application/favorites_controller.dart';
import '../../domain/entities/favorite_entities.dart';

/// EN: Favorites page widget.
/// KO: 즐겨찾기 페이지 위젯.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n(ko: '즐겨찾기', en: 'Favorites', ja: 'お気に入り')),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.refresh,
            tooltip: context.l10n(ko: '새로고침', en: 'Refresh', ja: '更新'),
            onPressed: () => ref
                .read(favoritesControllerProvider.notifier)
                .load(forceRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(favoritesControllerProvider.notifier)
            .load(forceRefresh: true),
        child: state.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: [
              const SizedBox(height: GBTSpacing.sm),
              GBTLoading(
                message: context.l10n(
                  ko: '즐겨찾기를 불러오는 중...',
                  en: 'Loading favorites...',
                  ja: 'お気に入りを読み込み中...',
                ),
              ),
            ],
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : context.l10n(
                    ko: '즐겨찾기를 불러오지 못했어요',
                    en: 'Failed to load favorites',
                    ja: 'お気に入りを読み込めませんでした',
                  );
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                const SizedBox(height: GBTSpacing.sm),
                GBTErrorState(
                  message: message,
                  onRetry: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
              ],
            );
          },
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: GBTSpacing.paddingPage,
                children: [
                  const SizedBox(height: GBTSpacing.sm),
                  GBTEmptyState(
                    icon: Icons.favorite_border,
                    message: context.l10n(
                      ko: '저장된 즐겨찾기가 없습니다.\n마음에 드는 장소, 이벤트, 뉴스를 저장해보세요.',
                      en: 'No saved favorites.\nSave places, events, or news you like.',
                      ja: '保存されたお気に入りがありません。\n気に入った場所、イベント、ニュースを保存してください。',
                    ),
                  ),
                ],
              );
            }

            return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const SizedBox(height: GBTSpacing.sm),
                  GBTSegmentedTabBar(
                    margin: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.md,
                    ),
                    isScrollable: true,
                    tabs: [
                      Tab(
                        text: context.l10n(ko: '전체', en: 'All', ja: '全体'),
                      ),
                      Tab(
                        text: context.l10n(ko: '장소', en: 'Places', ja: '場所'),
                      ),
                      Tab(
                        text: context.l10n(ko: '이벤트', en: 'Events', ja: 'イベント'),
                      ),
                      Tab(
                        text: context.l10n(ko: '뉴스', en: 'News', ja: 'ニュース'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _FavoritesList(
                          items: _filterExcluding(items, FavoriteType.post),
                        ),
                        _FavoritesList(
                          items: _filter(items, FavoriteType.place),
                        ),
                        _FavoritesList(
                          items: _filter(items, FavoriteType.liveEvent),
                        ),
                        _FavoritesList(
                          items: _filter(items, FavoriteType.news),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.items});

  final List<FavoriteItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: GBTSpacing.lg),
          GBTEmptyState(
            icon: Icons.favorite_border,
            message: context.l10n(
              ko: '이 카테고리에 저장된 항목이 없습니다.',
              en: 'No saved items in this category.',
              ja: 'このカテゴリに保存された項目がありません。',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.sm,
        GBTSpacing.pageHorizontal,
        GBTSpacing.xl,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
          child: _FavoriteCard(
            item: items[index],
            onTap: () => _openItem(context, items[index]),
          ),
        );
      },
    );
  }
}

// ========================================
// EN: Custom favorite card — 72px thumbnail + title + type badge
// KO: 커스텀 즐겨찾기 카드 — 72px 썸네일 + 제목 + 타입 배지
// ========================================

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item, required this.onTap});

  final FavoriteItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _typeColor(item.type);
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textTertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final surfaceColor = isDark ? GBTColors.darkSurfaceElevated : Colors.white;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Semantics(
      label:
          '${context.l10n(ko: "즐겨찾기", en: "Favorite", ja: "お気に入り")}: ${item.title ?? context.l10n(ko: "즐겨찾기 항목", en: "Favorite item", ja: "お気に入り項目")}, ${_typeLabel(context, item.type)}',
      button: true,
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
            child: Row(
              children: [
                // EN: Left thumbnail (72px) — image or icon fallback
                // KO: 왼쪽 썸네일 (72px) — 이미지 또는 아이콘 폴백
                _FavoriteThumbnail(
                  imageUrl: item.thumbnailUrl,
                  type: item.type,
                  color: color,
                  isDark: isDark,
                ),
                const SizedBox(width: GBTSpacing.md),
                // EN: Title and type badge
                // KO: 제목 및 타입 배지
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: GBTSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? '즐겨찾기 항목',
                          style: GBTTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: GBTSpacing.xs),
                        _TypeBadge(
                          type: item.type,
                          color: color,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: textTertiary,
                ),
                const SizedBox(width: GBTSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteThumbnail extends StatelessWidget {
  const _FavoriteThumbnail({
    required this.imageUrl,
    required this.type,
    required this.color,
    required this.isDark,
  });

  final String? imageUrl;
  final FavoriteType type;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(GBTSpacing.radiusMd - 1),
          bottomLeft: Radius.circular(GBTSpacing.radiusMd - 1),
        ),
        child: GBTImage(
          imageUrl: imageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          semanticLabel:
              '${_typeLabel(context, type)} ${context.l10n(ko: "이미지", en: "image", ja: "画像")}',
        ),
      );
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(GBTSpacing.radiusMd - 1),
          bottomLeft: Radius.circular(GBTSpacing.radiusMd - 1),
        ),
      ),
      child: Icon(
        _typeIcon(type),
        size: 28,
        color: color.withValues(alpha: 0.7),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.type,
    required this.color,
    required this.isDark,
  });

  final FavoriteType type;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        _typeLabel(context, type),
        style: GBTTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

List<FavoriteItem> _filter(List<FavoriteItem> items, FavoriteType type) {
  return items.where((item) => item.type == type).toList();
}

List<FavoriteItem> _filterExcluding(
  List<FavoriteItem> items,
  FavoriteType exclude,
) {
  return items.where((item) => item.type != exclude).toList();
}

String _typeLabel(BuildContext context, FavoriteType type) {
  return switch (type) {
    FavoriteType.place => context.l10n(ko: '장소', en: 'Places', ja: '場所'),
    FavoriteType.liveEvent => context.l10n(ko: '이벤트', en: 'Events', ja: 'イベント'),
    FavoriteType.news => context.l10n(ko: '뉴스', en: 'News', ja: 'ニュース'),
    FavoriteType.post => context.l10n(
      ko: '커뮤니티',
      en: 'Community',
      ja: 'コミュニティ',
    ),
    FavoriteType.unknown => context.l10n(ko: '기타', en: 'Other', ja: 'その他'),
  };
}

/// EN: Returns category-specific accent color for type badge.
/// KO: 타입 배지에 카테고리별 액센트 색상을 반환합니다.
Color _typeColor(FavoriteType type) {
  return switch (type) {
    FavoriteType.place => const Color(0xFF14B8A6), // teal
    FavoriteType.liveEvent => const Color(0xFF6366F1), // indigo
    FavoriteType.news => const Color(0xFFF59E0B), // amber
    FavoriteType.post => const Color(0xFFEC4899), // pink
    FavoriteType.unknown => const Color(0xFF9E9E9E), // neutral
  };
}

/// EN: Returns category-specific icon for thumbnail fallback.
/// KO: 썸네일 폴백용 카테고리별 아이콘을 반환합니다.
IconData _typeIcon(FavoriteType type) {
  return switch (type) {
    FavoriteType.place => Icons.place_rounded,
    FavoriteType.liveEvent => Icons.event_rounded,
    FavoriteType.news => Icons.article_rounded,
    FavoriteType.post => Icons.chat_bubble_rounded,
    FavoriteType.unknown => Icons.favorite_rounded,
  };
}

// EN: Route through shared helpers so overlay->shell transitions use safe navigation policy.
// KO: 오버레이->쉘 전환 시 안전한 이동 정책을 적용하도록 공통 헬퍼로 라우팅합니다.
void _openItem(BuildContext context, FavoriteItem item) {
  final entityId = item.entityId.trim();
  if (entityId.isEmpty) {
    return;
  }
  switch (item.type) {
    case FavoriteType.place:
      context.goToPlaceDetail(entityId);
      break;
    case FavoriteType.liveEvent:
      context.goToLiveDetail(entityId);
      break;
    case FavoriteType.news:
      context.goToNewsDetail(entityId);
      break;
    case FavoriteType.post:
      context.goToPostDetail(entityId, projectCode: item.projectCode);
      break;
    case FavoriteType.unknown:
      break;
  }
}
