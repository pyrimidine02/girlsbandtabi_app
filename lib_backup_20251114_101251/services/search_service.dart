import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class SearchService {
  SearchService();

  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> search({
    required String q,
    List<String>? types,
    String? projectId,
    List<String>? unitIds,
    int page = 0,
    int size = 20,
  }) async {
    final envelope = await _api.get(
      ApiConstants.search,
      queryParameters: {
        'q': q,
        if (types != null && types.isNotEmpty) 'types': types.join(','),
        if (projectId != null) 'projectId': projectId,
        if (unitIds != null && unitIds.isNotEmpty) 'unitIds': unitIds.join(','),
        'page': page,
        'size': size,
      },
    );

    final raw = envelope.data;
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    return {
      'results': raw,
      'pagination': envelope.pagination?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}
