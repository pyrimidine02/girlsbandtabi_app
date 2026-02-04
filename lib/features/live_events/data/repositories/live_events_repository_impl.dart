/// EN: Live events repository implementation with caching.
/// KO: 캐시를 포함한 라이브 이벤트 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/live_event_entities.dart';
import '../../domain/repositories/live_events_repository.dart';
import '../datasources/live_events_remote_data_source.dart';
import '../dto/live_event_dto.dart';

class LiveEventsRepositoryImpl implements LiveEventsRepository {
  LiveEventsRepositoryImpl({
    required LiveEventsRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final LiveEventsRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<List<LiveEventSummary>>> getLiveEvents({
    required String projectId,
    List<String> unitIds = const [],
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _listCacheKey(projectId, unitIds, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager
          .resolve<List<LiveEventSummaryDto>>(
            key: cacheKey,
            policy: policy,
            ttl: const Duration(minutes: 5),
            fetcher: () => _fetchLiveEvents(projectId, unitIds, page, size),
            toJson: (dtos) => {'items': dtos.map((e) => e.toJson()).toList()},
            fromJson: (json) {
              final items = json['items'];
              if (items is List) {
                return items
                    .whereType<Map<String, dynamic>>()
                    .map(LiveEventSummaryDto.fromJson)
                    .toList();
              }
              return <LiveEventSummaryDto>[];
            },
          );

      final entities = cacheResult.data
          .map((dto) => LiveEventSummary.fromDto(dto))
          .toList();

      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<LiveEventDetail>> getLiveEventDetail({
    required String projectId,
    required String eventId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _detailCacheKey(projectId, eventId);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<LiveEventDetailDto>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: () => _fetchLiveEventDetail(projectId, eventId),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => LiveEventDetailDto.fromJson(json),
      );

      return Result.success(LiveEventDetail.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<List<LiveEventSummaryDto>> _fetchLiveEvents(
    String projectId,
    List<String> unitIds,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchLiveEvents(
      projectId: projectId,
      unitIds: unitIds,
      page: page,
      size: size,
    );

    if (result is Success<List<LiveEventSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<LiveEventSummaryDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown live events result',
      code: 'unknown_live_events',
    );
  }

  Future<LiveEventDetailDto> _fetchLiveEventDetail(
    String projectId,
    String eventId,
  ) async {
    final result = await _remoteDataSource.fetchLiveEventDetail(
      projectId: projectId,
      eventId: eventId,
    );

    if (result is Success<LiveEventDetailDto>) {
      return result.data;
    }
    if (result is Err<LiveEventDetailDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown live event detail result',
      code: 'unknown_live_event_detail',
    );
  }

  String _listCacheKey(
    String projectId,
    List<String> unitIds,
    int page,
    int size,
  ) {
    final units = unitIds.isEmpty ? 'all' : unitIds.join(',');
    return 'live_events:$projectId:$units:p$page:s$size';
  }

  String _detailCacheKey(String projectId, String eventId) {
    return 'live_event_detail:$projectId:$eventId';
  }
}
