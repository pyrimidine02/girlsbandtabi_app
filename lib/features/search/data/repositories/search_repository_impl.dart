/// EN: Search repository implementation with caching.
/// KO: 캐시를 포함한 검색 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';
import '../dto/search_item_dto.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final SearchRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<List<SearchItem>>> search({
    required String query,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(query);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<SearchItemDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 2),
        fetcher: () => _fetchSearch(query),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(SearchItemDto.fromJson)
                .toList();
          }
          return <SearchItemDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => SearchItem.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<List<SearchItemDto>> _fetchSearch(String query) async {
    final result = await _remoteDataSource.search(query: query);

    if (result is Success<List<SearchItemDto>>) {
      return result.data;
    }
    if (result is Err<List<SearchItemDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure('Unknown search result', code: 'unknown_search');
  }

  String _cacheKey(String query) {
    final normalized = query.trim().toLowerCase();
    return 'search:$normalized';
  }
}
