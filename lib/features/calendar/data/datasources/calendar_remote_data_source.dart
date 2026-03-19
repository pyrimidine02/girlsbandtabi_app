/// EN: Remote data source for calendar events.
/// KO: 캘린더 이벤트의 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/calendar_event_dto.dart';

/// EN: Fetches calendar events from the remote API.
/// KO: 원격 API에서 캘린더 이벤트를 조회합니다.
class CalendarRemoteDataSource {
  const CalendarRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  /// EN: Fetches events for the given year and month, optionally filtered by project.
  /// KO: 주어진 연도/월의 이벤트를 조회합니다. 프로젝트로 필터링할 수 있습니다.
  Future<Result<List<CalendarEventDto>>> fetchEvents({
    required int year,
    required int month,
    String? projectId,
  }) {
    return apiClient.get<List<CalendarEventDto>>(
      ApiEndpoints.calendarEvents,
      queryParameters: {
        'year': year,
        'month': month,
        if (projectId != null) 'projectId': projectId,
      },
      fromJson: (json) {
        // EN: Accept both a root list and an object with a named items key.
        // KO: 최상위 배열과 named items 키를 가진 객체를 모두 허용합니다.
        final List<dynamic> items;
        if (json is List) {
          items = json;
        } else if (json is Map<String, dynamic>) {
          items = (json['events'] ??
                  json['items'] ??
                  json['data'] ??
                  const <dynamic>[]) as List<dynamic>;
        } else {
          items = const <dynamic>[];
        }
        return items
            .whereType<Map<String, dynamic>>()
            .map(CalendarEventDto.fromJson)
            .toList();
      },
    );
  }
}
