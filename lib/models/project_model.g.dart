// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      status: json['status'] as String,
      defaultTimezone: json['defaultTimezone'] as String,
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'status': instance.status,
      'defaultTimezone': instance.defaultTimezone,
    };

_$PageResponseProjectImpl _$$PageResponseProjectImplFromJson(
  Map<String, dynamic> json,
) => _$PageResponseProjectImpl(
  items: (json['items'] as List<dynamic>)
      .map((e) => Project.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  hasNext: json['hasNext'] as bool? ?? false,
  hasPrevious: json['hasPrevious'] as bool? ?? false,
);

Map<String, dynamic> _$$PageResponseProjectImplToJson(
  _$PageResponseProjectImpl instance,
) => <String, dynamic>{
  'items': instance.items,
  'page': instance.page,
  'size': instance.size,
  'total': instance.total,
  'totalPages': instance.totalPages,
  'hasNext': instance.hasNext,
  'hasPrevious': instance.hasPrevious,
};
