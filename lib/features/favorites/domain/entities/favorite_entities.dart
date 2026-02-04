/// EN: Favorite domain entities.
/// KO: 즐겨찾기 도메인 엔티티.
library;

import '../../data/dto/favorite_dto.dart';

enum FavoriteType { place, liveEvent, news, post, unknown }

class FavoriteItem {
  const FavoriteItem({
    required this.entityId,
    required this.type,
    this.title,
    this.thumbnailUrl,
  });

  final String entityId;
  final FavoriteType type;
  final String? title;
  final String? thumbnailUrl;

  factory FavoriteItem.fromDto(FavoriteItemDto dto) {
    return FavoriteItem(
      entityId: dto.entityId,
      type: _mapType(dto.entityType),
      title: dto.title,
      thumbnailUrl: dto.thumbnailUrl,
    );
  }
}

FavoriteType _mapType(String raw) {
  final value = raw.toLowerCase();
  if (value.contains('place')) return FavoriteType.place;
  if (value.contains('live') || value.contains('event')) {
    return FavoriteType.liveEvent;
  }
  if (value.contains('news')) return FavoriteType.news;
  if (value.contains('post') || value.contains('community')) {
    return FavoriteType.post;
  }
  return FavoriteType.unknown;
}
