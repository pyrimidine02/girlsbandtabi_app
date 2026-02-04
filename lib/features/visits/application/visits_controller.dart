/// EN: Visit history controllers and providers.
/// KO: 방문 기록 컨트롤러 및 프로바이더.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../../places/application/places_controller.dart';
import '../../places/domain/entities/place_entities.dart';
import '../data/datasources/visits_remote_data_source.dart';
import '../data/repositories/visits_repository_impl.dart';
import '../domain/entities/visit_entities.dart';
import '../domain/repositories/visits_repository.dart';

/// EN: Controller for user visit history.
/// KO: 사용자 방문 기록 컨트롤러.
class UserVisitsController extends StateNotifier<AsyncValue<List<VisitEvent>>> {
  UserVisitsController(this._ref) : super(const AsyncLoading());

  final Ref _ref;

  /// EN: Load all visit events for the user.
  /// KO: 사용자의 전체 방문 이벤트를 로드합니다.
  Future<void> load({bool forceRefresh = false}) async {
    state = const AsyncLoading();

    final repository = await _ref.read(visitsRepositoryProvider.future);
    final result = await repository.getAllVisits(
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<VisitEvent>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<VisitEvent>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

/// EN: Visits repository provider.
/// KO: 방문 기록 리포지토리 프로바이더.
final visitsRepositoryProvider =
    FutureProvider<VisitsRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return VisitsRepositoryImpl(
    remoteDataSource: VisitsRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Visit history controller provider.
/// KO: 방문 기록 컨트롤러 프로바이더.
final userVisitsControllerProvider =
    StateNotifierProvider<UserVisitsController, AsyncValue<List<VisitEvent>>>(
  (ref) => UserVisitsController(ref),
);

/// EN: Map of place ID to summary for visit screens.
/// KO: 방문 화면에서 사용할 장소 요약 맵.
final visitPlacesMapProvider =
    FutureProvider<Map<String, PlaceSummary>>((ref) async {
  final projectKey = ref.watch(selectedProjectKeyProvider);
  final projectId = ref.watch(selectedProjectIdProvider);
  final resolvedProjectKey = projectKey?.isNotEmpty == true
      ? projectKey!
      : (projectId ?? '');
  if (resolvedProjectKey.isEmpty) return <String, PlaceSummary>{};

  final repository = await ref.watch(placesRepositoryProvider.future);
  final result = await repository.getAllPlaces(projectId: resolvedProjectKey);
  if (result is Success<List<PlaceSummary>>) {
    return {
      for (final place in result.data) place.id: place,
    };
  }

  return <String, PlaceSummary>{};
});
