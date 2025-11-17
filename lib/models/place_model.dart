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
    String? introText,
    required double latitude,
    required double longitude,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'types', fromJson: _stringListFromJson, toJson: _stringListToJson)
    @Default(<String>[])
    List<String> types,
    @JsonKey(fromJson: _regionSummaryFromJson, toJson: _regionSummaryToJson)
    RegionSummary? regionSummary,
    String? thumbnailUrl,
    String? thumbnailFilename,
    int? thumbnailSize,
    @PlaceTypeConverter()
    required PlaceType type,
  }) = _PlaceSummary;

  factory PlaceSummary.fromJson(Map<String, dynamic> json) =>
      _$PlaceSummaryFromJson(_normalizePlaceJson(json));
}

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    String? introText,
    required String description,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'types', fromJson: _stringListFromJson, toJson: _stringListToJson)
    @Default(<String>[])
    List<String> types,
    @PlaceTypeConverter()
    required PlaceType type,
    String? address,
    String? imageUrl,
    @Default(<String>[]) List<String> tags,
    @JsonKey(fromJson: _placeImageFromJson, toJson: _placeImageToJson)
    PlaceImage? primaryImage,
    @JsonKey(fromJson: _placeImageListFromJson, toJson: _placeImageListToJson)
    @Default(<PlaceImage>[]) List<PlaceImage> images,
    @JsonKey(fromJson: _regionSummaryFromJson, toJson: _regionSummaryToJson)
    RegionSummary? regionSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) =>
      _$PlaceFromJson(_normalizePlaceJson(json));
}

@freezed
class PlaceCreateRequest with _$PlaceCreateRequest {
  const factory PlaceCreateRequest({
    required String name,
    String? introText,
    required String description,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'types', fromJson: _stringListFromJson, toJson: _stringListToJson)
    @Default(<String>[])
    List<String> types,
    String? address,
    String? imageUrl,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> unitIds,
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

/// EN: Utility for mapping between API place type strings and enums.
/// KO: API 장소 타입 문자열과 enum 간 매핑을 위한 유틸리티입니다.
class PlaceTypeCodec {
  static const Map<PlaceType, String> _apiValues = {
    PlaceType.concertVenue: 'concert_venue',
    PlaceType.cafeCollaboration: 'cafe_collaboration',
    PlaceType.animeLocation: 'anime_location',
    PlaceType.characterShop: 'character_shop',
    PlaceType.other: 'other',
  };

  static PlaceType fromJson(dynamic raw) {
    if (raw == null) return PlaceType.other;
    final value = raw.toString().trim();
    if (value.isEmpty) return PlaceType.other;
    final normalized = _normalize(value);
    if (normalized.isEmpty) return PlaceType.other;
    switch (normalized) {
      case 'concert_venue':
      case 'livehouse':
      case 'live_house':
        return PlaceType.concertVenue;
      case 'cafe_collaboration':
      case 'collaboration_cafe':
      case 'cafe':
      case 'cafe_event':
        return PlaceType.cafeCollaboration;
      case 'anime_location':
      case 'filming_location':
      case 'shooting_location':
      case 'real_location':
      case 'seichi':
        return PlaceType.animeLocation;
      case 'character_shop':
      case 'shop':
      case 'store':
      case 'merch_store':
        return PlaceType.characterShop;
      default:
        return PlaceType.other;
    }
  }

  static String toJson(PlaceType type) {
    return _apiValues[type] ?? 'other';
  }

  static String _normalize(String input) {
    final camelCaseNormalized = input.replaceAllMapped(
      RegExp('([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    );
    return camelCaseNormalized
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
}

/// EN: JsonConverter for a single PlaceType.
/// KO: 단일 PlaceType을 위한 JsonConverter 입니다.
class PlaceTypeConverter extends JsonConverter<PlaceType, dynamic> {
  const PlaceTypeConverter();

  @override
  PlaceType fromJson(dynamic json) => PlaceTypeCodec.fromJson(json);

  @override
  dynamic toJson(PlaceType object) => PlaceTypeCodec.toJson(object);
}

@freezed
class RegionSummary with _$RegionSummary {
  const factory RegionSummary({
    required String code,
    required String primaryName,
    required String path,
    required int level,
  }) = _RegionSummary;

  factory RegionSummary.fromJson(Map<String, dynamic> json) =>
      _$RegionSummaryFromJson(json);
}

@freezed
class PlaceImage with _$PlaceImage {
  const factory PlaceImage({
    required String imageId,
    required String url,
    String? filename,
    String? contentType,
    int? fileSize,
    DateTime? uploadedAt,
    @Default(false) bool isPrimary,
  }) = _PlaceImage;

  factory PlaceImage.fromJson(Map<String, dynamic> json) =>
      _$PlaceImageFromJson(json);
}

Map<String, dynamic> _normalizePlaceJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  if (!normalized.containsKey('type') || normalized['type'] == null) {
    final types = normalized['types'];
    if (types is List && types.isNotEmpty) {
      normalized['type'] = types.first;
    }
  }
  if (!normalized.containsKey('imageUrl') || normalized['imageUrl'] == null) {
    final primaryImage = normalized['primaryImage'];
    if (primaryImage is Map<String, dynamic> &&
        primaryImage['url'] != null) {
      normalized['imageUrl'] = primaryImage['url'];
    }
  }
  return normalized;
}

List<String> _stringListFromJson(dynamic raw) {
  if (raw is List) {
    return raw
        .map((e) => e?.toString())
        .whereType<String>()
        .toList(growable: false);
  }
  if (raw is String && raw.isNotEmpty) {
    return [raw];
  }
  return const <String>[];
}

List<String> _stringListToJson(List<String> values) => values;

RegionSummary? _regionSummaryFromJson(Map<String, dynamic>? json) =>
    json == null ? null : RegionSummary.fromJson(json);

Map<String, dynamic>? _regionSummaryToJson(RegionSummary? region) =>
    region?.toJson();

PlaceImage? _placeImageFromJson(Map<String, dynamic>? json) =>
    json == null ? null : PlaceImage.fromJson(json);

Map<String, dynamic>? _placeImageToJson(PlaceImage? image) => image?.toJson();

List<PlaceImage> _placeImageListFromJson(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(PlaceImage.fromJson)
        .toList(growable: false);
  }
  return const <PlaceImage>[];
}

List<Map<String, dynamic>> _placeImageListToJson(List<PlaceImage> images) =>
    images.map((e) => e.toJson()).toList(growable: false);
