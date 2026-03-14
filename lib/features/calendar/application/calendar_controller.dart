/// EN: Riverpod providers for calendar events.
/// KO: 캘린더 이벤트를 위한 Riverpod 프로바이더.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/calendar_remote_data_source.dart';
import '../data/repositories/calendar_repository_impl.dart';
import '../domain/entities/calendar_event.dart';
import '../domain/repositories/calendar_repository.dart';

/// EN: Provides a [CalendarRepository] backed by the shared [ApiClient].
/// KO: 공유 [ApiClient]를 사용하는 [CalendarRepository]를 제공합니다.
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CalendarRepositoryImpl(
    remoteDataSource: CalendarRemoteDataSource(apiClient: apiClient),
  );
});

/// EN: Query parameters for fetching calendar events.
/// KO: 캘린더 이벤트 조회 쿼리 파라미터.
typedef CalendarEventsQuery = ({int year, int month, String? projectId});

/// EN: Family provider — loads events for a specific year/month.
/// EN: Returns an empty list on failure so the UI stays functional.
/// KO: Family 프로바이더 — 특정 연도/월의 이벤트를 로드합니다.
/// KO: 실패 시 빈 목록을 반환해 UI 동작을 유지합니다.
final calendarEventsProvider = FutureProvider.autoDispose
    .family<List<CalendarEvent>, CalendarEventsQuery>((ref, query) async {
  final repo = ref.watch(calendarRepositoryProvider);
  final result = await repo.fetchEvents(
    year: query.year,
    month: query.month,
    projectId: query.projectId,
  );
  return result.when(
    success: (events) => events,
    failure: (_) => const <CalendarEvent>[],
  );
});
