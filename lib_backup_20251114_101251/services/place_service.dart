import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
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

    final rawList = envelope.requireDataAsList();
    final places = rawList
        .whereType<Map<String, dynamic>>()
        .map(PlaceSummary.fromJson)
        .toList(growable: false);
    final pagination = envelope.pagination;

    return PaginatedPlaceResponse(
      places: places,
      total: pagination?.totalItems ?? places.length,
      page: pagination?.currentPage ?? page,
      limit: pagination?.pageSize ?? size,
    );
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

    final rawList = envelope.requireDataAsList();
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(PlaceSummary.fromJson)
        .toList(growable: false);
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

    final rawList = envelope.requireDataAsList();
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(PlaceSummary.fromJson)
        .toList(growable: false);
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