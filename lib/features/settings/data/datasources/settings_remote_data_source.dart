/// EN: Remote data source for settings/profile APIs.
/// KO: 설정/프로필 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/account_tools_dto.dart';
import '../dto/notification_device_dto.dart';
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
    final payload = <String, dynamic>{'displayName': displayName};
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

  /// EN: Deactivate notification device registration by deviceId.
  /// KO: deviceId 기준 알림 디바이스 등록을 비활성화합니다.
  Future<Result<NotificationDeviceDeactivationDto>>
  deactivateNotificationDevice({required String deviceId}) {
    return _apiClient.delete<NotificationDeviceDeactivationDto>(
      ApiEndpoints.notificationDevice(deviceId),
      fromJson: (json) => NotificationDeviceDeactivationDto.fromJson(
        json is Map<String, dynamic> ? json : const <String, dynamic>{},
      ),
    );
  }

  Future<Result<List<UserBlockDto>>> fetchUserBlocks({
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<UserBlockDto>>(
      ApiEndpoints.userBlocks,
      queryParameters: {'page': page, 'size': size, 'pageable': '$page,$size'},
      fromJson: (json) {
        final list = _extractList(json);
        return list.map(UserBlockDto.fromJson).toList(growable: false);
      },
    );
  }

  Future<Result<void>> unblockUser({required String targetUserId}) {
    return _apiClient.delete<void>(
      ApiEndpoints.userBlock(targetUserId),
      fromJson: (_) {},
    );
  }

  Future<Result<List<VerificationAppealDto>>> fetchVerificationAppeals({
    required String projectId,
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<VerificationAppealDto>>(
      ApiEndpoints.verificationAppeals(projectId),
      queryParameters: {'page': page, 'size': size, 'pageable': '$page,$size'},
      fromJson: (json) {
        final list = _extractList(json);
        return list.map(VerificationAppealDto.fromJson).toList(growable: false);
      },
    );
  }

  Future<Result<VerificationAppealDto>> createVerificationAppeal({
    required String projectId,
    required VerificationAppealCreateRequestDto request,
  }) {
    return _apiClient.post<VerificationAppealDto>(
      ApiEndpoints.verificationAppeals(projectId),
      data: request.toJson(),
      fromJson: (json) => VerificationAppealDto.fromJson(
        json is Map<String, dynamic> ? json : const <String, dynamic>{},
      ),
    );
  }
}

List<Map<String, dynamic>> _extractList(dynamic json) {
  if (json is List) {
    return json.whereType<Map<String, dynamic>>().toList(growable: false);
  }
  if (json is Map<String, dynamic>) {
    final items =
        json['items'] ?? json['content'] ?? json['results'] ?? json['data'];
    if (items is List) {
      return items.whereType<Map<String, dynamic>>().toList(growable: false);
    }
  }
  return const <Map<String, dynamic>>[];
}
