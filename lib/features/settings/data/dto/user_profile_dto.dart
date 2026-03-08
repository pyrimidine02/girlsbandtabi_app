/// EN: User profile DTO for settings/profile.
/// KO: 설정/프로필용 사용자 프로필 DTO.
library;

class UserProfileDto {
  const UserProfileDto({
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
  final String? avatarUrl;
  final String? bio;
  final String? coverImageUrl;
  final String accountRole;
  final String baselineAccessLevel;
  final String effectiveAccessLevel;

  /// EN: Legacy role field kept for backward compatibility with old payloads.
  /// KO: 구형 응답 호환을 위해 유지하는 레거시 role 필드입니다.
  final String role;
  final DateTime createdAt;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = _string(json, ['createdAt', 'created_at']) ?? '';
    final parsedCreatedAt =
        DateTime.tryParse(createdAtRaw) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final accountRole = _string(json, ['accountRole']) ?? 'USER';
    final role = _string(json, ['role']) ?? accountRole;
    final baselineAccessLevel =
        _string(json, ['baselineAccessLevel']) ??
        _baselineFromAccountRole(accountRole);
    final effectiveAccessLevel =
        _string(json, ['effectiveAccessLevel', 'accessLevel']) ??
        _baselineFromAccountRole(accountRole);

    return UserProfileDto(
      id: _string(json, ['id', 'userId']) ?? '',
      email: _string(json, ['email', 'emailAddress']) ?? '',
      displayName: _string(json, ['displayName', 'nickname', 'name']) ?? '사용자',
      role: role,
      accountRole: accountRole,
      baselineAccessLevel: baselineAccessLevel,
      effectiveAccessLevel: effectiveAccessLevel,
      createdAt: parsedCreatedAt,
      avatarUrl: _string(json, ['avatarUrl', 'profileImageUrl', 'imageUrl']),
      bio: _string(json, ['bio', 'introduction', 'about', 'summary']),
      coverImageUrl: _string(json, [
        'coverImageUrl',
        'headerImageUrl',
        'bannerImageUrl',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'coverImageUrl': coverImageUrl,
      'accountRole': accountRole,
      'baselineAccessLevel': baselineAccessLevel,
      'effectiveAccessLevel': effectiveAccessLevel,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

String _baselineFromAccountRole(String accountRole) {
  final normalized = accountRole.trim().toUpperCase();
  if (normalized == 'ADMIN') {
    return 'ADMIN_NON_SENSITIVE';
  }
  return 'USER_BASE';
}
