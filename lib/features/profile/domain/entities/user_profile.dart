import 'package:equatable/equatable.dart';

/// EN: User profile entity representing user data in domain layer
/// KO: 도메인 계층에서 사용자 데이터를 나타내는 사용자 프로필 엔티티
class UserProfile extends Equatable {
  /// EN: Creates a new UserProfile instance
  /// KO: 새로운 UserProfile 인스턴스 생성
  const UserProfile({
    required this.id,
    required this.username,
    required this.nickname,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.website,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.preferences = const UserPreferences(),
    this.statistics = const UserStatistics(),
    this.socialLinks = const [],
    this.achievements = const [],
    this.roles = const [],
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  /// EN: Unique identifier for the user
  /// KO: 사용자의 고유 식별자
  final String id;

  /// EN: Username (unique)
  /// KO: 사용자명 (고유)
  final String username;

  /// EN: Display nickname
  /// KO: 표시용 닉네임
  final String nickname;

  /// EN: Email address
  /// KO: 이메일 주소
  final String email;

  /// EN: Profile picture URL
  /// KO: 프로필 사진 URL
  final String? avatarUrl;

  /// EN: User biography
  /// KO: 사용자 소개
  final String? bio;

  /// EN: User location
  /// KO: 사용자 위치
  final String? location;

  /// EN: Personal website URL
  /// KO: 개인 웹사이트 URL
  final String? website;

  /// EN: Phone number
  /// KO: 전화번호
  final String? phoneNumber;

  /// EN: Date of birth
  /// KO: 생년월일
  final DateTime? dateOfBirth;

  /// EN: Gender
  /// KO: 성별
  final String? gender;

  /// EN: User preferences and settings
  /// KO: 사용자 설정 및 기본값
  final UserPreferences preferences;

  /// EN: User activity statistics
  /// KO: 사용자 활동 통계
  final UserStatistics statistics;

  /// EN: Social media links
  /// KO: 소셜 미디어 링크
  final List<SocialLink> socialLinks;

  /// EN: User achievements and badges
  /// KO: 사용자 업적 및 배지
  final List<Achievement> achievements;

  /// EN: User roles in the system
  /// KO: 시스템에서의 사용자 역할
  final List<String> roles;

  /// EN: Whether email is verified
  /// KO: 이메일 인증 여부
  final bool isEmailVerified;

  /// EN: Whether phone is verified
  /// KO: 전화번호 인증 여부
  final bool isPhoneVerified;

  /// EN: Whether account is active
  /// KO: 계정 활성화 여부
  final bool isActive;

  /// EN: Last login timestamp
  /// KO: 마지막 로그인 시간
  final DateTime? lastLoginAt;

  /// EN: When the profile was created
  /// KO: 프로필 생성 시간
  final DateTime? createdAt;

  /// EN: When the profile was last updated
  /// KO: 프로필 마지막 업데이트 시간
  final DateTime? updatedAt;

  /// EN: Creates a copy of this profile with updated fields
  /// KO: 업데이트된 필드로 이 프로필의 복사본 생성
  UserProfile copyWith({
    String? id,
    String? username,
    String? nickname,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    String? website,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    UserPreferences? preferences,
    UserStatistics? statistics,
    List<SocialLink>? socialLinks,
    List<Achievement>? achievements,
    List<String>? roles,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
      socialLinks: socialLinks ?? this.socialLinks,
      achievements: achievements ?? this.achievements,
      roles: roles ?? this.roles,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// EN: Get display name (nickname or username)
  /// KO: 표시 이름 (닉네임 또는 사용자명) 가져오기
  String get displayName => nickname.isNotEmpty ? nickname : username;

  /// EN: Get user initials for avatar fallback
  /// KO: 아바타 대체용 사용자 이니셜 가져오기
  String get initials {
    final name = displayName;
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    } else if (name.length == 1) {
      return name.toUpperCase();
    }
    return 'U';
  }

  /// EN: Check if profile is complete
  /// KO: 프로필이 완전한지 확인
  bool get isProfileComplete {
    return avatarUrl != null &&
           bio != null &&
           bio!.isNotEmpty &&
           location != null &&
           location!.isNotEmpty;
  }

  /// EN: Get profile completion percentage
  /// KO: 프로필 완성도 백분율 가져오기
  int get profileCompletionPercentage {
    int completedFields = 0;
    const totalFields = 8; // EN: Key profile fields / KO: 주요 프로필 필드

    // EN: Basic fields (always present)
    // KO: 기본 필드 (항상 존재)
    completedFields += 3; // username, nickname, email

    if (avatarUrl != null) completedFields++;
    if (bio != null && bio!.isNotEmpty) completedFields++;
    if (location != null && location!.isNotEmpty) completedFields++;
    if (website != null && website!.isNotEmpty) completedFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completedFields++;

    return (completedFields / totalFields * 100).round();
  }

  /// EN: Check if user has admin role
  /// KO: 사용자가 관리자 역할을 가지고 있는지 확인
  bool get isAdmin => roles.contains('ADMIN');

  /// EN: Check if user has moderator role
  /// KO: 사용자가 중재자 역할을 가지고 있는지 확인
  bool get isModerator => roles.contains('MODERATOR') || isAdmin;

  /// EN: Get age from date of birth
  /// KO: 생년월일로부터 나이 가져오기
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        nickname,
        email,
        avatarUrl,
        bio,
        location,
        website,
        phoneNumber,
        dateOfBirth,
        gender,
        preferences,
        statistics,
        socialLinks,
        achievements,
        roles,
        isEmailVerified,
        isPhoneVerified,
        isActive,
        lastLoginAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserProfile(id: $id, username: $username, nickname: $nickname, email: $email)';
  }
}

/// EN: User preferences and settings
/// KO: 사용자 설정 및 기본값
class UserPreferences extends Equatable {
  const UserPreferences({
    this.language = 'ko',
    this.theme = 'system',
    this.notifications = const NotificationSettings(),
    this.privacy = const PrivacySettings(),
    this.accessibility = const AccessibilitySettings(),
  });

  /// EN: Preferred language code
  /// KO: 선호 언어 코드
  final String language;

  /// EN: Theme preference (light, dark, system)
  /// KO: 테마 설정 (light, dark, system)
  final String theme;

  /// EN: Notification settings
  /// KO: 알림 설정
  final NotificationSettings notifications;

  /// EN: Privacy settings
  /// KO: 개인정보 설정
  final PrivacySettings privacy;

  /// EN: Accessibility settings
  /// KO: 접근성 설정
  final AccessibilitySettings accessibility;

  UserPreferences copyWith({
    String? language,
    String? theme,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    AccessibilitySettings? accessibility,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      accessibility: accessibility ?? this.accessibility,
    );
  }

  @override
  List<Object?> get props => [language, theme, notifications, privacy, accessibility];
}

/// EN: User activity statistics
/// KO: 사용자 활동 통계
class UserStatistics extends Equatable {
  const UserStatistics({
    this.placesVisited = 0,
    this.eventsAttended = 0,
    this.photosUploaded = 0,
    this.commentsPosted = 0,
    this.guidesWritten = 0,
    this.favoritePlaces = 0,
    this.favoriteEvents = 0,
    this.totalPoints = 0,
    this.joinDate,
    this.lastActiveDate,
  });

  /// EN: Number of places visited
  /// KO: 방문한 장소 수
  final int placesVisited;

  /// EN: Number of events attended
  /// KO: 참석한 이벤트 수
  final int eventsAttended;

  /// EN: Number of photos uploaded
  /// KO: 업로드한 사진 수
  final int photosUploaded;

  /// EN: Number of comments posted
  /// KO: 작성한 댓글 수
  final int commentsPosted;

  /// EN: Number of guides written
  /// KO: 작성한 가이드 수
  final int guidesWritten;

  /// EN: Number of favorite places
  /// KO: 즐겨찾는 장소 수
  final int favoritePlaces;

  /// EN: Number of favorite events
  /// KO: 즐겨찾는 이벤트 수
  final int favoriteEvents;

  /// EN: Total activity points
  /// KO: 총 활동 점수
  final int totalPoints;

  /// EN: When the user joined
  /// KO: 사용자 가입 날짜
  final DateTime? joinDate;

  /// EN: Last activity date
  /// KO: 마지막 활동 날짜
  final DateTime? lastActiveDate;

  UserStatistics copyWith({
    int? placesVisited,
    int? eventsAttended,
    int? photosUploaded,
    int? commentsPosted,
    int? guidesWritten,
    int? favoritePlaces,
    int? favoriteEvents,
    int? totalPoints,
    DateTime? joinDate,
    DateTime? lastActiveDate,
  }) {
    return UserStatistics(
      placesVisited: placesVisited ?? this.placesVisited,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      photosUploaded: photosUploaded ?? this.photosUploaded,
      commentsPosted: commentsPosted ?? this.commentsPosted,
      guidesWritten: guidesWritten ?? this.guidesWritten,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
      totalPoints: totalPoints ?? this.totalPoints,
      joinDate: joinDate ?? this.joinDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  @override
  List<Object?> get props => [
        placesVisited,
        eventsAttended,
        photosUploaded,
        commentsPosted,
        guidesWritten,
        favoritePlaces,
        favoriteEvents,
        totalPoints,
        joinDate,
        lastActiveDate,
      ];
}

/// EN: Social media link
/// KO: 소셜 미디어 링크
class SocialLink extends Equatable {
  const SocialLink({
    required this.platform,
    required this.url,
    this.username,
  });

  /// EN: Platform name (twitter, instagram, youtube, etc.)
  /// KO: 플랫폼 이름 (twitter, instagram, youtube 등)
  final String platform;

  /// EN: Profile URL
  /// KO: 프로필 URL
  final String url;

  /// EN: Username on the platform
  /// KO: 플랫폼에서의 사용자명
  final String? username;

  @override
  List<Object?> get props => [platform, url, username];
}

/// EN: User achievement or badge
/// KO: 사용자 업적 또는 배지
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.unlockedAt,
    this.category,
    this.points = 0,
  });

  /// EN: Achievement ID
  /// KO: 업적 ID
  final String id;

  /// EN: Achievement name
  /// KO: 업적 이름
  final String name;

  /// EN: Achievement description
  /// KO: 업적 설명
  final String description;

  /// EN: Achievement icon URL
  /// KO: 업적 아이콘 URL
  final String iconUrl;

  /// EN: When the achievement was unlocked
  /// KO: 업적 달성 시간
  final DateTime unlockedAt;

  /// EN: Achievement category
  /// KO: 업적 카테고리
  final String? category;

  /// EN: Points earned for this achievement
  /// KO: 이 업적으로 얻은 점수
  final int points;

  @override
  List<Object?> get props => [id, name, description, iconUrl, unlockedAt, category, points];
}

/// EN: Notification settings
/// KO: 알림 설정
class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.newEventsEnabled = true,
    this.eventRemindersEnabled = true,
    this.commentsEnabled = true,
    this.achievementsEnabled = true,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool newEventsEnabled;
  final bool eventRemindersEnabled;
  final bool commentsEnabled;
  final bool achievementsEnabled;

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? newEventsEnabled,
    bool? eventRemindersEnabled,
    bool? commentsEnabled,
    bool? achievementsEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      newEventsEnabled: newEventsEnabled ?? this.newEventsEnabled,
      eventRemindersEnabled: eventRemindersEnabled ?? this.eventRemindersEnabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      achievementsEnabled: achievementsEnabled ?? this.achievementsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        pushEnabled,
        emailEnabled,
        newEventsEnabled,
        eventRemindersEnabled,
        commentsEnabled,
        achievementsEnabled,
      ];
}

