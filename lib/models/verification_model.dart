import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_model.freezed.dart';
part 'verification_model.g.dart';

@freezed
class VisitVerificationRequest with _$VisitVerificationRequest {
  const factory VisitVerificationRequest({
    required String token,
    required double lat,
    required double lon,
    required double accuracyM,
    required String clientTs,
  }) = _VisitVerificationRequest;

  factory VisitVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$VisitVerificationRequestFromJson(json);
}

@freezed
class VisitVerificationResponse with _$VisitVerificationResponse {
  const factory VisitVerificationResponse({
    required String placeId,
    required String result,
    double? distanceM,
    String? message,
  }) = _VisitVerificationResponse;

  factory VisitVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$VisitVerificationResponseFromJson(json);
}

@freezed
class LiveEventVerificationResponse with _$LiveEventVerificationResponse {
  const factory LiveEventVerificationResponse({
    required String liveEventId,
    required String result,
    String? message,
  }) = _LiveEventVerificationResponse;

  factory LiveEventVerificationResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveEventVerificationResponseFromJson(json);
}
