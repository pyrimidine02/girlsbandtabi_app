import 'package:jose/jose.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/verification_model.dart';

class VerificationService {
  VerificationService();

  final ApiClient _apiClient = ApiClient.instance;
  Map<String, dynamic>? _cachedConfig;

  Future<Map<String, dynamic>> getConfig({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedConfig != null) {
      return _cachedConfig!;
    }

    final envelope = await _apiClient.get(ApiConstants.verificationConfig);
    final data = Map<String, dynamic>.from(envelope.requireDataAsMap());
    _cachedConfig = data;
    return data;
  }

  Future<VisitVerificationResponse> verifyPlaceVisit({
    required String projectId,
    required String placeId,
    required String token,
  }) async {
    final envelope = await _apiClient.post(
      ApiConstants.placeVerification(projectId, placeId),
      data: {'token': token},
    );
    return VisitVerificationResponse.fromJson(
      envelope.requireDataAsMap(),
    );
  }

  Future<String> buildLocationToken({
    required double lat,
    required double lon,
    required double accuracyM,
    double? altitude,
    double? heading,
    double? speed,
    String? placeId,
    String? eventId,
  }) async {
    final config = await getConfig();
    final now = DateTime.now().toUtc();

    final publicKeys = (config['publicKeys'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList(growable: false);
    if (publicKeys.isEmpty) {
      throw StateError('No verification public key available');
    }

    final jwk = JsonWebKey.fromPem(publicKeys.first);
    final payload = <String, dynamic>{
      'lat': lat,
      'lon': lon,
      'accuracyM': accuracyM,
      'timestamp': (now.millisecondsSinceEpoch / 1000).floor(),
      'clientTs': now.toIso8601String(),
      if (altitude != null) 'altitude': altitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      if (placeId != null) 'placeId': placeId,
      if (eventId != null) 'eventId': eventId,
    };

    final alg = (config['jweAlg'] as String?) ?? 'RSA-OAEP-256';
    final enc = (config['jweEnc'] as String?) ?? 'A256GCM';

    final builder = JsonWebEncryptionBuilder()
      ..jsonContent = payload
      ..encryptionAlgorithm = enc
      ..addRecipient(jwk, algorithm: alg);

    final jwe = builder.build();
    return jwe.toCompactSerialization();
  }

  Future<LiveEventVerificationResponse> verifyLiveEvent({
    required String projectId,
    required String liveEventId,
    required String token,
  }) async {
    final envelope = await _apiClient.post(
      ApiConstants.liveEventVerification(projectId, liveEventId),
      data: {'token': token},
    );
    return LiveEventVerificationResponse.fromJson(
      envelope.requireDataAsMap(),
    );
  }
}
