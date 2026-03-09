import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:girlsbandtabi_app/core/error/failure.dart';
import 'package:girlsbandtabi_app/core/providers/core_providers.dart';
import 'package:girlsbandtabi_app/core/storage/local_storage.dart';
import 'package:girlsbandtabi_app/core/utils/result.dart';
import 'package:girlsbandtabi_app/features/settings/application/settings_controller.dart';
import 'package:girlsbandtabi_app/features/settings/domain/entities/account_tools.dart';
import 'package:girlsbandtabi_app/features/settings/domain/entities/consent_history.dart';
import 'package:girlsbandtabi_app/features/settings/domain/entities/notification_settings.dart';
import 'package:girlsbandtabi_app/features/settings/domain/entities/privacy_rights.dart';
import 'package:girlsbandtabi_app/features/settings/domain/entities/user_profile.dart';
import 'package:girlsbandtabi_app/features/settings/domain/repositories/settings_repository.dart';

void main() {
  group('UserProfileController', () {
    test('emits null profile when unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [isAuthenticatedProvider.overrideWith((ref) => false)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(userProfileControllerProvider.notifier);
      await notifier.load();

      final state = container.read(userProfileControllerProvider);
      expect(state.valueOrNull, isNull);
      expect(state.hasError, isFalse);
    });
  });

  group('NotificationSettingsController', () {
    test('keeps OFF and succeeds when device deactivation succeeds', () async {
      SharedPreferences.setMockInitialValues({
        LocalStorageKeys.notificationDeviceId: 'ios-123',
      });
      final storage = await LocalStorage.create();
      const offSettings = NotificationSettings(
        pushEnabled: false,
        emailEnabled: true,
        categories: <String>[NotificationSettings.categoryComments],
      );

      final repository = _FakeSettingsRepository(
        fetchSettingsResult: Result.success(NotificationSettings.initial()),
        updateSettingsResult: const Result.success(offSettings),
        deactivateResult: const Result.success(null),
      );

      final container = ProviderContainer(
        overrides: [
          isAuthenticatedProvider.overrideWith((ref) => true),
          localStorageProvider.overrideWith((ref) async => storage),
          settingsRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        notificationSettingsControllerProvider.notifier,
      );
      await notifier.load(forceRefresh: true);
      final result = await notifier.updateSettings(offSettings);

      expect(result, isA<Success<NotificationSettings>>());
      expect(repository.deactivateCalls, 1);
      expect(repository.lastDeactivatedDeviceId, 'ios-123');
      expect(storage.getString(LocalStorageKeys.notificationDeviceId), isNull);
      expect(
        container
            .read(notificationSettingsControllerProvider)
            .valueOrNull
            ?.pushEnabled,
        isFalse,
      );
    });

    test(
      'keeps OFF and succeeds even when device deactivation fails',
      () async {
        SharedPreferences.setMockInitialValues({
          LocalStorageKeys.notificationDeviceId: 'ios-456',
        });
        final storage = await LocalStorage.create();
        const offSettings = NotificationSettings(
          pushEnabled: false,
          emailEnabled: true,
          categories: <String>[NotificationSettings.categoryComments],
        );

        final repository = _FakeSettingsRepository(
          fetchSettingsResult: Result.success(NotificationSettings.initial()),
          updateSettingsResult: const Result.success(offSettings),
          deactivateResult: const Result.failure(
            NetworkFailure('Connection error', code: 'connection_error'),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            isAuthenticatedProvider.overrideWith((ref) => true),
            localStorageProvider.overrideWith((ref) async => storage),
            settingsRepositoryProvider.overrideWith((ref) async => repository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(
          notificationSettingsControllerProvider.notifier,
        );
        await notifier.load(forceRefresh: true);
        final result = await notifier.updateSettings(offSettings);

        expect(result, isA<Success<NotificationSettings>>());
        expect(repository.deactivateCalls, 1);
        expect(
          container
              .read(notificationSettingsControllerProvider)
              .valueOrNull
              ?.pushEnabled,
          isFalse,
        );
        expect(
          storage.getString(LocalStorageKeys.notificationDeviceId),
          'ios-456',
        );
      },
    );

    test('serializes rapid updates and keeps latest settings', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorage.create();
      const initialSettings = NotificationSettings(
        pushEnabled: true,
        emailEnabled: true,
        categories: <String>[NotificationSettings.categoryComments],
      );
      const offSettings = NotificationSettings(
        pushEnabled: false,
        emailEnabled: true,
        categories: <String>[NotificationSettings.categoryComments],
      );
      const latestSettings = NotificationSettings(
        pushEnabled: false,
        emailEnabled: false,
        categories: <String>[NotificationSettings.categoryComments],
      );

      final firstCallRelease = Completer<void>();
      var updateCallCount = 0;
      final repository = _FakeSettingsRepository(
        fetchSettingsResult: const Result.success(initialSettings),
        updateSettingsResult: const Result.success(initialSettings),
        deactivateResult: const Result.success(null),
        onUpdateSettings: (settings) async {
          updateCallCount += 1;
          if (updateCallCount == 1) {
            await firstCallRelease.future;
          }
          return Result.success(settings);
        },
      );

      final container = ProviderContainer(
        overrides: [
          isAuthenticatedProvider.overrideWith((ref) => true),
          localStorageProvider.overrideWith((ref) async => storage),
          settingsRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        notificationSettingsControllerProvider.notifier,
      );
      await notifier.load(forceRefresh: true);

      final firstFuture = notifier.updateSettings(offSettings);
      final secondFuture = notifier.updateSettings(latestSettings);
      await Future<void>.delayed(Duration.zero);
      firstCallRelease.complete();

      final firstResult = await firstFuture;
      final secondResult = await secondFuture;

      expect(firstResult, isA<Success<NotificationSettings>>());
      expect(secondResult, isA<Success<NotificationSettings>>());
      expect(updateCallCount, 2);
      expect(repository.updateSettingsCalls, 2);
      expect(
        container
            .read(notificationSettingsControllerProvider)
            .valueOrNull
            ?.pushEnabled,
        isFalse,
      );
      expect(
        container
            .read(notificationSettingsControllerProvider)
            .valueOrNull
            ?.emailEnabled,
        isFalse,
      );
    });

    test('retries once for transient server error and then succeeds', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorage.create();
      const initialSettings = NotificationSettings(
        pushEnabled: true,
        emailEnabled: true,
        categories: <String>[NotificationSettings.categoryComments],
      );
      const offSettings = NotificationSettings(
        pushEnabled: false,
        emailEnabled: true,
        categories: <String>[NotificationSettings.categoryComments],
      );
      var updateCallCount = 0;
      final repository = _FakeSettingsRepository(
        fetchSettingsResult: const Result.success(initialSettings),
        updateSettingsResult: const Result.success(offSettings),
        deactivateResult: const Result.success(null),
        onUpdateSettings: (settings) async {
          updateCallCount += 1;
          if (updateCallCount == 1) {
            return const Result.failure(
              ServerFailure('Temporary server error', code: '500'),
            );
          }
          return Result.success(settings);
        },
      );

      final container = ProviderContainer(
        overrides: [
          isAuthenticatedProvider.overrideWith((ref) => true),
          localStorageProvider.overrideWith((ref) async => storage),
          settingsRepositoryProvider.overrideWith((ref) async => repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        notificationSettingsControllerProvider.notifier,
      );
      await notifier.load(forceRefresh: true);
      final result = await notifier.updateSettings(offSettings);

      expect(result, isA<Success<NotificationSettings>>());
      expect(updateCallCount, 2);
      expect(repository.updateSettingsCalls, 2);
      expect(
        container
            .read(notificationSettingsControllerProvider)
            .valueOrNull
            ?.pushEnabled,
        isFalse,
      );
    });
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({
    required this.fetchSettingsResult,
    required this.updateSettingsResult,
    required this.deactivateResult,
    this.onUpdateSettings,
  });

  final Result<NotificationSettings> fetchSettingsResult;
  final Result<NotificationSettings> updateSettingsResult;
  final Result<void> deactivateResult;
  final Future<Result<NotificationSettings>> Function(
    NotificationSettings settings,
  )?
  onUpdateSettings;
  int deactivateCalls = 0;
  int updateSettingsCalls = 0;
  String? lastDeactivatedDeviceId;

  @override
  Future<Result<NotificationSettings>> getNotificationSettings({
    bool forceRefresh = false,
  }) async {
    return fetchSettingsResult;
  }

  @override
  Future<Result<NotificationSettings>> updateNotificationSettings({
    required NotificationSettings settings,
  }) async {
    updateSettingsCalls += 1;
    final callback = onUpdateSettings;
    if (callback != null) {
      return callback(settings);
    }
    return updateSettingsResult;
  }

  @override
  Future<Result<void>> deactivateNotificationDevice({
    required String deviceId,
  }) async {
    deactivateCalls += 1;
    lastDeactivatedDeviceId = deviceId;
    return deactivateResult;
  }

  @override
  Future<Result<PrivacySettings>> getPrivacySettings({
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<PrivacySettings>> updatePrivacySettings({
    required bool allowAutoTranslation,
    int? version,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<PrivacyRequestRecord>>> getPrivacyRequests({
    bool forceRefresh = false,
    int page = 0,
    int size = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<PrivacyRequestRecord>> createPrivacyRequest({
    required String requestType,
    required String reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<ConsentHistoryItem>>> getConsentHistory({
    bool forceRefresh = false,
    int page = 0,
    int size = 50,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteAccount() {
    throw UnimplementedError();
  }

  @override
  Future<Result<UserProfile>> getUserProfile({bool forceRefresh = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<UserProfile>> getUserProfileById({
    required String userId,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<UserProfile>> updateUserProfile({
    required String displayName,
    String? avatarUrl,
    String? bio,
    String? coverImageUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<UserBlock>>> getUserBlocks({bool forceRefresh = false}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> unblockUser({required String targetUserId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<ProjectRoleRequest>>> getProjectRoleRequests({
    bool forceRefresh = false,
    String? status,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<ProjectRoleRequest>> createProjectRoleRequest({
    required String projectId,
    required String requestedRole,
    required String justification,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> cancelProjectRoleRequest({required String requestId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<VerificationAppeal>>> getVerificationAppeals({
    required String projectId,
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<VerificationAppeal>> createVerificationAppeal({
    required String projectId,
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
    List<String> evidenceUrls = const [],
  }) {
    throw UnimplementedError();
  }
}
