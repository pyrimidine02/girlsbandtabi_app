// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveEventModelImpl _$$LiveEventModelImplFromJson(
  Map<String, dynamic> json,
) => _$LiveEventModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  eventDate: DateTime.parse(json['event_date'] as String),
  venue: json['venue'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  units:
      (json['units'] as List<dynamic>?)
          ?.map((e) => LiveEventUnitModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  bands:
      (json['bands'] as List<dynamic>?)
          ?.map((e) => LiveEventBandModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => LiveEventPhotoModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ticketUrl: json['ticket_url'] as String?,
  price: json['price'] as String?,
  status:
      $enumDecodeNullable(_$LiveEventStatusEnumMap, json['status']) ??
      LiveEventStatus.scheduled,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isFavorite: json['is_favorite'] as bool? ?? false,
  attendeeCount: (json['attendee_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$LiveEventModelImplToJson(
  _$LiveEventModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'event_date': instance.eventDate.toIso8601String(),
  'venue': instance.venue,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'units': instance.units,
  'bands': instance.bands,
  'photos': instance.photos,
  'ticket_url': instance.ticketUrl,
  'price': instance.price,
  'status': _$LiveEventStatusEnumMap[instance.status]!,
  'tags': instance.tags,
  'is_favorite': instance.isFavorite,
  'attendee_count': instance.attendeeCount,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$LiveEventStatusEnumMap = {
  LiveEventStatus.scheduled: 'scheduled',
  LiveEventStatus.live: 'live',
  LiveEventStatus.completed: 'completed',
  LiveEventStatus.cancelled: 'cancelled',
};

_$LiveEventUnitModelImpl _$$LiveEventUnitModelImplFromJson(
  Map<String, dynamic> json,
) => _$LiveEventUnitModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$$LiveEventUnitModelImplToJson(
  _$LiveEventUnitModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'avatar_url': instance.avatarUrl,
};

_$LiveEventBandModelImpl _$$LiveEventBandModelImplFromJson(
  Map<String, dynamic> json,
) => _$LiveEventBandModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  setTime: json['set_time'] == null
      ? null
      : DateTime.parse(json['set_time'] as String),
);

Map<String, dynamic> _$$LiveEventBandModelImplToJson(
  _$LiveEventBandModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'avatar_url': instance.avatarUrl,
  'set_time': instance.setTime?.toIso8601String(),
};

_$LiveEventPhotoModelImpl _$$LiveEventPhotoModelImplFromJson(
  Map<String, dynamic> json,
) => _$LiveEventPhotoModelImpl(
  id: json['id'] as String,
  url: json['url'] as String,
  caption: json['caption'] as String?,
  uploadedBy: json['uploaded_by'] as String?,
  uploadedAt: json['uploaded_at'] == null
      ? null
      : DateTime.parse(json['uploaded_at'] as String),
);

Map<String, dynamic> _$$LiveEventPhotoModelImplToJson(
  _$LiveEventPhotoModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'caption': instance.caption,
  'uploaded_by': instance.uploadedBy,
  'uploaded_at': instance.uploadedAt?.toIso8601String(),
};
