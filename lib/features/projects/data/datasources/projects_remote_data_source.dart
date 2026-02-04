/// EN: Remote data source for projects and units.
/// KO: 프로젝트/유닛 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/project_dto.dart';
import '../dto/unit_dto.dart';

class ProjectsRemoteDataSource {
  ProjectsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<List<ProjectDto>>> fetchProjects() {
    return _apiClient.get<List<ProjectDto>>(
      ApiEndpoints.projects,
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(ProjectDto.fromJson)
              .toList();
        }
        if (json is Map<String, dynamic>) {
          final items = json['items'] ?? json['data'] ?? json['results'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(ProjectDto.fromJson)
                .toList();
          }
        }
        return <ProjectDto>[];
      },
    );
  }

  Future<Result<List<UnitDto>>> fetchUnits({
    required String projectId,
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) {
    return _apiClient.get<List<UnitDto>>(
      ApiEndpoints.projectUnits(projectId),
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(UnitDto.fromJson)
              .toList();
        }
        if (json is Map<String, dynamic>) {
          final items = json['items'] ?? json['data'] ?? json['results'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(UnitDto.fromJson)
                .toList();
          }
        }
        return <UnitDto>[];
      },
    );
  }
}
