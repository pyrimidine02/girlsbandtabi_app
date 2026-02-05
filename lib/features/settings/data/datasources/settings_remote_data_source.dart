/// EN: Remote data source for settings/profile APIs.
/// KO: 설정/프로필 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/notification_settings_dto.dart';
import '../dto/user_profile_dto.dart';

class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<UserProfileDto>> fetchUserProfile() {
    return _apiClient.get<UserProfileDto>(
      ApiEndpoints.userMe,
      fromJson: (json) => UserProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Fetch public user profile by ID.
  /// KO: 사용자 ID로 공개 프로필을 조회합니다.
  Future<Result<UserProfileDto>> fetchUserProfileById(String userId) {
    return _apiClient.get<UserProfileDto>(
      ApiEndpoints.userProfile(userId),
      fromJson: (json) => UserProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<UserProfileDto>> updateUserProfile({
    required String displayName,
    String? avatarUrl,
    String? bio,
    String? coverImageUrl,
  }) {
    final payload = <String, dynamic>{
      'displayName': displayName,
    };
    if (avatarUrl != null) {
      payload['avatarUrl'] = avatarUrl;
    }
    if (bio != null) {
      payload['bio'] = bio;
    }
    if (coverImageUrl != null) {
      payload['coverImageUrl'] = coverImageUrl;
    }
    return _apiClient.patch<UserProfileDto>(
      ApiEndpoints.userMe,
      data: payload,
      fromJson: (json) => UserProfileDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<NotificationSettingsDto>> fetchNotificationSettings() {
    return _apiClient.get<NotificationSettingsDto>(
      ApiEndpoints.notificationSettings,
      fromJson: (json) =>
          NotificationSettingsDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Result<NotificationSettingsDto>> updateNotificationSettings({
    required NotificationSettingsDto settings,
  }) {
    return _apiClient.put<NotificationSettingsDto>(
      ApiEndpoints.notificationSettings,
      data: settings.toJson(),
      fromJson: (json) =>
          NotificationSettingsDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
