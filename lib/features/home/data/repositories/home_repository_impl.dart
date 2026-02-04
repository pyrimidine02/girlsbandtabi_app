/// EN: Home repository implementation with caching.
/// KO: 캐시를 포함한 홈 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../dto/home_summary_dto.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required HomeRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final HomeRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<HomeSummary>> getHomeSummary({
    required String projectId,
    List<String> unitIds = const [],
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCacheKey(projectId, unitIds);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<HomeSummaryDto>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 5),
        fetcher: () => _fetchSummary(projectId, unitIds),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => HomeSummaryDto.fromJson(json),
      );

      return Result.success(HomeSummary.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<HomeSummaryDto> _fetchSummary(
    String projectId,
    List<String> unitIds,
  ) async {
    final result = await _remoteDataSource.fetchSummary(
      projectId: projectId,
      unitIds: unitIds,
    );

    if (result is Success<HomeSummaryDto>) {
      return result.data;
    }
    if (result is Err<HomeSummaryDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown home summary result',
      code: 'unknown_home_summary',
    );
  }

  String _buildCacheKey(String projectId, List<String> unitIds) {
    final units = unitIds.isEmpty ? 'all' : unitIds.join(',');
    return 'home_summary:$projectId:$units';
  }
}
