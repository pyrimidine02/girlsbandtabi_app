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
    @PlaceTypeConverter()
    required PlaceType type,
    @PlaceTypeListConverter()
    @Default(<PlaceType>[])
    List<PlaceType> types,
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
    @PlaceTypeConverter()
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
    @PlaceTypeConverter()
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

  static List<PlaceType> fromJsonList(dynamic raw) {
    if (raw is List) {
      return raw.map(fromJson).toList(growable: false);
    }
    if (raw is String) {
      return [fromJson(raw)];
    }
    return const <PlaceType>[];
  }

  static String toJson(PlaceType type) {
    return _apiValues[type] ?? 'other';
  }

  static List<String> toJsonList(List<PlaceType> types) {
    return types.map(toJson).toList(growable: false);
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

/// EN: JsonConverter for PlaceType lists.
/// KO: PlaceType 목록을 위한 JsonConverter 입니다.
class PlaceTypeListConverter extends JsonConverter<List<PlaceType>, dynamic> {
  const PlaceTypeListConverter();

  @override
  List<PlaceType> fromJson(dynamic json) => PlaceTypeCodec.fromJsonList(json);

  @override
  dynamic toJson(List<PlaceType> object) => PlaceTypeCodec.toJsonList(object);
}
