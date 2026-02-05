/// EN: Community moderation DTOs.
/// KO: 커뮤니티 신고/차단 DTO.
library;

class ReportCreateRequestDto {
  const ReportCreateRequestDto({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
  });

  final String targetType;
  final String targetId;
  final String reason;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}

class BlockCreateRequestDto {
  const BlockCreateRequestDto({required this.targetUserId, this.reason});

  final String targetUserId;
  final String? reason;

  Map<String, dynamic> toJson() {
    return {
      'targetUserId': targetUserId,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
    };
  }
}

class BlockCheckDto {
  const BlockCheckDto({
    required this.isBlocked,
    required this.blockedByMe,
    required this.blockedMe,
    required this.blockedByAdmin,
  });

  final bool isBlocked;
  final bool blockedByMe;
  final bool blockedMe;
  final bool blockedByAdmin;

  factory BlockCheckDto.fromJson(Map<String, dynamic> json) {
    return BlockCheckDto(
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockedByMe: json['blockedByMe'] as bool? ?? false,
      blockedMe: json['blockedMe'] as bool? ?? false,
      blockedByAdmin: json['blockedByAdmin'] as bool? ?? false,
    );
  }
}
