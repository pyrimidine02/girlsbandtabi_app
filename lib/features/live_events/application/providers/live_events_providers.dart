import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/persistence/selection_persistence.dart';
import '../../../../core/providers/core_providers.dart' as core_providers;
import '../../../../core/utils/result.dart';
import '../../data/datasources/live_events_local_datasource.dart';
import '../../data/datasources/live_events_remote_datasource.dart';
import '../../data/repositories/live_events_repository_impl.dart';
import '../../domain/entities/live_event.dart';
import '../../domain/repositories/live_events_repository.dart';
import '../../domain/usecases/get_live_events_usecase.dart';
import '../../domain/usecases/get_live_event_by_id_usecase.dart';
import '../../domain/usecases/search_live_events_usecase.dart';
import '../../domain/usecases/toggle_live_event_favorite_usecase.dart';
import '../controllers/live_events_controller.dart';

/// EN: Live events remote data source provider
/// KO: 라이브 이벤트 원격 데이터 소스 프로바이더
final liveEventsRemoteDataSourceProvider = Provider<LiveEventsRemoteDataSource>((ref) {
  final apiClient = ref.watch(core_providers.apiClientProvider);
  return LiveEventsRemoteDataSourceImpl(apiClient: apiClient);
});

/// EN: Live events local data source provider
/// KO: 라이브 이벤트 로컬 데이터 소스 프로바이더
final liveEventsLocalDataSourceProvider = Provider<LiveEventsLocalDataSource>((ref) {
  final selectionPersistence = ref.watch(core_providers.selectionPersistenceProvider);
  return LiveEventsLocalDataSourceImpl(selectionPersistence: selectionPersistence);
});

/// EN: Live events repository provider
/// KO: 라이브 이벤트 리포지토리 프로바이더
final liveEventsRepositoryProvider = Provider<LiveEventsRepository>((ref) {
  final remoteDataSource = ref.watch(liveEventsRemoteDataSourceProvider);
  final localDataSource = ref.watch(liveEventsLocalDataSourceProvider);
  return LiveEventsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// EN: Get live events use case provider
/// KO: 라이브 이벤트 가져오기 유스케이스 프로바이더
final getLiveEventsUseCaseProvider = Provider<GetLiveEventsUseCase>((ref) {
  final repository = ref.watch(liveEventsRepositoryProvider);
  return GetLiveEventsUseCase(repository);
});

/// EN: Get live event by ID use case provider
/// KO: ID로 라이브 이벤트 가져오기 유스케이스 프로바이더
final getLiveEventByIdUseCaseProvider = Provider<GetLiveEventByIdUseCase>((ref) {
  final repository = ref.watch(liveEventsRepositoryProvider);
  return GetLiveEventByIdUseCase(repository);
});

/// EN: Search live events use case provider
/// KO: 라이브 이벤트 검색 유스케이스 프로바이더
final searchLiveEventsUseCaseProvider = Provider<SearchLiveEventsUseCase>((ref) {
  final repository = ref.watch(liveEventsRepositoryProvider);
  return SearchLiveEventsUseCase(repository);
});

/// EN: Toggle live event favorite use case provider
/// KO: 라이브 이벤트 즐겨찾기 토글 유스케이스 프로바이더
final toggleLiveEventFavoriteUseCaseProvider = Provider<ToggleLiveEventFavoriteUseCase>((ref) {
  final repository = ref.watch(liveEventsRepositoryProvider);
  return ToggleLiveEventFavoriteUseCase(repository);
});

/// EN: Live events controller provider
/// KO: 라이브 이벤트 컨트롤러 프로바이더
final liveEventsControllerProvider = StateNotifierProvider<LiveEventsController, LiveEventsState>((ref) {
  final getLiveEventsUseCase = ref.watch(getLiveEventsUseCaseProvider);
  final searchLiveEventsUseCase = ref.watch(searchLiveEventsUseCaseProvider);
  final toggleFavoriteUseCase = ref.watch(toggleLiveEventFavoriteUseCaseProvider);

  return LiveEventsController(
    getLiveEventsUseCase: getLiveEventsUseCase,
    searchLiveEventsUseCase: searchLiveEventsUseCase,
    toggleFavoriteUseCase: toggleFavoriteUseCase,
  );
});

/// EN: Live event detail controller provider (by ID)
/// KO: 라이브 이벤트 상세 컨트롤러 프로바이더 (ID별)
final liveEventDetailProvider = StateNotifierProvider.family<LiveEventDetailController, LiveEventDetailState, String>((ref, eventId) {
  final getLiveEventByIdUseCase = ref.watch(getLiveEventByIdUseCaseProvider);
  final toggleFavoriteUseCase = ref.watch(toggleLiveEventFavoriteUseCaseProvider);

  return LiveEventDetailController(
    eventId: eventId,
    getLiveEventByIdUseCase: getLiveEventByIdUseCase,
    toggleFavoriteUseCase: toggleFavoriteUseCase,
  );
});

/// EN: Live event detail controller
/// KO: 라이브 이벤트 상세 컨트롤러
class LiveEventDetailController extends StateNotifier<LiveEventDetailState> {
  LiveEventDetailController({
    required this.eventId,
    required this.getLiveEventByIdUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const LiveEventDetailInitial()) {
    loadEvent();
  }

  final String eventId;
  final GetLiveEventByIdUseCase getLiveEventByIdUseCase;
  final ToggleLiveEventFavoriteUseCase toggleFavoriteUseCase;

  Future<void> loadEvent() async {
    state = const LiveEventDetailLoading();

    final result = await getLiveEventByIdUseCase(eventId);

    state = switch (result) {
      Success(:final data) => LiveEventDetailSuccess(event: data),
      ResultFailure(:final failure) => LiveEventDetailError(
          failure: failure,
        ),
    };
  }

  Future<void> toggleFavorite() async {
    if (state is! LiveEventDetailSuccess) return;

    final currentEvent = (state as LiveEventDetailSuccess).event;
    final params = ToggleLiveEventFavoriteParams(eventId: eventId);

    final result = await toggleFavoriteUseCase(params);

    switch (result) {
      case Success(:final data):
        state = (state as LiveEventDetailSuccess).copyWith(event: data);
      case ResultFailure():
        // EN: Could show error message
        // KO: 오류 메시지 표시 가능
        break;
    }
  }
}

/// EN: Base class for live event detail state.
/// KO: 라이브 이벤트 상세 상태의 기본 클래스.
sealed class LiveEventDetailState {
  const LiveEventDetailState();
}

/// EN: Initial idle state before loading begins.
/// KO: 로딩이 시작되기 전 초기 상태.
class LiveEventDetailInitial extends LiveEventDetailState {
  const LiveEventDetailInitial();
}

/// EN: Loading state while fetching event detail.
/// KO: 이벤트 상세 정보를 로드하는 동안의 로딩 상태.
class LiveEventDetailLoading extends LiveEventDetailState {
  const LiveEventDetailLoading();
}

/// EN: Success state containing the loaded event.
/// KO: 로드된 이벤트를 포함하는 성공 상태.
class LiveEventDetailSuccess extends LiveEventDetailState {
  const LiveEventDetailSuccess({required this.event});

  final LiveEvent event;

  LiveEventDetailSuccess copyWith({LiveEvent? event}) {
    return LiveEventDetailSuccess(event: event ?? this.event);
  }
}

/// EN: Error state including failure information.
/// KO: 실패 정보를 포함하는 오류 상태.
class LiveEventDetailError extends LiveEventDetailState {
  const LiveEventDetailError({required this.failure});

  final Failure failure;
}
