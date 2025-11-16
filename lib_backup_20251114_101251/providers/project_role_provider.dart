import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:girlsbandtabi_app/core/constants/api_constants.dart';
import 'package:girlsbandtabi_app/models/project_role_model.dart';
import 'package:girlsbandtabi_app/providers/content_filter_provider.dart';
import 'package:girlsbandtabi_app/services/project_role_service.dart';

final projectRoleServiceProvider = Provider<ProjectRoleService>(
  (ref) => ProjectRoleService(),
);

class ProjectRolesState {
  const ProjectRolesState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ProjectRole> items;
  final bool isLoading;
  final String? error;

  ProjectRolesState copyWith({
    List<ProjectRole>? items,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return ProjectRolesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

class ProjectRolesNotifier extends StateNotifier<ProjectRolesState> {
  ProjectRolesNotifier(this._service, this._ref)
    : super(const ProjectRolesState());

  final ProjectRoleService _service;
  final Ref _ref;

  String get _currentProject =>
      _ref.read(selectedProjectProvider) ?? ApiConstants.defaultProjectId;

  Future<void> load() async {
    final projectId = _currentProject;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final roles = await _service.getRoles(projectId);
      state = state.copyWith(items: roles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> grant({required String userId, required String role}) async {
    final projectId = _currentProject;
    await _service.grantRole(projectId: projectId, userId: userId, role: role);
    await load();
  }

  Future<void> revoke({required String userId, required String role}) async {
    final projectId = _currentProject;
    await _service.revokeRole(projectId: projectId, userId: userId, role: role);
    await load();
  }
}

final projectRolesProvider =
    StateNotifierProvider<ProjectRolesNotifier, ProjectRolesState>((ref) {
      final notifier = ProjectRolesNotifier(
        ref.read(projectRoleServiceProvider),
        ref,
      );
      ref.listen<String?>(selectedProjectProvider, (_, __) => notifier.load());
      notifier.load();
      return notifier;
    });

const Object _sentinel = Object();
