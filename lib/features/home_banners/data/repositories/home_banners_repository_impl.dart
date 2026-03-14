/// EN: Concrete implementation of [HomeBannersRepository].
/// KO: [HomeBannersRepository]의 구체적인 구현체.
library;

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/home_banner.dart';
import '../../domain/repositories/home_banners_repository.dart';
import '../datasources/home_banners_remote_data_source.dart';

/// EN: Implementation that delegates to the remote data source and maps
/// EN: DTOs to domain entities sorted by [HomeBanner.sortOrder].
/// KO: 원격 데이터 소스에 위임하고 DTO를 [HomeBanner.sortOrder] 순으로
/// KO: 정렬된 도메인 엔티티로 매핑하는 구현체입니다.
class HomeBannersRepositoryImpl implements HomeBannersRepository {
  const HomeBannersRepositoryImpl({required this.remoteDataSource});

  final HomeBannersRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<HomeBanner>>> fetchBanners() async {
    final result = await remoteDataSource.fetchBanners();
    return result.when(
      success: (dtos) {
        final entities = dtos.map((dto) => dto.toEntity()).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return Result.success(entities);
      },
      failure: (failure) => Result.failure(
        NetworkFailure(
          'Failed to fetch home banners: ${failure.message}',
          stackTrace: failure.stackTrace,
        ),
      ),
    );
  }
}
