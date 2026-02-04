/// EN: Live events controllers for list and detail views.
/// KO: 라이브 이벤트 리스트/상세 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/live_events_remote_data_source.dart';
import '../data/repositories/live_events_repository_impl.dart';
import '../domain/entities/live_event_entities.dart';
import '../domain/repositories/live_events_repository.dart';

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

    final result = await repository.getLiveEvents(
      projectId: projectKey,
      unitIds: bandIds,
      forceRefresh: forceRefresh,
    );

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

    final result = await repository.getLiveEventDetail(
      projectId: projectKey,
      eventId: eventId,
      forceRefresh: forceRefresh,
    );

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
  final cacheManager = await ref.watch(cacheManagerProvider.future);
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
final liveEventDetailControllerProvider =
    StateNotifierProvider.family<
      LiveEventDetailController,
      AsyncValue<LiveEventDetail>,
      String
    >((ref, eventId) {
      return LiveEventDetailController(ref, eventId)..load();
    });

/// EN: Selected band IDs for live events filter.
/// KO: 라이브 이벤트 필터용 선택된 밴드 ID 목록.
final selectedLiveBandIdsProvider = StateProvider<List<String>>((ref) {
  return const [];
});
