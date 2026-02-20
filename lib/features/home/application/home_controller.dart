/// EN: Home controller for loading home summary.
/// KO: 홈 요약을 로드하는 홈 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/entities/home_summary.dart';
import '../domain/repositories/home_repository.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';

class HomeController extends StateNotifier<AsyncValue<HomeSummary>> {
  HomeController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      // EN: Use cache on project switch — no forced network round-trip.
      // KO: 프로젝트 전환 시 캐시 사용 — 강제 네트워크 호출 없음.
      load();
    });
    _ref.listen<List<String>>(selectedUnitIdsProvider, (_, __) {
      // EN: Re-fetch summary when unit filters change.
      // KO: 유닛 필터가 변경되면 홈 요약을 다시 조회합니다.
      load();
    });
  }

  final Ref _ref;
  String? _lastProjectKey;
  bool _isLoading = false;

  Future<void> load({bool forceRefresh = false}) async {
    final selectedProjectKey = _ref.read(selectedProjectKeyProvider);
    if (selectedProjectKey == null || selectedProjectKey.isEmpty) {
      return;
    }

    final unitIds = _ref.read(selectedUnitIdsProvider);
    final shouldSkip =
        !forceRefresh && _isLoading && _lastProjectKey == selectedProjectKey;
    if (shouldSkip) {
      return;
    }

    _lastProjectKey = selectedProjectKey;
    _isLoading = true;

    // EN: Keep previous data visible while loading (no full-screen spinner).
    // KO: 로딩 중 이전 데이터를 유지합니다 (전체 화면 스피너 없음).
    if (!state.hasValue) {
      state = const AsyncLoading();
    }

    final repository = await _ref.read(homeRepositoryProvider.future);
    final projectKey = selectedProjectKey;

    try {
      final result = await repository.getHomeSummary(
        projectId: projectKey,
        unitIds: unitIds,
        forceRefresh: forceRefresh,
      );

      if (result is Success<HomeSummary>) {
        state = AsyncData(result.data);
      } else if (result is Err<HomeSummary>) {
        state = AsyncError(result.failure, StackTrace.current);
      }
    } finally {
      _isLoading = false;
    }
  }
}

/// EN: Home repository provider.
/// KO: 홈 리포지토리 프로바이더.
final homeRepositoryProvider = FutureProvider<HomeRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return HomeRepositoryImpl(
    remoteDataSource: HomeRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Home controller provider.
/// KO: 홈 컨트롤러 프로바이더.
final homeControllerProvider =
    StateNotifierProvider<HomeController, AsyncValue<HomeSummary>>((ref) {
      // EN: Don't call load() here — selectedProjectKey is always null at
      // construction time. The listener triggers load() once project is selected.
      // KO: 여기서 load() 호출 불필요 — 생성 시점에 selectedProjectKey는 항상 null.
      // 리스너가 프로젝트 선택 후 load()를 트리거함.
      return HomeController(ref);
    });
