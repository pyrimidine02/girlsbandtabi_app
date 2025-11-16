import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/live_event_model.dart';
import '../models/verification_model.dart';

class LiveEventService {
  LiveEventService();

  final ApiClient _api = ApiClient.instance;

  Future<PageResponseLiveEvent> getLiveEvents({
    required String projectId,
    List<String>? unitIds,
    String? from,
    String? to,
    String? status,
    int page = 0,
    int size = 10,
    String? sort,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (sort != null) 'sort': sort,
      if (unitIds != null && unitIds.isNotEmpty) 'unitIds': unitIds.join(','),
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (status != null) 'status': status,
    };

    final envelope = await _api.get(
      ApiConstants.liveEvents(projectId),
      queryParameters: query,
    );

    final raw = envelope.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic>
            ? (raw['items'] as List?) ?? const <dynamic>[]
            : const <dynamic>[]);

    final events = list
        .whereType<Map<String, dynamic>>()
        .map(LiveEvent.fromJson)
        .toList(growable: false);
    final pagination = envelope.pagination;

    return PageResponseLiveEvent(
      items: events,
      page: pagination?.currentPage ?? page,
      size: pagination?.pageSize ?? size,
      total: pagination?.totalItems ?? events.length,
      totalPages: pagination?.totalPages,
      hasNext: pagination?.hasNext ?? false,
      hasPrevious: pagination?.hasPrevious ?? false,
    );
  }

  Future<LiveEvent> getLiveEventDetail({
    required String projectId,
    required String eventId,
  }) async {
    final envelope = await _api.get(
      ApiConstants.liveEventDetail(projectId, eventId),
    );
    return LiveEvent.fromJson(envelope.requireDataAsMap());
  }

  Future<LiveEventVerificationResponse> verifyLiveEvent({
    required String projectId,
    required String eventId,
    required String token,
  }) async {
    final envelope = await _api.post(
      ApiConstants.liveEventVerification(projectId, eventId),
      data: {'token': token},
    );
    return LiveEventVerificationResponse.fromJson(
      envelope.requireDataAsMap(),
    );
  }

  Future<LiveEvent> createLiveEvent({
    required String projectId,
    required String title,
    String? description,
    required DateTime startTime,
    DateTime? endTime,
    String? placeId,
    List<String>? unitIds,
  }) async {
    final envelope = await _api.post(
      ApiConstants.liveEvents(projectId),
      data: {
        'title': title,
        if (description != null) 'description': description,
        'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        if (placeId != null) 'placeId': placeId,
        if (unitIds != null) 'unitIds': unitIds,
      },
    );
    return LiveEvent.fromJson(envelope.requireDataAsMap());
  }

  Future<LiveEvent> updateLiveEvent({
    required String projectId,
    required String eventId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? placeId,
    List<String>? unitIds,
    String? status,
  }) async {
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (startTime != null) 'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime.toIso8601String(),
      if (placeId != null) 'placeId': placeId,
      if (unitIds != null) 'unitIds': unitIds,
      if (status != null) 'status': status,
    };

    final envelope = await _api.put(
      ApiConstants.liveEventDetail(projectId, eventId),
      data: payload,
    );
    return LiveEvent.fromJson(envelope.requireDataAsMap());
  }

  Future<void> deleteLiveEvent({
    required String projectId,
    required String eventId,
  }) async {
    await _api.delete(ApiConstants.liveEventDetail(projectId, eventId));
  }
}
