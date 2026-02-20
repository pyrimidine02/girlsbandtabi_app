/// EN: Admin operations domain entities.
/// KO: 운영/관리자 기능 도메인 엔티티.
library;

import 'package:flutter/material.dart';

/// EN: Community report moderation status.
/// KO: 커뮤니티 신고 처리 상태.
enum AdminReportStatus {
  open,
  inReview,
  resolved,
  rejected,
  duplicate,
  dismissed,
  unknown,
}

extension AdminReportStatusX on AdminReportStatus {
  String get apiValue {
    switch (this) {
      case AdminReportStatus.open:
        return 'OPEN';
      case AdminReportStatus.inReview:
        return 'IN_REVIEW';
      case AdminReportStatus.resolved:
        return 'RESOLVED';
      case AdminReportStatus.rejected:
        return 'REJECTED';
      case AdminReportStatus.duplicate:
        return 'DUPLICATE';
      case AdminReportStatus.dismissed:
        return 'DISMISSED';
      case AdminReportStatus.unknown:
        return 'UNKNOWN';
    }
  }

  String get label {
    switch (this) {
      case AdminReportStatus.open:
        return '접수됨';
      case AdminReportStatus.inReview:
        return '검토 중';
      case AdminReportStatus.resolved:
        return '조치 완료';
      case AdminReportStatus.rejected:
        return '반려';
      case AdminReportStatus.duplicate:
        return '중복';
      case AdminReportStatus.dismissed:
        return '종결';
      case AdminReportStatus.unknown:
        return '알 수 없음';
    }
  }

  static AdminReportStatus fromApiValue(String? rawValue) {
    switch (rawValue?.toUpperCase()) {
      case 'OPEN':
      case 'PENDING':
      case 'NEW':
        return AdminReportStatus.open;
      case 'IN_REVIEW':
      case 'PROCESSING':
      case 'UNDER_REVIEW':
        return AdminReportStatus.inReview;
      case 'RESOLVED':
      case 'CLOSED':
      case 'ACTIONED':
        return AdminReportStatus.resolved;
      case 'REJECTED':
        return AdminReportStatus.rejected;
      case 'DUPLICATE':
        return AdminReportStatus.duplicate;
      case 'DISMISSED':
        return AdminReportStatus.dismissed;
      default:
        return AdminReportStatus.unknown;
    }
  }
}

/// EN: Report list filter options.
/// KO: 신고 목록 필터 옵션.
enum AdminReportFilter { all, open, inReview, resolved, rejected }

extension AdminReportFilterX on AdminReportFilter {
  String get label {
    switch (this) {
      case AdminReportFilter.all:
        return '전체';
      case AdminReportFilter.open:
        return '접수됨';
      case AdminReportFilter.inReview:
        return '검토 중';
      case AdminReportFilter.resolved:
        return '완료';
      case AdminReportFilter.rejected:
        return '반려';
    }
  }

  String? get apiStatus {
    switch (this) {
      case AdminReportFilter.all:
        return null;
      case AdminReportFilter.open:
        return AdminReportStatus.open.apiValue;
      case AdminReportFilter.inReview:
        return AdminReportStatus.inReview.apiValue;
      case AdminReportFilter.resolved:
        return AdminReportStatus.resolved.apiValue;
      case AdminReportFilter.rejected:
        return AdminReportStatus.rejected.apiValue;
    }
  }
}

/// EN: Dashboard metrics for admin operations.
/// KO: 운영 대시보드 지표.
class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.openReports,
    required this.inReviewReports,
    required this.pendingRoleRequests,
    required this.pendingVerificationAppeals,
    required this.pendingMediaDeletionRequests,
    required this.activeSanctions,
    this.extraMetrics = const <String, int>{},
  });

  final int openReports;
  final int inReviewReports;
  final int pendingRoleRequests;
  final int pendingVerificationAppeals;
  final int pendingMediaDeletionRequests;
  final int activeSanctions;
  final Map<String, int> extraMetrics;

  int get totalPendingItems {
    return openReports +
        inReviewReports +
        pendingRoleRequests +
        pendingVerificationAppeals +
        pendingMediaDeletionRequests;
  }
}

/// EN: Community report entity for admin moderation UI.
/// KO: 운영 신고 관리 UI용 커뮤니티 신고 엔티티.
class AdminCommunityReport {
  const AdminCommunityReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.reporterId,
    this.reporterName,
    this.assigneeId,
    this.assigneeName,
    this.description,
    this.previewText,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String reason;
  final AdminReportStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reporterId;
  final String? reporterName;
  final String? assigneeId;
  final String? assigneeName;
  final String? description;
  final String? previewText;

  String get targetLabel {
    switch (targetType.toUpperCase()) {
      case 'POST':
        return '게시글';
      case 'COMMENT':
        return '댓글';
      case 'USER':
        return '사용자';
      default:
        return targetType;
    }
  }
}

/// EN: Returns true when a role can access admin operations screens.
/// KO: 관리자/운영 화면 접근이 가능한 역할인지 반환합니다.
bool hasAdminOpsAccessRole(String? role) {
  if (role == null || role.isEmpty) {
    return false;
  }

  const allowedRoles = <String>{
    'ADMIN',
    'SUPER_ADMIN',
    'APP_MANAGER',
    'MANAGER',
    'OPERATOR',
    'MODERATOR',
    'PROJECT_ADMIN',
  };

  return allowedRoles.contains(role.toUpperCase());
}

/// EN: UI palette for report states.
/// KO: 신고 상태별 UI 색상 팔레트.
class AdminReportStatusPalette {
  const AdminReportStatusPalette({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}
