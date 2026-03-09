/// EN: Places controllers for list and detail views.
/// KO: 장소 리스트/상세 컨트롤러.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../../projects/application/projects_controller.dart';
import '../../projects/domain/entities/project_entities.dart';
import '../data/datasources/places_remote_data_source.dart';
import '../data/repositories/places_repository_impl.dart';
import '../domain/entities/place_comment_entities.dart';
import '../domain/entities/place_entities.dart';
import '../domain/entities/place_guide_entities.dart';
import '../domain/entities/place_region_entities.dart';
import '../domain/repositories/places_repository.dart';

const int _kPlacesNavIndex = 1;

bool _isPlacesTabActive(Ref ref) {
  return ref.read(currentNavIndexProvider) == _kPlacesNavIndex;
}

class PlacesListController
    extends StateNotifier<AsyncValue<List<PlaceSummary>>> {
  PlacesListController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      if (!_isPlacesTabActive(_ref)) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<List<String>>(selectedPlaceRegionCodesProvider, (_, __) {
      if (!_isPlacesTabActive(_ref)) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<List<String>>(selectedPlaceBandIdsProvider, (_, __) {
      if (!_isPlacesTabActive(_ref)) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<PlaceListMode>(placeListModeProvider, (_, __) {
      if (!_isPlacesTabActive(_ref)) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<int>(currentNavIndexProvider, (previous, next) {
      if (next != _kPlacesNavIndex || next == previous) {
        return;
      }
      load(forceRefresh: true);
    });
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    if (!_isPlacesTabActive(_ref)) {
      return;
    }
    final projectKey = _ref.read(selectedProjectKeyProvider);
    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectKey == null || projectKey.isEmpty) {
      if (projectId == null || projectId.isEmpty) {
        // EN: Wait for project selection before loading.
        // KO: 로드 전 프로젝트 선택을 기다립니다.
        return;
      }
    }
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : projectId!;
    if (resolvedProjectKey.isEmpty) {
      // EN: Wait for project selection before loading.
      // KO: 로드 전 프로젝트 선택을 기다립니다.
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(placesRepositoryProvider.future);
    final bandIds = _ref.read(selectedPlaceBandIdsProvider);
    final regionCodes = _ref.read(selectedPlaceRegionCodesProvider);
    final listMode = _ref.read(placeListModeProvider);

    Result<List<PlaceSummary>> result;
    if (regionCodes.isNotEmpty) {
      result = await repository.getPlacesByRegionFilter(
        projectId: resolvedProjectKey,
        regionCodes: regionCodes,
        unitIds: bandIds,
      );
      if (result is Err<List<PlaceSummary>> &&
          projectId != null &&
          projectId.isNotEmpty &&
          projectId != resolvedProjectKey) {
        result = await repository.getPlacesByRegionFilter(
          projectId: projectId,
          regionCodes: regionCodes,
          unitIds: bandIds,
        );
      }
    } else {
      if (listMode == PlaceListMode.nearby) {
        try {
          final locationService = _ref.read(locationServiceProvider);
          final location = await locationService.getCurrentLocation();
          result = await repository.getNearbyPlaces(
            projectId: resolvedProjectKey,
            latitude: location.latitude,
            longitude: location.longitude,
            unitIds: bandIds,
          );
        } catch (error) {
          final failure = error is Failure
              ? error
              : const UnknownFailure('Failed to resolve current location');
          state = AsyncError(failure, StackTrace.current);
          return;
        }
      } else {
        result = await repository.getAllPlaces(
          projectId: resolvedProjectKey,
          unitIds: bandIds,
          forceRefresh: forceRefresh,
        );
        if (result is Err<List<PlaceSummary>> &&
            projectId != null &&
            projectId.isNotEmpty &&
            projectId != resolvedProjectKey) {
          result = await repository.getAllPlaces(
            projectId: projectId,
            unitIds: bandIds,
            forceRefresh: forceRefresh,
          );
        }
      }
    }

    if (result is Success<List<PlaceSummary>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<PlaceSummary>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class PlacesRegionOptionsController
    extends StateNotifier<AsyncValue<RegionFilterOptions>> {
  PlacesRegionOptionsController(this._ref) : super(const AsyncLoading()) {
    _ref.listen<String?>(selectedProjectKeyProvider, (_, __) {
      if (!_isPlacesTabActive(_ref)) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<String?>(selectedProjectIdProvider, (_, __) {
      if (!_isPlacesTabActive(_ref)) {
        return;
      }
      load(forceRefresh: true);
    });
    _ref.listen<int>(currentNavIndexProvider, (previous, next) {
      if (next != _kPlacesNavIndex || next == previous) {
        return;
      }
      load(forceRefresh: true);
    });
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    if (!_isPlacesTabActive(_ref)) {
      return;
    }
    final projectKey = _ref.read(selectedProjectKeyProvider);
    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectKey == null || projectKey.isEmpty) {
      if (projectId == null || projectId.isEmpty) {
        state = AsyncData(_emptyRegionFilterOptions);
        return;
      }
    }
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : projectId!;
    if (resolvedProjectKey.isEmpty) {
      state = AsyncData(_emptyRegionFilterOptions);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(placesRepositoryProvider.future);
    var result = await repository.getRegionFilterOptions(
      projectId: resolvedProjectKey,
      forceRefresh: forceRefresh,
    );
    if (result is Err<RegionFilterOptions> &&
        projectId != null &&
        projectId.isNotEmpty &&
        projectId != resolvedProjectKey) {
      result = await repository.getRegionFilterOptions(
        projectId: projectId,
        forceRefresh: forceRefresh,
      );
    }

    if (result is Success<RegionFilterOptions>) {
      state = AsyncData(result.data);
    } else if (result is Err<RegionFilterOptions>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  static const RegionFilterOptions _emptyRegionFilterOptions =
      RegionFilterOptions(
        countries: <RegionOption>[],
        popularRegions: <RegionOption>[],
        totalRegions: 0,
        totalPlaces: 0,
        lastUpdated: '',
      );
}

class PlaceDetailController extends StateNotifier<AsyncValue<PlaceDetail>> {
  PlaceDetailController(this._ref, this.placeId) : super(const AsyncLoading()) {
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
  final String placeId;

  Future<void> load({bool forceRefresh = false}) async {
    final resolvedProjectKey = await _resolveProjectKey();
    if (!mounted) {
      return;
    }
    if (resolvedProjectKey == null || resolvedProjectKey.isEmpty) {
      // EN: Surface explicit error instead of leaving the detail page in
      // EN: indefinite loading when project context is missing.
      // KO: 프로젝트 컨텍스트가 없을 때 무한 로딩 상태로 남기지 않고
      // KO: 명시적 에러를 노출합니다.
      state = AsyncError(
        const CacheFailure('Project context is not ready'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();

    final repository = await _ref.read(placesRepositoryProvider.future);

    var result = await repository.getPlaceDetail(
      projectId: resolvedProjectKey,
      placeId: placeId,
      forceRefresh: forceRefresh,
    );
    final attemptedProjectKeys = <String>{resolvedProjectKey};
    final selectedProjectId = _ref.read(selectedProjectIdProvider);
    if (result is Err<PlaceDetail> &&
        selectedProjectId != null &&
        selectedProjectId.isNotEmpty &&
        selectedProjectId != resolvedProjectKey) {
      attemptedProjectKeys.add(selectedProjectId);
      result = await repository.getPlaceDetail(
        projectId: selectedProjectId,
        placeId: placeId,
        forceRefresh: forceRefresh,
      );
    }
    if (result is Err<PlaceDetail>) {
      final fallbackProjectKeys = await _fallbackProjectKeys(
        attemptedProjectKeys,
      );
      if (fallbackProjectKeys.isNotEmpty) {
        result = await _resolvePlaceDetailFromFallbackProjects(
          repository: repository,
          projectKeys: fallbackProjectKeys,
          forceRefresh: forceRefresh,
        );
      }
    }

    if (!mounted) {
      return;
    }
    if (result is Success<PlaceDetail>) {
      state = AsyncData(result.data);
    } else if (result is Err<PlaceDetail>) {
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

  Future<Result<PlaceDetail>> _resolvePlaceDetailFromFallbackProjects({
    required PlacesRepository repository,
    required List<String> projectKeys,
    required bool forceRefresh,
  }) async {
    if (projectKeys.isEmpty) {
      return const Result.failure(
        UnknownFailure(
          'Unable to resolve place detail project',
          code: 'place_detail_project_unresolved',
        ),
      );
    }

    final completer = Completer<Result<PlaceDetail>>();
    Err<PlaceDetail>? lastError;
    var remaining = projectKeys.length;

    for (final projectKey in projectKeys) {
      unawaited(() async {
        final candidate = await repository.getPlaceDetail(
          projectId: projectKey,
          placeId: placeId,
          forceRefresh: forceRefresh,
        );

        if (candidate is Success<PlaceDetail>) {
          if (!completer.isCompleted) {
            completer.complete(candidate);
          }
        } else if (candidate is Err<PlaceDetail>) {
          lastError = candidate;
        }

        remaining -= 1;
        if (remaining == 0 && !completer.isCompleted) {
          if (lastError != null) {
            completer.complete(Result.failure(lastError!.failure));
          } else {
            completer.complete(
              const Result.failure(
                UnknownFailure(
                  'Unable to resolve place detail project',
                  code: 'place_detail_project_unresolved',
                ),
              ),
            );
          }
        }
      }());
    }

    return completer.future;
  }
}

class PlaceGuidesController
    extends StateNotifier<AsyncValue<List<PlaceGuideSummary>>> {
  PlaceGuidesController(this._ref, this.placeId) : super(const AsyncLoading());

  final Ref _ref;
  final String placeId;

  Future<void> load({bool forceRefresh = false}) async {
    if (placeId.isEmpty) return;
    state = const AsyncLoading();

    final repository = await _ref.read(placesRepositoryProvider.future);
    final result = await repository.getPlaceGuides(
      placeId: placeId,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<PlaceGuideSummary>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<PlaceGuideSummary>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class PlaceCommentsController
    extends StateNotifier<AsyncValue<List<PlaceComment>>> {
  PlaceCommentsController(this._ref, this.placeId)
    : super(const AsyncLoading());

  final Ref _ref;
  final String placeId;

  Future<void> load({bool forceRefresh = false}) async {
    if (placeId.isEmpty) return;
    state = const AsyncLoading();

    final repository = await _ref.read(placesRepositoryProvider.future);
    final result = await repository.getPlaceComments(
      placeId: placeId,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<PlaceComment>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<PlaceComment>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

/// EN: Places repository provider.
/// KO: 장소 리포지토리 프로바이더.
final placesRepositoryProvider = FutureProvider<PlacesRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
  return PlacesRepositoryImpl(
    remoteDataSource: PlacesRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Places list controller provider.
/// KO: 장소 리스트 컨트롤러 프로바이더.
final placesListControllerProvider =
    StateNotifierProvider<PlacesListController, AsyncValue<List<PlaceSummary>>>(
      (ref) {
        return PlacesListController(ref)..load();
      },
    );

/// EN: Places region options controller provider.
/// KO: 장소 지역 옵션 컨트롤러 프로바이더.
final placesRegionOptionsControllerProvider =
    StateNotifierProvider<
      PlacesRegionOptionsController,
      AsyncValue<RegionFilterOptions>
    >((ref) {
      return PlacesRegionOptionsController(ref)..load();
    });

/// EN: Selected place region codes provider.
/// KO: 선택된 장소 지역 코드 프로바이더.
final selectedPlaceRegionCodesProvider = StateProvider<List<String>>((ref) {
  return const [];
});

/// EN: Selected band IDs for places filter.
/// KO: 장소 필터용 선택된 밴드 ID 목록.
final selectedPlaceBandIdsProvider = StateProvider<List<String>>((ref) {
  return const [];
});

/// EN: Places list mode.
/// KO: 장소 리스트 표시 모드.
enum PlaceListMode {
  /// EN: Nearby places only.
  /// KO: 주변 장소만 표시.
  nearby,

  /// EN: All places in the project.
  /// KO: 프로젝트 전체 장소 표시.
  all,
}

/// EN: Places list mode provider.
/// KO: 장소 리스트 모드 프로바이더.
final placeListModeProvider = StateProvider<PlaceListMode>((ref) {
  return PlaceListMode.all;
});

/// EN: Place detail controller provider.
/// KO: 장소 상세 컨트롤러 프로바이더.
final placeDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<PlaceDetailController, AsyncValue<PlaceDetail>, String>((
      ref,
      placeId,
    ) {
      return PlaceDetailController(ref, placeId)..load();
    });

/// EN: Place guides controller provider.
/// KO: 장소 가이드 컨트롤러 프로바이더.
final placeGuidesControllerProvider = StateNotifierProvider.autoDispose
    .family<PlaceGuidesController, AsyncValue<List<PlaceGuideSummary>>, String>(
      (ref, placeId) {
        return PlaceGuidesController(ref, placeId)..load();
      },
    );

/// EN: Place comments controller provider.
/// KO: 장소 댓글 컨트롤러 프로바이더.
final placeCommentsControllerProvider = StateNotifierProvider.autoDispose
    .family<PlaceCommentsController, AsyncValue<List<PlaceComment>>, String>((
      ref,
      placeId,
    ) {
      return PlaceCommentsController(ref, placeId)..load();
    });
