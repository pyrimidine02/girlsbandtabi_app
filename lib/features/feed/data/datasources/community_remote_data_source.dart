/// EN: Remote data source for community moderation.
/// KO: 커뮤니티 신고/차단 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/community_moderation_dto.dart';

class CommunityRemoteDataSource {
  CommunityRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Create a community report.
  /// KO: 커뮤니티 신고를 생성합니다.
  Future<Result<void>> createReport({required ReportCreateRequestDto request}) {
    return _apiClient.post<void>(
      ApiEndpoints.communityReports,
      data: request.toJson(),
      fromJson: (_) {},
    );
  }

  /// EN: Check block status for a user.
  /// KO: 특정 사용자 차단 상태를 확인합니다.
  Future<Result<BlockCheckDto>> checkBlockStatus({required String userId}) {
    return _apiClient.get<BlockCheckDto>(
      ApiEndpoints.userBlocked(userId),
      fromJson: (json) => BlockCheckDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Block a user.
  /// KO: 사용자를 차단합니다.
  Future<Result<void>> blockUser({required BlockCreateRequestDto request}) {
    return _apiClient.post<void>(
      ApiEndpoints.userBlocks,
      data: request.toJson(),
      fromJson: (_) {},
    );
  }

  /// EN: Unblock a user.
  /// KO: 사용자를 차단 해제합니다.
  Future<Result<void>> unblockUser({required String userId}) {
    return _apiClient.delete<void>(
      ApiEndpoints.userBlock(userId),
      fromJson: (_) {},
    );
  }

  /// EN: Get sanction status for authenticated user.
  /// KO: 로그인 사용자의 제재 상태를 조회합니다.
  Future<Result<UserSanctionStatusDto>> getMySanctionStatus() {
    return _apiClient.get<UserSanctionStatusDto>(
      ApiEndpoints.userMe,
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        return UserSanctionStatusDto(
          level:
              (data['sanctionLevel'] ??
                      data['sanctionStatus'] ??
                      data['actionableStatus'] ??
                      'NONE')
                  .toString(),
          reason: data['sanctionReason'] as String?,
          expiresAt: data['sanctionExpiresAt'] as String?,
        );
      },
    );
  }

  /// EN: Submit moderation appeal.
  /// KO: 모더레이션 이의제기를 제출합니다.
  Future<Result<void>> submitAppeal({required AppealCreateRequestDto request}) {
    // EN: The current OpenAPI v3 spec does not expose a community appeal endpoint.
    // KO: 현재 OpenAPI v3 스펙에는 커뮤니티 이의제기 엔드포인트가 없습니다.
    return Future.value(
      const Result.failure(
        NotFoundFailure(
          'Community appeal endpoint is not available in current API spec.',
          code: 'community_appeal_unsupported',
        ),
      ),
    );
  }
}
