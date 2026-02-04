/// EN: Visits repository interface.
/// KO: 방문 기록 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/visit_entities.dart';

abstract class VisitsRepository {
  /// EN: Fetch a page of visit events.
  /// KO: 방문 이벤트 페이지를 가져옵니다.
  Future<Result<List<VisitEvent>>> getVisits({
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  });

  /// EN: Fetch all visit events for the user.
  /// KO: 사용자의 전체 방문 이벤트를 가져옵니다.
  Future<Result<List<VisitEvent>>> getAllVisits({
    int pageSize = 50,
    bool forceRefresh = false,
  });

  /// EN: Fetch visit summary for a place.
  /// KO: 특정 장소의 방문 요약을 가져옵니다.
  Future<Result<VisitSummary>> getVisitSummary({
    required String placeId,
    bool forceRefresh = false,
  });
}
