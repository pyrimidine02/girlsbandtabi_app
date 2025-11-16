import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../entities/live_event.dart';
import '../repositories/live_events_repository.dart';

/// EN: Use case for getting a specific live event by ID
/// KO: ID로 특정 라이브 이벤트 가져오기 유스케이스
class GetLiveEventByIdUseCase {
  /// EN: Creates GetLiveEventByIdUseCase with repository
  /// KO: 리포지토리와 함께 GetLiveEventByIdUseCase 생성
  const GetLiveEventByIdUseCase(this._repository);

  final LiveEventsRepository _repository;

  /// EN: Execute the use case to get live event by ID
  /// KO: ID로 라이브 이벤트를 가져오기 위한 유스케이스 실행
  Future<Result<LiveEvent>> call(String id) async {
    if (id.isEmpty) {
      return ResultFailure(ValidationFailure.required('eventId'));
    }

    return _repository.getLiveEventById(id);
  }
}