/// EN: Live events controllers for list and detail views.
/// KO: 라이브 이벤트 리스트/상세 컨트롤러.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../../projects/application/projects_controller.dart';
import '../../projects/domain/entities/project_entities.dart';
import '../data/datasources/live_events_remote_data_source.dart';
import '../data/repositories/live_events_repository_impl.dart';
import '../domain/entities/live_event_entities.dart';
import '../domain/repositories/live_events_repository.dart';
import 'pending_live_attendance_mutation.dart';

// EN: Max number of additional retries on load failure (total attempts = 1 + _kMaxRetries).
// KO: 로드 실패 시 최대 추가 재시도 횟수 (총 시도 = 1 + _kMaxRetries).
const int _kMaxRetries = 2;
const int _kLiveNavIndex = 2;
const int _kAttendanceHistoryPageSize = 20;

bool _shouldQueueLiveAttendanceMutationForRetry(Failure failure) {
  return failure is NetworkFailure || failure is AuthFailure;
}

class LiveEventsListController
    extends StateNotifier<AsyncValue<List<LiveEventSummary>>> {
  LiveEventsListController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      if (!_isLiveTabActive()) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<List<String>>(selectedLiveBandIdsProvider, (_, __) {
      if (!_isLiveTabActive()) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<int>(currentNavIndexProvider, (previous, next) {
      if (next != _kLiveNavIndex || next == previous) {
        return;
      }
      load(forceRefresh: true);
    });
  }

  final Ref _ref;

  bool _isLiveTabActive() {
    return _ref.read(currentNavIndexProvider) == _kLiveNavIndex;
  }

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
    : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      if (mounted) {
        load(forceRefresh: true);
      }
    });
    _ref.listen<String?>(selectedProjectIdProvider, (_, __) {
      if (mounted) {
        load(forceRefresh: true);
      }
    });
  }

  final Ref _ref;
  final String eventId;

  Future<void> load({bool forceRefresh = false}) async {
    final resolvedProjectKey = await _resolveProjectKey();
    if (!mounted) {
      return;
    }
    if (resolvedProjectKey == null || resolvedProjectKey.isEmpty) {
      // EN: Surface explicit error instead of keeping infinite loading.
      // KO: 무한 로딩 상태로 남기지 않고 명시적 에러를 노출합니다.
      state = AsyncError(
        const CacheFailure('Project context is not ready'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(liveEventsRepositoryProvider.future);

    // EN: Retry up to _kMaxRetries times on failure with exponential back-off.
    // KO: 실패 시 지수 백오프로 최대 _kMaxRetries회 재시도합니다.
    Result<LiveEventDetail>? result;
    final attemptedProjectKeys = <String>{resolvedProjectKey};
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
        projectId: resolvedProjectKey,
        eventId: eventId,
        forceRefresh: forceRefresh || attempt > 0,
      );
      if (result is Success<LiveEventDetail>) break;
    }

    final selectedProjectId = _ref.read(selectedProjectIdProvider);
    if (result is Err<LiveEventDetail> &&
        selectedProjectId != null &&
        selectedProjectId.isNotEmpty &&
        selectedProjectId != resolvedProjectKey) {
      attemptedProjectKeys.add(selectedProjectId);
      result = await repository.getLiveEventDetail(
        projectId: selectedProjectId,
        eventId: eventId,
        forceRefresh: forceRefresh,
      );
    }
    if (result is Err<LiveEventDetail>) {
      final fallbackProjectKeys = await _fallbackProjectKeys(
        attemptedProjectKeys,
      );
      for (final fallbackProjectKey in fallbackProjectKeys) {
        result = await repository.getLiveEventDetail(
          projectId: fallbackProjectKey,
          eventId: eventId,
          forceRefresh: forceRefresh,
        );
        if (result is Success<LiveEventDetail>) {
          break;
        }
      }
    }

    if (!mounted) {
      return;
    }
    if (result is Success<LiveEventDetail>) {
      state = AsyncData(result.data);
    } else if (result is Err<LiveEventDetail>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<String?> _resolveProjectKey() async {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey != null && projectKey.isNotEmpty) {
      return projectKey;
    }

    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectId != null && projectId.isNotEmpty) {
      return projectId;
    }

    final selection = _ref.read(projectSelectionControllerProvider);
    if (selection.projectKey != null && selection.projectKey!.isNotEmpty) {
      return selection.projectKey;
    }

    final repository = await _ref.read(projectsRepositoryProvider.future);
    final projectsResult = await repository.getProjects();
    if (projectsResult is Success<List<Project>> &&
        projectsResult.data.isNotEmpty) {
      final firstProject = projectsResult.data.first;
      final resolvedProjectKey = firstProject.code.isNotEmpty
          ? firstProject.code
          : firstProject.id;
      await _ref
          .read(projectSelectionControllerProvider.notifier)
          .selectProject(resolvedProjectKey, projectId: firstProject.id);
      return resolvedProjectKey;
    }

    return null;
  }

  Future<List<String>> _fallbackProjectKeys(Set<String> attempted) async {
    final repository = await _ref.read(projectsRepositoryProvider.future);
    final projectsResult = await repository.getProjects();
    if (projectsResult is! Success<List<Project>>) {
      return const [];
    }

    final keys = <String>[];
    for (final project in projectsResult.data) {
      final code = project.code.trim();
      if (code.isNotEmpty && attempted.add(code)) {
        keys.add(code);
      }
      final id = project.id.trim();
      if (id.isNotEmpty && attempted.add(id)) {
        keys.add(id);
      }
    }
    return keys;
  }
}

