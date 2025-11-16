import '../../../../core/persistence/selection_persistence.dart';
import '../models/live_event_model.dart';

/// EN: Local data source for live events caching and persistence
/// KO: 라이브 이벤트 캐싱 및 지속성을 위한 로컬 데이터 소스
abstract class LiveEventsLocalDataSource {
  /// EN: Cache live events locally
  /// KO: 라이브 이벤트를 로컬에 캐시
  Future<void> cacheLiveEvents(List<LiveEventModel> events);

  /// EN: Get cached live events
  /// KO: 캐시된 라이브 이벤트 가져오기
  Future<List<LiveEventModel>?> getCachedLiveEvents();

  /// EN: Cache specific live event
  /// KO: 특정 라이브 이벤트 캐시
  Future<void> cacheLiveEvent(LiveEventModel event);

  /// EN: Get cached live event by ID
  /// KO: ID로 캐시된 라이브 이벤트 가져오기
  Future<LiveEventModel?> getCachedLiveEventById(String id);

  /// EN: Clear all cached live events
  /// KO: 모든 캐시된 라이브 이벤트 지우기
  Future<void> clearCache();

  /// EN: Update live event favorite status in cache
  /// KO: 캐시에서 라이브 이벤트 즐겨찾기 상태 업데이트
  Future<void> updateFavoriteStatus(String eventId, bool isFavorite);

  /// EN: Get favorite live event IDs
  /// KO: 즐겨찾기 라이브 이벤트 ID 가져오기
  Future<List<String>> getFavoriteEventIds();

  /// EN: Save favorite live event IDs
  /// KO: 즐겨찾기 라이브 이벤트 ID 저장
  Future<void> saveFavoriteEventIds(List<String> eventIds);
}

/// EN: Implementation of LiveEventsLocalDataSource using SelectionPersistence
/// KO: SelectionPersistence를 사용한 LiveEventsLocalDataSource 구현
class LiveEventsLocalDataSourceImpl implements LiveEventsLocalDataSource {
  /// EN: Creates LiveEventsLocalDataSourceImpl with persistence
  /// KO: 지속성과 함께 LiveEventsLocalDataSourceImpl 생성
  const LiveEventsLocalDataSourceImpl({
    required SelectionPersistence selectionPersistence,
  }) : _selectionPersistence = selectionPersistence;

  final SelectionPersistence _selectionPersistence;

  // EN: Cache keys for different data types
  // KO: 다양한 데이터 타입을 위한 캐시 키
  static const String _liveEventsCacheKey = 'cached_live_events';
  static const String _liveEventCacheKeyPrefix = 'cached_live_event_';
  static const String _favoriteEventIdsKey = 'favorite_event_ids';

  @override
  Future<void> cacheLiveEvents(List<LiveEventModel> events) async {
    try {
      // EN: Convert events to JSON and store
      // KO: 이벤트를 JSON으로 변환하고 저장
      final eventsJson = events.map((event) => event.toJson()).toList();
      await _selectionPersistence.saveSelection(
        _liveEventsCacheKey,
        eventsJson,
      );

      // EN: Also cache individual events for quick access
      // KO: 빠른 접근을 위해 개별 이벤트도 캐시
      for (final event in events) {
        await cacheLiveEvent(event);
      }
    } catch (e) {
      throw Exception('Failed to cache live events: $e');
    }
  }

