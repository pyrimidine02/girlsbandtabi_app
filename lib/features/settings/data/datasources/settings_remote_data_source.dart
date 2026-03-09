/// EN: Remote data source for settings/profile APIs.
/// KO: 설정/프로필 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/account_tools_dto.dart';
import '../dto/consent_history_dto.dart';
import '../dto/notification_device_dto.dart';
import '../dto/notification_settings_dto.dart';
import '../dto/privacy_rights_dto.dart';
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
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return NotificationSettingsDto.fromJson(json);
        }
        // EN: Some environments can acknowledge settings update with an empty
        // EN: payload; keep UI state consistent by falling back to request body.
        // KO: 일부 환경에서는 설정 저장 응답이 빈 페이로드일 수 있으므로
        // KO: 요청 본문으로 폴백해 UI 상태를 일관되게 유지합니다.
        return settings;
      },
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

  Future<Result<PrivacySettingsDto>> fetchPrivacySettings() {
    return _apiClient.get<PrivacySettingsDto>(
      ApiEndpoints.userPrivacySettings,
      fromJson: (json) => PrivacySettingsDto.fromJson(
        json is Map<String, dynamic> ? json : const <String, dynamic>{},
      ),
    );
  }

  Future<Result<PrivacySettingsDto>> updatePrivacySettings({
    required bool allowAutoTranslation,
    int? version,
  }) {
    final payload = PrivacySettingsDto(
      allowAutoTranslation: allowAutoTranslation,
      version: version,
      updatedAt: null,
    );
    return _apiClient.patch<PrivacySettingsDto>(
      ApiEndpoints.userPrivacySettings,
      data: payload.toPatchJson(),
      fromJson: (json) => PrivacySettingsDto.fromJson(
        json is Map<String, dynamic> ? json : const <String, dynamic>{},
      ),
    );
  }

  Future<Result<List<PrivacyRequestRecordDto>>> fetchPrivacyRequests({
    int page = 0,
    int size = 20,
  }) {
    return _apiClient.get<List<PrivacyRequestRecordDto>>(
      ApiEndpoints.userPrivacyRequests,
      queryParameters: {'page': page, 'size': size, 'sort': 'requestedAt,desc'},
      fromJson: (json) {
        final items = _extractList(json);
        return items
            .map(PrivacyRequestRecordDto.fromJson)
            .toList(growable: false);
      },
    );
  }

  Future<Result<PrivacyRequestRecordDto>> createPrivacyRequest({
    required String requestType,
    required String reason,
  }) {
    return _apiClient.post<PrivacyRequestRecordDto>(
      ApiEndpoints.userPrivacyRequests,
      data: {'requestType': requestType, 'reason': reason},
      fromJson: (json) => PrivacyRequestRecordDto.fromJson(
        json is Map<String, dynamic> ? json : const <String, dynamic>{},
      ),
    );
  }

  Future<Result<List<ConsentHistoryItemDto>>> fetchConsentHistory({
    int page = 0,
    int size = 50,
  }) {
    return _apiClient.get<List<ConsentHistoryItemDto>>(
      ApiEndpoints.userConsents,
      queryParameters: {'page': page, 'size': size, 'sort': 'agreedAt,desc'},
      fromJson: (json) {
        final items = _extractList(json);
        return items
            .map(ConsentHistoryItemDto.fromJson)
            .toList(growable: false);
      },
    );
  }

  Future<Result<void>> deleteAccount() {
    return _apiClient.delete<void>(ApiEndpoints.userMe, fromJson: (_) {});
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

  Future<Result<List<ProjectRoleRequestDto>>> fetchProjectRoleRequests({
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
    String? status,
  }) {
    return _apiClient.get<List<ProjectRoleRequestDto>>(
      ApiEndpoints.projectRoleRequests,
      queryParameters: {
        'page': page,
        'size': size,
        'pageable': '$page,$size',
        if (status != null && status.isNotEmpty) 'status': status,
        'sort': 'createdAt,desc',
      },
      fromJson: (json) => ProjectRoleRequestDto.listFromAny(json),
    );
  }

  Future<Result<ProjectRoleRequestDto>> fetchProjectRoleRequestDetail({
    required String requestId,
  }) {
    return _apiClient.get<ProjectRoleRequestDto>(
      ApiEndpoints.projectRoleRequest(requestId),
      fromJson: (json) {
        final payload = json is Map<String, dynamic>
            ? json
            : const <String, dynamic>{};
        return ProjectRoleRequestDto.fromJson(payload);
      },
    );
  }

  Future<Result<ProjectRoleRequestDto>> createProjectRoleRequest({
    required ProjectRoleRequestCreateRequestDto request,
  }) {
    return _apiClient.post<ProjectRoleRequestDto>(
      ApiEndpoints.projectRoleRequests,
      data: request.toJson(),
      fromJson: (json) {
        final payload = json is Map<String, dynamic>
            ? json
            : const <String, dynamic>{};
        return ProjectRoleRequestDto.fromJson(payload);
      },
    );
  }

  Future<Result<void>> cancelProjectRoleRequest({required String requestId}) {
    return _apiClient.delete<void>(
      ApiEndpoints.projectRoleRequest(requestId),
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
