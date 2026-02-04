/// EN: Project domain entities.
/// KO: 프로젝트 도메인 엔티티.
library;

import '../../data/dto/project_dto.dart';
import '../../data/dto/unit_dto.dart';

class Project {
  const Project({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.defaultTimezone,
  });

  final String id;
  final String code;
  final String name;
  final String status;
  final String defaultTimezone;

  factory Project.fromDto(ProjectDto dto) {
    return Project(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      status: dto.status,
      defaultTimezone: dto.defaultTimezone,
    );
  }
}

class Unit {
  const Unit({
    required this.id,
    required this.code,
    required this.displayName,
  });

  final String id;
  final String code;
  final String displayName;

  factory Unit.fromDto(UnitDto dto) {
    return Unit(
      id: dto.id,
      code: dto.code,
      displayName: dto.displayName,
    );
  }
}

class ProjectSelectionState {
  const ProjectSelectionState({
    required this.projectKey,
    required this.unitIds,
  });

  final String? projectKey;
  final List<String> unitIds;

  ProjectSelectionState copyWith({
    String? projectKey,
    List<String>? unitIds,
  }) {
    return ProjectSelectionState(
      projectKey: projectKey ?? this.projectKey,
      unitIds: unitIds ?? this.unitIds,
    );
  }

  factory ProjectSelectionState.initial() {
    return const ProjectSelectionState(projectKey: null, unitIds: []);
  }
}
