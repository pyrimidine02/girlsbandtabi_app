/// EN: Settings controllers for profile and notification preferences.
/// KO: 프로필/알림 설정 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/settings_remote_data_source.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/entities/account_tools.dart';
import '../domain/entities/notification_settings.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/settings_repository.dart';

class UserProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileController(this._ref) : super(const AsyncLoading());

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData(null);
      return;
    }

    final previousProfile = state.valueOrNull;
    if (previousProfile == null) {
      state = const AsyncLoading();
    } else {
      // EN: Keep previously resolved profile during refresh to avoid
      // EN: permission flicker on transient /users/me failures.
      // KO: /users/me 일시 오류 시 권한 UI가 깜빡이지 않도록
      // KO: 새로고침 중에는 이전 프로필 상태를 유지합니다.
      state = AsyncData(previousProfile);
    }
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getUserProfile(forceRefresh: forceRefresh);

    if (result is Success<UserProfile>) {
      state = AsyncData(result.data);
    } else if (result is Err<UserProfile>) {
      if (previousProfile != null) {
        AppLogger.warning(
          'Failed to refresh user profile; keeping previous profile cache',
          data: result.failure,
          tag: 'UserProfileController',
        );
        state = AsyncData(previousProfile);
      } else {
        state = AsyncError(result.failure, StackTrace.current);
      }
    }
  }

  Future<Result<UserProfile>> updateProfile({
    required String displayName,
    String? avatarUrl,
    String? bio,
    String? coverImageUrl,
  }) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      const failure = AuthFailure('Login required', code: 'auth_required');
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.updateUserProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      coverImageUrl: coverImageUrl,
    );

    if (result is Success<UserProfile>) {
      state = AsyncData(result.data);
    } else if (result is Err<UserProfile>) {
      state = AsyncError(result.failure, StackTrace.current);
    }

    return result;
  }
}

