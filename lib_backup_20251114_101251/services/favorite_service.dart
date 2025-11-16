import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/favorite_model.dart';

class FavoriteService {
  FavoriteService();

  final ApiClient _api = ApiClient.instance;

  Future<void> addFavorite({
    required FavoriteEntityType entityType,
    required String entityId,
  }) async {
    await _api.post(
      ApiConstants.myFavorites,
      data: {
        'entityType': entityType.apiValue,
        'entityId': entityId,
      },
    );
  }

  Future<void> removeFavorite({
    required FavoriteEntityType entityType,
    required String entityId,
  }) async {
    await _api.delete(
      ApiConstants.myFavorites,
      data: {
        'entityType': entityType.apiValue,
        'entityId': entityId,
      },
    );
  }

  Future<FavoritesPage> getMyFavorites({
    FavoriteEntityType? type,
    int page = 0,
    int size = 20,
  }) async {
    final envelope = await _api.get(
      ApiConstants.myFavorites,
      queryParameters: {
        if (type != null && type != FavoriteEntityType.unknown)
          'type': type.apiValue,
        'page': page,
        'size': size,
      },
    );

    final raw = envelope.data;
    List<dynamic> entries;
    if (raw is List) {
      entries = raw;
    } else if (raw is Map<String, dynamic>) {
      entries = (raw['items'] as List?) ??
          (raw['favorites'] as List?) ??
          const <dynamic>[];
    } else {
      entries = const <dynamic>[];
    }

    final items = entries
        .whereType<Map<String, dynamic>>()
        .map(FavoriteItem.fromMap)
        .toList(growable: false);
    final pagination = envelope.pagination;

    return FavoritesPage(
      items: items,
      page: pagination?.currentPage ?? page,
      size: pagination?.pageSize ?? size,
      total: pagination?.totalItems ?? items.length,
      totalPages: pagination?.totalPages,
      hasNext: pagination?.hasNext ?? false,
      hasPrevious: pagination?.hasPrevious ?? false,
    );
  }
}
