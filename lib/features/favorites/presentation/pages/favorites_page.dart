/// EN: Favorites page with saved items.
/// KO: 저장된 즐겨찾기 목록 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
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
        title: const Text('즐겨찾기'),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.refresh,
            tooltip: '새로고침',
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
            children: const [
              SizedBox(height: GBTSpacing.sm),
              GBTLoading(message: '즐겨찾기를 불러오는 중...'),
            ],
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : '즐겨찾기를 불러오지 못했어요';
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
                children: const [
                  SizedBox(height: GBTSpacing.sm),
                  GBTEmptyState(
                    icon: Icons.favorite_border,
                    message: '저장된 즐겨찾기가 없습니다.\n마음에 드는 장소나 이벤트를 저장해보세요.',
                  ),
                ],
              );
            }

            return DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const SizedBox(height: GBTSpacing.sm),
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
                    child: TabBarView(
                      children: [
                        _FavoritesList(items: items),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTEmptyState(
            icon: Icons.favorite_border,
            message: '이 카테고리에 저장된 항목이 없습니다.',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: GBTSpacing.paddingPage,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Semantics(
          label:
              '즐겨찾기: ${item.title ?? '즐겨찾기 항목'}, '
              '${_typeLabel(item.type)}',
          button: true,
          child: Card(
            margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
            child: ListTile(
              leading: _FavoriteLeading(imageUrl: item.thumbnailUrl),
              title: Text(
                item.title ?? '즐겨찾기 항목',
                style: GBTTypography.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _typeLabel(item.type),
                style: GBTTypography.bodySmall.copyWith(color: tertiaryColor),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _typeColor(
                    item.type,
                    isDark: isDark,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusXs),
                ),
                child: Text(
                  _typeLabel(item.type),
                  style: GBTTypography.labelSmall.copyWith(
                    color: _typeColor(item.type, isDark: isDark),
                  ),
                ),
              ),
              onTap: () => _openItem(context, item),
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteLeading extends StatelessWidget {
  const _FavoriteLeading({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: Icon(
          Icons.favorite,
          // EN: Use neutral tertiary instead of brand secondary.
          // KO: 브랜드 보조색 대신 뉴트럴 tertiary를 사용합니다.
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          size: 20,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      child: GBTImage(
        imageUrl: imageUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        semanticLabel: '즐겨찾기 이미지',
      ),
    );
  }
}

List<FavoriteItem> _filter(List<FavoriteItem> items, FavoriteType type) {
  return items.where((item) => item.type == type).toList();
}

String _typeLabel(FavoriteType type) {
  return switch (type) {
    FavoriteType.place => '장소',
    FavoriteType.liveEvent => '이벤트',
    FavoriteType.news => '뉴스',
    FavoriteType.post => '커뮤니티',
    FavoriteType.unknown => '기타',
  };
}

/// EN: Returns neutral color for type badge — decorative only, no brand colors.
/// KO: 타입 배지용 뉴트럴 색상 반환 — 장식용이므로 브랜드 색상을 사용하지 않습니다.
Color _typeColor(FavoriteType type, {required bool isDark}) {
  return isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
}

// EN: Use push so /favorites stays in the back stack — pressing back returns here.
// KO: /favorites가 백스택에 남도록 push를 사용합니다 — 뒤로가기 시 즐겨찾기로 복귀합니다.
void _openItem(BuildContext context, FavoriteItem item) {
  switch (item.type) {
    case FavoriteType.place:
      context.push('/places/${item.entityId}');
      break;
    case FavoriteType.liveEvent:
      context.push('/live/${item.entityId}');
      break;
    case FavoriteType.news:
      context.push('/info/news/${item.entityId}');
      break;
    case FavoriteType.post:
      context.push('/board/posts/${item.entityId}');
      break;
    case FavoriteType.unknown:
      break;
  }
}
