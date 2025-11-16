import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/favorite_model.dart';
import '../services/favorite_service.dart';

const _allKey = '_ALL';

String _compositeKey(FavoriteEntityType type, String entityId) =>
    '${type.apiValue}:$entityId';

final favoriteServiceProvider = Provider<FavoriteService>(
  (ref) => FavoriteService(),
);

final favoriteFilterProvider = StateProvider<FavoriteEntityType?>(
  (ref) => null,
);

class FavoriteCacheNotifier extends StateNotifier<Map<String, Set<String>>> {
  FavoriteCacheNotifier() : super(<String, Set<String>>{});

  void replace(FavoriteEntityType? filter, Iterable<FavoriteItem> items) {
    final updated = Map<String, Set<String>>.from(state);
    if (filter == null || filter == FavoriteEntityType.unknown) {
      updated.clear();
      final allSet = <String>{};
      final byType = <String, Set<String>>{};
      for (final item in items) {
        final typeKey = item.entityType.apiValue;
        final set = byType.putIfAbsent(typeKey, () => <String>{});
        set.add(item.entityId);
        allSet.add(_compositeKey(item.entityType, item.entityId));
      }
      updated.addAll(byType);
      updated[_allKey] = allSet;
    } else {
      final key = filter.apiValue;
      final typeSet = items.map((e) => e.entityId).toSet();
      updated[key] = typeSet;
      final allSet = updated[_allKey] != null
          ? Set<String>.from(updated[_allKey]!)
          : <String>{};
      allSet.removeWhere((entry) => entry.startsWith('$key:'));
      for (final item in items) {
        allSet.add(_compositeKey(item.entityType, item.entityId));
      }
      updated[_allKey] = allSet;
    }
    state = updated;
  }

  bool isFavorite(FavoriteEntityType type, String entityId) {
    final typedSet = state[type.apiValue];
    if (typedSet != null && typedSet.contains(entityId)) {
      return true;
    }
    final allSet = state[_allKey];
    if (allSet != null && allSet.contains(_compositeKey(type, entityId))) {
      return true;
    }
    return false;
  }

  void setFavorite(FavoriteEntityType type, String entityId, bool isFavorite) {
    final updated = Map<String, Set<String>>.from(state);
    final key = type.apiValue;
    final typedSet = updated.putIfAbsent(key, () => <String>{});
    if (isFavorite) {
      typedSet.add(entityId);
    } else {
      typedSet.remove(entityId);
    }
    updated[key] = typedSet;

    final composite = _compositeKey(type, entityId);
    final allSet = updated.putIfAbsent(_allKey, () => <String>{});
    if (isFavorite) {
      allSet.add(composite);
    } else {
      allSet.remove(composite);
    }
    updated[_allKey] = allSet;
    state = updated;
  }
}

final favoriteCacheProvider =
    StateNotifierProvider<FavoriteCacheNotifier, Map<String, Set<String>>>(
      (ref) => FavoriteCacheNotifier(),
    );

