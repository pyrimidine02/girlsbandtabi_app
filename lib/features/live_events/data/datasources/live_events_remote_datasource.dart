import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/live_event.dart';
import '../../domain/repositories/live_events_repository.dart';
import '../models/live_event_model.dart';

/// EN: Remote data source for live events API operations
/// KO: 라이브 이벤트 API 작업을 위한 원격 데이터 소스
abstract class LiveEventsRemoteDataSource {
  /// EN: Get live events from API
  /// KO: API에서 라이브 이벤트 가져오기
  Future<List<LiveEventModel>> getLiveEvents(GetLiveEventsParams params);

  /// EN: Get specific live event by ID from API
  /// KO: API에서 ID로 특정 라이브 이벤트 가져오기
  Future<LiveEventModel> getLiveEventById(String id);

  /// EN: Search live events from API
  /// KO: API에서 라이브 이벤트 검색
  Future<List<LiveEventModel>> searchLiveEvents(SearchLiveEventsParams params);

  /// EN: Get upcoming live events from API
  /// KO: API에서 예정된 라이브 이벤트 가져오기
  Future<List<LiveEventModel>> getUpcomingLiveEvents({
    int page = 0,
    int size = 20,
  });

  /// EN: Get live events by status from API
  /// KO: API에서 상태별 라이브 이벤트 가져오기
  Future<List<LiveEventModel>> getLiveEventsByStatus({
    required LiveEventStatus status,
    int page = 0,
    int size = 20,
  });

  /// EN: Toggle favorite status for live event
  /// KO: 라이브 이벤트의 즐겨찾기 상태 토글
  Future<LiveEventModel> toggleFavorite(ToggleLiveEventFavoriteParams params);

  /// EN: Get user's favorite live events from API
  /// KO: API에서 사용자의 즐겨찾기 라이브 이벤트 가져오기
  Future<List<LiveEventModel>> getFavoriteLiveEvents({
    int page = 0,
    int size = 20,
  });
}

/// EN: Implementation of LiveEventsRemoteDataSource
/// KO: LiveEventsRemoteDataSource 구현
class LiveEventsRemoteDataSourceImpl implements LiveEventsRemoteDataSource {
  /// EN: Creates LiveEventsRemoteDataSourceImpl with API client
  /// KO: API 클라이언트와 함께 LiveEventsRemoteDataSourceImpl 생성
  const LiveEventsRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  static const String _eventsEndpoint = '${ApiConstants.apiBase}/events';
  static const String _searchEventsEndpoint = '${ApiConstants.apiBase}/search/events';
  static const String _favoritesEndpoint = '${ApiConstants.apiBase}/events/favorites';
  static String _eventDetail(String id) => '$_eventsEndpoint/$id';
  static String _toggleFavorite(String id) => '${_eventDetail(id)}/toggle-favorite';

  @override
  Future<List<LiveEventModel>> getLiveEvents(GetLiveEventsParams params) async {
    try {
      // EN: Build query parameters based on API documentation
      // KO: API 문서를 기반으로 쿼리 매개변수 구축
      final queryParams = <String, dynamic>{
        'page': params.page,
        'size': params.size,
      };

      if (params.startDate != null) {
        queryParams['start_date'] = params.startDate!.toIso8601String();
      }
      if (params.endDate != null) {
        queryParams['end_date'] = params.endDate!.toIso8601String();
      }
      if (params.status != null) {
        queryParams['status'] = params.status!.name;
      }
      if (params.tags != null && params.tags!.isNotEmpty) {
        queryParams['tags'] = params.tags!.join(',');
      }
      if (params.unitIds != null && params.unitIds!.isNotEmpty) {
        queryParams['unit_ids'] = params.unitIds!.join(',');
      }

      // EN: Call API endpoint GET /api/v1/events
      // KO: API 엔드포인트 GET /api/v1/events 호출
      final response = await _apiClient.get(
        _eventsEndpoint,
        queryParameters: queryParams,
      );

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final List<dynamic> eventsJson = response.data['data'] ?? [];
      return eventsJson
          .map((json) => LiveEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get live events: $e');
    }
  }

  @override
  Future<LiveEventModel> getLiveEventById(String id) async {
    try {
      // EN: Call API endpoint GET /api/v1/events/{id}
      // KO: API 엔드포인트 GET /api/v1/events/{id} 호출
      final response = await _apiClient.get(_eventDetail(id));

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final Map<String, dynamic> eventJson = response.data['data'];
      return LiveEventModel.fromJson(eventJson);
    } catch (e) {
      throw Exception('Failed to get live event by ID: $e');
    }
  }

  @override
  Future<List<LiveEventModel>> searchLiveEvents(SearchLiveEventsParams params) async {
    try {
      final queryParams = <String, dynamic>{
        'q': params.query,
        'page': params.page,
        'size': params.size,
      };

      if (params.startDate != null) {
        queryParams['start_date'] = params.startDate!.toIso8601String();
      }
      if (params.endDate != null) {
        queryParams['end_date'] = params.endDate!.toIso8601String();
      }

      // EN: Call API endpoint GET /api/v1/search/events
      // KO: API 엔드포인트 GET /api/v1/search/events 호출
      final response = await _apiClient.get(
        _searchEventsEndpoint,
        queryParameters: queryParams,
      );

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final List<dynamic> eventsJson = response.data['data'] ?? [];
      return eventsJson
          .map((json) => LiveEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search live events: $e');
    }
  }

  @override
  Future<List<LiveEventModel>> getUpcomingLiveEvents({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        'status': 'scheduled',
        'start_date': DateTime.now().toIso8601String(),
      };

      // EN: Call API endpoint with upcoming filter
      // KO: 예정 필터로 API 엔드포인트 호출
      final response = await _apiClient.get(
        _eventsEndpoint,
        queryParameters: queryParams,
      );

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final List<dynamic> eventsJson = response.data['data'] ?? [];
      return eventsJson
          .map((json) => LiveEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming live events: $e');
    }
  }

  @override
  Future<List<LiveEventModel>> getLiveEventsByStatus({
    required LiveEventStatus status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'status': status.name,
        'page': page,
        'size': size,
      };

      // EN: Call API endpoint with status filter
      // KO: 상태 필터로 API 엔드포인트 호출
      final response = await _apiClient.get(
        _eventsEndpoint,
        queryParameters: queryParams,
      );

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final List<dynamic> eventsJson = response.data['data'] ?? [];
      return eventsJson
          .map((json) => LiveEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get live events by status: $e');
    }
  }

  @override
  Future<LiveEventModel> toggleFavorite(ToggleLiveEventFavoriteParams params) async {
    try {
      // EN: Call API endpoint POST /api/v1/events/{id}/toggle-favorite
      // KO: API 엔드포인트 POST /api/v1/events/{id}/toggle-favorite 호출
      final response = await _apiClient.post(_toggleFavorite(params.eventId));

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final Map<String, dynamic> eventJson = response.data['data'];
      return LiveEventModel.fromJson(eventJson);
    } catch (e) {
      throw Exception('Failed to toggle live event favorite: $e');
    }
  }

  @override
  Future<List<LiveEventModel>> getFavoriteLiveEvents({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      // EN: Call API endpoint GET /api/v1/events/favorites
      // KO: API 엔드포인트 GET /api/v1/events/favorites 호출
      final response = await _apiClient.get(
        _favoritesEndpoint,
        queryParameters: queryParams,
      );

      // EN: Parse response data
      // KO: 응답 데이터 파싱
      final List<dynamic> eventsJson = response.data['data'] ?? [];
      return eventsJson
          .map((json) => LiveEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get favorite live events: $e');
    }
  }
}
