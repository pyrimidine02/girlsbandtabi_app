// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VisitImpl _$$VisitImplFromJson(Map<String, dynamic> json) => _$VisitImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  place: Place.fromJson(json['place'] as Map<String, dynamic>),
  visitDate: DateTime.parse(json['visitDate'] as String),
  notes: json['notes'] as String?,
  status: json['status'] as String?,
  distanceM: (json['distanceM'] as num?)?.toDouble(),
  accuracyM: (json['accuracyM'] as num?)?.toDouble(),
  verificationMethod: json['verificationMethod'] as String?,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$VisitImplToJson(_$VisitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'place': instance.place,
      'visitDate': instance.visitDate.toIso8601String(),
      'notes': instance.notes,
      'status': instance.status,
      'distanceM': instance.distanceM,
      'accuracyM': instance.accuracyM,
      'verificationMethod': instance.verificationMethod,
      'photoUrls': instance.photoUrls,
    };

_$VisitSummaryImpl _$$VisitSummaryImplFromJson(Map<String, dynamic> json) =>
    _$VisitSummaryImpl(
      placeId: json['placeId'] as String,
      totalVisits: (json['totalVisits'] as num).toInt(),
      firstVisit: json['firstVisit'] == null
          ? null
          : DateTime.parse(json['firstVisit'] as String),
      lastVisit: json['lastVisit'] == null
          ? null
          : DateTime.parse(json['lastVisit'] as String),
      userVisits: (json['userVisits'] as num?)?.toInt() ?? 0,
      uniqueSubjects: (json['uniqueSubjects'] as num?)?.toInt(),
      avgAccuracyM: (json['avgAccuracyM'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$VisitSummaryImplToJson(_$VisitSummaryImpl instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'totalVisits': instance.totalVisits,
      'firstVisit': instance.firstVisit?.toIso8601String(),
      'lastVisit': instance.lastVisit?.toIso8601String(),
      'userVisits': instance.userVisits,
      'uniqueSubjects': instance.uniqueSubjects,
      'avgAccuracyM': instance.avgAccuracyM,
    };
