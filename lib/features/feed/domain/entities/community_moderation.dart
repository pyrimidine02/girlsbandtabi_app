/// EN: Community moderation domain entities.
/// KO: 커뮤니티 신고/차단 도메인 엔티티.
library;

import 'package:intl/intl.dart';

enum CommunityReportTargetType { post, comment, user, place, guide, photo }

extension CommunityReportTargetTypeX on CommunityReportTargetType {
  String get apiValue {
    switch (this) {
      case CommunityReportTargetType.post:
        return 'POST';
      case CommunityReportTargetType.comment:
        return 'COMMENT';
      case CommunityReportTargetType.user:
        return 'USER';
      case CommunityReportTargetType.place:
        return 'PLACE';
      case CommunityReportTargetType.guide:
        return 'GUIDE';
      case CommunityReportTargetType.photo:
        return 'PHOTO';
    }
  }

  String get label {
    final languageCode = _languageCode();
    switch (this) {
      case CommunityReportTargetType.post:
        if (languageCode == 'en') return 'Post';
        if (languageCode == 'ja') return '投稿';
        return '게시글';
      case CommunityReportTargetType.comment:
        if (languageCode == 'en') return 'Comment';
        if (languageCode == 'ja') return 'コメント';
        return '댓글';
      case CommunityReportTargetType.user:
        if (languageCode == 'en') return 'User';
        if (languageCode == 'ja') return 'ユーザー';
        return '사용자';
      case CommunityReportTargetType.place:
        if (languageCode == 'en') return 'Place';
        if (languageCode == 'ja') return '場所';
        return '장소';
      case CommunityReportTargetType.guide:
        if (languageCode == 'en') return 'Guide';
        if (languageCode == 'ja') return 'ガイド';
        return '가이드';
      case CommunityReportTargetType.photo:
        if (languageCode == 'en') return 'Photo';
        if (languageCode == 'ja') return '写真';
        return '사진';
    }
  }