/// EN: Offline outbox controller for live attendance toggle mutations.
/// KO: 라이브 출석 토글 오프라인 대기열(아웃박스) 컨트롤러입니다.
class LiveAttendanceOutboxController {
  LiveAttendanceOutboxController(this._ref) {
    _ref.listen<AsyncValue<ConnectivityStatus>>(connectivityStatusProvider, (
      _,
      next,
    ) {
      if (next.valueOrNull == ConnectivityStatus.online) {
        unawaited(syncPendingMutations());
      }
    });
    _ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
      if (next && previous != true) {
        unawaited(syncPendingMutations());
      }
    });
    unawaited(syncPendingMutations());
  }

  final Ref _ref;
  bool _isSyncing = false;
  static const int _maxPendingMutations = 200;

  Future<void> enqueue({
    required String projectKey,
    required String eventId,
    required bool attended,
  }) async {
    final pending = await _readPendingMutations();
    pending.removeWhere(
      (mutation) =>
          mutation.projectKey == projectKey && mutation.eventId == eventId,
    );
    pending.add(
      PendingLiveAttendanceMutation(
        projectKey: projectKey,
        eventId: eventId,
        attended: attended,
        queuedAt: DateTime.now(),
      ),
    );
    if (pending.length > _maxPendingMutations) {
      pending.removeRange(0, pending.length - _maxPendingMutations);
    }
    await _writePendingMutations(pending);
  }

  Future<void> removePending({
    required String projectKey,
    required String eventId,
  }) async {
    final pending = await _readPendingMutations();
    final before = pending.length;
    pending.removeWhere(
      (mutation) =>
          mutation.projectKey == projectKey && mutation.eventId == eventId,
    );
    if (pending.length != before) {
      await _writePendingMutations(pending);
    }
  }

  Future<PendingLiveAttendanceMutation?> findPending({
    required String projectKey,
    required String eventId,
  }) async {
    final pending = await _readPendingMutations();
    for (var i = pending.length - 1; i >= 0; i -= 1) {
      final mutation = pending[i];
      if (mutation.projectKey == projectKey && mutation.eventId == eventId) {
        return mutation;
      }
    }
    return null;
  }

  Future<void> syncPendingMutations() async {
    if (_isSyncing) {
      return;
    }
    if (!_ref.read(isAuthenticatedProvider)) {
      return;
    }

    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) {
      return;
    }

    _isSyncing = true;
    try {
      final pending = await _readPendingMutations();
      if (pending.isEmpty) {
        return;
      }

      final repository = await _ref.read(liveEventsRepositoryProvider.future);
      final remaining = <PendingLiveAttendanceMutation>[];
      var appliedCount = 0;

      for (var i = 0; i < pending.length; i += 1) {
        final mutation = pending[i];
        final result = await repository.toggleLiveAttendance(
          projectId: mutation.projectKey,
          eventId: mutation.eventId,
          attended: mutation.attended,
        );
        if (result is Success<LiveAttendanceState>) {
          appliedCount += 1;
          continue;
        }
        if (result is Err<LiveAttendanceState>) {
          if (_shouldQueueLiveAttendanceMutationForRetry(result.failure)) {
            remaining.add(mutation);
            remaining.addAll(pending.skip(i + 1));
            break;
          }
          // EN: Drop non-retriable mutation.
          // KO: 재시도 불가능한 작업은 대기열에서 제거합니다.
          continue;
        }
      }

      await _writePendingMutations(remaining);
      if (appliedCount > 0) {
        _ref.invalidate(liveAttendanceHistoryControllerProvider);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<PendingLiveAttendanceMutation>> _readPendingMutations() async {
    final storage = await _ref.read(localStorageProvider.future);
    final raw = storage.getPendingLiveAttendanceMutations();
    return raw
        .map(PendingLiveAttendanceMutation.fromJson)
        .where(
          (mutation) =>
              mutation.projectKey.isNotEmpty && mutation.eventId.isNotEmpty,
        )
        .toList(growable: true);
  }

  Future<void> _writePendingMutations(
    List<PendingLiveAttendanceMutation> pending,
  ) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.setPendingLiveAttendanceMutations(
      pending.map((mutation) => mutation.toJson()).toList(growable: false),
    );
  }
}

