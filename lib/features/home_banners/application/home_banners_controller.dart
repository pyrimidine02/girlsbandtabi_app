/// EN: Riverpod providers for home banner slides.
/// KO: 홈 배너 슬라이드를 위한 Riverpod 프로바이더.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/home_banners_remote_data_source.dart';
import '../data/repositories/home_banners_repository_impl.dart';
import '../domain/entities/home_banner.dart';
import '../domain/repositories/home_banners_repository.dart';

/// EN: Provides the [HomeBannersRepository] wired with its data source.
/// KO: 데이터 소스와 연결된 [HomeBannersRepository]를 제공합니다.
final homeBannersRepositoryProvider = Provider<HomeBannersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeBannersRepositoryImpl(
    remoteDataSource: HomeBannersRemoteDataSource(apiClient: apiClient),
  );
});

/// EN: Loads and holds the sorted list of active home banner slides.
/// EN: Returns an empty list on failure so the carousel hides gracefully.
/// KO: 정렬된 활성 홈 배너 슬라이드 목록을 로드하고 보유합니다.
/// KO: 실패 시 빈 목록을 반환하여 캐러셀이 자연스럽게 숨겨집니다.
final homeBannersProvider = FutureProvider.autoDispose<List<HomeBanner>>((
  ref,
) async {
  final repository = ref.watch(homeBannersRepositoryProvider);
  final result = await repository.fetchBanners();
  return result.when(
    success: (banners) => banners,
    failure: (_) => const <HomeBanner>[],
  );
});
