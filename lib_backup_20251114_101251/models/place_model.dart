import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_model.freezed.dart';
part 'place_model.g.dart';

enum PlaceType {
  concertVenue,
  cafeCollaboration,
  animeLocation,
  characterShop,
  other,
}

@freezed
class PlaceSummary with _$PlaceSummary {
  const factory PlaceSummary({
    required String id,
    required String name,
    required String type,
    required List<String> types,
    required double latitude,
    required double longitude,
    String? thumbnailUrl,
    String? thumbnailFilename,
    int? thumbnailSize,
  }) = _PlaceSummary;

  factory PlaceSummary.fromJson(Map<String, dynamic> json) => _$PlaceSummaryFromJson(json);
}

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required PlaceType type,
    String? address,
    String? imageUrl,
    @Default(<String>[]) List<String> tags,
    DateTime? createdAt,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}

@freezed
class PlaceCreateRequest with _$PlaceCreateRequest {
  const factory PlaceCreateRequest({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required PlaceType type,
    String? address,
    String? imageUrl,
    @Default(<String>[]) List<String> tags,
  }) = _PlaceCreateRequest;

  factory PlaceCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceCreateRequestFromJson(json);
}

@freezed
class PaginatedPlaceResponse with _$PaginatedPlaceResponse {
  const factory PaginatedPlaceResponse({
    required List<PlaceSummary> places,
    required int total,
    required int page,
    required int limit,
  }) = _PaginatedPlaceResponse;

  factory PaginatedPlaceResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedPlaceResponseFromJson(json);
}

@freezed
class VerificationRequest with _$VerificationRequest {
  const factory VerificationRequest({
    required String placeId,
    required double latitude,
    required double longitude,
  }) = _VerificationRequest;

  factory VerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$VerificationRequestFromJson(json);
}

@freezed
class VerificationResponse with _$VerificationResponse {
  const factory VerificationResponse({
    required bool verified,
    required double distance,
    String? message,
  }) = _VerificationResponse;

  factory VerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$VerificationResponseFromJson(json);
}