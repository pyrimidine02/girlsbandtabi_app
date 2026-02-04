/// EN: Verification domain entities.
/// KO: 인증 도메인 엔티티.
library;

import '../../data/dto/verification_dto.dart';

class VerificationConfig {
  const VerificationConfig({
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

  factory VerificationConfig.fromDto(VerificationConfigDto dto) {
    return VerificationConfig(
      jweAlg: dto.jweAlg,
      jwsAlg: dto.jwsAlg,
      publicKeys: dto.publicKeys,
      toleranceMeters: dto.toleranceMeters,
      timeSkewSec: dto.timeSkewSec,
    );
  }
}

class VerificationChallenge {
  const VerificationChallenge({required this.nonce, required this.expiresAt});

  final String nonce;
  final DateTime expiresAt;

  factory VerificationChallenge.fromDto(VerificationChallengeDto dto) {
    return VerificationChallenge(nonce: dto.nonce, expiresAt: dto.expiresAt);
  }
}

class VerificationResult {
  const VerificationResult({
    required this.result,
    this.placeId,
    this.liveEventId,
  });

  final String result;
  final String? placeId;
  final String? liveEventId;

  factory VerificationResult.fromDto(VerificationResultDto dto) {
    return VerificationResult(
      result: dto.result,
      placeId: dto.placeId,
      liveEventId: dto.liveEventId,
    );
  }
}
