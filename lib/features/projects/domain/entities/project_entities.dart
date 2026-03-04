/// EN: Project domain entities.
/// KO: 프로젝트 도메인 엔티티.
library;

import '../../data/dto/member_dto.dart';
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
  const Unit({required this.id, required this.code, required this.displayName});

  final String id;
  final String code;
  final String displayName;

  factory Unit.fromDto(UnitDto dto) {
    return Unit(id: dto.id, code: dto.code, displayName: dto.displayName);
  }
}

/// EN: Domain entity for a unit member (band character + voice actor).
/// KO: 유닛 멤버(밴드 캐릭터 + 성우) 도메인 엔티티.
class UnitMember {
  const UnitMember({
    required this.id,
    required this.name,
    this.role,
    this.voiceActorName,
    this.imageUrl,
    this.order,
    this.birthdate,
    this.description,
    this.instrument,
    this.isActive,
  });

  final String id;
  final String name;
  final String? role;

  // EN: Voice actor / seiyuu name for this character.
  // KO: 이 캐릭터의 성우(세이유) 이름.
  final String? voiceActorName;
  final String? imageUrl;
  final int? order;
  final String? birthdate;
  final String? description;
  final String? instrument;
  final bool? isActive;

  factory UnitMember.fromDto(MemberDto dto) {
    return UnitMember(
      id: dto.id,
      name: dto.name,
      role: dto.role,
      voiceActorName: dto.voiceActorName,
      imageUrl: dto.imageUrl,
      order: dto.order,
      birthdate: dto.birthdate,
      description: dto.description,
      instrument: dto.instrument,
      isActive: dto.isActive,
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

  ProjectSelectionState copyWith({String? projectKey, List<String>? unitIds}) {
    return ProjectSelectionState(
      projectKey: projectKey ?? this.projectKey,
      unitIds: unitIds ?? this.unitIds,
    );
  }

  factory ProjectSelectionState.initial() {
    return const ProjectSelectionState(projectKey: null, unitIds: []);
  }
}
