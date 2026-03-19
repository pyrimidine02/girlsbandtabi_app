/// EN: Remote data source for home banner slides.
/// KO: 홈 배너 슬라이드의 원격 데이터 소스.
library;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../dto/home_banner_dto.dart';

/// EN: Fetches home banner slides from the REST API.
/// KO: REST API에서 홈 배너 슬라이드를 가져옵니다.
class HomeBannersRemoteDataSource {
  const HomeBannersRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  /// EN: Fetches all active home banners. Returns an empty list on empty
  /// EN: or unexpected response shapes rather than a failure.
  /// KO: 활성화된 모든 홈 배너를 가져옵니다. 응답이 비어 있거나 예상치 못한
  /// KO: 형태일 경우 실패 대신 빈 목록을 반환합니다.
  Future<Result<List<HomeBannerDto>>> fetchBanners() {
    return apiClient.get<List<HomeBannerDto>>(
      ApiEndpoints.homeBanners,
      fromJson: (dynamic raw) {
        // EN: Normalise both top-level list and envelope objects.
        // KO: 최상위 목록과 엔벨로프 객체를 모두 정규화합니다.
        List<dynamic> items;
        if (raw is List) {
          items = raw;
        } else if (raw is Map<String, dynamic>) {
          final payload =
              raw['banners'] ?? raw['items'] ?? raw['data'] ?? const [];
          items = payload is List ? payload : [];
        } else {
          items = [];
        }
        return items
            .whereType<Map<String, dynamic>>()
            .map(HomeBannerDto.fromJson)
            .toList(growable: false);
      },
    );
  }
}
