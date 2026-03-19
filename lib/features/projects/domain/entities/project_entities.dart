/// EN: Project domain entities.
/// KO: 프로젝트 도메인 엔티티.
library;

import '../../data/dto/member_dto.dart';
import '../../data/dto/project_dto.dart';
import '../../data/dto/unit_dto.dart';
import '../../data/dto/voice_actor_dto.dart';

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
    this.description,
    this.status,
    this.logoUrl,
    this.colorHex,
    this.debutDate,
    this.memberSummaries = const [],
  });

  final String id;
  final String code;
  final String displayName;
  final String? description;
  final String? status;
  final String? logoUrl;
  final String? colorHex;
  final String? debutDate;
  final List<UnitMemberSummary> memberSummaries;

  factory Unit.fromDto(UnitDto dto) {
    return Unit(
      id: dto.id,
      code: dto.slug,
      displayName: dto.name,
      description: dto.description,
      status: dto.status,
      logoUrl: dto.logoUrl,
      colorHex: dto.colorHex,
      debutDate: dto.debutDate,
      memberSummaries: dto.members.map(UnitMemberSummary.fromDto).toList(),
    );
  }
}

class UnitMemberSummary {
  const UnitMemberSummary({
    required this.id,
    required this.characterName,
    this.position,
    this.isLeader,
    this.characterImageUrl,
    this.displayOrder,
  });

  final String id;
  final String characterName;
  final String? position;
  final bool? isLeader;
  final String? characterImageUrl;
  final int? displayOrder;

  factory UnitMemberSummary.fromDto(UnitMemberSummaryDto dto) {
    return UnitMemberSummary(
      id: dto.id,
      characterName: dto.characterName,
      position: dto.position,
      isLeader: dto.isLeader,
      characterImageUrl: dto.characterImageUrl,
      displayOrder: dto.displayOrder,
    );
  }
}

class VoiceActorRole {
  const VoiceActorRole({
    required this.id,
    required this.displayName,
    this.roleType,
    this.profileImageUrl,
  });

  final String id;
  final String displayName;
  final String? roleType;
  final String? profileImageUrl;

  factory VoiceActorRole.fromDto(MemberVoiceActorDto dto) {
    return VoiceActorRole(
      id: dto.id,
      displayName: dto.displayName,
      roleType: dto.roleType,
      profileImageUrl: dto.profileImageUrl,
    );
  }
}

/// EN: Domain entity for a unit member (band character + voice actor).
/// KO: 유닛 멤버(밴드 캐릭터 + 성우) 도메인 엔티티.
class UnitMember {
  const UnitMember({
    required this.id,
    required this.name,
    this.unitId,
    this.characterNameKana,
    this.role,
    this.voiceActorName,
    this.imageUrl,
    this.order,
    this.birthdate,
    this.hometown,
    this.description,
    this.instrument,
    this.isLeader,
    this.isActive,
    this.voiceActors = const [],
  });

  final String id;
  final String name;
  final String? unitId;
  final String? characterNameKana;
  final String? role;

  // EN: Primary voice actor/seiyuu name for backward compatibility.
  // KO: 하위 호환을 위한 대표 성우명 필드.
  final String? voiceActorName;
  final String? imageUrl;
  final int? order;
  final String? birthdate;
  final String? hometown;
  final String? description;
  final String? instrument;
  final bool? isLeader;
  final bool? isActive;
  final List<VoiceActorRole> voiceActors;

  factory UnitMember.fromDto(MemberDto dto) {
    final roles = dto.voiceActors.map(VoiceActorRole.fromDto).toList();
    return UnitMember(
      id: dto.id,
      name: dto.name,
      unitId: dto.unitId.isEmpty ? null : dto.unitId,
      characterNameKana: dto.characterNameKana,
      role: dto.role,
      voiceActorName: dto.voiceActorName,
      imageUrl: dto.imageUrl,
      order: dto.order,
      birthdate: dto.birthdate,
      hometown: dto.hometown,
      description: dto.description,
      instrument: dto.instrument,
      isLeader: dto.isLeader,
      isActive: dto.isActive,
      voiceActors: roles,
    );
  }
}

class VoiceActorListItem {
  const VoiceActorListItem({
    required this.id,
    required this.displayName,
    this.realName,
    this.stageName,
    this.agency,
    this.profileImageUrl,
  });

