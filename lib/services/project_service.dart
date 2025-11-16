import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/project_model.dart';

class ProjectService {
  ProjectService();

  final ApiClient _api = ApiClient.instance;

  Future<PageResponseProject> getProjects({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (sort != null) 'sort': sort,
    };

    final envelope = await _api.get(
      ApiConstants.projects,
      queryParameters: query,
    );

    final raw = envelope.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic>
            ? (raw['items'] as List?) ?? const <dynamic>[]
            : const <dynamic>[]);

    final projects = list
        .whereType<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList(growable: false);
    final pagination = envelope.pagination;

    return PageResponseProject(
      items: projects,
      page: pagination?.currentPage ?? page,
      size: pagination?.pageSize ?? size,
      total: pagination?.totalItems ?? projects.length,
      totalPages: pagination?.totalPages,
      hasNext: pagination?.hasNext ?? false,
      hasPrevious: pagination?.hasPrevious ?? false,
    );
  }

  Future<Project> createProject({
    required String name,
    required String code,
    required String status,
    String? defaultTimezone,
  }) async {
    final envelope = await _api.post(
      ApiConstants.projects,
      data: {
        'name': name,
        'code': code,
        'defaultTimezone': defaultTimezone,
      },
    );
    return Project.fromJson(envelope.requireDataAsMap());
  }

  Future<Project> updateProject({
    required String projectId,
    String? name,
    String? code,
    String? status,
    String? defaultTimezone,
  }) async {
    final payload = <String, dynamic>{
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (status != null) 'status': status,
      if (defaultTimezone != null) 'defaultTimezone': defaultTimezone,
    };

    final envelope = await _api.put(
      ApiConstants.project(projectId),
      data: payload,
    );
    return Project.fromJson(envelope.requireDataAsMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _api.delete(ApiConstants.project(projectId));
  }
}
