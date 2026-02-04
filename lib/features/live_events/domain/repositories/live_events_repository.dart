/// EN: Live events repository interface.
/// KO: 라이브 이벤트 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/live_event_entities.dart';

abstract class LiveEventsRepository {
  /// EN: Get paginated live events for a project.
  /// KO: 프로젝트의 페이지네이션된 라이브 이벤트를 가져옵니다.
  Future<Result<List<LiveEventSummary>>> getLiveEvents({
    required String projectId,
    List<String> unitIds = const [],
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  });

  Future<Result<LiveEventDetail>> getLiveEventDetail({
    required String projectId,
    required String eventId,
    bool forceRefresh = false,
  });
}
