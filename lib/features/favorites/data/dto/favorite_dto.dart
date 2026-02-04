/// EN: Favorite DTO for saved items.
/// KO: 즐겨찾기 아이템 DTO.
library;

class FavoriteItemDto {
  const FavoriteItemDto({
    required this.entityType,
    required this.entityId,
    this.title,
    this.thumbnailUrl,
  });

  final String entityType;
  final String entityId;
  final String? title;
  final String? thumbnailUrl;

  factory FavoriteItemDto.fromJson(Map<String, dynamic> json) {
    return FavoriteItemDto(
      entityType: _string(json, ['entityType', 'targetType', 'type']) ?? '',
      entityId: _string(json, ['entityId', 'targetId', 'itemId']) ?? '',
      title: _string(json, ['title', 'name']),
      thumbnailUrl: _string(json, ['thumbnailUrl', 'imageUrl', 'image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'entityId': entityId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
