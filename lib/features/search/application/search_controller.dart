/// EN: Search controllers for query results and history.
/// KO: 검색 결과/기록 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/search_remote_data_source.dart';
import '../data/repositories/search_repository_impl.dart';
import '../domain/entities/search_entities.dart';
import '../domain/repositories/search_repository.dart';

class SearchController extends StateNotifier<AsyncValue<List<SearchItem>>> {
  SearchController(this._ref) : super(const AsyncData([]));

  final Ref _ref;

  Future<void> search(String query, {bool forceRefresh = false}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(searchRepositoryProvider.future);
    final result = await repository.search(
      query: trimmed,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<SearchItem>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<SearchItem>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class SearchHistoryController extends StateNotifier<List<String>> {
  SearchHistoryController(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final storage = await _ref.read(localStorageProvider.future);
    state = storage.getRecentSearches();
  }

  Future<void> addSearch(String query) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.addRecentSearch(query);
    state = storage.getRecentSearches();
  }

  Future<void> removeSearch(String query) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.removeRecentSearch(query);
    state = storage.getRecentSearches();
  }

  Future<void> clear() async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.clearRecentSearches();
    state = const [];
  }
}

/// EN: Search repository provider.
/// KO: 검색 리포지토리 프로바이더.
final searchRepositoryProvider = FutureProvider<SearchRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return SearchRepositoryImpl(
    remoteDataSource: SearchRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Search controller provider.
/// KO: 검색 컨트롤러 프로바이더.
final searchControllerProvider =
    StateNotifierProvider<SearchController, AsyncValue<List<SearchItem>>>((
      ref,
    ) {
      return SearchController(ref);
    });

/// EN: Search history controller provider.
/// KO: 검색 기록 컨트롤러 프로바이더.
final searchHistoryControllerProvider =
    StateNotifierProvider<SearchHistoryController, List<String>>((ref) {
      return SearchHistoryController(ref);
    });
