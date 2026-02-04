/// EN: User profile domain entity.
/// KO: 사용자 프로필 도메인 엔티티.
library;

import '../../data/dto/user_profile_dto.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final DateTime createdAt;
  final String? avatarUrl;

  String get summaryLabel {
    return '가입일: ${createdAt.toLocal().toIso8601String().split('T').first}';
  }

  factory UserProfile.fromDto(UserProfileDto dto) {
    return UserProfile(
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
      role: dto.role,
      createdAt: dto.createdAt,
    );
  }
}
