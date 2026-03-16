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
      // EN: API uses 'action' field; fall back to 'type' for backwards compat.
      // KO: API는 'action' 필드를 사용합니다. 이전 호환을 위해 'type'도 읽습니다.
      type: json['action'] as String? ?? json['type'] as String?,
      // EN: API uses 'points' field; fall back to camelCase/snake_case variants.
      // KO: API는 'points' 필드를 사용합니다. 카멜케이스/스네이크케이스도 읽습니다.
      xpEarned:
          json['points'] as int? ??
          json['xpEarned'] as int? ??
          json['xp_earned'] as int? ??
          0,
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
    // EN: API uses 'recentHistory'; fall back to camelCase/snake_case variants.
    // KO: API는 'recentHistory' 필드를 사용합니다.
    final activitiesJson =
        json['recentHistory'] as List<dynamic>? ??
        json['recentActivities'] as List<dynamic>? ??
        json['recent_activities'] as List<dynamic>? ??
        const [];
    // EN: currentLevel / nextLevel are nested objects in the API response.
    // KO: currentLevel / nextLevel은 API 응답에서 중첩 객체로 반환됩니다.
    final currentLevel = json['currentLevel'] as Map<String, dynamic>?;
    final nextLevel = json['nextLevel'] as Map<String, dynamic>?;
    return FanLevelProfileDto(
      userId:
          json['userId'] as String? ?? json['user_id'] as String? ?? '',
      // EN: Grade code lives in currentLevel.code (e.g. "NEWBIE").
      // KO: 등급 코드는 currentLevel.code에 있습니다 (예: "NEWBIE").
      grade:
          currentLevel?['code'] as String? ?? json['grade'] as String?,
      // EN: API uses 'totalPoints'; fall back to camelCase/snake_case variants.
      // KO: API는 'totalPoints' 필드를 사용합니다.
      totalXp:
          json['totalPoints'] as int? ??
          json['totalXp'] as int? ??
          json['total_xp'] as int? ??
          0,
      // EN: Progress within current level — fall back to nested minPoints.
      // KO: 현재 레벨 내 진행 XP — 중첩 minPoints로 폴백합니다.
      currentLevelXp:
          json['currentLevelXp'] as int? ??
          json['current_level_xp'] as int? ??
          (currentLevel?['minPoints'] as int? ?? 0),
      // EN: XP threshold for next level — fall back to nested minPoints.
      // KO: 다음 레벨 XP 임계값 — 중첩 minPoints로 폴백합니다.
      nextLevelXp:
          json['nextLevelXp'] as int? ??
          json['next_level_xp'] as int? ??
          (nextLevel?['minPoints'] as int? ?? 100),
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
      // EN: API uses 'pointsEarned'; fall back to camelCase/snake_case variants.
      // KO: API는 'pointsEarned' 필드를 사용합니다.
      xpEarned:
          json['pointsEarned'] as int? ??
          json['xpEarned'] as int? ??
          json['xp_earned'] as int? ??
          10,
      // EN: API uses 'totalPoints' for the new cumulative total.
      // KO: API는 누적 합계에 'totalPoints' 필드를 사용합니다.
      newTotalXp:
          json['totalPoints'] as int? ??
          json['newTotalXp'] as int? ??
          json['new_total_xp'] as int? ??
          0,
      newGrade:
          json['newGrade'] as String? ?? json['new_grade'] as String?,
      // EN: API uses 'consecutiveDays'; fall back to camelCase/snake_case variants.
      // KO: API는 'consecutiveDays' 필드를 사용합니다.
      streakDays:
          json['consecutiveDays'] as int? ??
          json['streakDays'] as int? ??
          json['streak_days'] as int? ??
          1,
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
