/// EN: Remote data source for admin operations APIs.
/// KO: 운영/관리자 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/admin_ops_dto.dart';

class AdminOpsRemoteDataSource {
  AdminOpsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Fetch admin dashboard summary.
  /// KO: 관리자 대시보드 요약을 조회합니다.
  Future<Result<AdminDashboardDto>> fetchDashboard() {
    return _apiClient.get<AdminDashboardDto>(
      ApiEndpoints.adminDashboard,
      fromJson: (json) {
        final payload = json is Map<String, dynamic>
            ? json
            : <String, dynamic>{};
        return AdminDashboardDto.fromJson(payload);
      },
    );
  }

  /// EN: Fetch moderation-specific dashboard summary.
  /// KO: 모더레이션 전용 대시보드 요약을 조회합니다.
  Future<Result<AdminDashboardDto>> fetchModerationDashboard() {
    return _apiClient.get<AdminDashboardDto>(
      ApiEndpoints.adminModerationDashboard,
      fromJson: (json) {
        final payload = json is Map<String, dynamic>
            ? json
            : <String, dynamic>{};
        return AdminDashboardDto.fromJson(payload);
      },
    );
  }

  /// EN: Fetch community reports list for admin moderation.
  /// KO: 운영 신고 관리용 커뮤니티 신고 목록을 조회합니다.
  Future<Result<List<AdminCommunityReportDto>>> fetchCommunityReports({
    String? status,
    int page = 0,
    int size = 30,
  }) {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      'pageable': '$page,$size',
      if (status != null && status.isNotEmpty) 'status': status,
    };

    return _apiClient.get<List<AdminCommunityReportDto>>(
      ApiEndpoints.adminCommunityReports,
      queryParameters: query,
      fromJson: (json) => AdminCommunityReportDto.listFromAny(json),
    );
  }

  /// EN: Fetch single community report detail.
  /// KO: 커뮤니티 신고 단건 상세를 조회합니다.
  Future<Result<AdminCommunityReportDto>> fetchCommunityReportDetail({
    required String reportId,
  }) {
    return _apiClient.get<AdminCommunityReportDto>(
      ApiEndpoints.adminCommunityReport(reportId),
      fromJson: (json) {
        final payload = json is Map<String, dynamic>
            ? json
            : <String, dynamic>{};
        return AdminCommunityReportDto.fromJson(payload);
      },
    );
  }

  /// EN: Assign report to a moderator/admin user.
  /// KO: 신고를 운영자에게 할당합니다.
  Future<Result<void>> assignCommunityReport({
    required String reportId,
    required String assigneeUserId,
  }) {
    return _apiClient.patch<void>(
      ApiEndpoints.adminCommunityReportAssign(reportId),
      data: {
        'assigneeId': assigneeUserId,
        'assigneeUserId': assigneeUserId,
        'assignedToUserId': assigneeUserId,
      },
      fromJson: (_) {},
    );
  }

  /// EN: Update report moderation status.
  /// KO: 신고 처리 상태를 업데이트합니다.
  Future<Result<void>> updateCommunityReportStatus({
    required String reportId,
    required String status,
    String? note,
  }) {
    return _apiClient.patch<void>(
      ApiEndpoints.adminCommunityReport(reportId),
      data: {
        'status': status,
        if (note != null && note.isNotEmpty) 'note': note,
        if (note != null && note.isNotEmpty) 'resolutionNote': note,
      },
      fromJson: (_) {},
    );
  }
}
