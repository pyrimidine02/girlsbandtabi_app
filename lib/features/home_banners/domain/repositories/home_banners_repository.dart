/// EN: Repository interface for home banner slides.
/// KO: 홈 배너 슬라이드 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/home_banner.dart';

/// EN: Contract for fetching home page banner data.
/// KO: 홈 페이지 배너 데이터 조회 계약.
abstract class HomeBannersRepository {
  /// EN: Fetches all active home banners sorted by [HomeBanner.sortOrder].
  /// KO: [HomeBanner.sortOrder] 순으로 정렬된 활성 홈 배너를 모두 가져옵니다.
  Future<Result<List<HomeBanner>>> fetchBanners();
}
