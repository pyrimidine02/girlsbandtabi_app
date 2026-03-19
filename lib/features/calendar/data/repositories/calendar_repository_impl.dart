/// EN: Concrete implementation of [CalendarRepository].
/// KO: [CalendarRepository]의 구체적인 구현체.
library;

import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_data_source.dart';

/// EN: Implements [CalendarRepository] by delegating to the remote data source.
/// KO: 원격 데이터 소스에 위임하여 [CalendarRepository]를 구현합니다.
class CalendarRepositoryImpl implements CalendarRepository {
  const CalendarRepositoryImpl({required this.remoteDataSource});

  final CalendarRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<CalendarEvent>>> fetchEvents({
    required int year,
    required int month,
    String? projectId,
  }) async {
    try {
      final result = await remoteDataSource.fetchEvents(
        year: year,
        month: month,
        projectId: projectId,
      );
      return result.map((dtos) {
        // EN: Map DTOs to domain entities and sort ascending by date.
        // KO: DTO를 도메인 엔티티로 매핑하고 날짜 오름차순으로 정렬합니다.
        final entities = dtos.map((dto) => dto.toEntity()).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        return entities;
      });
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }
}
