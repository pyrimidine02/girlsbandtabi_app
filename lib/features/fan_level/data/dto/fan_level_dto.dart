/// EN: DTOs for fan level API responses — maps raw JSON to domain entities.
/// KO: 팬 레벨 API 응답의 DTO — 원시 JSON을 도메인 엔티티로 매핑합니다.
library;

import '../../domain/entities/fan_level.dart';

/// EN: DTO for a single fan XP activity record.
/// KO: 단일 팬 XP 활동 기록 DTO.
class FanActivityDto {
  const FanActivityDto({
    required this.id,
    required this.xpEarned,
    required this.earnedAt,
    this.type,
    this.description,
  });

  /// EN: Deserializes a [FanActivityDto] from a raw JSON map.
  /// KO: 원시 JSON 맵에서 [FanActivityDto]를 역직렬화합니다.
  factory FanActivityDto.fromJson(Map<String, dynamic> json) {
    return FanActivityDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String?,
      xpEarned:
          json['xpEarned'] as int? ?? json['xp_earned'] as int? ?? 0,
      earnedAt: DateTime.tryParse(
            json['earnedAt'] as String? ??
                json['earned_at'] as String? ??
                '',
          ) ??
          DateTime.now(),
      description: json['description'] as String?,
    );
  }

  final String id;
  final String? type;
  final int xpEarned;
  final DateTime earnedAt;
  final String? description;

  /// EN: Converts this DTO to its domain [FanActivity] entity.
  /// KO: 이 DTO를 도메인 [FanActivity] 엔티티로 변환합니다.
  FanActivity toEntity() => FanActivity(
    id: id,
    type: FanActivityType.fromString(type),
    xpEarned: xpEarned,
    earnedAt: earnedAt,
    description: description,
  );
}

/// EN: DTO for the user's complete fan level profile.
/// KO: 사용자의 전체 팬 레벨 프로필 DTO.
class FanLevelProfileDto {
  const FanLevelProfileDto({
    required this.userId,
    required this.totalXp,
    required this.currentLevelXp,
    required this.nextLevelXp,
    required this.rank,
    this.grade,
    this.hasCheckedInToday = false,
    this.recentActivities = const [],
  });

  /// EN: Deserializes a [FanLevelProfileDto] from a raw JSON map.
  /// KO: 원시 JSON 맵에서 [FanLevelProfileDto]를 역직렬화합니다.
  factory FanLevelProfileDto.fromJson(Map<String, dynamic> json) {
    final activitiesJson =
        json['recentActivities'] as List<dynamic>? ??
        json['recent_activities'] as List<dynamic>? ??
        const [];
    return FanLevelProfileDto(
      userId:
          json['userId'] as String? ?? json['user_id'] as String? ?? '',
      grade: json['grade'] as String?,
      totalXp: json['totalXp'] as int? ?? json['total_xp'] as int? ?? 0,
      currentLevelXp:
          json['currentLevelXp'] as int? ??
          json['current_level_xp'] as int? ??
          0,
      nextLevelXp:
          json['nextLevelXp'] as int? ??
          json['next_level_xp'] as int? ??
          100,
      rank: json['rank'] as int? ?? 0,
      hasCheckedInToday:
          json['hasCheckedInToday'] as bool? ??
          json['has_checked_in_today'] as bool? ??
          false,
      recentActivities: activitiesJson
          .whereType<Map<String, dynamic>>()
          .map(FanActivityDto.fromJson)
          .toList(growable: false),
    );
  }

  final String userId;
  final String? grade;
  final int totalXp;
  final int currentLevelXp;
  final int nextLevelXp;
  final int rank;
  final bool hasCheckedInToday;
  final List<FanActivityDto> recentActivities;

  /// EN: Converts this DTO to its domain [FanLevelProfile] entity.
  /// KO: 이 DTO를 도메인 [FanLevelProfile] 엔티티로 변환합니다.
  FanLevelProfile toEntity() => FanLevelProfile(
    userId: userId,
    grade: FanGrade.fromString(grade),
    totalXp: totalXp,
    currentLevelXp: currentLevelXp,
    nextLevelXp: nextLevelXp,
    rank: rank,
    hasCheckedInToday: hasCheckedInToday,
    recentActivities: recentActivities
        .map((a) => a.toEntity())
        .toList(growable: false),
  );
}

/// EN: DTO for the result of a daily check-in.
/// KO: 일일 출석 체크 결과 DTO.
class CheckInResultDto {
  const CheckInResultDto({
    required this.xpEarned,
    required this.newTotalXp,
    required this.streakDays,
    this.newGrade,
    this.didLevelUp = false,
  });

  /// EN: Deserializes a [CheckInResultDto] from a raw JSON map.
  /// KO: 원시 JSON 맵에서 [CheckInResultDto]를 역직렬화합니다.
  factory CheckInResultDto.fromJson(Map<String, dynamic> json) {
    return CheckInResultDto(
      xpEarned:
          json['xpEarned'] as int? ?? json['xp_earned'] as int? ?? 10,
      newTotalXp:
          json['newTotalXp'] as int? ?? json['new_total_xp'] as int? ?? 0,
      newGrade:
          json['newGrade'] as String? ?? json['new_grade'] as String?,
      streakDays:
          json['streakDays'] as int? ?? json['streak_days'] as int? ?? 1,
      didLevelUp:
          json['didLevelUp'] as bool? ??
          json['did_level_up'] as bool? ??
          false,
    );
  }

  final int xpEarned;
  final int newTotalXp;
  final String? newGrade;
  final int streakDays;
  final bool didLevelUp;

  /// EN: Converts this DTO to its domain [CheckInResult] entity.
  /// KO: 이 DTO를 도메인 [CheckInResult] 엔티티로 변환합니다.
  CheckInResult toEntity() => CheckInResult(
    xpEarned: xpEarned,
    newTotalXp: newTotalXp,
    newGrade: FanGrade.fromString(newGrade),
    streakDays: streakDays,
    didLevelUp: didLevelUp,
  );
}
