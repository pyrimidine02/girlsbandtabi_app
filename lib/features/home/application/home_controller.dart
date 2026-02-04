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
      load(forceRefresh: true);
    });
  }

  final Ref _ref;
  String? _lastProjectKey;
  bool _isLoading = false;

  Future<void> load({bool forceRefresh = false}) async {
    final selectedProjectKey = _ref.read(selectedProjectKeyProvider);
    if (selectedProjectKey == null || selectedProjectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    const unitIds = <String>[];
    final shouldSkip =
        !forceRefresh && _isLoading && _lastProjectKey == selectedProjectKey;
    if (shouldSkip) {
      return;
    }

    _lastProjectKey = selectedProjectKey;
    _isLoading = true;
    state = const AsyncLoading();

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
      return HomeController(ref)..load();
    });
