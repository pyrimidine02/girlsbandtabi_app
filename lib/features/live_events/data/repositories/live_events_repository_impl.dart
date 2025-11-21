import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/live_event.dart';
import '../../domain/repositories/live_events_repository.dart';
import '../datasources/live_events_local_datasource.dart';
import '../datasources/live_events_remote_datasource.dart';
import '../models/live_event_model.dart';

/// EN: Implementation of LiveEventsRepository
/// KO: LiveEventsRepository 구현
class LiveEventsRepositoryImpl implements LiveEventsRepository {
  /// EN: Creates LiveEventsRepositoryImpl with data sources
  /// KO: 데이터 소스와 함께 LiveEventsRepositoryImpl 생성
  const LiveEventsRepositoryImpl({
    required LiveEventsRemoteDataSource remoteDataSource,
    required LiveEventsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final LiveEventsRemoteDataSource _remoteDataSource;
  final LiveEventsLocalDataSource _localDataSource;

  @override
  Future<Result<List<LiveEvent>>> getLiveEvents(GetLiveEventsParams params) async {
    try {
      // EN: Use the default project ID
      // KO: 기본 프로젝트 ID 사용
      const projectId = ApiConstants.defaultProjectId;
      
      // EN: Try to get events from remote source first
      // KO: 먼저 원격 소스에서 이벤트 가져오기 시도
      try {
        final remoteEvents = await _remoteDataSource.getLiveEvents(params, projectId);
        final domainEvents = remoteEvents.map((model) => model.toDomain()).toList();

        // EN: Cache the events for offline access
        // KO: 오프라인 접근을 위해 이벤트 캐시
        await _localDataSource.cacheLiveEvents(remoteEvents);

        return Success(domainEvents);
      } catch (e) {
        // EN: If remote fails, try to get cached events
        // KO: 원격 실패 시 캐시된 이벤트 가져오기 시도
        final cachedEvents = await _localDataSource.getCachedLiveEvents();
        if (cachedEvents != null && cachedEvents.isNotEmpty) {
          final domainEvents = cachedEvents.map((model) => model.toDomain()).toList();
          return Success(domainEvents);
        }

        // EN: If both remote and cache fail, return error
        // KO: 원격과 캐시 모두 실패하면 오류 반환
        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to get live events: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<LiveEvent>> getLiveEventById(String id) async {
    try {
      // EN: Check cache first for quick access
      // KO: 빠른 접근을 위해 먼저 캐시 확인
      final cachedEvent = await _localDataSource.getCachedLiveEventById(id);
      if (cachedEvent != null) {
        return Success(cachedEvent.toDomain());
      }

      // EN: If not in cache, fetch from remote
      // KO: 캐시에 없으면 원격에서 가져오기
      try {
        final remoteEvent = await _remoteDataSource.getLiveEventById(id);
        final domainEvent = remoteEvent.toDomain();

        // EN: Cache the event for future access
        // KO: 향후 접근을 위해 이벤트 캐시
        await _localDataSource.cacheLiveEvent(remoteEvent);

        return Success(domainEvent);
      } catch (e) {
        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to get live event: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<LiveEvent>>> searchLiveEvents(SearchLiveEventsParams params) async {
    try {
      // EN: Use the default project ID
      // KO: 기본 프로젝트 ID 사용
      const projectId = ApiConstants.defaultProjectId;
      
      // EN: Search is always performed on remote data for accuracy
      // KO: 검색은 정확성을 위해 항상 원격 데이터에서 수행
      try {
        final remoteEvents = await _remoteDataSource.searchLiveEvents(params, projectId);
        final domainEvents = remoteEvents.map((model) => model.toDomain()).toList();

        return Success(domainEvents);
      } catch (e) {
        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to search live events: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<LiveEvent>>> getUpcomingLiveEvents({
    int page = 0,
    int size = 20,
  }) async {
    try {
      // EN: Use the default project ID
      // KO: 기본 프로젝트 ID 사용
      const projectId = ApiConstants.defaultProjectId;
      
      try {
        final remoteEvents = await _remoteDataSource.getUpcomingLiveEvents(
          projectId: projectId,
          page: page,
          size: size,
        );
        final domainEvents = remoteEvents.map((model) => model.toDomain()).toList();

        return Success(domainEvents);
      } catch (e) {
        // EN: For upcoming events, we can filter cached events by date
        // KO: 예정된 이벤트의 경우 캐시된 이벤트를 날짜로 필터링 가능
        final cachedEvents = await _localDataSource.getCachedLiveEvents();
        if (cachedEvents != null && cachedEvents.isNotEmpty) {
          final now = DateTime.now();
          final upcomingEvents = cachedEvents
              .where((event) => event.eventDate.isAfter(now) && 
                             event.status == LiveEventStatus.scheduled)
              .map((model) => model.toDomain())
              .toList();

          if (upcomingEvents.isNotEmpty) {
            return Success(upcomingEvents);
          }
        }

        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to get upcoming live events: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<LiveEvent>>> getLiveEventsByStatus({
    required LiveEventStatus status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      // EN: Use the default project ID
      // KO: 기본 프로젝트 ID 사용
      const projectId = ApiConstants.defaultProjectId;
      
      try {
        final remoteEvents = await _remoteDataSource.getLiveEventsByStatus(
          projectId: projectId,
          status: status,
          page: page,
          size: size,
        );
        final domainEvents = remoteEvents.map((model) => model.toDomain()).toList();

        return Success(domainEvents);
      } catch (e) {
        // EN: Filter cached events by status
        // KO: 상태별로 캐시된 이벤트 필터링
        final cachedEvents = await _localDataSource.getCachedLiveEvents();
        if (cachedEvents != null && cachedEvents.isNotEmpty) {
          final filteredEvents = cachedEvents
              .where((event) => event.status == status)
              .map((model) => model.toDomain())
              .toList();

          if (filteredEvents.isNotEmpty) {
            return Success(filteredEvents);
          }
        }

        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to get live events by status: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<LiveEvent>> toggleFavorite(ToggleLiveEventFavoriteParams params) async {
    try {
      try {
        // EN: Update favorite status on remote
        // KO: 원격에서 즐겨찾기 상태 업데이트
        final updatedEvent = await _remoteDataSource.toggleFavorite(params);
        final domainEvent = updatedEvent.toDomain();

        // EN: Update local cache
        // KO: 로컬 캐시 업데이트
        await _localDataSource.updateFavoriteStatus(
          params.eventId,
          updatedEvent.isFavorite,
        );

        return Success(domainEvent);
      } catch (e) {
        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to toggle favorite: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<LiveEvent>>> getFavoriteLiveEvents({
    int page = 0,
    int size = 20,
  }) async {
    try {
      try {
        final remoteEvents = await _remoteDataSource.getFavoriteLiveEvents(
          page: page,
          size: size,
        );
        final domainEvents = remoteEvents.map((model) => model.toDomain()).toList();

        return Success(domainEvents);
      } catch (e) {
        // EN: Get favorite IDs from local storage and filter cached events
        // KO: 로컬 저장소에서 즐겨찾기 ID를 가져와서 캐시된 이벤트 필터링
        final favoriteIds = await _localDataSource.getFavoriteEventIds();
        final cachedEvents = await _localDataSource.getCachedLiveEvents();

        if (cachedEvents != null && favoriteIds.isNotEmpty) {
          final favoriteEvents = cachedEvents
              .where((event) => favoriteIds.contains(event.id))
              .map((model) => model.toDomain())
              .toList();

          if (favoriteEvents.isNotEmpty) {
            return Success(favoriteEvents);
          }
        }

        if (e is NetworkException) {
          return ResultFailure(NetworkFailure(
            message: 'Network error: ${e.message}',
            code: 'NETWORK_ERROR',
          ));
        }
        return ResultFailure(UnknownFailure.unexpected('Failed to get favorite live events: $e'));
      }
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected('Unexpected error: $e'));
    }
  }
}