class LiveAttendanceViewState {
  const LiveAttendanceViewState({
    required this.attendance,
    this.isSubmitting = false,
    this.isLoading = false,
  });

  final LiveAttendanceState attendance;
  final bool isSubmitting;
  final bool isLoading;

  LiveAttendanceViewState copyWith({
    LiveAttendanceState? attendance,
    bool? isSubmitting,
    bool? isLoading,
  }) {
    return LiveAttendanceViewState(
      attendance: attendance ?? this.attendance,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LiveAttendanceController extends StateNotifier<LiveAttendanceViewState> {
  LiveAttendanceController(this._ref, this.eventId)
    : super(
        LiveAttendanceViewState(attendance: LiveAttendanceState.none(eventId)),
      ) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      unawaited(load(forceRefresh: true));
    });
    unawaited(load());
  }

  final Ref _ref;
  final String eventId;

  Future<Result<LiveAttendanceState>> load({bool forceRefresh = false}) async {
    final projectKey = _resolvedProjectKey();
    if (projectKey == null || projectKey.isEmpty) {
      final empty = LiveAttendanceState.none(eventId);
      state = state.copyWith(
        attendance: empty,
        isSubmitting: false,
        isLoading: false,
      );
      return Result.success(empty);
    }

    state = state.copyWith(isLoading: true);
    final repository = await _ref.read(liveEventsRepositoryProvider.future);
    final result = await repository.getLiveAttendanceState(
      projectId: projectKey,
      eventId: eventId,
      forceRefresh: forceRefresh,
    );
    if (!mounted) {
      return result;
    }

    if (result case Success<LiveAttendanceState>(:final data)) {
      final outbox = _ref.read(liveAttendanceOutboxControllerProvider);
      final pending = await outbox.findPending(
        projectKey: projectKey,
        eventId: eventId,
      );
      final resolved = pending == null
          ? data
          : _optimisticState(data, pending.attended);
      state = state.copyWith(
        attendance: resolved,
        isSubmitting: false,
        isLoading: false,
      );
      return Result.success(resolved);
    }

    state = state.copyWith(isLoading: false);
    return result;
  }

