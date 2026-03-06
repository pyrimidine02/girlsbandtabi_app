/// EN: Settings repository implementation with caching.
/// KO: 캐시를 포함한 설정 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/account_tools.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
import '../dto/account_tools_dto.dart';
import '../dto/notification_device_dto.dart';
import '../dto/notification_settings_dto.dart';
import '../dto/user_profile_dto.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required SettingsRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final SettingsRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<UserProfile>> getUserProfile({
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<UserProfileDto>(
        key: _profileCacheKey,
        policy: policy,
        ttl: const Duration(minutes: 10),
        fetcher: _fetchUserProfile,
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => UserProfileDto.fromJson(json),
      );
      return Result.success(UserProfile.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<UserProfile>> getUserProfileById({
    required String userId,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<UserProfileDto>(
        key: _userProfileCacheKey(userId),
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: () => _fetchUserProfileById(userId),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => UserProfileDto.fromJson(json),
      );
      return Result.success(UserProfile.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<UserProfile>> updateUserProfile({
    required String displayName,
    String? avatarUrl,
    String? bio,
    String? coverImageUrl,
  }) async {
    try {
      final result = await _remoteDataSource.updateUserProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio,
        coverImageUrl: coverImageUrl,
      );

      if (result is Success<UserProfileDto>) {
        await _cacheManager.setJson(
          _profileCacheKey,
          result.data.toJson(),
          ttl: const Duration(minutes: 10),
        );
        return Result.success(UserProfile.fromDto(result.data));
      }
      if (result is Err<UserProfileDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown user profile update result',
          code: 'unknown_profile_update',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<NotificationSettings>> getNotificationSettings({
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<NotificationSettingsDto>(
        key: _notificationCacheKey,
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: _fetchNotificationSettings,
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => NotificationSettingsDto.fromJson(json),
      );
      return Result.success(NotificationSettings.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<NotificationSettings>> updateNotificationSettings({
    required NotificationSettings settings,
  }) async {
    try {
      final dto = NotificationSettingsDto(
        pushEnabled: settings.pushEnabled,
        emailEnabled: settings.emailEnabled,
        categories: settings.categories,
      );
      final result = await _remoteDataSource.updateNotificationSettings(
        settings: dto,
      );

      if (result is Success<NotificationSettingsDto>) {
        await _cacheManager.setJson(
          _notificationCacheKey,
          result.data.toJson(),
          ttl: const Duration(minutes: 5),
        );
        return Result.success(NotificationSettings.fromDto(result.data));
      }
      if (result is Err<NotificationSettingsDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown notification settings update result',
          code: 'unknown_notification_update',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> deactivateNotificationDevice({
    required String deviceId,
  }) async {
    try {
      final result = await _remoteDataSource.deactivateNotificationDevice(
        deviceId: deviceId,
      );

      if (result is Success<NotificationDeviceDeactivationDto>) {
        // EN: Treat any 200 success as successful deactivation intent.
        // KO: 200 성공 응답은 deactivated 값과 무관하게 해제 의도 성공으로 처리합니다.
        return const Result.success(null);
      }
      if (result is Err<NotificationDeviceDeactivationDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown notification device deactivate result',
          code: 'unknown_notification_device_deactivate',
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<UserBlock>>> getUserBlocks({
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;
    try {
      final cacheResult = await _cacheManager.resolve<List<UserBlockDto>>(
        key: _userBlocksCacheKey,
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: _fetchUserBlocks,
        toJson: (dtos) => {'items': dtos.map(_userBlockToJson).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(UserBlockDto.fromJson)
                .toList(growable: false);
          }
          return const <UserBlockDto>[];
        },
      );
      return Result.success(
        cacheResult.data.map(UserBlock.fromDto).toList(growable: false),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> unblockUser({required String targetUserId}) async {
    try {
      final result = await _remoteDataSource.unblockUser(
        targetUserId: targetUserId,
      );
      if (result is Success<void>) {
        await _cacheManager.remove(_userBlocksCacheKey);
      }
      return result;
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<ProjectRoleRequest>>> getProjectRoleRequests({
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;
    try {
      final cacheResult = await _cacheManager
          .resolve<List<ProjectRoleRequestSummaryDto>>(
            key: _projectRoleRequestsCacheKey,
            policy: policy,
            ttl: const Duration(minutes: 5),
            fetcher: _fetchProjectRoleRequests,
            toJson: (dtos) => {
              'items': dtos.map(_roleRequestSummaryToJson).toList(),
            },
            fromJson: (json) {
              final items = json['items'];
              if (items is List) {
                return items
                    .whereType<Map<String, dynamic>>()
                    .map(ProjectRoleRequestSummaryDto.fromJson)
                    .toList(growable: false);
              }
              return const <ProjectRoleRequestSummaryDto>[];
            },
          );
      return Result.success(
        cacheResult.data
            .map(ProjectRoleRequest.fromSummaryDto)
            .toList(growable: false),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<ProjectRoleRequest>> createProjectRoleRequest({
    required String projectId,
    required String requestedRole,
    required String justification,
  }) async {
    try {
      final result = await _remoteDataSource.createProjectRoleRequest(
        request: ProjectRoleRequestCreateRequestDto(
          projectId: projectId,
          requestedRole: requestedRole,
          justification: justification,
        ),
      );
      if (result is Success<ProjectRoleRequestDetailDto>) {
        await _cacheManager.remove(_projectRoleRequestsCacheKey);
        return Result.success(ProjectRoleRequest.fromDetailDto(result.data));
      }
      if (result is Err<ProjectRoleRequestDetailDto>) {
        return Result.failure(result.failure);
      }
      return Result.failure(
        const UnknownFailure(
          'Unknown project role request create result',
          code: 'unknown_project_role_request_create',
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> cancelProjectRoleRequest({
    required String requestId,
  }) async {
    try {
      final result = await _remoteDataSource.cancelProjectRoleRequest(
        requestId: requestId,
      );
      if (result is Success<void>) {
        await _cacheManager.remove(_projectRoleRequestsCacheKey);
      }
      return result;
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<VerificationAppeal>>> getVerificationAppeals({
    required String projectId,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;
    final cacheKey = _verificationAppealsCacheKey(projectId);
    try {
      final cacheResult = await _cacheManager
          .resolve<List<VerificationAppealDto>>(
            key: cacheKey,
            policy: policy,
            ttl: const Duration(minutes: 3),
            fetcher: () => _fetchVerificationAppeals(projectId),
            toJson: (dtos) => {
              'items': dtos.map(_verificationAppealToJson).toList(),
            },
            fromJson: (json) {
              final items = json['items'];
              if (items is List) {
                return items
                    .whereType<Map<String, dynamic>>()
                    .map(VerificationAppealDto.fromJson)
                    .toList(growable: false);
              }
              return const <VerificationAppealDto>[];
            },
          );
      return Result.success(
        cacheResult.data
            .map(VerificationAppeal.fromDto)
            .toList(growable: false),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<VerificationAppeal>> createVerificationAppeal({
    required String projectId,
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
    List<String> evidenceUrls = const [],
  }) async {
    try {
      final result = await _remoteDataSource.createVerificationAppeal(
        projectId: projectId,
        request: VerificationAppealCreateRequestDto(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          description: description,
          evidenceUrls: evidenceUrls,
        ),
      );
      if (result is Success<VerificationAppealDto>) {
        await _cacheManager.remove(_verificationAppealsCacheKey(projectId));
        return Result.success(VerificationAppeal.fromDto(result.data));
      }
      if (result is Err<VerificationAppealDto>) {
        return Result.failure(result.failure);
      }
      return Result.failure(
        const UnknownFailure(
          'Unknown verification appeal create result',
          code: 'unknown_verification_appeal_create',
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  Future<UserProfileDto> _fetchUserProfile() async {
    final result = await _remoteDataSource.fetchUserProfile();

    if (result is Success<UserProfileDto>) {
      return result.data;
    }
    if (result is Err<UserProfileDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown user profile result',
      code: 'unknown_profile',
    );
  }

  Future<UserProfileDto> _fetchUserProfileById(String userId) async {
    final result = await _remoteDataSource.fetchUserProfileById(userId);

    if (result is Success<UserProfileDto>) {
      return result.data;
    }
    if (result is Err<UserProfileDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown user profile by id result',
      code: 'unknown_profile_by_id',
    );
  }

  Future<NotificationSettingsDto> _fetchNotificationSettings() async {
    final result = await _remoteDataSource.fetchNotificationSettings();

    if (result is Success<NotificationSettingsDto>) {
      return result.data;
    }
    if (result is Err<NotificationSettingsDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown notification settings result',
      code: 'unknown_notification_settings',
    );
  }

  Future<List<UserBlockDto>> _fetchUserBlocks() async {
    final result = await _remoteDataSource.fetchUserBlocks();
    if (result is Success<List<UserBlockDto>>) {
      return result.data;
    }
    if (result is Err<List<UserBlockDto>>) {
      throw result.failure;
    }
    throw const UnknownFailure(
      'Unknown user blocks result',
      code: 'unknown_user_blocks',
    );
  }

  Future<List<ProjectRoleRequestSummaryDto>> _fetchProjectRoleRequests() async {
    final result = await _remoteDataSource.fetchProjectRoleRequests();
    if (result is Success<List<ProjectRoleRequestSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<ProjectRoleRequestSummaryDto>>) {
      throw result.failure;
    }
    throw const UnknownFailure(
      'Unknown project role requests result',
      code: 'unknown_project_role_requests',
    );
  }

  Future<List<VerificationAppealDto>> _fetchVerificationAppeals(
    String projectId,
  ) async {
    final result = await _remoteDataSource.fetchVerificationAppeals(
      projectId: projectId,
    );
    if (result is Success<List<VerificationAppealDto>>) {
      return result.data;
    }
    if (result is Err<List<VerificationAppealDto>>) {
      throw result.failure;
    }
    throw const UnknownFailure(
      'Unknown verification appeals result',
      code: 'unknown_verification_appeals',
    );
  }

  static const String _profileCacheKey = 'user_profile';
  static const String _notificationCacheKey = 'notification_settings';
  static const String _userBlocksCacheKey = 'user_blocks';
  static const String _projectRoleRequestsCacheKey = 'project_role_requests';

  String _userProfileCacheKey(String userId) {
    return 'user_profile:$userId';
  }

  String _verificationAppealsCacheKey(String projectId) {
    return 'verification_appeals:$projectId';
  }
}

Map<String, dynamic> _blockedUserToJson(BlockedUserDto dto) {
  return {
    'id': dto.id,
    'displayName': dto.displayName,
    if (dto.avatarUrl != null) 'avatarUrl': dto.avatarUrl,
  };
}

Map<String, dynamic> _userBlockToJson(UserBlockDto dto) {
  return {
    'id': dto.id,
    'blockedUser': _blockedUserToJson(dto.blockedUser),
    if (dto.reason != null) 'reason': dto.reason,
    'createdAt': dto.createdAt.toIso8601String(),
  };
}

Map<String, dynamic> _roleRequestSummaryToJson(
  ProjectRoleRequestSummaryDto dto,
) {
  return {
    'id': dto.id,
    if (dto.projectSlug != null) 'projectSlug': dto.projectSlug,
    if (dto.projectName != null) 'projectName': dto.projectName,
    'requestedRole': dto.requestedRole,
    'status': dto.status,
    'createdAt': dto.createdAt.toIso8601String(),
  };
}

Map<String, dynamic> _verificationAppealToJson(VerificationAppealDto dto) {
  return {
    'id': dto.id,
    'targetType': dto.targetType,
    'targetId': dto.targetId,
    if (dto.placeId != null) 'placeId': dto.placeId,
    'reason': dto.reason,
    if (dto.description != null) 'description': dto.description,
    'evidenceUrls': dto.evidenceUrls,
    'status': dto.status,
    if (dto.reviewerMemo != null) 'reviewerMemo': dto.reviewerMemo,
    'createdAt': dto.createdAt.toIso8601String(),
    if (dto.resolvedAt != null) 'resolvedAt': dto.resolvedAt!.toIso8601String(),
  };
}
