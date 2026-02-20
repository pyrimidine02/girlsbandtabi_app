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
    String? projectId,
    List<String> unitIds = const [],
    List<String> types = const [],
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(
      query: query,
      projectId: projectId,
      unitIds: unitIds,
      types: types,
      page: page,
      size: size,
    );
    // EN: Use staleWhileRevalidate — show cached search results instantly.
    // KO: staleWhileRevalidate 사용 — 캐시된 검색 결과 즉시 표시.
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<List<SearchItemDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: () => _fetchSearch(
          query: query,
          projectId: projectId,
          unitIds: unitIds,
          types: types,
          page: page,
          size: size,
        ),
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

  Future<List<SearchItemDto>> _fetchSearch({
    required String query,
    String? projectId,
    List<String> unitIds = const [],
    List<String> types = const [],
    int page = 0,
    int size = 20,
  }) async {
    final result = await _remoteDataSource.search(
      query: query,
      projectId: projectId,
      unitIds: unitIds,
      types: types,
      page: page,
      size: size,
    );

    if (result is Success<List<SearchItemDto>>) {
      return result.data;
    }
    if (result is Err<List<SearchItemDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure('Unknown search result', code: 'unknown_search');
  }

  String _cacheKey({
    required String query,
    String? projectId,
    List<String> unitIds = const [],
    List<String> types = const [],
    int page = 0,
    int size = 20,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedProjectId = projectId?.trim().toLowerCase() ?? '';
    final normalizedUnitIds = List<String>.from(unitIds)
      ..removeWhere((unitId) => unitId.trim().isEmpty)
      ..sort();
    final normalizedTypes = List<String>.from(types)
      ..removeWhere((type) => type.trim().isEmpty)
      ..sort();
    final unitKey = normalizedUnitIds.isEmpty
        ? 'all'
        : normalizedUnitIds.join(',');
    final typeKey = normalizedTypes.isEmpty ? 'all' : normalizedTypes.join(',');
    return 'search:$normalizedQuery:$normalizedProjectId:$unitKey:$typeKey:$page:$size';
  }
}
