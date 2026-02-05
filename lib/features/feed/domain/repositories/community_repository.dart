/// EN: Community moderation repository interface.
/// KO: 커뮤니티 신고/차단 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/community_moderation.dart';

abstract class CommunityRepository {
  /// EN: Create a report.
  /// KO: 신고를 생성합니다.
  Future<Result<void>> createReport({
    required CommunityReportTargetType targetType,
    required String targetId,
    required CommunityReportReason reason,
    String? description,
  });

  /// EN: Check block status for a user.
  /// KO: 사용자 차단 상태를 확인합니다.
  Future<Result<BlockStatus>> getBlockStatus({
    required String userId,
  });

  /// EN: Block a user.
  /// KO: 사용자를 차단합니다.
  Future<Result<void>> blockUser({
    required String targetUserId,
    String? reason,
  });

  /// EN: Unblock a user.
  /// KO: 사용자를 차단 해제합니다.
  Future<Result<void>> unblockUser({
    required String targetUserId,
  });
}
