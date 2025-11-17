// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceSummaryImpl _$$PlaceSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PlaceSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      introText: json['introText'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      types: json['types'] == null
          ? const <String>[]
          : _stringListFromJson(json['types']),
      regionSummary: _regionSummaryFromJson(
        json['regionSummary'] as Map<String, dynamic>?,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      thumbnailFilename: json['thumbnailFilename'] as String?,
      thumbnailSize: (json['thumbnailSize'] as num?)?.toInt(),
      type: const PlaceTypeConverter().fromJson(json['type']),
    );

Map<String, dynamic> _$$PlaceSummaryImplToJson(_$PlaceSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'introText': instance.introText,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'tags': instance.tags,
      'types': _stringListToJson(instance.types),
      'regionSummary': _regionSummaryToJson(instance.regionSummary),
      'thumbnailUrl': instance.thumbnailUrl,
      'thumbnailFilename': instance.thumbnailFilename,
      'thumbnailSize': instance.thumbnailSize,
      'type': const PlaceTypeConverter().toJson(instance.type),
    };

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  introText: json['introText'] as String?,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  types: json['types'] == null
      ? const <String>[]
      : _stringListFromJson(json['types']),
  type: const PlaceTypeConverter().fromJson(json['type']),
  address: json['address'] as String?,
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  primaryImage: _placeImageFromJson(
    json['primaryImage'] as Map<String, dynamic>?,
  ),
  images: json['images'] == null
      ? const <PlaceImage>[]
      : _placeImageListFromJson(json['images']),
  regionSummary: _regionSummaryFromJson(
    json['regionSummary'] as Map<String, dynamic>?,
  ),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'introText': instance.introText,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'types': _stringListToJson(instance.types),
      'type': const PlaceTypeConverter().toJson(instance.type),
      'address': instance.address,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
      'primaryImage': _placeImageToJson(instance.primaryImage),
      'images': _placeImageListToJson(instance.images),
      'regionSummary': _regionSummaryToJson(instance.regionSummary),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PlaceCreateRequestImpl _$$PlaceCreateRequestImplFromJson(
  Map<String, dynamic> json,
) => _$PlaceCreateRequestImpl(
  name: json['name'] as String,
  introText: json['introText'] as String?,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  types: json['types'] == null
      ? const <String>[]
      : _stringListFromJson(json['types']),
  address: json['address'] as String?,
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  unitIds:
      (json['unitIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$$PlaceCreateRequestImplToJson(
  _$PlaceCreateRequestImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'introText': instance.introText,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'types': _stringListToJson(instance.types),
  'address': instance.address,
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
  'unitIds': instance.unitIds,
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

_$RegionSummaryImpl _$$RegionSummaryImplFromJson(Map<String, dynamic> json) =>
    _$RegionSummaryImpl(
      code: json['code'] as String,
      primaryName: json['primaryName'] as String,
      path: json['path'] as String,
      level: (json['level'] as num).toInt(),
    );

Map<String, dynamic> _$$RegionSummaryImplToJson(_$RegionSummaryImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'primaryName': instance.primaryName,
      'path': instance.path,
      'level': instance.level,
    };

_$PlaceImageImpl _$$PlaceImageImplFromJson(Map<String, dynamic> json) =>
    _$PlaceImageImpl(
      imageId: json['imageId'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String?,
      contentType: json['contentType'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
      isPrimary: json['isPrimary'] as bool? ?? false,
    );

Map<String, dynamic> _$$PlaceImageImplToJson(_$PlaceImageImpl instance) =>
    <String, dynamic>{
      'imageId': instance.imageId,
      'url': instance.url,
      'filename': instance.filename,
      'contentType': instance.contentType,
      'fileSize': instance.fileSize,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'isPrimary': instance.isPrimary,
    };
