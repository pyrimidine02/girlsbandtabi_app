/// EN: Remote data source for unified search.
/// KO: 통합 검색 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/search_item_dto.dart';

class SearchRemoteDataSource {
  SearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<List<SearchItemDto>>> search({required String query}) {
    return _apiClient.get<List<SearchItemDto>>(
      ApiEndpoints.search,
      queryParameters: {
        'q': query,
      },
      fromJson: (json) {
        if (json is List) {
          return json
              .whereType<Map<String, dynamic>>()
              .map(SearchItemDto.fromJson)
              .toList();
        }
        if (json is Map<String, dynamic>) {
          final items = json['items'] ?? json['results'] ?? json['data'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(SearchItemDto.fromJson)
                .toList();
          }
        }
        return <SearchItemDto>[];
      },
    );
  }
}
