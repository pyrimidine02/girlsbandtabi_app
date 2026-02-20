/// EN: Community moderation domain entities.
/// KO: 커뮤니티 신고/차단 도메인 엔티티.
library;

enum CommunityReportTargetType { post, comment, user }

extension CommunityReportTargetTypeX on CommunityReportTargetType {
  String get apiValue {
    switch (this) {
      case CommunityReportTargetType.post:
        return 'POST';
      case CommunityReportTargetType.comment:
        return 'COMMENT';
      case CommunityReportTargetType.user:
        return 'USER';
    }
  }

  String get label {
    switch (this) {
      case CommunityReportTargetType.post:
        return '게시글';
      case CommunityReportTargetType.comment:
        return '댓글';
      case CommunityReportTargetType.user:
        return '사용자';
    }
  }
}

enum CommunityReportReason {
  spam,
  abuse,
  harassment,
  hate,
  offTopic,
  illegal,
  misinformation,
  copyright,
  other,
}

extension CommunityReportReasonX on CommunityReportReason {
  String get apiValue {
    switch (this) {
      case CommunityReportReason.spam:
        return 'SPAM';
      case CommunityReportReason.abuse:
        return 'ABUSE';
      case CommunityReportReason.harassment:
        return 'HARASSMENT';
      case CommunityReportReason.hate:
        return 'HATE';
      case CommunityReportReason.offTopic:
        return 'OFF_TOPIC';
      case CommunityReportReason.illegal:
        return 'ILLEGAL';
      case CommunityReportReason.misinformation:
        return 'MISINFORMATION';
      case CommunityReportReason.copyright:
        return 'COPYRIGHT';
      case CommunityReportReason.other:
        return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case CommunityReportReason.spam:
        return '스팸/도배';
      case CommunityReportReason.abuse:
        return '욕설/모욕';
      case CommunityReportReason.harassment:
        return '괴롭힘';
      case CommunityReportReason.hate:
        return '혐오 표현';
      case CommunityReportReason.offTopic:
        return '주제와 무관';
      case CommunityReportReason.illegal:
        return '불법 콘텐츠';
      case CommunityReportReason.misinformation:
        return '허위 정보';
      case CommunityReportReason.copyright:
        return '저작권 침해';
      case CommunityReportReason.other:
        return '기타';
    }
  }
}

/// EN: Content moderation status for posts/comments.
/// KO: 게시글/댓글의 모더레이션 상태.
enum ContentModerationStatus { published, quarantined, deleted }

extension ContentModerationStatusX on ContentModerationStatus {
  String get apiValue {
    switch (this) {
      case ContentModerationStatus.published:
        return 'PUBLISHED';
      case ContentModerationStatus.quarantined:
        return 'QUARANTINED';
      case ContentModerationStatus.deleted:
        return 'DELETED';
    }
  }

  String get label {
    switch (this) {
      case ContentModerationStatus.published:
        return '정상';
      case ContentModerationStatus.quarantined:
        return '검토 중';
      case ContentModerationStatus.deleted:
        return '삭제됨';
    }
  }

  static ContentModerationStatus fromApiValue(String? value) {
    switch (value) {
      case 'QUARANTINED':
        return ContentModerationStatus.quarantined;
      case 'DELETED':
        return ContentModerationStatus.deleted;
      default:
        return ContentModerationStatus.published;
    }
  }
}

/// EN: User sanction level.
/// KO: 사용자 제재 수준.
enum UserSanctionLevel { none, warning, muted, banned }

extension UserSanctionLevelX on UserSanctionLevel {
  String get apiValue {
    switch (this) {
      case UserSanctionLevel.none:
        return 'NONE';
      case UserSanctionLevel.warning:
        return 'WARNING';
      case UserSanctionLevel.muted:
        return 'MUTED';
      case UserSanctionLevel.banned:
        return 'BANNED';
    }
  }

  String get label {
    switch (this) {
      case UserSanctionLevel.none:
        return '정상';
      case UserSanctionLevel.warning:
        return '경고';
      case UserSanctionLevel.muted:
        return '작성 제한';
      case UserSanctionLevel.banned:
        return '이용 정지';
    }
  }

  static UserSanctionLevel fromApiValue(String? value) {
    switch (value) {
      case 'WARNING':
        return UserSanctionLevel.warning;
      case 'MUTED':
        return UserSanctionLevel.muted;
      case 'BANNED':
        return UserSanctionLevel.banned;
      default:
        return UserSanctionLevel.none;
    }
  }
}

/// EN: User sanction state.
/// KO: 사용자 제재 상태.
class UserSanctionStatus {
  const UserSanctionStatus({required this.level, this.reason, this.expiresAt});

  final UserSanctionLevel level;
  final String? reason;
  final DateTime? expiresAt;

  /// EN: Whether posting/commenting should be blocked.
  /// KO: 게시글/댓글 작성 제한 상태인지 여부.
  bool get isRestricted =>
      level == UserSanctionLevel.muted || level == UserSanctionLevel.banned;
}

class BlockStatus {
  const BlockStatus({
    required this.isBlocked,
    required this.blockedByMe,
    required this.blockedMe,
    required this.blockedByAdmin,
  });

  final bool isBlocked;
  final bool blockedByMe;
  final bool blockedMe;
  final bool blockedByAdmin;
}
