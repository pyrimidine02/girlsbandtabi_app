/// EN: Verification DTOs for check-in/attendance.
/// KO: 방문/참석 인증 DTO.
library;

class VerificationConfigDto {
  const VerificationConfigDto({
    required this.jweAlg,
    required this.jwsAlg,
    required this.publicKeys,
    required this.toleranceMeters,
    required this.timeSkewSec,
  });

  final String jweAlg;
  final String jwsAlg;
  final List<String> publicKeys;
  final int toleranceMeters;
  final int timeSkewSec;

  factory VerificationConfigDto.fromJson(Map<String, dynamic> json) {
    return VerificationConfigDto(
      jweAlg: _string(json, ['jweAlg']) ?? '',
      jwsAlg: _string(json, ['jwsAlg']) ?? '',
      publicKeys: _stringList(json, ['publicKeys']),
      toleranceMeters: _int(json, ['toleranceMeters']) ?? 0,
      timeSkewSec: _int(json, ['timeSkewSec']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jweAlg': jweAlg,
      'jwsAlg': jwsAlg,
      'publicKeys': publicKeys,
      'toleranceMeters': toleranceMeters,
      'timeSkewSec': timeSkewSec,
    };
  }
}

class VerificationChallengeDto {
  const VerificationChallengeDto({required this.nonce, required this.expiresAt});

  final String nonce;
  final DateTime expiresAt;

  factory VerificationChallengeDto.fromJson(Map<String, dynamic> json) {
    final expiresAtRaw = _string(json, ['expiresAt', 'expires_at']) ?? '';
    final parsedExpiresAt =
        DateTime.tryParse(expiresAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return VerificationChallengeDto(
      nonce: _string(json, ['nonce', 'token', 'challengeToken']) ?? '',
      expiresAt: parsedExpiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nonce': nonce, 'expiresAt': expiresAt.toIso8601String()};
  }
}

class VerificationRequestDto {
  const VerificationRequestDto({
    this.token,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.verificationMethod,
    this.evidence,
  });

  final String? token;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? verificationMethod;
  final String? evidence;

  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (verificationMethod != null) 'verificationMethod': verificationMethod,
      if (evidence != null) 'evidence': evidence,
    };
  }
}

class VerificationResultDto {
  const VerificationResultDto({
    this.placeId,
    this.liveEventId,
    required this.result,
  });

  final String? placeId;
  final String? liveEventId;
  final String result;

  factory VerificationResultDto.fromJson(Map<String, dynamic> json) {
    return VerificationResultDto(
      placeId: _string(json, ['placeId']),
      liveEventId: _string(json, ['liveEventId']),
      result: _string(json, ['result']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'liveEventId': liveEventId,
      'result': result,
    };
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

int? _int(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

List<String> _stringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.whereType<String>().toList();
    }
  }
  return <String>[];
}
