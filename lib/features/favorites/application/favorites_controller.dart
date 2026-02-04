/// EN: Favorites controller for saved items.
/// KO: 즐겨찾기 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/favorites_remote_data_source.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../domain/entities/favorite_entities.dart';
import '../domain/repositories/favorites_repository.dart';

class FavoritesController
    extends StateNotifier<AsyncValue<List<FavoriteItem>>> {
  FavoritesController(this._ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(favoritesRepositoryProvider.future);
    final result = await repository.getFavorites(forceRefresh: forceRefresh);

    if (result is Success<List<FavoriteItem>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<FavoriteItem>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<void>> toggleFavorite({
    required String entityId,
    required FavoriteType type,
    bool? isCurrentlyFavorite,
  }) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return Result.failure(
        const AuthFailure('Login required', code: 'auth_required'),
      );
    }

    final repository = await _ref.read(favoritesRepositoryProvider.future);
    final currentItems = state.maybeWhen(
      data: (items) => items,
      orElse: () {
        return <FavoriteItem>[];
      },
    );

    final currentlyFavorite =
        isCurrentlyFavorite ??
        currentItems.any(
          (item) => item.entityId == entityId && item.type == type,
        );

    if (currentlyFavorite) {
      final result = await repository.removeFavorite(
        entityId: entityId,
        type: type,
      );
      if (result is Success<void>) {
        await load(forceRefresh: true);
      }
      return result;
    }

    final result = await repository.addFavorite(
      entityId: entityId,
      type: type,
    );
    if (result is Success<FavoriteItem>) {
      await load(forceRefresh: true);
      return const Result.success(null);
    }
    if (result is Err<FavoriteItem>) {
      return Result.failure(result.failure);
    }

    return Result.failure(
      const UnknownFailure(
        'Unknown favorite toggle result',
        code: 'unknown_favorite_toggle',
      ),
    );
  }
}

/// EN: Favorites repository provider.
/// KO: 즐겨찾기 리포지토리 프로바이더.
final favoritesRepositoryProvider = FutureProvider<FavoritesRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return FavoritesRepositoryImpl(
    remoteDataSource: FavoritesRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Favorites controller provider.
/// KO: 즐겨찾기 컨트롤러 프로바이더.
final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, AsyncValue<List<FavoriteItem>>>((
      ref,
    ) {
      return FavoritesController(ref);
    });
