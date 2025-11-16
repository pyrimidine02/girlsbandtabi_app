import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AdminService {
  AdminService();

  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>?> getHealth() async {
    try {
      final envelope = await _api.get(
        ApiConstants.health,
        expectEnvelope: false,
      );
      final data = envelope.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInfo() async {
    try {
      final envelope = await _api.get(
        ApiConstants.info,
        expectEnvelope: false,
      );
      final data = envelope.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getPlaceVisits({
    required String projectId,
    required String placeId,
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminPlaceVisits(projectId, placeId),
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getPlaceVisitSummary({
    required String projectId,
    required String placeId,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminPlaceVisitsSummary(projectId, placeId),
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getPlaceVisitAnomalies({
    required String projectId,
    required String placeId,
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminPlaceVisitsAnomalies(projectId, placeId),
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> moderatePlaceVisit({
    required String projectId,
    required String placeId,
    required String visitId,
    required String action,
    String? reason,
    String? note,
  }) async {
    final envelope = await _api.post(
      ApiConstants.adminPlaceVisitModeration(projectId, placeId, visitId),
      data: {
        'action': action,
        if (reason != null) 'reason': reason,
        if (note != null) 'note': note,
      },
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> replacePlaceUnits({
    required String projectId,
    required String placeId,
    required List<String> unitIds,
  }) async {
    final envelope = await _api.post(
      ApiConstants.adminPlaceUnitsReplace(projectId, placeId),
      data: {'unitIds': unitIds},
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> replaceNewsUnits({
    required String projectId,
    required String newsId,
    required List<String> unitIds,
  }) async {
    final envelope = await _api.post(
      ApiConstants.adminNewsUnitsReplace(projectId, newsId),
      data: {'unitIds': unitIds},
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> replaceLiveEventUnits({
    required String projectId,
    required String liveEventId,
    required List<String> unitIds,
  }) async {
    final envelope = await _api.post(
      ApiConstants.adminLiveEventUnitsReplace(projectId, liveEventId),
      data: {'unitIds': unitIds},
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getAdminLiveEvents({
    required String projectId,
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminLiveEvents(projectId),
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getAdminUsers({
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminUsers,
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    final envelope = await _api.post(
      ApiConstants.adminUserRole(userId),
      data: {'role': role},
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> revokeToken(String jti) async {
    final envelope = await _api.post(
      ApiConstants.adminTokensRevoke,
      data: {'jti': jti},
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final envelope = await _api.get(ApiConstants.adminDashboard);
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getAuditLogs({
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminAuditLogs,
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<List<dynamic>> getInsightsProjects() async {
    final envelope = await _api.get(ApiConstants.adminInsightsProjects);
    final data = envelope.data;
    if (data is List) return List<dynamic>.from(data);
    if (data is Map<String, dynamic>) {
      final items = (data['items'] as List?) ?? const <dynamic>[];
      return List<dynamic>.from(items);
    }
    return const <dynamic>[];
  }

  Future<List<dynamic>> getInsightsProjectUnits(
    String projectId, {
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminInsightsProjectUnits(projectId),
      queryParameters: filters,
    );
    final data = envelope.data;
    if (data is List) return List<dynamic>.from(data);
    if (data is Map<String, dynamic>) {
      final items = (data['items'] as List?) ?? const <dynamic>[];
      return List<dynamic>.from(items);
    }
    return const <dynamic>[];
  }

  Future<Map<String, dynamic>> createExport(Map<String, dynamic> payload) async {
    final envelope = await _api.post(
      ApiConstants.adminExports,
      data: payload,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getExport(String exportId) async {
    final envelope = await _api.get(
      ApiConstants.adminExport(exportId),
    );
    return envelope.requireDataAsMap();
  }

  Future<List<int>> downloadExport(String exportId) async {
    final response = await _api.getRaw<List<int>>(
      ApiConstants.adminExportDownload(exportId),
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
      queryParameters: null,
    );
    return response.data ?? const <int>[];
  }

  Future<Response<ResponseBody>> streamAdminEvents() {
    return _api.getRaw<ResponseBody>(
      ApiConstants.adminEventsStream,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );
  }

  Future<Map<String, dynamic>> getAnalyticsVisitsByPlace({
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminAnalyticsVisitsByPlace,
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getAnalyticsVisitsTimeseries({
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminAnalyticsVisitsTimeseries,
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<Map<String, dynamic>> getMediaDeletionRequests({
    Map<String, dynamic>? filters,
  }) async {
    final envelope = await _api.get(
      ApiConstants.adminMediaDeletions,
      queryParameters: filters,
    );
    return envelope.requireDataAsMap();
  }

  Future<void> approveMediaDeletion(String requestId) async {
    await _api.post(ApiConstants.adminMediaDeletionApprove(requestId));
  }

  Future<void> rejectMediaDeletion(String requestId) async {
    await _api.post(ApiConstants.adminMediaDeletionReject(requestId));
  }
}
