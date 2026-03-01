/// EN: Settings repository interface.
/// KO: 설정 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/account_tools.dart';
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

  Future<Result<List<UserBlock>>> getUserBlocks({bool forceRefresh = false});

  Future<Result<void>> unblockUser({required String targetUserId});

  Future<Result<List<ProjectRoleRequest>>> getProjectRoleRequests({
    bool forceRefresh = false,
  });

  Future<Result<ProjectRoleRequest>> createProjectRoleRequest({
    required String projectId,
    required String requestedRole,
    required String justification,
  });

  Future<Result<void>> cancelProjectRoleRequest({required String requestId});

  Future<Result<List<VerificationAppeal>>> getVerificationAppeals({
    required String projectId,
    bool forceRefresh = false,
  });

  Future<Result<VerificationAppeal>> createVerificationAppeal({
    required String projectId,
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
    List<String> evidenceUrls = const [],
  });
}