  Future<Result<LiveAttendanceState>> toggle(bool attended) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return const Result.failure(
        AuthFailure('Login required', code: 'auth_required'),
      );
    }

    if (state.isSubmitting) {
      return const Result.failure(
        ValidationFailure(
          'Attendance update already in progress',
          code: 'attendance_toggle_in_progress',
        ),
      );
    }

    final current = state.attendance;
    if (!attended && current.attended && !current.canUndo) {
      return const Result.failure(
        ValidationFailure(
          'Verified attendance cannot be undone',
          code: 'ATTENDANCE_UPDATE_FAILED',
        ),
      );
    }

    final projectKey = _resolvedProjectKey();
    if (projectKey == null || projectKey.isEmpty) {
      return const Result.failure(
        ValidationFailure('Project is required', code: 'project_required'),
      );
    }

    final previous = current;
    final optimistic = _optimisticState(previous, attended);
    state = state.copyWith(attendance: optimistic, isSubmitting: true);
    final outbox = _ref.read(liveAttendanceOutboxControllerProvider);
    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) {
      await outbox.enqueue(
        projectKey: projectKey,
        eventId: eventId,
        attended: attended,
      );
      if (!mounted) {
        return Result.success(optimistic);
      }
      state = state.copyWith(
        attendance: optimistic,
        isSubmitting: false,
        isLoading: false,
      );
      _ref.invalidate(liveAttendanceHistoryControllerProvider);
      return Result.success(optimistic);
    }

    final repository = await _ref.read(liveEventsRepositoryProvider.future);
    final result = await repository.toggleLiveAttendance(
      projectId: projectKey,
      eventId: eventId,
      attended: attended,
    );

    if (!mounted) {
      return result;
    }

    if (result case Success<LiveAttendanceState>(:final data)) {
      await outbox.removePending(projectKey: projectKey, eventId: eventId);
      state = state.copyWith(
        attendance: data,
        isSubmitting: false,
        isLoading: false,
      );
      _ref.invalidate(liveAttendanceHistoryControllerProvider);
      return result;
    }

    if (result case Err<LiveAttendanceState>(:final failure)) {
      if (_shouldQueueLiveAttendanceMutationForRetry(failure)) {
        await outbox.enqueue(
          projectKey: projectKey,
          eventId: eventId,
          attended: attended,
        );
        if (!mounted) {
          return Result.success(optimistic);
        }
        state = state.copyWith(
          attendance: optimistic,
          isSubmitting: false,
          isLoading: false,
        );
        _ref.invalidate(liveAttendanceHistoryControllerProvider);
        return Result.success(optimistic);
      }
      state = state.copyWith(attendance: previous, isSubmitting: false);
      return Result.failure(failure);
    }

    state = state.copyWith(attendance: previous, isSubmitting: false);
    return result;
  }

  LiveAttendanceState _optimisticState(
    LiveAttendanceState previous,
    bool attended,
  ) {
    if (!attended) {
      return previous.copyWith(
        attended: false,
        status: LiveAttendanceStatus.none,
        canUndo: false,
      );
    }

    final isVerified = previous.status == LiveAttendanceStatus.verified;
    return previous.copyWith(
      attended: true,
      status: isVerified
          ? LiveAttendanceStatus.verified
          : LiveAttendanceStatus.declared,
      canUndo: !isVerified,
    );
  }

  String? _resolvedProjectKey() {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey != null && projectKey.isNotEmpty) {
      return projectKey;
    }
    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectId != null && projectId.isNotEmpty) {
      return projectId;
    }
    return null;
  }
}

class LiveAttendanceHistoryViewState {
  const LiveAttendanceHistoryViewState({
    this.items = const [],
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.hasNext = false,
    this.nextPage = 0,
    this.failure,
  });

  final List<LiveAttendanceHistoryRecord> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int nextPage;
  final Failure? failure;

