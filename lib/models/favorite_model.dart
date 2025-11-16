enum FavoriteEntityType { place, live, news, unknown }

extension FavoriteEntityTypeX on FavoriteEntityType {
  String get apiValue {
    switch (this) {
      case FavoriteEntityType.place:
        return 'PLACE';
      case FavoriteEntityType.live:
        return 'LIVE';
      case FavoriteEntityType.news:
        return 'NEWS';
      case FavoriteEntityType.unknown:
        return 'UNKNOWN';
    }
  }

  static FavoriteEntityType fromApi(String? raw) {
    if (raw == null) return FavoriteEntityType.unknown;
    final upper = raw.toUpperCase();
    for (final type in FavoriteEntityType.values) {
      if (type.apiValue == upper) {
        return type;
      }
    }
    return FavoriteEntityType.unknown;
  }
}

class FavoriteItem {
  FavoriteItem({
    this.id,
    required this.entityId,
    required this.entityType,
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.createdAt,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? const {};

  final String? id;
  final String entityId;
  final FavoriteEntityType entityType;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  final Map<String, dynamic> metadata;

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    final entityId = (map['entityId'] ?? map['id'] ?? '').toString();
    final entityType = FavoriteEntityTypeX.fromApi(
      map['entityType']?.toString(),
    );
    final title = map['title']?.toString() ?? map['name']?.toString();
    final subtitle = map['subtitle']?.toString() ?? map['summary']?.toString();
    final description =
        map['description']?.toString() ?? map['body']?.toString();
    final imageUrl =
        map['imageUrl']?.toString() ?? map['thumbnailUrl']?.toString();
    final createdAtRaw =
        map['createdAt'] ?? map['favoritedAt'] ?? map['updatedAt'];
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw.toString())
        : null;

    final metadataRaw = map['metadata'];
    final metadata = metadataRaw is Map<String, dynamic>
        ? metadataRaw
        : <String, dynamic>{};

    return FavoriteItem(
      id: map['id']?.toString(),
      entityId: entityId,
      entityType: entityType,
      title: title,
      subtitle: subtitle,
      description: description,
      imageUrl: imageUrl,
      createdAt: createdAt,
      metadata: metadata,
    );
  }
}

class FavoritesPage {
  const FavoritesPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    this.totalPages,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  final List<FavoriteItem> items;
  final int page;
  final int size;
  final int total;
  final int? totalPages;
  final bool hasNext;
  final bool hasPrevious;
}
