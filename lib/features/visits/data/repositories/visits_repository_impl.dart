/// EN: Visits repository implementation with caching.
/// KO: 캐시를 포함한 방문 기록 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/visit_entities.dart';
import '../../domain/repositories/visits_repository.dart';
import '../datasources/visits_remote_data_source.dart';
import '../dto/visit_dto.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  VisitsRepositoryImpl({
    required VisitsRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final VisitsRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<List<VisitEvent>>> getVisits({
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<List<VisitEventDto>>(
        key: _visitsCacheKey(page, size),
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: () => _fetchVisits(page: page, size: size),
        toJson: _encodeVisitList,
        fromJson: _decodeVisitList,
      );

      final entities = cacheResult.data
          .map(VisitEvent.fromDto)
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<VisitEvent>>> getAllVisits({
    int pageSize = 50,
    bool forceRefresh = false,
  }) async {
    final allVisits = <VisitEvent>[];
    var page = 0;
    var shouldRefresh = forceRefresh;

    while (true) {
      final result = await getVisits(
        page: page,
        size: pageSize,
        forceRefresh: shouldRefresh,
      );
      if (result is Err<List<VisitEvent>>) {
        return Result.failure(result.failure);
      }
      final visits = (result as Success<List<VisitEvent>>).data;
      allVisits.addAll(visits);
      if (visits.length < pageSize) break;
      page += 1;
      shouldRefresh = false;
    }

    return Result.success(allVisits);
  }

  @override
  Future<Result<VisitSummary>> getVisitSummary({
    required String placeId,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<VisitSummaryDto>(
        key: _summaryCacheKey(placeId),
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: () => _fetchSummary(placeId: placeId),
        toJson: (dto) => dto.toJson(),
        fromJson: VisitSummaryDto.fromJson,
      );
      return Result.success(VisitSummary.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  Future<List<VisitEventDto>> _fetchVisits({
    required int page,
    required int size,
  }) async {
    final result = await _remoteDataSource.fetchUserVisits(
      page: page,
      size: size,
    );
    if (result is Success<List<VisitEventDto>>) {
      return result.data;
    }
    if (result is Err<List<VisitEventDto>>) {
      throw result.failure;
    }
    throw const UnknownFailure(
      'Unknown visit list result',
      code: 'unknown_visit_list',
    );
  }

  Future<VisitSummaryDto> _fetchSummary({required String placeId}) async {
    final result = await _remoteDataSource.fetchVisitSummary(placeId: placeId);
    if (result is Success<VisitSummaryDto>) {
      return result.data;
    }
    if (result is Err<VisitSummaryDto>) {
      throw result.failure;
    }
    throw const UnknownFailure(
      'Unknown visit summary result',
      code: 'unknown_visit_summary',
    );
  }
}

String _visitsCacheKey(int page, int size) =>
    'user_visits_page_${page}_size_$size';
String _summaryCacheKey(String placeId) => 'user_visits_summary_$placeId';

Map<String, dynamic> _encodeVisitList(List<VisitEventDto> items) {
  return {
    'items': items.map((item) => item.toJson()).toList(),
  };
}

List<VisitEventDto> _decodeVisitList(Map<String, dynamic> json) {
  final raw = json['items'];
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(VisitEventDto.fromJson)
        .toList();
  }
  return <VisitEventDto>[];
}