  @override
  Future<List<LiveEventModel>?> getCachedLiveEvents() async {
    try {
      final cachedData = await _selectionPersistence.getSelection(
        _liveEventsCacheKey,
      );

      if (cachedData == null) return null;

      // EN: Parse cached JSON data
      // KO: 캐시된 JSON 데이터 파싱
      final List<dynamic> eventsJson = cachedData as List<dynamic>;
      return eventsJson
          .map((json) => LiveEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // EN: Return null if parsing fails
      // KO: 파싱 실패 시 null 반환
      return null;
    }
  }

  @override
  Future<void> cacheLiveEvent(LiveEventModel event) async {
    try {
      final cacheKey = '$_liveEventCacheKeyPrefix${event.id}';
      await _selectionPersistence.saveSelection(
        cacheKey,
        event.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to cache live event: $e');
    }
  }

  @override
  Future<LiveEventModel?> getCachedLiveEventById(String id) async {
    try {
      final cacheKey = '$_liveEventCacheKeyPrefix$id';
      final cachedData = await _selectionPersistence.getSelection(cacheKey);

      if (cachedData == null) return null;

      // EN: Parse cached JSON data
      // KO: 캐시된 JSON 데이터 파싱
      return LiveEventModel.fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      // EN: Return null if parsing fails
      // KO: 파싱 실패 시 null 반환
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // EN: Clear main events cache
      // KO: 메인 이벤트 캐시 지우기
      await _selectionPersistence.clearSelection(_liveEventsCacheKey);

      // EN: Clear favorite IDs cache
      // KO: 즐겨찾기 ID 캐시 지우기
      await _selectionPersistence.clearSelection(_favoriteEventIdsKey);

      // EN: Note: Individual event cache cleanup would require tracking all cached IDs
      // KO: 참고: 개별 이벤트 캐시 정리는 모든 캐시된 ID를 추적해야 함
      // EN: For now, they will expire based on the persistence implementation's TTL
      // KO: 현재로서는 지속성 구현의 TTL에 따라 만료됨
    } catch (e) {
      throw Exception('Failed to clear live events cache: $e');
    }
  }

  @override
  Future<void> updateFavoriteStatus(String eventId, bool isFavorite) async {
    try {
      // EN: Update individual event cache if exists
      // KO: 존재하는 경우 개별 이벤트 캐시 업데이트
      final cachedEvent = await getCachedLiveEventById(eventId);
      if (cachedEvent != null) {
        final updatedEvent = cachedEvent.copyWith(isFavorite: isFavorite);
        await cacheLiveEvent(updatedEvent);
      }

      // EN: Update main events cache if exists
      // KO: 존재하는 경우 메인 이벤트 캐시 업데이트
      final cachedEvents = await getCachedLiveEvents();
      if (cachedEvents != null) {
        final updatedEvents = cachedEvents.map((event) {
          if (event.id == eventId) {
            return event.copyWith(isFavorite: isFavorite);
          }
          return event;
        }).toList();
        await cacheLiveEvents(updatedEvents);
      }

      // EN: Update favorite IDs list
      // KO: 즐겨찾기 ID 목록 업데이트
      final favoriteIds = await getFavoriteEventIds();
      final updatedFavoriteIds = List<String>.from(favoriteIds);

      if (isFavorite) {
        if (!updatedFavoriteIds.contains(eventId)) {
          updatedFavoriteIds.add(eventId);
        }
      } else {
        updatedFavoriteIds.remove(eventId);
      }

      await saveFavoriteEventIds(updatedFavoriteIds);
    } catch (e) {
      throw Exception('Failed to update favorite status: $e');
    }
  }

  @override
  Future<List<String>> getFavoriteEventIds() async {
    try {
      final cachedData = await _selectionPersistence.getSelection(
        _favoriteEventIdsKey,
      );

      if (cachedData == null) return [];

      // EN: Parse cached favorite IDs
      // KO: 캐시된 즐겨찾기 ID 파싱
      return List<String>.from(cachedData as List<dynamic>);
    } catch (e) {
      // EN: Return empty list if parsing fails
      // KO: 파싱 실패 시 빈 목록 반환
      return [];
    }
  }

  @override
  Future<void> saveFavoriteEventIds(List<String> eventIds) async {
    try {
      await _selectionPersistence.saveSelection(
        _favoriteEventIdsKey,
        eventIds,
      );
    } catch (e) {
      throw Exception('Failed to save favorite event IDs: $e');
    }
  }
}