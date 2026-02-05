/// EN: Settings repository interface.
/// KO: 설정 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/notification_settings.dart';
import '../entities/user_profile.dart';

abstract class SettingsRepository {
  Future<Result<UserProfile>> getUserProfile({bool forceRefresh = false});
  Future<Result<UserProfile>> getUserProfileById({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Result<UserProfile>> updateUserProfile({
    required String displayName,
    String? avatarUrl,
    String? bio,
    String? coverImageUrl,
  });

  Future<Result<NotificationSettings>> getNotificationSettings({
    bool forceRefresh = false,
  });

  Future<Result<NotificationSettings>> updateNotificationSettings({
    required NotificationSettings settings,
  });
}
