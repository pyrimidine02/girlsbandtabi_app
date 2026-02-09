/// EN: Remote data source for user visit APIs.
/// KO: 사용자 방문 API 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../dto/user_ranking_dto.dart';
import '../dto/visit_dto.dart';

class VisitsRemoteDataSource {
  VisitsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// EN: Fetch user visit events.
  /// KO: 사용자 방문 이벤트를 조회합니다.
  Future<Result<List<VisitEventDto>>> fetchUserVisits({
    int page = 0,
    int size = ApiPagination.defaultSize,
  }) {
    return _apiClient.get<List<VisitEventDto>>(
      ApiEndpoints.userVisits,
      queryParameters: {'page': page, 'size': size},
      fromJson: (json) => _decodeList(json, VisitEventDto.fromJson),
    );
  }

  /// EN: Fetch visit summary for a place.
  /// KO: 특정 장소의 방문 요약을 조회합니다.
  Future<Result<VisitSummaryDto>> fetchVisitSummary({
    required String placeId,
  }) {
    return _apiClient.get<VisitSummaryDto>(
      ApiEndpoints.userVisitsSummary,
      queryParameters: {'placeId': placeId},
      fromJson: (json) => VisitSummaryDto.fromJson(
        json as Map<String, dynamic>,
      ),
    );
  }

  /// EN: Fetch current user's ranking.
  /// KO: 현재 사용자의 랭킹을 조회합니다.
  Future<Result<UserRankingDto>> fetchUserRanking({
    required String projectId,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.rankingsUsers(projectId),
      fromJson: (json) => _decodeRankingResponse(json),
    );

    if (result is Err<Map<String, dynamic>>) {
      return Result.failure(result.failure);
    }

    final data = (result as Success<Map<String, dynamic>>).data;
    final rankings =
        data['rankings'] ?? data['users'] ?? data['items'] ?? data['content'];

    if (rankings is List && rankings.isNotEmpty) {
      final totalUsers = _extractTotalUsers(data, rankings.length);
      final first = rankings.first;
      if (first is Map<String, dynamic>) {
        final dto = UserRankingDto.fromJson({
          ...first,
          'totalUsers': totalUsers,
        });
        return Result.success(dto);
      }
    }

    return Result.failure(
      const UnknownFailure('No ranking data', code: 'no_ranking_data'),
    );
  }
}

List<T> _decodeList<T>(dynamic json, T Function(Map<String, dynamic>) mapper) {
  if (json is List) {
    return json.whereType<Map<String, dynamic>>().map(mapper).toList();
  }
  if (json is Map<String, dynamic>) {
    const listKeys = ['items', 'content', 'data', 'results'];
    for (final key in listKeys) {
      final value = json[key];
      if (value is List) {
        return value.whereType<Map<String, dynamic>>().map(mapper).toList();
      }
    }
  }
  return <T>[];
}

Map<String, dynamic> _decodeRankingResponse(dynamic json) {
  if (json is Map<String, dynamic>) {
    return json;
  }
  return <String, dynamic>{};
}

int _extractTotalUsers(Map<String, dynamic> data, int fallback) {
  final value = data['totalUsers'] ?? data['totalElements'] ?? data['total'];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
