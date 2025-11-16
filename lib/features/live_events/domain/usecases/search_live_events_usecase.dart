import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../entities/live_event.dart';
import '../repositories/live_events_repository.dart';

/// EN: Use case for searching live events
/// KO: 라이브 이벤트 검색 유스케이스
class SearchLiveEventsUseCase {
  /// EN: Creates SearchLiveEventsUseCase with repository
  /// KO: 리포지토리와 함께 SearchLiveEventsUseCase 생성
  const SearchLiveEventsUseCase(this._repository);

  final LiveEventsRepository _repository;

  /// EN: Execute the use case to search live events
  /// KO: 라이브 이벤트 검색을 위한 유스케이스 실행
  Future<Result<List<LiveEvent>>> call(SearchLiveEventsParams params) async {
    if (params.query.trim().isEmpty) {
      return ResultFailure(ValidationFailure.required('query'));
    }

    return _repository.searchLiveEvents(params);
  }
}