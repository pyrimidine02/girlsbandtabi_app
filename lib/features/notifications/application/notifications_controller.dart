/// EN: Notifications controller for list and read state.
/// KO: 알림 목록/읽음 처리를 위한 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../domain/entities/notification_entities.dart';
import '../domain/repositories/notifications_repository.dart';

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  NotificationsController(this._ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    final repository = await _ref.read(notificationsRepositoryProvider.future);
    final result = await repository.getNotifications(
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<NotificationItem>>) {
      state = AsyncData(result.data);
    } else if (result is Err<List<NotificationItem>>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }

  Future<Result<void>> markAsRead(
    String notificationId, {
    bool refresh = true,
  }) async {
    final isAuthenticated = _ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      return Result.failure(
        const AuthFailure('Login required', code: 'auth_required'),
      );
    }

    final repository = await _ref.read(notificationsRepositoryProvider.future);
    final result = await repository.markAsRead(notificationId);
    if (result is Success<void> && refresh) {
      await load(forceRefresh: true);
    }
    return result;
  }

  Future<void> markAllAsRead() async {
    final items = state.maybeWhen(data: (data) => data, orElse: () => []);
    if (items.isEmpty) return;

    for (final item in items.where((item) => !item.isRead)) {
      await markAsRead(item.id, refresh: false);
    }
    await load(forceRefresh: true);
  }
}

/// EN: Notifications repository provider.
/// KO: 알림 리포지토리 프로바이더.
final notificationsRepositoryProvider = FutureProvider<NotificationsRepository>(
  (ref) async {
    final apiClient = ref.watch(apiClientProvider);
    final cacheManager = await ref.watch(cacheManagerProvider.future);
    return NotificationsRepositoryImpl(
      remoteDataSource: NotificationsRemoteDataSource(apiClient),
      cacheManager: cacheManager,
    );
  },
);

/// EN: Notifications controller provider.
/// KO: 알림 컨트롤러 프로바이더.
final notificationsControllerProvider =
    StateNotifierProvider<
      NotificationsController,
      AsyncValue<List<NotificationItem>>
    >((ref) {
      return NotificationsController(ref);
    });
