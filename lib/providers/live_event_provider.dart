import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../models/live_event_model.dart';
import '../services/live_event_service.dart';
import 'content_filter_provider.dart';

final liveEventServiceProvider = Provider<LiveEventService>((ref) => LiveEventService());

enum LiveTab { upcoming, ongoing, past }

final liveTabProvider = StateProvider<LiveTab>((ref) => LiveTab.upcoming);

final liveEventsProvider = FutureProvider.autoDispose<PageResponseLiveEvent>((ref) async {
  final service = ref.watch(liveEventServiceProvider);
  final projectCode = ref.watch(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
  final bandId = ref.watch(selectedBandProvider);
  final tab = ref.watch(liveTabProvider);
  String? statusParam;
  switch (tab) {
    case LiveTab.upcoming:
      statusParam = 'UPCOMING';
      break;
    case LiveTab.ongoing:
      statusParam = 'ONGOING';
      break;
    case LiveTab.past:
      statusParam = 'COMPLETED';
      break;
  }

  return service.getLiveEvents(
    projectId: projectCode,
    unitIds: bandId != null ? [bandId] : null,
    status: statusParam,
    page: 0,
    size: 20,
    sort: 'startTime,asc',
  );
});
