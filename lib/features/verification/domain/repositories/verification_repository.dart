/// EN: Verification repository interface.
/// KO: 인증 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/verification_entities.dart';

abstract class VerificationRepository {
  Future<Result<VerificationConfig>> getConfig();

  Future<Result<VerificationChallenge>> getChallenge();

  Future<Result<VerificationResult>> verifyPlace({
    required String projectId,
    required String placeId,
  });

  Future<Result<VerificationResult>> verifyLiveEvent({
    required String projectId,
    required String liveEventId,
    String? verificationMethod,
  });
}
