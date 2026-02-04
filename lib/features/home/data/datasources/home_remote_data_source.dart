/// EN: Remote data source for home summary.
/// KO: 홈 요약용 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/home_summary_dto.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<HomeSummaryDto>> fetchSummary({
    required String projectId,
    List<String> unitIds = const [],
  }) {
    return _apiClient.get<HomeSummaryDto>(
      ApiEndpoints.homeSummary,
      queryParameters: {
        'projectId': projectId,
        if (unitIds.isNotEmpty) 'unitIds': unitIds,
      },
      fromJson: (json) => HomeSummaryDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
