import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/home_summary_model.dart';

class HomeService {
  HomeService();

  final ApiClient _api = ApiClient.instance;

  Future<HomeSummary> getSummary({
    required String projectId,
    List<String>? unitIds,
  }) async {
    final envelope = await _api.get(
      ApiConstants.homeSummary,
      queryParameters: {
        'projectId': projectId,
        if (unitIds != null && unitIds.isNotEmpty)
          'unitIds': unitIds.join(','),
      },
    );

    final data = envelope.requireDataAsMap();
    return HomeSummary.fromJson(data);
  }
}
