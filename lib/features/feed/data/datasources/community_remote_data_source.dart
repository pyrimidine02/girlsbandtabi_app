/// EN: Remote data source for community moderation.
/// KO: 커뮤니티 신고/차단 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/community_moderation_dto.dart';

class CommunityRemoteDataSource {
  CommunityRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Create a community report.
  /// KO: 커뮤니티 신고를 생성합니다.
  Future<Result<void>> createReport({
    required ReportCreateRequestDto request,
  }) {
    return _apiClient.post<void>(
      ApiEndpoints.communityReports,
      data: request.toJson(),
      fromJson: (_) {},
    );
  }

  /// EN: Check block status for a user.
  /// KO: 특정 사용자 차단 상태를 확인합니다.
  Future<Result<BlockCheckDto>> checkBlockStatus({
    required String userId,
  }) {
    return _apiClient.get<BlockCheckDto>(
      ApiEndpoints.userBlocked(userId),
      fromJson: (json) => BlockCheckDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// EN: Block a user.
  /// KO: 사용자를 차단합니다.
  Future<Result<void>> blockUser({
    required BlockCreateRequestDto request,
  }) {
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
}
