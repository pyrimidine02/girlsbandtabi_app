import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/band_model.dart';

class BandService {
  BandService();

  final ApiClient _api = ApiClient.instance;

  Future<List<BandUnit>> getBands(
    String projectId, {
    int page = 0,
    int size = 50,
    String? sort,
  }) async {
    try {
      final envelope = await _api.get(
        ApiConstants.units(projectId),
        queryParameters: {
          'page': page,
          'size': size,
          if (sort != null) 'sort': sort,
        },
      );
      final list = envelope.requireDataAsList();
      return list
          .whereType<Map<String, dynamic>>()
          .map(BandUnit.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const <BandUnit>[];
    }
  }

  Future<Map<String, dynamic>?> getBandDetail(String projectId, String unitCode) async {
    try {
      final envelope = await _api.get(
        ApiConstants.unitDetail(projectId, unitCode),
      );
      return envelope.requireDataAsMap();
    } catch (_) {
      return null;
    }
  }

  Future<BandUnit> createBand(
    String projectId, {
    required String code,
    required String displayName,
  }) async {
    final envelope = await _api.post(
      ApiConstants.units(projectId),
      data: {
        'code': code,
        'displayName': displayName,
      },
    );
    return BandUnit.fromJson(envelope.requireDataAsMap());
  }

  Future<BandUnit> updateBand(
    String projectId,
    String unitCode, {
    String? displayName,
  }) async {
    final envelope = await _api.put(
      ApiConstants.unitDetail(projectId, unitCode),
      data: {
        if (displayName != null) 'displayName': displayName,
      },
    );
    return BandUnit.fromJson(envelope.requireDataAsMap());
  }

  Future<void> deleteBand(String projectId, String unitCode) async {
    await _api.delete(ApiConstants.unitDetail(projectId, unitCode));
  }

  Future<List<BandUnit>> searchUnits(
    String projectId,
    String q, {
    int page = 0,
    int size = 20,
  }) async {
    final envelope = await _api.get(
      ApiConstants.unitSearch(projectId),
      queryParameters: {
        'q': q,
        'page': page,
        'size': size,
      },
    );
    final list = envelope.requireDataAsList();
    return list
        .whereType<Map<String, dynamic>>()
        .map(BandUnit.fromJson)
        .toList(growable: false);
  }
}
