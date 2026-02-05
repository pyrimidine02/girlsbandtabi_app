/// EN: Settings controllers for profile and notification preferences.
/// KO: 프로필/알림 설정 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/settings_remote_data_source.dart';
import '../data/repositories/settings_repository_impl.dart';
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

    state = const AsyncLoading();
    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.getUserProfile(forceRefresh: forceRefresh);

    if (result is Success<UserProfile>) {
      state = AsyncData(result.data);
    } else if (result is Err<UserProfile>) {
      state = AsyncError(result.failure, StackTrace.current);
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

    state = const AsyncLoading();

    final repository = await _ref.read(settingsRepositoryProvider.future);
    final result = await repository.updateNotificationSettings(
      settings: settings,
    );

    if (result is Success<NotificationSettings>) {
      state = AsyncData(result.data);
    } else if (result is Err<NotificationSettings>) {
      state = AsyncError(result.failure, StackTrace.current);
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
  final cacheManager = await ref.watch(cacheManagerProvider.future);
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
final userProfileByIdProvider =
    StateNotifierProvider.family<
      UserProfileByIdController,
      AsyncValue<UserProfile?>,
      String
    >((ref, userId) {
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
