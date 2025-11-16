// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceSummaryImpl _$$PlaceSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PlaceSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      thumbnailFilename: json['thumbnailFilename'] as String?,
      thumbnailSize: (json['thumbnailSize'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PlaceSummaryImplToJson(_$PlaceSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'types': instance.types,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'thumbnailUrl': instance.thumbnailUrl,
      'thumbnailFilename': instance.thumbnailFilename,
      'thumbnailSize': instance.thumbnailSize,
    };

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  type: $enumDecode(_$PlaceTypeEnumMap, json['type']),
  address: json['address'] as String?,
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$PlaceTypeEnumMap[instance.type]!,
      'address': instance.address,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$PlaceTypeEnumMap = {
  PlaceType.concertVenue: 'concertVenue',
  PlaceType.cafeCollaboration: 'cafeCollaboration',
  PlaceType.animeLocation: 'animeLocation',
  PlaceType.characterShop: 'characterShop',
  PlaceType.other: 'other',
};

_$PlaceCreateRequestImpl _$$PlaceCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PlaceCreateRequestImpl(
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  type: $enumDecode(_$PlaceTypeEnumMap, json['type']),
  address: json['address'] as String?,
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$$PlaceCreateRequestImplToJson(
  _$PlaceCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'type': _$PlaceTypeEnumMap[instance.type]!,
  'address': instance.address,
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
};

_$PaginatedPlaceResponseImpl _$$PaginatedPlaceResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PaginatedPlaceResponseImpl(
  places: (json['places'] as List<dynamic>)
      .map((e) => PlaceSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$$PaginatedPlaceResponseImplToJson(
  _$PaginatedPlaceResponseImpl instance,
) => <String, dynamic>{
  'places': instance.places,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
};

_$VerificationRequestImpl _$$VerificationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$VerificationRequestImpl(
  placeId: json['placeId'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$VerificationRequestImplToJson(
  _$VerificationRequestImpl instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$VerificationResponseImpl _$$VerificationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$VerificationResponseImpl(
  verified: json['verified'] as bool,
  distance: (json['distance'] as num).toDouble(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$$VerificationResponseImplToJson(
  _$VerificationResponseImpl instance,
) => <String, dynamic>{
  'verified': instance.verified,
  'distance': instance.distance,
  'message': instance.message,
};
