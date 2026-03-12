/// EN: Favorites controller for saved items.
/// KO: 즐겨찾기 컨트롤러.
library;

import 'dart:async' show unawaited;

import '../../../core/connectivity/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/favorites_remote_data_source.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../domain/entities/favorite_entities.dart';
import '../domain/repositories/favorites_repository.dart';
import 'pending_favorite_mutation.dart';

class FavoritesController
    extends StateNotifier<AsyncValue<List<FavoriteItem>>> {
  FavoritesController(this._ref) : super(const AsyncLoading()) {
    load();
    _ref.listen<AsyncValue<ConnectivityStatus>>(connectivityStatusProvider, (
      _,
      next,
    ) {
      if (next.valueOrNull == ConnectivityStatus.online) {
        unawaited(syncPendingMutations());
      }
    });
    _ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next && previous != true) {
        unawaited(syncPendingMutations());
      }
      if (!next) {
        state = const AsyncData([]);
      }
    });
    unawaited(syncPendingMutations());
  }

  final Ref _ref;
  bool _isSyncingPending = false;
  static const int _maxPendingMutations = 200;

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
    final targetIsFavorite = !currentlyFavorite;
    _applyOptimisticFavoriteToggle(
      entityId: entityId,
      type: type,
      targetIsFavorite: targetIsFavorite,
    );

    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) {
      await _enqueuePendingMutation(
        entityId: entityId,
        type: type,
        targetIsFavorite: targetIsFavorite,
      );
      return const Result.success(null);
    }

    final result = await _applyRemoteToggle(
      repository: repository,
      entityId: entityId,
      type: type,
      targetIsFavorite: targetIsFavorite,
    );
    if (result is Success<void>) {
      await _dequeuePendingMutation(entityId: entityId, type: type);
      await load(forceRefresh: true);
      return const Result.success(null);
    }
    if (result is Err<void>) {
      if (_shouldQueueForRetry(result.failure)) {
        await _enqueuePendingMutation(
          entityId: entityId,
          type: type,
          targetIsFavorite: targetIsFavorite,
        );
        return const Result.success(null);
      }
      await load(forceRefresh: true);
      return Result.failure(result.failure);
    }

    return Result.failure(
      const UnknownFailure(
        'Unknown favorite toggle result',
        code: 'unknown_favorite_toggle',
      ),
    );
  }

  Future<void> syncPendingMutations() async {
    if (_isSyncingPending) {
      return;
    }
    if (!_ref.read(isAuthenticatedProvider)) {
      return;
    }
    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) {
      return;
    }

    _isSyncingPending = true;
    try {
      final pending = await _readPendingMutations();
      if (pending.isEmpty) {
        return;
      }

      final repository = await _ref.read(favoritesRepositoryProvider.future);
      final remaining = <PendingFavoriteMutation>[];
      var appliedCount = 0;

      for (var i = 0; i < pending.length; i += 1) {
        final mutation = pending[i];
        final result = await _applyRemoteToggle(
          repository: repository,
          entityId: mutation.entityId,
          type: mutation.type,
          targetIsFavorite: mutation.isFavorite,
        );
        if (result is Success<void>) {
          appliedCount += 1;
          continue;
        }

        if (result is Err<void>) {
          if (_shouldQueueForRetry(result.failure)) {
            remaining.add(mutation);
            remaining.addAll(pending.skip(i + 1));
            break;
          }
          // EN: Drop non-retriable mutation.
          // KO: 재시도 불가 작업은 폐기합니다.
          continue;
        }

        remaining.add(mutation);
      }

      await _writePendingMutations(remaining);
      if (appliedCount > 0) {
        await load(forceRefresh: true);
      }
    } finally {
      _isSyncingPending = false;
    }
  }

  Future<Result<void>> _applyRemoteToggle({
    required FavoritesRepository repository,
    required String entityId,
    required FavoriteType type,
    required bool targetIsFavorite,
  }) async {
    if (targetIsFavorite) {
      final result = await repository.addFavorite(
        entityId: entityId,
        type: type,
      );
      if (result is Success<FavoriteItem>) {
        return const Result.success(null);
      }
      if (result is Err<FavoriteItem>) {
        return Result.failure(result.failure);
      }
      return const Result.failure(
        UnknownFailure(
          'Unknown add favorite toggle result',
          code: 'unknown_add_favorite_toggle',
        ),
      );
    }

    return repository.removeFavorite(entityId: entityId, type: type);
  }

  void _applyOptimisticFavoriteToggle({
    required String entityId,
    required FavoriteType type,
    required bool targetIsFavorite,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final exists = current.any(
      (item) => item.entityId == entityId && item.type == type,
    );
    if (targetIsFavorite) {
      if (exists) {
        return;
      }
      state = AsyncData([
        FavoriteItem(entityId: entityId, type: type),
        ...current,
      ]);
      return;
    }

    if (!exists) {
      return;
    }
    state = AsyncData(
      current
          .where((item) => !(item.entityId == entityId && item.type == type))
          .toList(growable: false),
    );
  }

  bool _shouldQueueForRetry(Failure failure) {
    return failure is NetworkFailure || failure is AuthFailure;
  }

  Future<void> _enqueuePendingMutation({
    required String entityId,
    required FavoriteType type,
    required bool targetIsFavorite,
  }) async {
    final pending = await _readPendingMutations();
    pending.removeWhere(
      (mutation) => mutation.entityId == entityId && mutation.type == type,
    );
    pending.add(
      PendingFavoriteMutation(
        entityId: entityId,
        type: type,
        isFavorite: targetIsFavorite,
        queuedAt: DateTime.now(),
      ),
    );
    if (pending.length > _maxPendingMutations) {
      pending.removeRange(0, pending.length - _maxPendingMutations);
    }
    await _writePendingMutations(pending);
  }

  Future<void> _dequeuePendingMutation({
    required String entityId,
    required FavoriteType type,
  }) async {
    final pending = await _readPendingMutations();
    final before = pending.length;
    pending.removeWhere(
      (mutation) => mutation.entityId == entityId && mutation.type == type,
    );
    if (pending.length != before) {
      await _writePendingMutations(pending);
    }
  }

  Future<List<PendingFavoriteMutation>> _readPendingMutations() async {
    final storage = await _ref.read(localStorageProvider.future);
    final raw = storage.getPendingFavoriteMutations();
    return raw
        .map(PendingFavoriteMutation.fromJson)
        .where(
          (mutation) =>
              mutation.entityId.isNotEmpty &&
              mutation.type != FavoriteType.unknown,
        )
        .toList(growable: true);
  }

  Future<void> _writePendingMutations(
    List<PendingFavoriteMutation> pending,
  ) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.setPendingFavoriteMutations(
      pending.map((mutation) => mutation.toJson()).toList(growable: false),
    );
  }
}

/// EN: Favorites repository provider.
/// KO: 즐겨찾기 리포지토리 프로바이더.
final favoritesRepositoryProvider = FutureProvider<FavoritesRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
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
