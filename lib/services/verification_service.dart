import 'dart:convert';
import 'dart:developer' as developer;

import 'package:jose/jose.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/verification_model.dart';

class VerificationConfig {
  VerificationConfig({
    required this.publicKeys,
    required this.keyEncryptionAlgorithm,
    required this.contentEncryptionAlgorithm,
    required this.signatureAlgorithm,
    required this.toleranceMeters,
    required this.timeSkewSeconds,
  });

  factory VerificationConfig.fromJson(Map<String, dynamic> json) {
    final keys = (json['publicKeys'] as List<dynamic>? ?? [])
        .map((e) => e?.toString().trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (keys.isEmpty) {
      throw StateError('No verification public key available');
    }
    return VerificationConfig(
      publicKeys: keys,
      keyEncryptionAlgorithm:
          (json['jweAlg'] as String?)?.trim().isNotEmpty == true
          ? json['jweAlg'].toString().trim()
          : 'RSA-OAEP-256',
      contentEncryptionAlgorithm:
          (json['jweEnc'] as String?)?.trim().isNotEmpty == true
          ? json['jweEnc'].toString().trim()
          : 'A256GCM',
      signatureAlgorithm: (json['jwsAlg'] as String?)?.trim().isNotEmpty == true
          ? json['jwsAlg'].toString().trim()
          : 'none',
      toleranceMeters: (json['toleranceMeters'] as num?)?.toDouble() ?? 0,
      timeSkewSeconds: (json['timeSkewSec'] as num?)?.toInt() ?? 0,
    );
  }

  final List<String> publicKeys;
  final String keyEncryptionAlgorithm;
  final String contentEncryptionAlgorithm;
  final String signatureAlgorithm;
  final double toleranceMeters;
  final int timeSkewSeconds;

  JsonWebKey get primaryJwk => JsonWebKey.fromPem(publicKeys.first);
}

class VerificationService {
  VerificationService();

  final ApiClient _apiClient = ApiClient.instance;
  VerificationConfig? _cachedConfig;
  Duration _serverClockOffset = Duration.zero;

  Future<VerificationConfig> getConfig({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedConfig != null) {
      return _cachedConfig!;
    }

    final response = await _apiClient.getRaw<dynamic>(
      ApiConstants.verificationConfig,
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid verification config payload');
    }
    final serverDateHeader =
        response.headers.value('date') ?? response.headers.value('Date');
    if (serverDateHeader != null) {
      final serverInstant = DateTime.tryParse(serverDateHeader);
      if (serverInstant != null) {
        _serverClockOffset = serverInstant.toUtc().difference(
          DateTime.now().toUtc(),
        );
      }
    }
    final config = VerificationConfig.fromJson(data);
    _cachedConfig = config;
    return config;
  }

  void invalidateCache() {
    _cachedConfig = null;
    _serverClockOffset = Duration.zero;
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
    return VisitVerificationResponse.fromJson(envelope.requireDataAsMap());
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
    bool forceConfigRefresh = false,
  }) async {
    final config = await getConfig(forceRefresh: forceConfigRefresh);
    final now = DateTime.now().toUtc().add(_serverClockOffset);

    final jwk = config.primaryJwk;
    final payload = <String, dynamic>{
      'lat': lat,
      'lon': lon,
      if (accuracyM.isFinite) 'accuracyM': accuracyM,
      'timestamp': now.millisecondsSinceEpoch ~/ 1000,
    };
    assert(() {
      developer.log(jsonEncode(payload), name: 'VerificationService:payload');
      return true;
    }());

    final nestedJwt = _buildNestedJwt(payload, config.signatureAlgorithm);

    final builder = JsonWebEncryptionBuilder()
      ..stringContent = nestedJwt
      ..mediaType = 'JWT'
      ..encryptionAlgorithm = config.contentEncryptionAlgorithm
      ..addRecipient(jwk, algorithm: config.keyEncryptionAlgorithm);

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
    return LiveEventVerificationResponse.fromJson(envelope.requireDataAsMap());
  }
}

String _buildNestedJwt(
  Map<String, dynamic> payload,
  String signatureAlgorithm,
) {
  final normalizedAlg = signatureAlgorithm.toUpperCase();
  if (normalizedAlg == 'NONE') {
    final header = {'alg': 'none', 'typ': 'JWT'};
    final encodedHeader = _encodeBase64Url(jsonEncode(header));
    final encodedPayload = _encodeBase64Url(jsonEncode(payload));
    return '$encodedHeader.$encodedPayload.';
  }
  throw UnimplementedError('Unsupported JWS algorithm: $signatureAlgorithm');
}

String _encodeBase64Url(String value) {
  final encoded = base64Url.encode(utf8.encode(value));
  return encoded.replaceAll('=', '');
}
