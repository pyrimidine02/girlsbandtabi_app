// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisitVerificationRequestImpl _$$VisitVerificationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$VisitVerificationRequestImpl(
  token: json['token'] as String,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  accuracyM: (json['accuracyM'] as num).toDouble(),
  clientTs: json['clientTs'] as String,
);

Map<String, dynamic> _$$VisitVerificationRequestImplToJson(
  _$VisitVerificationRequestImpl instance,
) => <String, dynamic>{
  'token': instance.token,
  'lat': instance.lat,
  'lon': instance.lon,
  'accuracyM': instance.accuracyM,
  'clientTs': instance.clientTs,
};

_$VisitVerificationResponseImpl _$$VisitVerificationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$VisitVerificationResponseImpl(
  placeId: json['placeId'] as String,
  result: json['result'] as String,
  distanceM: (json['distanceM'] as num?)?.toDouble(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$$VisitVerificationResponseImplToJson(
  _$VisitVerificationResponseImpl instance,
) => <String, dynamic>{
  'placeId': instance.placeId,
  'result': instance.result,
  'distanceM': instance.distanceM,
  'message': instance.message,
};

_$LiveEventVerificationResponseImpl
_$$LiveEventVerificationResponseImplFromJson(Map<String, dynamic> json) =>
    _$LiveEventVerificationResponseImpl(
      liveEventId: json['liveEventId'] as String,
      result: json['result'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$LiveEventVerificationResponseImplToJson(
  _$LiveEventVerificationResponseImpl instance,
) => <String, dynamic>{
  'liveEventId': instance.liveEventId,
  'result': instance.result,
  'message': instance.message,
};