/// EN: Privacy settings
/// KO: 개인정보 설정
class PrivacySettings extends Equatable {
  const PrivacySettings({
    this.profileVisibility = 'public',
    this.showEmail = false,
    this.showLocation = true,
    this.showStatistics = true,
    this.allowMessages = true,
  });

  /// EN: Profile visibility (public, friends, private)
  /// KO: 프로필 공개 설정 (public, friends, private)
  final String profileVisibility;

  final bool showEmail;
  final bool showLocation;
  final bool showStatistics;
  final bool allowMessages;

  PrivacySettings copyWith({
    String? profileVisibility,
    bool? showEmail,
    bool? showLocation,
    bool? showStatistics,
    bool? allowMessages,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showEmail: showEmail ?? this.showEmail,
      showLocation: showLocation ?? this.showLocation,
      showStatistics: showStatistics ?? this.showStatistics,
      allowMessages: allowMessages ?? this.allowMessages,
    );
  }

  @override
  List<Object?> get props => [
        profileVisibility,
        showEmail,
        showLocation,
        showStatistics,
        allowMessages,
      ];
}

/// EN: Accessibility settings
/// KO: 접근성 설정
class AccessibilitySettings extends Equatable {
  const AccessibilitySettings({
    this.textSize = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
    this.screenReader = false,
  });

  /// EN: Text size multiplier
  /// KO: 텍스트 크기 배율
  final double textSize;

  final bool highContrast;
  final bool reduceMotion;
  final bool screenReader;

  AccessibilitySettings copyWith({
    double? textSize,
    bool? highContrast,
    bool? reduceMotion,
    bool? screenReader,
  }) {
    return AccessibilitySettings(
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      screenReader: screenReader ?? this.screenReader,
    );
  }

  @override
  List<Object?> get props => [textSize, highContrast, reduceMotion, screenReader];
}