import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/project_role_model.dart';

class ProjectRoleService {
  ProjectRoleService();

  final ApiClient _api = ApiClient.instance;

  Future<List<ProjectRole>> getRoles(String projectId) async {
    final envelope = await _api.get(
      ApiConstants.projectRoles(projectId),
    );
    final list = envelope.data is List
        ? envelope.data as List
        : (envelope.data is Map<String, dynamic>
            ? (envelope.data['items'] as List?) ?? const <dynamic>[]
            : const <dynamic>[]);
    return list
        .whereType<Map<String, dynamic>>()
        .map(ProjectRole.fromMap)
        .toList(growable: false);
  }

  Future<ProjectRole> grantRole({
    required String projectId,
    required String userId,
    required String role,
  }) async {
    final envelope = await _api.post(
      ApiConstants.grantRole(projectId),
      data: {
        'userId': userId,
        'role': role,
      },
    );
    return ProjectRole.fromMap(envelope.requireDataAsMap());
  }

  Future<void> revokeRole({
    required String projectId,
    required String userId,
    required String role,
  }) async {
    await _api.post(
      ApiConstants.revokeRole(projectId),
      data: {
        'userId': userId,
        'role': role,
      },
    );
  }
}