class UserProfileByIdController
    extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileByIdController(this._ref, this.userId)
    : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;
  final String userId;

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getUserProfileById(
      userId: userId,
      forceRefresh: forceRefresh,
    );

    if (result is Success<UserProfile>) {
      state = AsyncData(result.data);
    } else if (result is Err<UserProfile>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class NotificationSettingsController
    extends StateNotifier<AsyncValue<NotificationSettings>> {
  NotificationSettingsController(this._ref) : super(const AsyncLoading());

  final Ref _ref;
  bool _isUpdating = false;
  NotificationSettings? _queuedSettings;

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = AsyncData(NotificationSettings.initial());
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getNotificationSettings(
      forceRefresh: forceRefresh,
    );

    if (result is Success<NotificationSettings>) {
      await _persistPushEnabled(result.data.pushEnabled);
      state = AsyncData(result.data);
    } else if (result is Err<NotificationSettings>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<NotificationSettings>> updateSettings(
    NotificationSettings settings,
  ) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      const failure = AuthFailure('Login required', code: 'auth_required');
      state = AsyncError(failure, StackTrace.current);
      return Result.failure(failure);
    }

    // EN: Serialize rapid toggle updates to avoid stale write/revert race.
    // KO: 빠른 연속 토글에서 오래된 쓰기/복원 경쟁이 나지 않도록 직렬 처리합니다.
    _queuedSettings = settings;
    if (_isUpdating) {
      state = AsyncData(settings);
      await _persistPushEnabled(settings.pushEnabled);
      return Result.success(settings);
    }

    _isUpdating = true;
    var lastResult = Result<NotificationSettings>.success(settings);
    try {
      while (_queuedSettings != null) {
        final next = _queuedSettings!;
        _queuedSettings = null;
        lastResult = await _commitSettingsUpdate(next);
      }
    } finally {
      _isUpdating = false;
    }
    return lastResult;
  }

  Future<Result<NotificationSettings>> _commitSettingsUpdate(
    NotificationSettings settings,
  ) async {
    // EN: Optimistic update — apply changes immediately so toggles feel instant.
    // EN: On failure, revert to the previous state to keep UI consistent.
    // KO: Optimistic 업데이트 — 토글이 즉각 반응하도록 변경을 즉시 적용합니다.
    // KO: 실패 시 이전 상태로 복원하여 UI 일관성을 유지합니다.
    final previousState = state;
    state = AsyncData(settings);
    await _persistPushEnabled(settings.pushEnabled);

    final repository = await _ref.read(settingsRepositoryProvider.future);
    var result = await repository.updateNotificationSettings(
      settings: settings,
    );
    if (_isTransientSettingsFailure(result)) {
      result = await repository.updateNotificationSettings(settings: settings);
    }

    if (result is Success<NotificationSettings>) {
      final previousPushEnabled = previousState.valueOrNull?.pushEnabled;
      await _persistPushEnabled(result.data.pushEnabled);
      state = AsyncData(result.data);
      if (!result.data.pushEnabled) {
        final deactivateResult = await _deactivateDeviceRegistration();
        if (deactivateResult is Err<void>) {
          // EN: Settings update already succeeded; keep OFF state and log
          //     deactivation failure for follow-up without showing save error.
          // KO: 설정 업데이트는 이미 성공했으므로 OFF 상태는 유지하고,
          //     디바이스 해제 실패는 저장 실패로 처리하지 않고 로그만 남깁니다.
          AppLogger.warning(
            'Notification device deactivation failed after push OFF update',
            data: deactivateResult.failure,
            tag: 'NotificationSettingsController',
          );
        }
      } else if (previousPushEnabled != true) {
        await _activateDeviceRegistration();
      }
      return result;
    }

    if (result is Err<NotificationSettings>) {
      final hasPending = _queuedSettings != null;
      if (!hasPending) {
        final previousPushEnabled = previousState.valueOrNull?.pushEnabled;
        if (previousPushEnabled != null) {
          await _persistPushEnabled(previousPushEnabled);
        }
        state = previousState;
      }
    }
    return result;
  }

  bool _isTransientSettingsFailure(Result<NotificationSettings> result) {
    if (result is! Err<NotificationSettings>) {
      return false;
    }
    final failure = result.failure;
    if (failure is NetworkFailure) {
      return true;
    }
    if (failure is ServerFailure) {
      final code = failure.code?.trim();
      if (code == null || code.isEmpty) {
        return true;
      }
      return code == '500' ||
          code == '502' ||
          code == '503' ||
          code == '504' ||
          code == '429';
    }
    return false;
  }

  /// EN: Persist push toggle for foreground local-alert eligibility checks.
  /// KO: 포그라운드 로컬 알림 표시 여부 판단용 푸시 토글을 저장합니다.
  Future<void> _persistPushEnabled(bool value) async {
    final storage = await _ref.read(localStorageProvider.future);
    await storage.setBool(LocalStorageKeys.notificationsEnabled, value);
  }

  /// EN: Deactivate stored notification device registration when push is turned off.
  /// KO: 푸시 OFF 전환 시 저장된 알림 디바이스 등록을 비활성화합니다.
  Future<Result<void>> _deactivateDeviceRegistration() async {
    final storage = await _ref.read(localStorageProvider.future);
    final deviceId = _resolveStoredNotificationDeviceId(storage);
    if (deviceId == null || deviceId.isEmpty) {
      return const Result.success(null);
    }

    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.deactivateNotificationDevice(
      deviceId: deviceId,
    );
    if (result is Success<void>) {
      await Future.wait([
        storage.remove(LocalStorageKeys.notificationDeviceId),
        storage.remove(LocalStorageKeys.notificationDeviceIdLegacy),
        storage.remove(LocalStorageKeys.notificationPushToken),
      ]);
      return const Result.success(null);
    }
    return result;
  }

  /// EN: Re-register push device when push setting is turned on.
  /// KO: 푸시 설정이 ON으로 전환되면 디바이스 등록을 다시 수행합니다.
  Future<void> _activateDeviceRegistration() async {
    try {
      final remotePushService = _ref.read(remotePushServiceProvider);
      await remotePushService.initialize();
      await remotePushService.setAuthenticated(true);
      await remotePushService.requestPermission();
      await remotePushService.syncRegistration();

      final localNotifier = _ref.read(localNotificationsServiceProvider);
      await localNotifier.requestPermissions();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Notification device activation failed after push ON update',
        data: error,
        tag: 'NotificationSettingsController',
      );
      AppLogger.error(
        'Notification activation error',
        error: error,
        stackTrace: stackTrace,
        tag: 'NotificationSettingsController',
      );
    }
  }

  String? _resolveStoredNotificationDeviceId(LocalStorage storage) {
    final primary = storage.getString(LocalStorageKeys.notificationDeviceId);
    if (primary != null && primary.trim().isNotEmpty) {
      return primary.trim();
    }
    final legacy = storage.getString(
      LocalStorageKeys.notificationDeviceIdLegacy,
    );
    if (legacy != null && legacy.trim().isNotEmpty) {
      return legacy.trim();
    }
    return null;
  }
}

class UserBlocksController extends StateNotifier<AsyncValue<List<UserBlock>>> {
  UserBlocksController(this._ref) : super(const AsyncLoading());

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData(<UserBlock>[]);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getUserBlocks(forceRefresh: forceRefresh);