  static CommunityReportTargetType fromApiValue(String? value) {
    switch (value) {
      case 'COMMENT':
        return CommunityReportTargetType.comment;
      case 'USER':
        return CommunityReportTargetType.user;
      case 'PLACE':
        return CommunityReportTargetType.place;
      case 'GUIDE':
        return CommunityReportTargetType.guide;
      case 'PHOTO':
        return CommunityReportTargetType.photo;
      default:
        return CommunityReportTargetType.post;
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
    final languageCode = _languageCode();
    switch (this) {
      case CommunityReportReason.spam:
        if (languageCode == 'en') return 'Spam/Flood';
        if (languageCode == 'ja') return 'スパム/連投';
        return '스팸/도배';
      case CommunityReportReason.abuse:
        if (languageCode == 'en') return 'Abuse/Insult';
        if (languageCode == 'ja') return '暴言/侮辱';
        return '욕설/모욕';
      case CommunityReportReason.harassment:
        if (languageCode == 'en') return 'Harassment';
        if (languageCode == 'ja') return '嫌がらせ';
        return '괴롭힘';
      case CommunityReportReason.hate:
        if (languageCode == 'en') return 'Hate speech';
        if (languageCode == 'ja') return 'ヘイト表現';
        return '혐오 표현';
      case CommunityReportReason.offTopic:
        if (languageCode == 'en') return 'Off-topic';
        if (languageCode == 'ja') return '話題と無関係';
        return '주제와 무관';
      case CommunityReportReason.illegal:
        if (languageCode == 'en') return 'Illegal content';
        if (languageCode == 'ja') return '違法コンテンツ';
        return '불법 콘텐츠';
      case CommunityReportReason.misinformation:
        if (languageCode == 'en') return 'Misinformation';
        if (languageCode == 'ja') return '虚偽情報';
        return '허위 정보';
      case CommunityReportReason.copyright:
        if (languageCode == 'en') return 'Copyright infringement';
        if (languageCode == 'ja') return '著作権侵害';
        return '저작권 침해';
      case CommunityReportReason.other:
        if (languageCode == 'en') return 'Other';
        if (languageCode == 'ja') return 'その他';
        return '기타';
    }
  }

  static CommunityReportReason fromApiValue(String? value) {
    switch (value) {
      case 'SPAM':
        return CommunityReportReason.spam;
      case 'ABUSE':
        return CommunityReportReason.abuse;
      case 'HARASSMENT':
        return CommunityReportReason.harassment;
      case 'HATE':
        return CommunityReportReason.hate;
      case 'OFF_TOPIC':
        return CommunityReportReason.offTopic;
      case 'ILLEGAL':
        return CommunityReportReason.illegal;
      case 'MISINFORMATION':
        return CommunityReportReason.misinformation;
      case 'COPYRIGHT':
        return CommunityReportReason.copyright;
      default:
        return CommunityReportReason.other;
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
    final languageCode = _languageCode();
    switch (this) {
      case ContentModerationStatus.published:
        if (languageCode == 'en') return 'Normal';
        if (languageCode == 'ja') return '正常';
        return '정상';
      case ContentModerationStatus.quarantined:
        if (languageCode == 'en') return 'Under review';
        if (languageCode == 'ja') return '確認中';
        return '검토 중';
      case ContentModerationStatus.deleted:
        if (languageCode == 'en') return 'Deleted';
        if (languageCode == 'ja') return '削除済み';
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
    final languageCode = _languageCode();
    switch (this) {
      case UserSanctionLevel.none:
        if (languageCode == 'en') return 'Normal';
        if (languageCode == 'ja') return '正常';
        return '정상';
      case UserSanctionLevel.warning:
        if (languageCode == 'en') return 'Warning';
        if (languageCode == 'ja') return '警告';
        return '경고';
      case UserSanctionLevel.muted:
        if (languageCode == 'en') return 'Muted';
        if (languageCode == 'ja') return '投稿制限';
        return '작성 제한';
      case UserSanctionLevel.banned:
        if (languageCode == 'en') return 'Banned';
        if (languageCode == 'ja') return '利用停止';
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

class UserFollowStatus {
  const UserFollowStatus({
    required this.targetUserId,
    required this.following,
    required this.followedByTarget,
    required this.targetFollowerCount,
    required this.targetFollowingCount,
    this.followedAt,
  });

  final String targetUserId;
  final bool following;
  final bool followedByTarget;
  final DateTime? followedAt;
  final int targetFollowerCount;
  final int targetFollowingCount;
}

class UserFollowSummary {
  const UserFollowSummary({
    required this.userId,
    required this.displayName,
    required this.followedAt,
    this.avatarUrl,
    this.bio,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime followedAt;
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

String _languageCode() {
  final locale = Intl.getCurrentLocale();
  if (locale.isEmpty) return 'ko';
  return locale.split(RegExp(r'[_-]')).first;
}

enum CommunityReportStatus { open, inReview, resolved, rejected }

extension CommunityReportStatusX on CommunityReportStatus {
  static CommunityReportStatus fromApiValue(String? value) {
    switch (value) {
      case 'IN_REVIEW':
        return CommunityReportStatus.inReview;
      case 'RESOLVED':
        return CommunityReportStatus.resolved;
      case 'REJECTED':
        return CommunityReportStatus.rejected;
      default:
        return CommunityReportStatus.open;
    }
  }
}

enum CommunityReportPriority { low, normal, high, critical }

extension CommunityReportPriorityX on CommunityReportPriority {
  static CommunityReportPriority fromApiValue(String? value) {
    switch (value) {
      case 'LOW':
        return CommunityReportPriority.low;
      case 'HIGH':
        return CommunityReportPriority.high;
      case 'CRITICAL':
        return CommunityReportPriority.critical;
      default:
        return CommunityReportPriority.normal;
    }
  }
}

enum CommunityAdminAction {
  none,
  contentRemoved,
  userWarned,
  userSuspended,
  userBanned,
}

extension CommunityAdminActionX on CommunityAdminAction {
  static CommunityAdminAction fromApiValue(String? value) {
    switch (value) {
      case 'CONTENT_REMOVED':
        return CommunityAdminAction.contentRemoved;
      case 'USER_WARNED':
        return CommunityAdminAction.userWarned;
      case 'USER_SUSPENDED':
        return CommunityAdminAction.userSuspended;
      case 'USER_BANNED':
        return CommunityAdminAction.userBanned;
      default:
        return CommunityAdminAction.none;
    }
  }
}

class CommunityReportSummary {
  const CommunityReportSummary({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  final String id;
  final CommunityReportTargetType targetType;
  final String targetId;
  final CommunityReportReason reason;
  final CommunityReportStatus status;
  final CommunityReportPriority priority;
  final DateTime createdAt;
}

class CommunityReportDetail {
  const CommunityReportDetail({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.adminAction,
    this.resolvedAt,
  });

  final String id;
  final CommunityReportTargetType targetType;
  final String targetId;
  final CommunityReportReason reason;
  final CommunityReportStatus status;
  final CommunityReportPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final CommunityAdminAction? adminAction;
  final DateTime? resolvedAt;
}

class ProjectCommunityBan {
  const ProjectCommunityBan({
    required this.id,
    required this.projectId,
    required this.bannedUserId,
    required this.moderatorUserId,
    required this.createdAt,
    this.bannedUserDisplayName,
    this.bannedUserEmail,
    this.bannedUserAvatarUrl,
    this.reason,
    this.expiresAt,
  });

  final String id;
  final String projectId;
  final String bannedUserId;
  final String moderatorUserId;
  final DateTime createdAt;
  final String? bannedUserDisplayName;
  final String? bannedUserEmail;
  final String? bannedUserAvatarUrl;
  final String? reason;
  final DateTime? expiresAt;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}
