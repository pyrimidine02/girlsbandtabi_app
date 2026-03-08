/// EN: Access-level model and guards for account role migration.
/// KO: 계정 권한 체계 마이그레이션용 접근 레벨 모델과 가드입니다.
library;

/// EN: Effective user access levels from backend policy.
/// KO: 백엔드 정책 기준 유효 접근 레벨입니다.
enum UserAccessLevel {
  userBase('USER_BASE', 0),
  contentEditor('CONTENT_EDITOR', 1),
  communityModerator('COMMUNITY_MODERATOR', 2),
  adminNonSensitive('ADMIN_NON_SENSITIVE', 3),
  platformSuperAdmin('PLATFORM_SUPER_ADMIN', 4),
  unknown('UNKNOWN', -1);

  const UserAccessLevel(this.apiValue, this.rank);

  final String apiValue;
  final int rank;
}

extension UserAccessLevelX on UserAccessLevel {
  /// EN: Human-readable Korean label for settings/admin UI.
  /// KO: 설정/관리자 UI에 표시할 한글 라벨입니다.
  String get labelKo => switch (this) {
    UserAccessLevel.userBase => '일반 사용자',
    UserAccessLevel.contentEditor => '콘텐츠 에디터',
    UserAccessLevel.communityModerator => '커뮤니티 모더레이터',
    UserAccessLevel.adminNonSensitive => '비민감 관리자',
    UserAccessLevel.platformSuperAdmin => '플랫폼 최고 관리자',
    UserAccessLevel.unknown => '알 수 없음',
  };

  /// EN: Returns true when this level includes the required level.
  /// KO: 현재 레벨이 요구 레벨 이상인지 반환합니다.
  bool isAtLeast(UserAccessLevel required) {
    if (this == UserAccessLevel.unknown) {
      return false;
    }
    return rank >= required.rank;
  }

  /// EN: Parses API access-level string to enum.
  /// KO: API 접근 레벨 문자열을 enum으로 파싱합니다.
  static UserAccessLevel fromApiValue(String? rawValue) {
    final normalized = rawValue?.trim().toUpperCase();
    switch (normalized) {
      case 'USER_BASE':
        return UserAccessLevel.userBase;
      case 'CONTENT_EDITOR':
        return UserAccessLevel.contentEditor;
      case 'COMMUNITY_MODERATOR':
        return UserAccessLevel.communityModerator;
      case 'ADMIN_NON_SENSITIVE':
        return UserAccessLevel.adminNonSensitive;
      case 'PLATFORM_SUPER_ADMIN':
        return UserAccessLevel.platformSuperAdmin;
      default:
        return UserAccessLevel.unknown;
    }
  }

  /// EN: Resolves access level with API value first and account-role fallback.
  /// KO: API 접근 레벨을 우선하고 account-role을 보조로 사용해 결정합니다.
  static UserAccessLevel resolve({
    String? effectiveAccessLevel,
    String? accountRole,
  }) {
    final explicit = fromApiValue(effectiveAccessLevel);
    if (explicit != UserAccessLevel.unknown) {
      return explicit;
    }

    final normalizedAccountRole = accountRole?.trim().toUpperCase();
    if (normalizedAccountRole == 'ADMIN') {
      return UserAccessLevel.adminNonSensitive;
    }
    if (normalizedAccountRole == 'USER') {
      return UserAccessLevel.userBase;
    }

    return UserAccessLevel.unknown;
  }
}

/// EN: Returns true when user can access ops center screens.
/// KO: 사용자에게 운영센터 화면 접근 권한이 있는지 반환합니다.
bool hasAdminOpsAccess({String? effectiveAccessLevel, String? accountRole}) {
  final level = UserAccessLevelX.resolve(
    effectiveAccessLevel: effectiveAccessLevel,
    accountRole: accountRole,
  );
  return level.isAtLeast(UserAccessLevel.communityModerator);
}

/// EN: Returns true when user can perform community moderation actions.
/// KO: 사용자에게 커뮤니티 모더레이션 권한이 있는지 반환합니다.
bool canModerateCommunity({String? effectiveAccessLevel, String? accountRole}) {
  final level = UserAccessLevelX.resolve(
    effectiveAccessLevel: effectiveAccessLevel,
    accountRole: accountRole,
  );
  return level.isAtLeast(UserAccessLevel.communityModerator);
}

/// EN: Returns true when user can access non-sensitive admin APIs.
/// KO: 비민감 관리자 API 접근 권한이 있는지 반환합니다.
bool canAccessNonSensitiveAdmin({
  String? effectiveAccessLevel,
  String? accountRole,
}) {
  final level = UserAccessLevelX.resolve(
    effectiveAccessLevel: effectiveAccessLevel,
    accountRole: accountRole,
  );
  return level.isAtLeast(UserAccessLevel.adminNonSensitive);
}

/// EN: Returns true when user can access sensitive admin APIs.
/// KO: 민감 관리자 API 접근 권한이 있는지 반환합니다.
bool canAccessSensitiveAdmin({
  String? effectiveAccessLevel,
  String? accountRole,
}) {
  final level = UserAccessLevelX.resolve(
    effectiveAccessLevel: effectiveAccessLevel,
    accountRole: accountRole,
  );
  return level.isAtLeast(UserAccessLevel.platformSuperAdmin);
}
