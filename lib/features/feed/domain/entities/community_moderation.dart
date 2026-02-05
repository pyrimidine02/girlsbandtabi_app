/// EN: Community moderation domain entities.
/// KO: 커뮤니티 신고/차단 도메인 엔티티.
library;

enum CommunityReportTargetType {
  post,
  comment,
  user,
}

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
