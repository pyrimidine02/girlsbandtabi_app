/// EN: Live events controllers for list and detail views.
/// KO: 라이브 이벤트 리스트/상세 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/live_events_remote_data_source.dart';
import '../data/repositories/live_events_repository_impl.dart';
import '../domain/entities/live_event_entities.dart';
import '../domain/repositories/live_events_repository.dart';

// EN: Max number of additional retries on load failure (total attempts = 1 + _kMaxRetries).
// KO: 로드 실패 시 최대 추가 재시도 횟수 (총 시도 = 1 + _kMaxRetries).
const int _kMaxRetries = 2;

class LiveEventsListController
    extends StateNotifier<AsyncValue<List<LiveEventSummary>>> {
  LiveEventsListController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      load(forceRefresh: true);
    });
    _ref.listen<List<String>>(selectedLiveBandIdsProvider, (_, __) {
      load(forceRefresh: true);
    });
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(liveEventsRepositoryProvider.future);
    final bandIds = _ref.read(selectedLiveBandIdsProvider);

    // EN: Retry up to _kMaxRetries times on failure with exponential back-off.
    // KO: 실패 시 지수 백오프로 최대 _kMaxRetries회 재시도합니다.
    Result<List<LiveEventSummary>>? result;
    for (var attempt = 0; attempt <= _kMaxRetries; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: attempt));
        if (!mounted) return;
        AppLogger.info(
          'Retrying live events load (attempt $attempt)',
          tag: 'LiveEventsListController',
        );
      }
      result = await repository.getLiveEvents(
        projectId: projectKey,
        unitIds: bandIds,
        forceRefresh: forceRefresh || attempt > 0,
      );
      if (result is Success<List<LiveEventSummary>>) break;
    }

    if (!mounted) return;
    if (result is Success<List<LiveEventSummary>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<LiveEventSummary>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class LiveEventDetailController
    extends StateNotifier<AsyncValue<LiveEventDetail>> {
  LiveEventDetailController(this._ref, this.eventId)
    : super(const AsyncLoading());

  final Ref _ref;
  final String eventId;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(liveEventsRepositoryProvider.future);

    // EN: Retry up to _kMaxRetries times on failure with exponential back-off.
    // KO: 실패 시 지수 백오프로 최대 _kMaxRetries회 재시도합니다.
    Result<LiveEventDetail>? result;
    for (var attempt = 0; attempt <= _kMaxRetries; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: attempt));
        if (!mounted) return;
        AppLogger.info(
          'Retrying live event detail load (attempt $attempt)',
          tag: 'LiveEventDetailController',
        );
      }
      result = await repository.getLiveEventDetail(
        projectId: projectKey,
        eventId: eventId,
        forceRefresh: forceRefresh || attempt > 0,
      );
      if (result is Success<LiveEventDetail>) break;
    }

    if (!mounted) return;
    if (result is Success<LiveEventDetail>) {
      state = AsyncData(result.data);
    } else if (result is Err<LiveEventDetail>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

/// EN: Live events repository provider.
/// KO: 라이브 이벤트 리포지토리 프로바이더.
final liveEventsRepositoryProvider = FutureProvider<LiveEventsRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
  return LiveEventsRepositoryImpl(
    remoteDataSource: LiveEventsRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Live events list controller provider.
/// KO: 라이브 이벤트 리스트 컨트롤러 프로바이더.
final liveEventsListControllerProvider =
    StateNotifierProvider<
      LiveEventsListController,
      AsyncValue<List<LiveEventSummary>>
    >((ref) {
      return LiveEventsListController(ref)..load();
    });

/// EN: Live event detail controller provider.
/// KO: 라이브 이벤트 상세 컨트롤러 프로바이더.
final liveEventDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<LiveEventDetailController, AsyncValue<LiveEventDetail>, String>((
      ref,
      eventId,
    ) {
      return LiveEventDetailController(ref, eventId)..load();
    });

/// EN: Selected band IDs for live events filter.
/// KO: 라이브 이벤트 필터용 선택된 밴드 ID 목록.
final selectedLiveBandIdsProvider = StateProvider<List<String>>((ref) {
  return const [];
});

/// EN: Selected year for live events client-side filter (null = all years).
/// KO: 라이브 이벤트 클라이언트 연도 필터 선택값 (null = 전체 연도).
final selectedLiveEventYearProvider = StateProvider<int?>((ref) {
  return null;
});
