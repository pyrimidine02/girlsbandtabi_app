import 'package:freezed_annotation/freezed_annotation.dart';
import 'place_model.dart';

part 'visit_model.freezed.dart';
part 'visit_model.g.dart';

@freezed
class Visit with _$Visit {
  const factory Visit({
    required String id,
    required String userId,
    required Place place,
    required DateTime visitDate,
    String? notes,
    String? status,
    double? distanceM,
    double? accuracyM,
    String? verificationMethod,
    @Default([]) List<String> photoUrls,
  }) = _Visit;

  factory Visit.fromJson(Map<String, dynamic> json) => _$VisitFromJson(json);
}

@freezed
class VisitSummary with _$VisitSummary {
  const factory VisitSummary({
    required String placeId,
    required int totalVisits,
    DateTime? firstVisit,
    DateTime? lastVisit,
    @Default(0) int userVisits,
    int? uniqueSubjects,
    double? avgAccuracyM,
  }) = _VisitSummary;

  factory VisitSummary.fromJson(Map<String, dynamic> json) => _$VisitSummaryFromJson(json);
}
