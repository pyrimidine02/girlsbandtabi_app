/// EN: User profile DTO for settings/profile.
/// KO: 설정/프로필용 사용자 프로필 DTO.
library;

class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
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
  final String role;
  final DateTime createdAt;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = _string(json, ['createdAt', 'created_at']) ?? '';
    final parsedCreatedAt =
        DateTime.tryParse(createdAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0);

    return UserProfileDto(
      id: _string(json, ['id', 'userId']) ?? '',
      email: _string(json, ['email', 'emailAddress']) ?? '',
      displayName: _string(json, ['displayName', 'nickname', 'name']) ?? '사용자',
      role: _string(json, ['role']) ?? 'USER',
      createdAt: parsedCreatedAt,
      avatarUrl: _string(json, ['avatarUrl', 'profileImageUrl', 'imageUrl']),
      bio: _string(json, ['bio', 'introduction', 'about', 'summary']),
      coverImageUrl: _string(
        json,
        ['coverImageUrl', 'headerImageUrl', 'bannerImageUrl'],
      ),
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