  final String id;
  final String displayName;
  final String? realName;
  final String? stageName;
  final String? agency;
  final String? profileImageUrl;

  factory VoiceActorListItem.fromDto(VoiceActorListItemDto dto) {
    return VoiceActorListItem(
      id: dto.id,
      displayName: dto.displayName,
      realName: dto.realName,
      stageName: dto.stageName,
      agency: dto.agency,
      profileImageUrl: dto.profileImageUrl,
    );
  }
}

class VoiceActorDetail {
  const VoiceActorDetail({
    required this.id,
    required this.displayName,
    this.realName,
    this.stageName,
    this.birthDate,
    this.agency,
    this.debutDate,
    this.bio,
    this.profileImageUrl,
    this.officialWebsite,
    this.twitterHandle,
    this.instagramHandle,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? realName;
  final String? stageName;
  final String? birthDate;
  final String? agency;
  final String? debutDate;
  final String? bio;
  final String? profileImageUrl;
  final String? officialWebsite;
  final String? twitterHandle;
  final String? instagramHandle;
  final String? createdAt;
  final String? updatedAt;

  factory VoiceActorDetail.fromDto(VoiceActorDetailDto dto) {
    return VoiceActorDetail(
      id: dto.id,
      displayName: dto.displayName,
      realName: dto.realName,
      stageName: dto.stageName,
      birthDate: dto.birthDate,
      agency: dto.agency,
      debutDate: dto.debutDate,
      bio: dto.bio,
      profileImageUrl: dto.profileImageUrl,
      officialWebsite: dto.officialWebsite,
      twitterHandle: dto.twitterHandle,
      instagramHandle: dto.instagramHandle,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}

class VoiceActorMemberSummary {
  const VoiceActorMemberSummary({
    required this.memberId,
    required this.unitId,
    required this.unitSlug,
    required this.unitName,
    required this.characterName,
    this.characterImageUrl,
    this.position,
    this.isLeader,
    this.roleType,
    this.rolePriority,
    this.startDate,
    this.endDate,
  });

  final String memberId;
  final String unitId;
  final String unitSlug;
  final String unitName;
  final String characterName;
  final String? characterImageUrl;
  final String? position;
  final bool? isLeader;
  final String? roleType;
  final int? rolePriority;
  final String? startDate;
  final String? endDate;

  factory VoiceActorMemberSummary.fromDto(VoiceActorMemberSummaryDto dto) {
    return VoiceActorMemberSummary(
      memberId: dto.memberId,
      unitId: dto.unitId,
      unitSlug: dto.unitSlug,
      unitName: dto.unitName,
      characterName: dto.characterName,
      characterImageUrl: dto.characterImageUrl,
      position: dto.position,
      isLeader: dto.isLeader,
      roleType: dto.roleType,
      rolePriority: dto.rolePriority,
      startDate: dto.startDate,
      endDate: dto.endDate,
    );
  }
}

class VoiceActorCreditSummary {
  const VoiceActorCreditSummary({
    required this.projectId,
    required this.projectSlug,
    required this.projectName,
    required this.unitId,
    required this.unitSlug,
    required this.unitName,
    required this.memberId,
    required this.characterName,
    this.characterImageUrl,
    this.position,
    this.isLeader,
    this.roleType,
    this.rolePriority,
    this.startDate,
    this.endDate,
    this.notes,
  });

  final String projectId;
  final String projectSlug;
  final String projectName;
  final String unitId;
  final String unitSlug;
  final String unitName;
  final String memberId;
  final String characterName;
  final String? characterImageUrl;
  final String? position;
  final bool? isLeader;
  final String? roleType;
  final int? rolePriority;
  final String? startDate;
  final String? endDate;
  final String? notes;

  factory VoiceActorCreditSummary.fromDto(VoiceActorCreditSummaryDto dto) {
    return VoiceActorCreditSummary(
      projectId: dto.projectId,
      projectSlug: dto.projectSlug,
      projectName: dto.projectName,
      unitId: dto.unitId,
      unitSlug: dto.unitSlug,
      unitName: dto.unitName,
      memberId: dto.memberId,
      characterName: dto.characterName,
      characterImageUrl: dto.characterImageUrl,
      position: dto.position,
      isLeader: dto.isLeader,
      roleType: dto.roleType,
      rolePriority: dto.rolePriority,
      startDate: dto.startDate,
      endDate: dto.endDate,
      notes: dto.notes,
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
