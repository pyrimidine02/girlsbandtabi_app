import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_envelope.dart';
import '../models/place_model.dart';
import '../models/verification_model.dart';

class PlaceService {
  PlaceService();

  final ApiClient _apiClient = ApiClient.instance;

  Future<PaginatedPlaceResponse> getPlaces({
    required String projectId,
    int page = 0,
    int size = 20,
    String? sort,
    List<String>? unitIds,
    bool includeShared = false,
  }) async {
    final envelope = await _apiClient.get(
      ApiConstants.places(projectId),
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
        if (unitIds != null && unitIds.isNotEmpty) 'unitIds': unitIds.join(','),
        if (includeShared) 'includeShared': includeShared,
      },
    );

    final payload = _parsePaginatedPlaces(envelope, fallbackPage: page, fallbackSize: size);
    return payload;
  }

  Future<Place> getPlaceDetail({
    required String projectId,
    required String placeId,
  }) async {
    final envelope = await _apiClient.get(
      ApiConstants.placeDetail(projectId, placeId),
    );
    final data = envelope.requireDataAsMap();
    return Place.fromJson(data);
  }

  Future<Place> createPlace({
    required String projectId,
    required PlaceCreateRequest request,
  }) async {
    final envelope = await _apiClient.post(
      ApiConstants.places(projectId),
      data: request.toJson(),
    );
    final data = envelope.requireDataAsMap();
    return Place.fromJson(data);
  }

  Future<Place> updatePlace({
    required String projectId,
    required String placeId,
    required PlaceCreateRequest request,
  }) async {
    final envelope = await _apiClient.put(
      ApiConstants.placeDetail(projectId, placeId),
      data: request.toJson(),
    );
    final data = envelope.requireDataAsMap();
    return Place.fromJson(data);
  }

  Future<void> deletePlace({
    required String projectId,
    required String placeId,
  }) async {
    await _apiClient.delete(
      ApiConstants.placeDetail(projectId, placeId),
    );
  }

  Future<List<PlaceSummary>> getNearbyPlaces({
    required String projectId,
    required double lat,
    required double lon,
    required double radius,
  }) async {
    final envelope = await _apiClient.get(
      ApiConstants.nearbyPlaces(projectId),
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'radius': radius,
      },
    );

    return _extractPlaceSummaries(envelope.data);
  }

  Future<List<PlaceSummary>> getPlacesWithinBounds({
    required String projectId,
    required double north,
    required double south,
    required double east,
    required double west,
  }) async {
    final envelope = await _apiClient.get(
      ApiConstants.placesWithinBounds(projectId),
      queryParameters: {
        'north': north,
        'south': south,
        'east': east,
        'west': west,
      },
    );

    return _extractPlaceSummaries(envelope.data);
  }

  Future<VisitVerificationResponse> verifyVisit({
    required String projectId,
    required String placeId,
    required String token,
  }) async {
    final envelope = await _apiClient.post(
      ApiConstants.placeVerification(projectId, placeId),
      data: {'token': token},
    );
    final data = envelope.requireDataAsMap();
    return VisitVerificationResponse.fromJson(data);
  }
}

PaginatedPlaceResponse _parsePaginatedPlaces(
  ApiEnvelope envelope, {
  required int fallbackPage,
  required int fallbackSize,
}) {
  final data = envelope.data;
  final items = _extractItems(data);
  final places = items
      .whereType<Map<String, dynamic>>()
      .map(PlaceSummary.fromJson)
      .toList(growable: false);

  final dataMap = data is Map<String, dynamic> ? data : null;
  final total = envelope.pagination?.totalItems ??
      (dataMap?['totalItems'] as num?)?.toInt() ??
      (dataMap?['total'] as num?)?.toInt() ??
      places.length;
  final page = envelope.pagination?.currentPage ??
      (dataMap?['currentPage'] as num?)?.toInt() ??
      (dataMap?['page'] as num?)?.toInt() ??
      fallbackPage;
  final limit = envelope.pagination?.pageSize ??
      (dataMap?['pageSize'] as num?)?.toInt() ??
      (dataMap?['size'] as num?)?.toInt() ??
      fallbackSize;

  return PaginatedPlaceResponse(
    places: places,
    total: total,
    page: page,
    limit: limit,
  );
}

List<PlaceSummary> _extractPlaceSummaries(dynamic raw) {
  final items = _extractItems(raw);
  return items
      .whereType<Map<String, dynamic>>()
      .map(PlaceSummary.fromJson)
      .toList(growable: false);
}

List<dynamic> _extractItems(dynamic raw) {
  if (raw is List) return raw;
  if (raw is Map<String, dynamic>) {
    final candidates = [
      raw['items'],
      raw['places'],
      raw['data'],
      raw['content'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }
  }
  return const <dynamic>[];
}
