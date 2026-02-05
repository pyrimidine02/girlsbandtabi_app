/// EN: Settings repository implementation with caching.
/// KO: 캐시를 포함한 설정 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
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

  static const String _profileCacheKey = 'user_profile';
  static const String _notificationCacheKey = 'notification_settings';

  String _userProfileCacheKey(String userId) {
    return 'user_profile:$userId';
  }
}
