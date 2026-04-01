/// EN: Domain entities for account-tools features.
/// KO: 계정 도구 기능 도메인 엔티티.
library;

import '../../data/dto/account_tools_dto.dart';

/// EN: Result of the account restoration request.
/// KO: 계정 복구 요청 결과.
class RestoreAccountResult {
  const RestoreAccountResult({
    required this.result,
    required this.restoredAt,
    this.retentionUntil,
  });

  final String result;
  final DateTime restoredAt;
  final DateTime? retentionUntil;

  factory RestoreAccountResult.fromDto(RestoreAccountResultDto dto) {
    return RestoreAccountResult(
      result: dto.result,
      restoredAt: dto.restoredAt,
      retentionUntil: dto.retentionUntil,
    );
  }
}

class BlockedUser {
  const BlockedUser({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;

  factory BlockedUser.fromDto(BlockedUserDto dto) {
    return BlockedUser(
      id: dto.id,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
    );
  }
}

class UserBlock {
  const UserBlock({
    required this.id,
    required this.blockedUser,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final BlockedUser blockedUser;
  final String? reason;
  final DateTime createdAt;

  factory UserBlock.fromDto(UserBlockDto dto) {
    return UserBlock(
      id: dto.id,
      blockedUser: BlockedUser.fromDto(dto.blockedUser),
      reason: dto.reason,
      createdAt: dto.createdAt,
    );
  }
}

class VerificationAppeal {
  const VerificationAppeal({
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

  factory VerificationAppeal.fromDto(VerificationAppealDto dto) {
    return VerificationAppeal(
      id: dto.id,
      targetType: dto.targetType,
      targetId: dto.targetId,
      placeId: dto.placeId,
      reason: dto.reason,
      description: dto.description,
      evidenceUrls: dto.evidenceUrls,
      status: dto.status,
      reviewerMemo: dto.reviewerMemo,
      createdAt: dto.createdAt,
      resolvedAt: dto.resolvedAt,
    );
  }
}

class ProjectRoleRequest {
  const ProjectRoleRequest({
    required this.id,
    required this.projectId,
    required this.requestedRole,
    required this.status,
    required this.justification,
    required this.createdAt,
    this.projectCode,
    this.projectName,
    this.adminMemo,
    this.reviewedAt,
    this.reviewerId,
    this.reviewerName,
  });

  final String id;
  final String projectId;
  final String? projectCode;
  final String? projectName;
  final String requestedRole;
  final String status;
  final String justification;
  final DateTime createdAt;
  final String? adminMemo;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? reviewerName;

  bool get isPending {
    return status.toUpperCase() == 'PENDING' ||
        status.toUpperCase() == 'OPEN' ||
        status.toUpperCase() == 'REQUESTED';
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'OPEN':
      case 'REQUESTED':
        return '대기중';
      case 'APPROVED':
      case 'GRANTED':
        return '승인됨';
      case 'REJECTED':
      case 'DENIED':
        return '거절됨';
      case 'CANCELED':
      case 'CANCELLED':
        return '취소됨';
      default:
        return status;
    }
  }

  String get requestedRoleLabel {
    switch (requestedRole.toUpperCase()) {
      case 'PLACE_EDITOR':
        return '콘텐츠 편집';
      case 'COMMUNITY_MODERATOR':
        return '커뮤니티 운영';
      case 'ADMIN':
        return '프로젝트 관리자';
      case 'MEMBER':
        return '멤버';
      default:
        return requestedRole;
    }
  }

  factory ProjectRoleRequest.fromDto(ProjectRoleRequestDto dto) {
    return ProjectRoleRequest(
      id: dto.id,
      projectId: dto.projectId,
      projectCode: dto.projectCode,
      projectName: dto.projectName,
      requestedRole: dto.requestedRole,
      status: dto.status,
      justification: dto.justification,
      createdAt: dto.createdAt,
      adminMemo: dto.adminMemo,
      reviewedAt: dto.reviewedAt,
      reviewerId: dto.reviewerId,
      reviewerName: dto.reviewerName,
    );
  }
}
