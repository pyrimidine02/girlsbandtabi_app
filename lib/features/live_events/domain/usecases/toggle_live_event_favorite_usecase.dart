import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../entities/live_event.dart';
import '../repositories/live_events_repository.dart';

/// EN: Use case for toggling live event favorite status
/// KO: 라이브 이벤트 즐겨찾기 상태 토글 유스케이스
class ToggleLiveEventFavoriteUseCase {
  /// EN: Creates ToggleLiveEventFavoriteUseCase with repository
  /// KO: 리포지토리와 함께 ToggleLiveEventFavoriteUseCase 생성
  const ToggleLiveEventFavoriteUseCase(this._repository);

  final LiveEventsRepository _repository;

  /// EN: Execute the use case to toggle live event favorite
  /// KO: 라이브 이벤트 즐겨찾기 토글을 위한 유스케이스 실행
  Future<Result<LiveEvent>> call(ToggleLiveEventFavoriteParams params) async {
    if (params.eventId.isEmpty) {
      return ResultFailure(ValidationFailure.required('eventId'));
    }

    return _repository.toggleFavorite(params);
  }
}