class FavoritesListState {
  const FavoritesListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.total = 0,
    this.error,
  });

  final List<FavoriteItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int total;
  final String? error;

  FavoritesListState copyWith({
    List<FavoriteItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? total,
    Object? error = _sentinel,
  }) {
    return FavoritesListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const Object _sentinel = Object();

class FavoritesListNotifier extends StateNotifier<FavoritesListState> {
  FavoritesListNotifier(this._ref)
    : _service = _ref.read(favoriteServiceProvider),
      _cache = _ref.read(favoriteCacheProvider.notifier),
      super(const FavoritesListState());

  static const int _pageSize = 50;

  final Ref _ref;
  final FavoriteService _service;
  final FavoriteCacheNotifier _cache;

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    final filter = _ref.read(favoriteFilterProvider);
    state = state.copyWith(
      isLoading: true,
      error: null,
      hasMore: true,
      page: 0,
      total: 0,
    );
    try {
      final page = await _service.getMyFavorites(
        type: filter,
        page: 0,
        size: _pageSize,
      );
      final hasMore = (page.page + 1) * page.size < page.total;
      _cache.replace(filter, page.items);
      state = state.copyWith(
        items: page.items,
        isLoading: false,
        page: page.page,
        total: page.total,
        hasMore: hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    final filter = _ref.read(favoriteFilterProvider);
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await _service.getMyFavorites(
        type: filter,
        page: nextPage,
        size: _pageSize,
      );
      final hasMore = (page.page + 1) * page.size < page.total;

      final existingKeys = state.items
          .map((item) => _compositeKey(item.entityType, item.entityId))
          .toSet();
      final additional = <FavoriteItem>[];
      for (final item in page.items) {
        final key = _compositeKey(item.entityType, item.entityId);
        if (existingKeys.add(key)) {
          additional.add(item);
        }
        _cache.setFavorite(item.entityType, item.entityId, true);
      }

      state = state.copyWith(
        items: [...state.items, ...additional],
        isLoadingMore: false,
        page: page.page,
        total: page.total,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void removeById(FavoriteEntityType type, String entityId) {
    final updated = state.items
        .where((item) => item.entityType != type || item.entityId != entityId)
        .toList();
    state = state.copyWith(items: updated);
  }

  Future<void> reloadAfterAddition(FavoriteEntityType type) async {
    final filter = _ref.read(favoriteFilterProvider);
    if (filter == null ||
        filter == FavoriteEntityType.unknown ||
        filter == type) {
      await loadInitial();
    }
  }
}

final favoritesListProvider =
    StateNotifierProvider.autoDispose<
      FavoritesListNotifier,
      FavoritesListState
    >((ref) {
      final notifier = FavoritesListNotifier(ref);
      Future.microtask(() => notifier.loadInitial());
      ref.listen<FavoriteEntityType?>(favoriteFilterProvider, (prev, next) {
        notifier.loadInitial();
      });
      return notifier;
    });

class FavoriteController {
  FavoriteController(this._ref);

  final Ref _ref;

  Future<bool> toggle(FavoriteEntityType type, String entityId) async {
    final cache = _ref.read(favoriteCacheProvider.notifier);
    final isFav = cache.isFavorite(type, entityId);
    final service = _ref.read(favoriteServiceProvider);
    final listNotifier = _ref.read(favoritesListProvider.notifier);

    if (isFav) {
      await service.removeFavorite(entityType: type, entityId: entityId);
      cache.setFavorite(type, entityId, false);
      listNotifier.removeById(type, entityId);
      return false;
    } else {
      await service.addFavorite(entityType: type, entityId: entityId);
      cache.setFavorite(type, entityId, true);
      await listNotifier.reloadAfterAddition(type);
      return true;
    }
  }
}

final favoriteControllerProvider = Provider<FavoriteController>(
  (ref) => FavoriteController(ref),
);

class FavoriteKey {
  const FavoriteKey(this.type, this.entityId);
  final FavoriteEntityType type;
  final String entityId;

  @override
  bool operator ==(Object other) {
    return other is FavoriteKey &&
        other.type == type &&
        other.entityId == entityId;
  }

  @override
  int get hashCode => Object.hash(type, entityId);
}

final isFavoriteProvider = Provider.family<bool, FavoriteKey>((ref, key) {
  final cache = ref.watch(favoriteCacheProvider);
  final typedSet = cache[key.type.apiValue];
  if (typedSet != null && typedSet.contains(key.entityId)) {
    return true;
  }
  final allSet = cache[_allKey];
  if (allSet != null &&
      allSet.contains(_compositeKey(key.type, key.entityId))) {
    return true;
  }
  return false;
});

final favoritesBootstrapProvider = FutureProvider.autoDispose<void>((
  ref,
) async {
  final existing = ref.read(favoriteCacheProvider);
  if (existing.isNotEmpty) {
    return;
  }
  final service = ref.watch(favoriteServiceProvider);
  final page = await service.getMyFavorites(page: 0, size: 100);
  ref.read(favoriteCacheProvider.notifier).replace(null, page.items);
});
