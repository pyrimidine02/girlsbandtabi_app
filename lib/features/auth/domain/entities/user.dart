import 'package:equatable/equatable.dart';

/// EN: User entity representing authenticated user data in domain layer
/// KO: 도메인 계층에서 인증된 사용자 데이터를 나타내는 사용자 엔티티
class User extends Equatable {
  /// EN: Creates a new User instance
  /// KO: 새로운 User 인스턴스 생성
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  /// EN: Unique identifier for the user
  /// KO: 사용자의 고유 식별자
  final String id;

  /// EN: User's email address
  /// KO: 사용자의 이메일 주소
  final String email;

  /// EN: User's display name
  /// KO: 사용자의 표시 이름
  final String displayName;

  /// EN: Optional avatar image URL
  /// KO: 선택적 아바타 이미지 URL
  final String? avatarUrl;

  /// EN: Whether the user's email has been verified
  /// KO: 사용자의 이메일 검증 여부
  final bool isEmailVerified;

  /// EN: When the user account was created
  /// KO: 사용자 계정 생성 시간
  final DateTime? createdAt;

  /// EN: When the user account was last updated
  /// KO: 사용자 계정 마지막 업데이트 시간
  final DateTime? updatedAt;

  /// EN: Creates a copy of this user with updated fields
  /// KO: 업데이트된 필드로 이 사용자의 복사본 생성
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// EN: Get user's initials for avatar display
  /// KO: 아바타 표시용 사용자 이니셜 가져오기
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }

  /// EN: Get display text for the user
  /// KO: 사용자의 표시 텍스트 가져오기
  String get displayText => displayName.isNotEmpty ? displayName : email;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, '
           'isEmailVerified: $isEmailVerified)';
  }
}