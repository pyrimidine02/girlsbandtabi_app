/// EN: DTOs for settings account-tools APIs.
/// KO: 설정 계정 도구 API DTO 모음.
library;

class BlockedUserDto {
  const BlockedUserDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;

  factory BlockedUserDto.fromJson(Map<String, dynamic> json) {
    return BlockedUserDto(
      id: _string(json, const ['id', 'userId']) ?? '',
      displayName:
          _string(json, const ['displayName', 'nickname', 'name']) ?? '사용자',
      avatarUrl: _string(json, const [
        'avatarUrl',
        'profileImageUrl',
        'imageUrl',
      ]),
    );
  }
}

class UserBlockDto {
  const UserBlockDto({
    required this.id,
    required this.blockedUser,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final BlockedUserDto blockedUser;
  final String? reason;
  final DateTime createdAt;

  factory UserBlockDto.fromJson(Map<String, dynamic> json) {
    final blockedUserRaw = json['blockedUser'];
    final blockedUserMap = blockedUserRaw is Map<String, dynamic>
        ? blockedUserRaw
        : <String, dynamic>{};

    return UserBlockDto(
      id: _string(json, const ['id']) ?? '',
      blockedUser: BlockedUserDto.fromJson(blockedUserMap),
      reason: _string(json, const ['reason']),
      createdAt:
          _dateTime(json, const ['createdAt', 'blockedAt', 'created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ProjectRoleRequestSummaryDto {
  const ProjectRoleRequestSummaryDto({
    required this.id,
    required this.requestedRole,
    required this.status,
    required this.createdAt,
    this.projectSlug,
    this.projectName,
  });

  final String id;
  final String? projectSlug;
  final String? projectName;
  final String requestedRole;
  final String status;
  final DateTime createdAt;

  factory ProjectRoleRequestSummaryDto.fromJson(Map<String, dynamic> json) {
    return ProjectRoleRequestSummaryDto(
      id: _string(json, const ['id']) ?? '',
      projectSlug: _string(json, const ['projectSlug', 'projectCode']),
      projectName: _string(json, const ['projectName']),
      requestedRole: _string(json, const ['requestedRole']) ?? 'VIEWER',
      status: _string(json, const ['status']) ?? 'PENDING',
      createdAt:
          _dateTime(json, const ['createdAt', 'created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ProjectRoleRequestDetailDto {
  const ProjectRoleRequestDetailDto({
    required this.id,
    required this.requestedRole,
    required this.status,
    required this.createdAt,
    this.projectSlug,
    this.projectName,
    this.justification,
    this.reviewDecision,
    this.adminMemo,
    this.reviewedAt,
  });

  final String id;
  final String? projectSlug;
  final String? projectName;
  final String requestedRole;
  final String status;
  final String? justification;
  final String? reviewDecision;
  final String? adminMemo;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  factory ProjectRoleRequestDetailDto.fromJson(Map<String, dynamic> json) {
    return ProjectRoleRequestDetailDto(
      id: _string(json, const ['id']) ?? '',
      projectSlug: _string(json, const ['projectSlug', 'projectCode']),
      projectName: _string(json, const ['projectName']),
      requestedRole: _string(json, const ['requestedRole']) ?? 'VIEWER',
      status: _string(json, const ['status']) ?? 'PENDING',
      justification: _string(json, const ['justification']),
      reviewDecision: _string(json, const ['reviewDecision']),
      adminMemo: _string(json, const ['adminMemo']),
      reviewedAt: _dateTime(json, const ['reviewedAt']),
      createdAt:
          _dateTime(json, const ['createdAt', 'created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ProjectRoleRequestCreateRequestDto {
  const ProjectRoleRequestCreateRequestDto({
    required this.projectId,
    required this.requestedRole,
    required this.justification,
  });

  final String projectId;
  final String requestedRole;
  final String justification;

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'requestedRole': requestedRole,
      'justification': justification,
    };
  }
}

class VerificationAppealDto {
  const VerificationAppealDto({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.placeId,
    this.description,
    this.evidenceUrls = const <String>[],
    this.reviewerMemo,
    this.resolvedAt,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String? placeId;
  final String reason;
  final String? description;
  final List<String> evidenceUrls;
  final String status;
  final String? reviewerMemo;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  factory VerificationAppealDto.fromJson(Map<String, dynamic> json) {
    final evidenceRaw = json['evidenceUrls'];
    final evidenceUrls = <String>[];
    if (evidenceRaw is List) {
      evidenceUrls.addAll(
        evidenceRaw
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    }

    return VerificationAppealDto(
      id: _string(json, const ['id']) ?? '',
      targetType: _string(json, const ['targetType']) ?? 'PLACE_VISIT',
      targetId: _string(json, const ['targetId']) ?? '',
      placeId: _string(json, const ['placeId']),
      reason: _string(json, const ['reason']) ?? 'OTHER',
      description: _string(json, const ['description']),
      evidenceUrls: evidenceUrls,
      status: _string(json, const ['status']) ?? 'PENDING',
      reviewerMemo: _string(json, const ['reviewerMemo']),
      createdAt:
          _dateTime(json, const ['createdAt', 'created_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      resolvedAt: _dateTime(json, const ['resolvedAt']),
    );
  }
}

class VerificationAppealCreateRequestDto {
  const VerificationAppealCreateRequestDto({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.evidenceUrls = const <String>[],
  });

  final String targetType;
  final String targetId;
  final String reason;
  final String? description;
  final List<String> evidenceUrls;

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      if (evidenceUrls.isNotEmpty) 'evidenceUrls': evidenceUrls,
    };
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

DateTime? _dateTime(Map<String, dynamic> json, List<String> keys) {
  final raw = _string(json, keys);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}
