/// EN: User profile domain entity.
/// KO: 사용자 프로필 도메인 엔티티.
library;

import '../../data/dto/user_profile_dto.dart';
import '../../../../core/security/user_access_level.dart' as access;

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.accountRole,
    required this.baselineAccessLevel,
    required this.effectiveAccessLevel,
    required this.createdAt,
    this.avatarUrl,
    this.bio,
    this.coverImageUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final String accountRole;
  final String baselineAccessLevel;
  final String effectiveAccessLevel;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? bio;
  final String? coverImageUrl;

  String get summaryLabel {
    return '가입일: ${createdAt.toLocal().toIso8601String().split('T').first}';
  }

  /// EN: Parsed effective level for access guards.
  /// KO: 접근 제어에 사용하는 파싱된 유효 접근 레벨입니다.
  access.UserAccessLevel get resolvedAccessLevel {
    return access.UserAccessLevelX.resolve(
      effectiveAccessLevel: effectiveAccessLevel,
      accountRole: accountRole,
    );
  }

  /// EN: Display text for effective access level.
  /// KO: 유효 접근 레벨 표시 문자열입니다.
  String get effectiveAccessLevelLabel => resolvedAccessLevel.labelKo;

  /// EN: Whether this profile can access admin operations screens.
  /// KO: 운영센터 화면 접근 가능 여부입니다.
  bool get canAccessAdminOps {
    return access.hasAdminOpsAccess(
      effectiveAccessLevel: effectiveAccessLevel,
      accountRole: accountRole,
    );
  }

  /// EN: Whether this profile can execute moderation actions.
  /// KO: 모더레이션 액션 실행 가능 여부입니다.
  bool get canModerateCommunity {
    return access.canModerateCommunity(
      effectiveAccessLevel: effectiveAccessLevel,
      accountRole: accountRole,
    );
  }

  factory UserProfile.fromDto(UserProfileDto dto) {
    return UserProfile(
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
      role: dto.role,
      accountRole: dto.accountRole,
      baselineAccessLevel: dto.baselineAccessLevel,
      effectiveAccessLevel: dto.effectiveAccessLevel,
      createdAt: dto.createdAt,
      bio: dto.bio,
      coverImageUrl: dto.coverImageUrl,
    );
  }
}
