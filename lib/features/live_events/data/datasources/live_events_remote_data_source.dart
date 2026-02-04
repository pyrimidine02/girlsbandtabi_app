/// EN: Remote data source for live events API.
/// KO: 라이브 이벤트 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/live_event_dto.dart';

class LiveEventsRemoteDataSource {
  LiveEventsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Fetch paginated live events for a project.
  /// KO: 프로젝트의 페이지네이션된 라이브 이벤트를 조회합니다.
  Future<Result<List<LiveEventSummaryDto>>> fetchLiveEvents({
    required String projectId,
    List<String> unitIds = const [],
    int page = ApiPagination.defaultPage,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<LiveEventSummaryDto>>(
      ApiEndpoints.liveEvents(projectId),
      queryParameters: {
        'page': page,
        'size': size,
        if (unitIds.isNotEmpty) 'unitIds': unitIds,
      },
      fromJson: (json) => _decodeLiveEventList(json),
    );
  }

  /// EN: Fetch live event detail.
  /// KO: 라이브 이벤트 상세를 조회합니다.
  Future<Result<LiveEventDetailDto>> fetchLiveEventDetail({
    required String projectId,
    required String eventId,
  }) {
    return _apiClient.get<LiveEventDetailDto>(
      ApiEndpoints.liveEvent(projectId, eventId),
      fromJson: (json) =>
          LiveEventDetailDto.fromJson(json as Map<String, dynamic>),
    );
  }
}

List<LiveEventSummaryDto> _decodeLiveEventList(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map<String, dynamic>>()
        .map(LiveEventSummaryDto.fromJson)
        .toList();
  }
  if (json is Map<String, dynamic>) {
    const listKeys = ['items', 'content', 'data', 'results'];
    for (final key in listKeys) {
      final value = json[key];
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map(LiveEventSummaryDto.fromJson)
            .toList();
      }
    }
  }
  return <LiveEventSummaryDto>[];
}
