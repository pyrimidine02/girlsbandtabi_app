import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/live_event.dart';
import '../../domain/usecases/get_live_events_usecase.dart';
import '../../domain/usecases/search_live_events_usecase.dart';
import '../../domain/usecases/toggle_live_event_favorite_usecase.dart';
import '../../domain/repositories/live_events_repository.dart';

part 'live_events_controller.freezed.dart';

/// EN: State representation for live events list
/// KO: 라이브 이벤트 목록 상태 표현
@freezed
class LiveEventsState with _$LiveEventsState {
  /// EN: Initial state
  /// KO: 초기 상태
  const factory LiveEventsState.initial() = _Initial;
  
  /// EN: Loading state during live events operations
  /// KO: 라이브 이벤트 작업 중 로딩 상태
  const factory LiveEventsState.loading() = _Loading;
  
  /// EN: Success state with live events data
  /// KO: 라이브 이벤트 데이터와 함께하는 성공 상태
  const factory LiveEventsState.success({
    required List<LiveEvent> events,
    @Default(false) bool hasMore,
    @Default(0) int currentPage,
  }) = _Success;
  
  /// EN: Error state with failure information
  /// KO: 실패 정보와 함께하는 오류 상태
  const factory LiveEventsState.error({
    required Failure failure,
  }) = _Error;
}

