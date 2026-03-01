/// EN: Domain entities for account-tools features.
/// KO: 계정 도구 기능 도메인 엔티티.
library;

import '../../data/dto/account_tools_dto.dart';

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

class ProjectRoleRequest {
  const ProjectRoleRequest({
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

  bool get canCancel {
    final normalized = status.trim().toUpperCase();
    return normalized == 'PENDING' || normalized == 'REQUESTED';
  }

  factory ProjectRoleRequest.fromSummaryDto(ProjectRoleRequestSummaryDto dto) {
    return ProjectRoleRequest(
      id: dto.id,
      projectSlug: dto.projectSlug,
      projectName: dto.projectName,
      requestedRole: dto.requestedRole,
      status: dto.status,
      createdAt: dto.createdAt,
    );
  }

  factory ProjectRoleRequest.fromDetailDto(ProjectRoleRequestDetailDto dto) {
    return ProjectRoleRequest(
      id: dto.id,
      projectSlug: dto.projectSlug,
      projectName: dto.projectName,
      requestedRole: dto.requestedRole,
      status: dto.status,
      justification: dto.justification,
      reviewDecision: dto.reviewDecision,
      adminMemo: dto.adminMemo,
      reviewedAt: dto.reviewedAt,
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