  LiveAttendanceHistoryViewState copyWith({
    List<LiveAttendanceHistoryRecord>? items,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? nextPage,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return LiveAttendanceHistoryViewState(
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      nextPage: nextPage ?? this.nextPage,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

class LiveAttendanceHistoryController
    extends StateNotifier<LiveAttendanceHistoryViewState> {
  LiveAttendanceHistoryController(this._ref)
    : super(const LiveAttendanceHistoryViewState(isInitialLoading: true)) {
    unawaited(load());
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final projectKey = _resolvedProjectKey();
    if (projectKey == null || projectKey.isEmpty) {
      state = const LiveAttendanceHistoryViewState(
        items: [],
        isInitialLoading: false,
        hasNext: false,
      );
      return;
    }

    state = state.copyWith(
      isInitialLoading: true,
      isLoadingMore: false,
      items: const [],
      hasNext: false,
      nextPage: 0,
      clearFailure: true,
    );

    final repository = await _ref.read(liveEventsRepositoryProvider.future);
    final result = await repository.getLiveAttendanceHistory(
      projectId: projectKey,
      page: 0,
      size: _kAttendanceHistoryPageSize,
      forceRefresh: forceRefresh,
    );

    if (!mounted) {
      return;
    }

    if (result case Success<LiveAttendanceHistoryPageData>(:final data)) {
      final enriched = await _enrichWithEventDetails(
        repository,
        projectKey,
        data.items,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        items: _sortByLatest(enriched),
        isInitialLoading: false,
        hasNext: data.hasNext,
        nextPage: data.currentPage + 1,
        clearFailure: true,
      );
      return;
    }

    state = state.copyWith(
      isInitialLoading: false,
      failure: result.failureOrNull,
      clearFailure: true,
    );
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasNext) {
      return;
    }
    final projectKey = _resolvedProjectKey();
    if (projectKey == null || projectKey.isEmpty) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearFailure: true);
    final repository = await _ref.read(liveEventsRepositoryProvider.future);
    final result = await repository.getLiveAttendanceHistory(
      projectId: projectKey,
      page: state.nextPage,
      size: _kAttendanceHistoryPageSize,
    );
    if (!mounted) {
      return;
    }

    if (result case Success<LiveAttendanceHistoryPageData>(:final data)) {
      final enriched = await _enrichWithEventDetails(
        repository,
        projectKey,
        data.items,
      );
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        items: _sortByLatest([...state.items, ...enriched]),
        isLoadingMore: false,
        hasNext: data.hasNext,
        nextPage: data.currentPage + 1,
        clearFailure: true,
      );
      return;
    }

    state = state.copyWith(
      isLoadingMore: false,
      failure: result.failureOrNull,
      clearFailure: true,
    );
  }

  Future<List<LiveAttendanceHistoryRecord>> _enrichWithEventDetails(
    LiveEventsRepository repository,
    String projectKey,
    List<LiveAttendanceHistoryRecord> records, {
    bool forceRefresh = false,
  }) async {
    return Future.wait(
      records.map((record) async {
        final detailResult = await repository.getLiveEventDetail(
          projectId: projectKey,
          eventId: record.eventId,
          forceRefresh: forceRefresh,
        );
        if (detailResult case Success<LiveEventDetail>(:final data)) {
          return record.withDetail(data);
        }
        return record;
      }),
    );
  }

  List<LiveAttendanceHistoryRecord> _sortByLatest(
    List<LiveAttendanceHistoryRecord> items,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final aTime =
          a.attendedAt ??
          a.showStartTime ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.attendedAt ??
          b.showStartTime ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  String? _resolvedProjectKey() {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey != null && projectKey.isNotEmpty) {
      return projectKey;
    }
    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectId != null && projectId.isNotEmpty) {
      return projectId;
    }
    return null;
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

/// EN: Live attendance outbox controller provider.
/// KO: 라이브 출석 오프라인 대기열 컨트롤러 프로바이더.
final liveAttendanceOutboxControllerProvider =
    Provider<LiveAttendanceOutboxController>((ref) {
      return LiveAttendanceOutboxController(ref);
    });

/// EN: App-scope bootstrap provider for live attendance outbox auto-sync.
/// KO: 라이브 출석 아웃박스 자동 동기화를 위한 앱 전역 부트스트랩 프로바이더.
final liveAttendanceOutboxBootstrapProvider = Provider<void>((ref) {
  ref.watch(liveAttendanceOutboxControllerProvider);
});

final liveAttendanceControllerProvider = StateNotifierProvider.autoDispose
    .family<LiveAttendanceController, LiveAttendanceViewState, String>((
      ref,
      eventId,
    ) {
      return LiveAttendanceController(ref, eventId);
    });

final liveAttendanceHistoryControllerProvider =
    StateNotifierProvider.autoDispose<
      LiveAttendanceHistoryController,
      LiveAttendanceHistoryViewState
    >((ref) {
      return LiveAttendanceHistoryController(ref);
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
