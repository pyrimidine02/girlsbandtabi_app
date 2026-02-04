/// EN: Favorites page with saved items.
/// KO: 저장된 즐겨찾기 목록 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
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
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: state.when(
        loading: () => const GBTLoading(message: '즐겨찾기를 불러오는 중...'),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '즐겨찾기를 불러오지 못했어요';
          return GBTErrorState(
            message: message,
            onRetry: () => ref
                .read(favoritesControllerProvider.notifier)
                .load(forceRefresh: true),
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return const GBTEmptyState(message: '저장된 즐겨찾기가 없습니다');
          }

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
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
                      _FavoritesList(items: _filter(items, FavoriteType.place)),
                      _FavoritesList(
                        items: _filter(items, FavoriteType.liveEvent),
                      ),
                      _FavoritesList(items: _filter(items, FavoriteType.news)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
      return const Center(child: Text('결과가 없습니다'));
    }

    return ListView.builder(
      padding: GBTSpacing.paddingPage,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
          child: ListTile(
            leading: _FavoriteLeading(imageUrl: item.thumbnailUrl),
            title: Text(
              item.title ?? '즐겨찾기 항목',
              style: GBTTypography.bodyMedium,
            ),
            subtitle: Text(
              _typeLabel(item.type),
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.textTertiary,
              ),
            ),
            trailing: Text(
              _typeLabel(item.type),
              style: GBTTypography.labelSmall.copyWith(
                color: _typeColor(item.type),
              ),
            ),
            onTap: () => _openItem(context, item),
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
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: Icon(Icons.favorite, color: GBTColors.accentPink, size: 20),
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

Color _typeColor(FavoriteType type) {
  return switch (type) {
    FavoriteType.place => GBTColors.accentBlue,
    FavoriteType.liveEvent => GBTColors.accentPink,
    FavoriteType.news => GBTColors.accent,
    FavoriteType.post => GBTColors.secondary,
    FavoriteType.unknown => GBTColors.textSecondary,
  };
}

void _openItem(BuildContext context, FavoriteItem item) {
  switch (item.type) {
    case FavoriteType.place:
      context.goToPlaceDetail(item.entityId);
      break;
    case FavoriteType.liveEvent:
      context.goToLiveDetail(item.entityId);
      break;
    case FavoriteType.news:
      context.goToNewsDetail(item.entityId);
      break;
    case FavoriteType.post:
      context.goToPostDetail(item.entityId);
      break;
    case FavoriteType.unknown:
      break;
  }
}
