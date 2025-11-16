import '../../../../core/utils/result.dart';
import '../entities/live_event.dart';
import '../repositories/live_events_repository.dart';

/// EN: Use case for getting live events list
/// KO: 라이브 이벤트 목록 가져오기 유스케이스
class GetLiveEventsUseCase {
  /// EN: Creates GetLiveEventsUseCase with repository
  /// KO: 리포지토리와 함께 GetLiveEventsUseCase 생성
  const GetLiveEventsUseCase(this._repository);

  final LiveEventsRepository _repository;

  /// EN: Execute the use case to get live events
  /// KO: 라이브 이벤트를 가져오기 위한 유스케이스 실행
  Future<Result<List<LiveEvent>>> call(GetLiveEventsParams params) async {
    return _repository.getLiveEvents(params);
  }
}