    if (result is Success<List<UserBlock>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<UserBlock>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<void>> unblock(String targetUserId) async {
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.unblockUser(targetUserId: targetUserId);
    if (result is Success<void>) {
      await load(forceRefresh: true);
    }
    return result;
  }
}

class ProjectRoleRequestsController
    extends StateNotifier<AsyncValue<List<ProjectRoleRequest>>> {
  ProjectRoleRequestsController(this._ref) : super(const AsyncLoading());

  final Ref _ref;

  String? _resolveProjectId() {
    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectId != null && projectId.isNotEmpty) {
      return projectId;
    }
    final projectKey = _ref.read(selectedProjectKeyProvider);
    if (projectKey != null && projectKey.isNotEmpty) {
      return projectKey;
    }
    return null;
  }

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData(<ProjectRoleRequest>[]);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getProjectRoleRequests(
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<ProjectRoleRequest>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<ProjectRoleRequest>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<ProjectRoleRequest>> create({
    required String requestedRole,
    required String justification,
  }) async {
    final trimmed = justification.trim();
    if (trimmed.length < 20 || trimmed.length > 2000) {
      return const Result.failure(
        ValidationFailure(
          'Justification must be between 20 and 2000 characters',
          code: 'invalid_justification_length',
        ),
      );
    }

    final projectId = _resolveProjectId();
    if (projectId == null || projectId.isEmpty) {
      return const Result.failure(
        ValidationFailure('Project is required', code: 'project_required'),
      );
    }

    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.createProjectRoleRequest(
      projectId: projectId,
      requestedRole: requestedRole,
      justification: trimmed,
    );
    if (result is Success<ProjectRoleRequest>) {
      await load(forceRefresh: true);
    }
    return result;
  }

  Future<Result<void>> cancel({required String requestId}) async {
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.cancelProjectRoleRequest(
      requestId: requestId,
    );
    if (result is Success<void>) {
      await load(forceRefresh: true);
    }
    return result;
  }
}

class VerificationAppealsController
    extends StateNotifier<AsyncValue<List<VerificationAppeal>>> {
  VerificationAppealsController(this._ref) : super(const AsyncLoading());

  final Ref _ref;

  String? _resolveProjectId() {
    final projectKey = _ref.read(selectedProjectKeyProvider);
    final projectId = _ref.read(selectedProjectIdProvider);
    if (projectKey != null && projectKey.isNotEmpty) return projectKey;
    if (projectId != null && projectId.isNotEmpty) return projectId;
    return null;
  }

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData(<VerificationAppeal>[]);
      return;
    }
    final projectId = _resolveProjectId();
    if (projectId == null || projectId.isEmpty) {
      state = const AsyncData(<VerificationAppeal>[]);
      return;
    }
    state = const AsyncLoading();
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getVerificationAppeals(
      projectId: projectId,
      forceRefresh: forceRefresh,
    );
    if (result is Success<List<VerificationAppeal>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<VerificationAppeal>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<VerificationAppeal>> create({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    final projectId = _resolveProjectId();
    if (projectId == null || projectId.isEmpty) {
      return const Result.failure(
        ValidationFailure('Project is required', code: 'project_required'),
      );
    }
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.createVerificationAppeal(
      projectId: projectId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      description: description,
    );
    if (result is Success<VerificationAppeal>) {
      await load(forceRefresh: true);
    }
    return result;
  }
}

/// EN: Settings repository provider.
/// KO: 설정 리포지토리 프로바이더.
final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
  return SettingsRepositoryImpl(
    remoteDataSource: SettingsRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: User profile controller provider.
/// KO: 사용자 프로필 컨트롤러 프로바이더.
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, AsyncValue<UserProfile?>>((
      ref,
    ) {
      return UserProfileController(ref)..load();
    });

/// EN: User profile controller provider by ID.
/// KO: 사용자 ID별 프로필 컨트롤러 프로바이더.
final userProfileByIdProvider = StateNotifierProvider.autoDispose
    .family<UserProfileByIdController, AsyncValue<UserProfile?>, String>((
      ref,
      userId,
    ) {
      return UserProfileByIdController(ref, userId);
    });

/// EN: Notification settings controller provider.
/// KO: 알림 설정 컨트롤러 프로바이더.
final notificationSettingsControllerProvider =
    StateNotifierProvider<
      NotificationSettingsController,
      AsyncValue<NotificationSettings>
    >((ref) {
      return NotificationSettingsController(ref)..load();
    });

/// EN: User blocks controller provider.
/// KO: 사용자 차단 목록 컨트롤러 프로바이더.
final userBlocksControllerProvider =
    StateNotifierProvider<UserBlocksController, AsyncValue<List<UserBlock>>>((
      ref,
    ) {
      return UserBlocksController(ref)..load();
    });

/// EN: Project role request controller provider.
/// KO: 프로젝트 권한 요청 컨트롤러 프로바이더.
final projectRoleRequestsControllerProvider =
    StateNotifierProvider<
      ProjectRoleRequestsController,
      AsyncValue<List<ProjectRoleRequest>>
    >((ref) {
      return ProjectRoleRequestsController(ref)..load();
    });

/// EN: Verification appeals controller provider.
/// KO: 인증 이의제기 컨트롤러 프로바이더.
final verificationAppealsControllerProvider =
    StateNotifierProvider<
      VerificationAppealsController,
      AsyncValue<List<VerificationAppeal>>
    >((ref) {
      return VerificationAppealsController(ref)..load();
    });
