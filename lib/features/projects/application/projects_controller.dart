/// EN: Projects controllers for list, units, and selection.
/// KO: 프로젝트/유닛/선택 컨트롤러.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/projects_remote_data_source.dart';
import '../data/repositories/projects_repository_impl.dart';
import '../domain/entities/project_entities.dart';
import '../domain/repositories/projects_repository.dart';

class ProjectsController extends StateNotifier<AsyncValue<List<Project>>> {
  ProjectsController(this._ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    state = const AsyncLoading();
    final repository = await _ref.read(projectsRepositoryProvider.future);
    final result = await repository.getProjects(forceRefresh: forceRefresh);

    if (result is Success<List<Project>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<Project>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class ProjectUnitsController extends StateNotifier<AsyncValue<List<Unit>>> {
  ProjectUnitsController(this._ref, this.projectKey)
    : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final String projectKey;

  Future<void> load({bool forceRefresh = false}) async {
    state = const AsyncLoading();
    final repository = await _ref.read(projectsRepositoryProvider.future);
    final result = await repository.getUnits(
      projectId: projectKey,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<Unit>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<Unit>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class ProjectSelectionController extends StateNotifier<ProjectSelectionState> {
  ProjectSelectionController(this._ref)
    : super(ProjectSelectionState.initial()) {
    _initialize();
  }

  final Ref _ref;

  Future<void> _initialize() async {
    final storage = await _ref.read(localStorageProvider.future);
    final storedProjectKey = storage.getSelectedProjectKey();
    final storedProjectId = storage.getSelectedProjectId();
    final storedUnitIds = storage.getSelectedUnitIds();
    final hasStoredProjectKey =
        storedProjectKey != null && storedProjectKey.isNotEmpty;
    final hasStoredProjectId =
        storedProjectId != null && storedProjectId.isNotEmpty;
    List<Project>? projects;

    if (hasStoredProjectKey || hasStoredProjectId) {
      projects = await _fetchProjects();
      final match = _findProject(projects, storedProjectKey, storedProjectId);
      if (match != null) {
        final resolvedProjectKey = _projectKeyFor(match);
        // EN: Use stored selection.
        // KO: 저장된 선택을 사용합니다.
        state = ProjectSelectionState(
          projectKey: resolvedProjectKey,
          unitIds: storedUnitIds,
        );
        await storage.setSelectedProjectKey(resolvedProjectKey);
        await storage.setSelectedProjectId(match.id);
        _setSelectedProjectKey(resolvedProjectKey);
        _setSelectedProjectId(match.id);
        _setSelectedUnitIdsIfChanged(storedUnitIds);
        return;
      }
    }

    // EN: No stored project — fetch from API and auto-select first.
    // KO: 저장된 프로젝트 없음 — API에서 조회 후 첫 번째를 자동 선택합니다.
    projects ??= await _fetchProjects();
    if (projects.isNotEmpty) {
      await selectProject(
        _projectKeyFor(projects.first),
        projectId: projects.first.id,
      );
    }
  }

  Future<List<Project>> _fetchProjects() async {
    final repository = await _ref.read(projectsRepositoryProvider.future);
    final result = await repository.getProjects();
    if (result is! Success<List<Project>> || result.data.isEmpty) {
      return <Project>[];
    }

    return result.data;
  }

  Future<void> selectProject(String? projectKey, {String? projectId}) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.setSelectedProjectKey(projectKey ?? '');
    if (projectId != null && projectId.isNotEmpty) {
      await storage.setSelectedProjectId(projectId);
      _setSelectedProjectId(projectId);
    } else {
      await storage.setSelectedProjectId('');
      _setSelectedProjectId(null);
    }
    await storage.setSelectedUnitIds([]);
    state = state.copyWith(projectKey: projectKey, unitIds: []);
    _setSelectedProjectKey(projectKey);
    _setSelectedUnitIdsIfChanged(const []);
  }

  Future<void> selectUnits(List<String> unitIds) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.setSelectedUnitIds(unitIds);
    state = state.copyWith(unitIds: unitIds);
    _setSelectedUnitIdsIfChanged(unitIds);
  }

  void _setSelectedProjectKey(String? projectKey) {
    // EN: Keep provider updates minimal to avoid duplicate reloads.
    // KO: 중복 로드를 피하기 위해 프로바이더 업데이트를 최소화합니다.
    final current = _ref.read(selectedProjectKeyProvider);
    if (projectKey == null || projectKey.isEmpty) {
      if (current != null) {
        _ref.read(selectedProjectKeyProvider.notifier).state = null;
      }
      return;
    }

    if (current != projectKey) {
      _ref.read(selectedProjectKeyProvider.notifier).state = projectKey;
    }
  }

  void _setSelectedProjectId(String? projectId) {
    // EN: Keep provider updates minimal to avoid duplicate reloads.
    // KO: 중복 로드를 피하기 위해 프로바이더 업데이트를 최소화합니다.
    final current = _ref.read(selectedProjectIdProvider);
    if (projectId == null || projectId.isEmpty) {
      if (current != null) {
        _ref.read(selectedProjectIdProvider.notifier).state = null;
      }
      return;
    }

    if (current != projectId) {
      _ref.read(selectedProjectIdProvider.notifier).state = projectId;
    }
  }

  void _setSelectedUnitIdsIfChanged(List<String> unitIds) {
    // EN: Avoid emitting identical unit lists to prevent duplicate fetches.
    // KO: 동일한 유닛 리스트 방출을 막아 중복 호출을 방지합니다.
    final current = _ref.read(selectedUnitIdsProvider);
    if (!listEquals(current, unitIds)) {
      _ref.read(selectedUnitIdsProvider.notifier).state =
          List<String>.from(unitIds);
    }
  }
}

/// EN: Projects repository provider.
/// KO: 프로젝트 리포지토리 프로바이더.
final projectsRepositoryProvider = FutureProvider<ProjectsRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.watch(cacheManagerProvider.future);
  return ProjectsRepositoryImpl(
    remoteDataSource: ProjectsRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Projects controller provider.
/// KO: 프로젝트 목록 컨트롤러 프로바이더.
final projectsControllerProvider =
    StateNotifierProvider<ProjectsController, AsyncValue<List<Project>>>((ref) {
      return ProjectsController(ref);
    });

/// EN: Project units controller provider.
/// KO: 프로젝트 유닛 컨트롤러 프로바이더.
final projectUnitsControllerProvider =
    StateNotifierProvider.family<
      ProjectUnitsController,
      AsyncValue<List<Unit>>,
      String
    >((ref, projectKey) {
      return ProjectUnitsController(ref, projectKey);
    });

/// EN: Project selection controller provider.
/// KO: 프로젝트 선택 컨트롤러 프로바이더.
final projectSelectionControllerProvider =
    StateNotifierProvider<ProjectSelectionController, ProjectSelectionState>((
      ref,
    ) {
      return ProjectSelectionController(ref);
    });

Project? _findProject(
  List<Project> projects,
  String? storedProjectKey,
  String? storedProjectId,
) {
  if (storedProjectKey != null && storedProjectKey.isNotEmpty) {
    for (final project in projects) {
      if (project.code == storedProjectKey || project.id == storedProjectKey) {
        return project;
      }
    }
  }

  if (storedProjectId != null && storedProjectId.isNotEmpty) {
    for (final project in projects) {
      if (project.id == storedProjectId) {
        return project;
      }
    }
  }

  return null;
}

String _projectKeyFor(Project project) {
  return project.code.isNotEmpty ? project.code : project.id;
}
