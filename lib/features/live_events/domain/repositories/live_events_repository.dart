import '../../../../core/utils/result.dart';
import '../entities/live_event.dart';

/// EN: Parameters for getting live events
/// KO: 라이브 이벤트 가져오기 매개변수
class GetLiveEventsParams {
  const GetLiveEventsParams({
    this.page = 0,
    this.size = 20,
    this.startDate,
    this.endDate,
    this.status,
    this.tags,
    this.unitIds,
  });

  final int page;
  final int size;
  final DateTime? startDate;
  final DateTime? endDate;
  final LiveEventStatus? status;
  final List<String>? tags;
  final List<String>? unitIds;
}

/// EN: Parameters for searching live events
/// KO: 라이브 이벤트 검색 매개변수
class SearchLiveEventsParams {
  const SearchLiveEventsParams({
    required this.query,
    this.page = 0,
    this.size = 20,
    this.startDate,
    this.endDate,
  });

  final String query;
  final int page;
  final int size;
  final DateTime? startDate;
  final DateTime? endDate;
}

/// EN: Parameters for toggling live event favorite
/// KO: 라이브 이벤트 즐겨찾기 토글 매개변수
class ToggleLiveEventFavoriteParams {
  const ToggleLiveEventFavoriteParams({
    required this.eventId,
  });

  final String eventId;
}

/// EN: Result container for paginated live event queries
/// KO: 페이지네이션된 라이브 이벤트 쿼리를 위한 결과 컨테이너
class LiveEventsResult {
  /// EN: Creates a new LiveEventsResult instance
  /// KO: 새로운 LiveEventsResult 인스턴스 생성
  const LiveEventsResult({
    required this.events,
    required this.totalCount,
    required this.hasMore,
  });

  /// EN: List of events in current page
  /// KO: 현재 페이지의 이벤트 목록
  final List<LiveEvent> events;

  /// EN: Total number of events matching the query
  /// KO: 쿼리에 일치하는 총 이벤트 수
  final int totalCount;

  /// EN: Whether there are more results available
  /// KO: 더 많은 결과가 사용 가능한지 여부
  final bool hasMore;
}

/// EN: Repository interface for live events data operations
/// KO: 라이브 이벤트 데이터 작업을 위한 리포지토리 인터페이스
abstract class LiveEventsRepository {
  /// EN: Get list of live events with optional filtering and pagination
  /// KO: 선택적 필터링 및 페이지네이션으로 라이브 이벤트 목록 가져오기
  Future<Result<List<LiveEvent>>> getLiveEvents(GetLiveEventsParams params);

  /// EN: Get a specific live event by ID
  /// KO: ID로 특정 라이브 이벤트 가져오기
  Future<Result<LiveEvent>> getLiveEventById(String id);

  /// EN: Search live events with query
  /// KO: 쿼리로 라이브 이벤트 검색
  Future<Result<List<LiveEvent>>> searchLiveEvents(SearchLiveEventsParams params);

  /// EN: Get upcoming live events
  /// KO: 예정된 라이브 이벤트 가져오기
  Future<Result<List<LiveEvent>>> getUpcomingLiveEvents({
    int page = 0,
    int size = 20,
  });

  /// EN: Get live events by status
  /// KO: 상태별 라이브 이벤트 가져오기
  Future<Result<List<LiveEvent>>> getLiveEventsByStatus({
    required LiveEventStatus status,
    int page = 0,
    int size = 20,
  });

  /// EN: Toggle favorite status for a live event
  /// KO: 라이브 이벤트의 즐겨찾기 상태 토글
  Future<Result<LiveEvent>> toggleFavorite(ToggleLiveEventFavoriteParams params);

  /// EN: Get user's favorite live events
  /// KO: 사용자의 즐겨찾기 라이브 이벤트 가져오기
  Future<Result<List<LiveEvent>>> getFavoriteLiveEvents({
    int page = 0,
    int size = 20,
  });
}