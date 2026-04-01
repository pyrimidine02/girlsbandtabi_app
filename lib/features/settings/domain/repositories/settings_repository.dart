/// EN: Settings repository interface.
/// KO: 설정 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/account_tools.dart';
import '../entities/consent_history.dart';
import '../entities/notification_settings.dart';
import '../entities/privacy_rights.dart';
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

  Future<Result<void>> deactivateNotificationDevice({required String deviceId});

  Future<Result<PrivacySettings>> getPrivacySettings({
    bool forceRefresh = false,
  });

  Future<Result<PrivacySettings>> updatePrivacySettings({
    required bool allowAutoTranslation,
    int? version,
  });

  Future<Result<List<PrivacyRequestRecord>>> getPrivacyRequests({
    bool forceRefresh = false,
    int page = 0,
    int size = 20,
  });

  Future<Result<PrivacyRequestRecord>> createPrivacyRequest({
    required String requestType,
    required String reason,
  });

  Future<Result<List<ConsentHistoryItem>>> getConsentHistory({
    bool forceRefresh = false,
    int page = 0,
    int size = 50,
  });

  Future<Result<Map<String, dynamic>>> getMandatoryConsentStatus();

  Future<Result<void>> submitMandatoryConsents({
    required List<Map<String, dynamic>> consents,
  });

  Future<Result<void>> deleteAccount();

  /// EN: Restore a deactivated account within the 30-day grace period.
  /// KO: 비활성화 후 30일 유예기간 내에 계정을 복구합니다.
  Future<Result<RestoreAccountResult>> restoreAccount();

  Future<Result<List<UserBlock>>> getUserBlocks({bool forceRefresh = false});

  Future<Result<void>> unblockUser({required String targetUserId});

  Future<Result<List<ProjectRoleRequest>>> getProjectRoleRequests({
    bool forceRefresh = false,
    String? status,
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