/// EN: Controller for managing live events state and operations
/// KO: 라이브 이벤트 상태 및 작업을 관리하는 컨트롤러
class LiveEventsController extends StateNotifier<LiveEventsState> {
  /// EN: Creates LiveEventsController with use cases
  /// KO: 유스케이스와 함께 LiveEventsController 생성
  LiveEventsController({
    required this.getLiveEventsUseCase,
    required this.searchLiveEventsUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const LiveEventsState.initial());

  /// EN: Use case for getting live events
  /// KO: 라이브 이벤트들을 가져오는 유스케이스
  final GetLiveEventsUseCase getLiveEventsUseCase;

  /// EN: Use case for searching live events
  /// KO: 라이브 이벤트 검색 유스케이스
  final SearchLiveEventsUseCase searchLiveEventsUseCase;

  /// EN: Use case for toggling favorite status
  /// KO: 즐겨찾기 상태 토글 유스케이스
  final ToggleLiveEventFavoriteUseCase toggleFavoriteUseCase;

  /// EN: Current filter settings
  /// KO: 현재 필터 설정
  LiveEventStatus? _currentStatus;
  List<String>? _currentTags;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  /// EN: Load live events with optional filters
  /// KO: 선택적 필터로 라이브 이벤트 로드
  Future<void> loadLiveEvents({
    LiveEventStatus? status,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    bool refresh = false,
  }) async {
    // EN: Store current filter settings
    // KO: 현재 필터 설정 저장
    _currentStatus = status;
    _currentTags = tags;
    _currentStartDate = startDate;
    _currentEndDate = endDate;

    if (refresh || state is! _Success) {
      state = const LiveEventsState.loading();
    }

    final params = GetLiveEventsParams(
      page: 0,
      size: 20,
      status: status,
      tags: tags,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await getLiveEventsUseCase(params);

    state = switch (result) {
      Success(:final data) => LiveEventsState.success(
          events: data,
          hasMore: data.length >= 20,
          currentPage: 0,
        ),
      ResultFailure(:final failure) => LiveEventsState.error(
          failure: failure,
        ),
    };
  }

  /// EN: Load more live events (pagination)
  /// KO: 더 많은 라이브 이벤트들 로드 (페이지네이션)
  Future<void> loadMoreLiveEvents() async {
    if (state is! _Success) return;

    final currentState = state as _Success;
    if (!currentState.hasMore) return;

    final params = GetLiveEventsParams(
      page: currentState.currentPage + 1,
      size: 20,
      status: _currentStatus,
      tags: _currentTags,
      startDate: _currentStartDate,
      endDate: _currentEndDate,
    );

    final result = await getLiveEventsUseCase(params);

    state = switch (result) {
      Success(:final data) => currentState.copyWith(
          events: [...currentState.events, ...data],
          hasMore: data.length >= 20,
          currentPage: currentState.currentPage + 1,
        ),
      ResultFailure() => state, // EN: Keep current state on failure / KO: 실패시 현재 상태 유지
    };
  }

  /// EN: Search live events with query
  /// KO: 쿼리로 라이브 이벤트 검색
  Future<void> searchLiveEvents({
    required String query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (query.trim().isEmpty) {
      // EN: If query is empty, load regular events
      // KO: 쿼리가 비어있으면 일반 이벤트들 로드
      await loadLiveEvents(refresh: true);
      return;
    }

    state = const LiveEventsState.loading();

    final params = SearchLiveEventsParams(
      query: query,
      page: 0,
      size: 50, // EN: More results for search / KO: 검색에는 더 많은 결과
      startDate: startDate,
      endDate: endDate,
    );

    final result = await searchLiveEventsUseCase(params);

    state = switch (result) {
      Success(:final data) => LiveEventsState.success(
          events: data,
          hasMore: false, // EN: No pagination for search / KO: 검색에는 페이지네이션 없음
          currentPage: 0,
        ),
      ResultFailure(:final failure) => LiveEventsState.error(
          failure: failure,
        ),
    };
  }

  /// EN: Toggle favorite status of a live event
  /// KO: 라이브 이벤트의 즐겨찾기 상태 토글
  Future<void> toggleFavorite(String eventId) async {
    final params = ToggleLiveEventFavoriteParams(eventId: eventId);

    final result = await toggleFavoriteUseCase(params);

    switch (result) {
      case Success(:final data):
        // EN: Update the event in current state
        // KO: 현재 상태에서 이벤트 업데이트
        _updateEventInState(data);
      case ResultFailure():
        // EN: Could show a snackbar or handle error
        // KO: 스낵바를 표시하거나 오류를 처리할 수 있음
        break;
    }
  }

  /// EN: Filter events by status
  /// KO: 상태별 이벤트 필터링
  Future<void> filterByStatus(LiveEventStatus? status) async {
    await loadLiveEvents(
      status: status,
      tags: _currentTags,
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      refresh: true,
    );
  }

  /// EN: Filter events by date range
  /// KO: 날짜 범위별 이벤트 필터링
  Future<void> filterByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await loadLiveEvents(
      status: _currentStatus,
      tags: _currentTags,
      startDate: startDate,
      endDate: endDate,
      refresh: true,
    );
  }

  /// EN: Refresh current events
  /// KO: 현재 이벤트들 새로 고침
  Future<void> refresh() async {
    await loadLiveEvents(
      status: _currentStatus,
      tags: _currentTags,
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      refresh: true,
    );
  }

  /// EN: Clear current state
  /// KO: 현재 상태 지우기
  void clearState() {
    state = const LiveEventsState.initial();
    _currentStatus = null;
    _currentTags = null;
    _currentStartDate = null;
    _currentEndDate = null;
  }

  /// EN: Clear error state
  /// KO: 오류 상태 지우기
  void clearError() {
    if (state is _Error) {
      state = const LiveEventsState.initial();
    }
  }

  /// EN: Update a specific event in the current state
  /// KO: 현재 상태에서 특정 이벤트 업데이트
  void _updateEventInState(LiveEvent updatedEvent) {
    if (state is! _Success) return;

    final currentState = state as _Success;
    final updatedEvents = currentState.events.map((event) {
      return event.id == updatedEvent.id ? updatedEvent : event;
    }).toList();

    state = currentState.copyWith(events: updatedEvents);
  }

  /// EN: Check if currently loading
  /// KO: 현재 로딩 중인지 확인
  bool get isLoading => state is _Loading;

  /// EN: Check if has events
  /// KO: 이벤트가 있는지 확인
  bool get hasEvents => state is _Success && (state as _Success).events.isNotEmpty;

  /// EN: Get current events
  /// KO: 현재 이벤트들 가져오기
  List<LiveEvent> get events => switch (state) {
    _Success(:final events) => events,
    _ => [],
  };

  /// EN: Check if has more events to load
  /// KO: 로드할 이벤트가 더 있는지 확인
  bool get hasMore => switch (state) {
    _Success(:final hasMore) => hasMore,
    _ => false,
  };

  /// EN: Get current error
  /// KO: 현재 오류 가져오기
  Failure? get error => switch (state) {
    _Error(:final failure) => failure,
    _ => null,
  };
}
