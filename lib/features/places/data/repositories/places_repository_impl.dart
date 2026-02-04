/// EN: Places repository implementation with caching policies.
/// KO: 캐시 정책을 포함한 장소 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/place_comment_entities.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_guide_entities.dart';
import '../../domain/entities/place_region_entities.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_data_source.dart';
import '../dto/place_comment_dto.dart';
import '../dto/place_dto.dart';
import '../dto/place_guide_dto.dart';
import '../dto/place_region_filter_dto.dart';
import '../dto/place_stats_dto.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl({
    required PlacesRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final PlacesRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<List<PlaceSummary>>> getPlaces({
    required String projectId,
    List<String> unitIds = const [],
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _listCacheKey(projectId, unitIds, page, size);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.cacheFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PlaceSummaryDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 30),
        fetcher: () => _fetchPlaces(projectId, unitIds, page, size),
        toJson: (dtos) => {'items': dtos.map((e) => e.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PlaceSummaryDto.fromJson)
                .toList();
          }
          return <PlaceSummaryDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PlaceSummary.fromDto(dto))
          .toList();

      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<PlaceSummary>>> getAllPlaces({
    required String projectId,
    List<String> unitIds = const [],
    bool forceRefresh = false,
  }) async {
    final cacheKey = _allCacheKey(projectId, unitIds);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.cacheFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PlaceSummaryDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 30),
        fetcher: () => _fetchAllPlaces(projectId, unitIds),
        toJson: (dtos) => {'items': dtos.map((e) => e.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PlaceSummaryDto.fromJson)
                .toList();
          }
          return <PlaceSummaryDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PlaceSummary.fromDto(dto))
          .toList();

      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<RegionFilterOptions>> getRegionFilterOptions({
    required String projectId,
    String language = 'ko',
    int minPlaceCount = 1,
    bool hierarchical = true,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'places_regions_available_${projectId}_$language'
        '_${minPlaceCount}_$hierarchical';
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.cacheFirst;

    try {
      final cacheResult = await _cacheManager.resolve<RegionFilterOptionsDto>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(hours: 6),
        fetcher:
            () => _fetchRegionFilterOptions(
              projectId,
              language,
              minPlaceCount,
              hierarchical,
            ),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => RegionFilterOptionsDto.fromJson(json),
      );

      return Result.success(RegionFilterOptions.fromDto(cacheResult.data));
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<PlaceSummary>>> getPlacesByRegionFilter({
    required String projectId,
    required List<String> regionCodes,
    bool includeChildren = true,
    List<String> placeTypes = const [],
    List<String> unitIds = const [],
    int page = 0,
    int size = 20,
    List<String> sort = const [],
  }) async {
    try {
      final dtos = await _fetchAllPlacesByRegionFilter(
        projectId: projectId,
        regionCodes: regionCodes,
        includeChildren: includeChildren,
        placeTypes: placeTypes,
        unitIds: unitIds,
        sort: sort,
      );
      final entities = dtos.map((dto) => PlaceSummary.fromDto(dto)).toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<RegionMapBounds>> getRegionMapBounds({
    required String projectId,
    required String regionCode,
    bool includeChildren = true,
  }) async {
    try {
      final result = await _remoteDataSource.fetchRegionMapBounds(
        projectId: projectId,
        regionCode: regionCode,
        includeChildren: includeChildren,
      );

      if (result is Success<RegionMapBoundsDto>) {
        return Result.success(RegionMapBounds.fromDto(result.data));
      }
      if (result is Err<RegionMapBoundsDto>) {
        return Result.failure(result.failure);
      }
      return Result.failure(
        const UnknownFailure('Unknown region bounds result'),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<PlaceDetail>> getPlaceDetail({
    required String projectId,
    required String placeId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _detailCacheKey(projectId, placeId);
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.networkFirst;

    try {
      final cacheResult = await _cacheManager.resolve<PlaceDetailDto>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 10),
        fetcher: () => _fetchPlaceDetail(projectId, placeId),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => PlaceDetailDto.fromJson(json),
      );

      PlaceStatsDto? stats;
      try {
        stats = await _fetchPlaceStats(projectId, placeId);
      } catch (_) {
        stats = null;
      }

      return Result.success(PlaceDetail.fromDto(cacheResult.data, stats: stats));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<PlaceSummary>>> getPlacesWithinBounds({
    required String projectId,
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    List<String> unitIds = const [],
  }) async {
    try {
      final result = await _remoteDataSource.fetchPlacesWithinBounds(
        projectId: projectId,
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
        unitIds: unitIds,
      );

      if (result is Success<List<PlaceSummaryDto>>) {
        final entities =
            result.data.map((dto) => PlaceSummary.fromDto(dto)).toList();
        return Result.success(entities);
      }
      if (result is Err<List<PlaceSummaryDto>>) {
        return Result.failure(result.failure);
      }
      return Result.failure(
        const UnknownFailure('Unknown within-bounds result'),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<PlaceSummary>>> getNearbyPlaces({
    required String projectId,
    required double latitude,
    required double longitude,
    double? radiusKm,
    List<String> unitIds = const [],
  }) async {
    try {
      final result = await _remoteDataSource.fetchNearbyPlaces(
        projectId: projectId,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        unitIds: unitIds,
      );

      if (result is Success<List<PlaceSummaryDto>>) {
        final entities =
            result.data.map((dto) => PlaceSummary.fromDto(dto)).toList();
        return Result.success(entities);
      }
      if (result is Err<List<PlaceSummaryDto>>) {
        return Result.failure(result.failure);
      }
      return Result.failure(
        const UnknownFailure('Unknown nearby result'),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<PlaceGuideSummary>>> getPlaceGuides({
    required String placeId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'place_guides_${placeId}_${page}_$size';
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.cacheFirst;

    try {
      final cacheResult = await _cacheManager.resolve<List<PlaceGuideSummaryDto>>(
        key: cacheKey,
        policy: policy,
        ttl: const Duration(minutes: 10),
        fetcher: () => _fetchPlaceGuides(placeId, page, size),
        toJson: (dtos) => {'items': dtos.map((e) => e.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(PlaceGuideSummaryDto.fromJson)
                .toList();
          }
          return <PlaceGuideSummaryDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => PlaceGuideSummary.fromDto(dto))
          .toList();

      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<List<PlaceComment>>> getPlaceComments({
    required String placeId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'place_comments_${placeId}_${page}_$size';
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.cacheFirst;

    try {
      final cacheResult =
          await _cacheManager.resolve<List<PlaceCommentDetailDto>>(
            key: cacheKey,
            policy: policy,
            ttl: const Duration(minutes: 5),
            fetcher: () => _fetchPlaceComments(placeId, page, size),
            toJson: (dtos) => {'items': dtos.map((e) => e.toJson()).toList()},
            fromJson: (json) {
              final items = json['items'];
              if (items is List) {
                return items
                    .whereType<Map<String, dynamic>>()
                    .map(PlaceCommentDetailDto.fromJson)
                    .toList();
              }
              return <PlaceCommentDetailDto>[];
            },
          );

      final entities = cacheResult.data
          .map((dto) => PlaceComment.fromDto(dto))
          .toList();

      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  @override
  Future<Result<PlaceComment>> createPlaceComment({
    required String placeId,
    required String body,
    required List<String> photoUploadIds,
    bool isPublic = true,
    List<String> tags = const [],
  }) async {
    try {
      final request = CreatePlaceCommentRequestDto(
        bodyMarkdown: body,
        tags: tags,
        photoUploadIds: photoUploadIds,
        isPublic: isPublic,
      );
      final result = await _remoteDataSource.createPlaceComment(
        placeId: placeId,
        request: request,
      );
      if (result is Success<PlaceCommentDetailDto>) {
        return Result.success(PlaceComment.fromDto(result.data));
      }
      if (result is Err<PlaceCommentDetailDto>) {
        return Result.failure(result.failure);
      }
      return Result.failure(
        const UnknownFailure('Unknown place comment result'),
      );
    } catch (e, stackTrace) {
      return Result.failure(ErrorHandler.mapException(e, stackTrace));
    }
  }

  Future<List<PlaceSummaryDto>> _fetchPlaces(
    String projectId,
    List<String> unitIds,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchPlaces(
      projectId: projectId,
      unitIds: unitIds,
      page: page,
      size: size,
    );

    if (result is Success<List<PlaceSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<PlaceSummaryDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown places list result',
      code: 'unknown_places_list',
    );
  }

  Future<List<PlaceSummaryDto>> _fetchAllPlaces(
    String projectId,
    List<String> unitIds,
  ) async {
    const pageSize = ApiPagination.maxSize;
    const maxPages = 50;
    final all = <PlaceSummaryDto>[];
    var page = 0;

    while (page < maxPages) {
      final result = await _remoteDataSource.fetchPlaces(
        projectId: projectId,
        unitIds: unitIds,
        page: page,
        size: pageSize,
      );

      if (result is Success<List<PlaceSummaryDto>>) {
        final batch = result.data;
        all.addAll(batch);
        if (batch.length < pageSize) {
          break;
        }
        page += 1;
        continue;
      }
      if (result is Err<List<PlaceSummaryDto>>) {
        throw result.failure;
      }
      throw const UnknownFailure(
        'Unknown places list result',
        code: 'unknown_places_list',
      );
    }

    return all;
  }

  Future<List<PlaceSummaryDto>> _fetchAllPlacesByRegionFilter({
    required String projectId,
    required List<String> regionCodes,
    bool includeChildren = true,
    List<String> placeTypes = const [],
    List<String> unitIds = const [],
    List<String> sort = const [],
  }) async {
    const pageSize = ApiPagination.maxSize;
    const maxPages = 50;
    final all = <PlaceSummaryDto>[];
    var page = 0;

    while (page < maxPages) {
      final result = await _remoteDataSource.fetchPlacesByRegionFilter(
        projectId: projectId,
        regionCodes: regionCodes,
        includeChildren: includeChildren,
        placeTypes: placeTypes,
        unitIds: unitIds,
        page: page,
        size: pageSize,
        sort: sort,
      );

      if (result is Success<List<PlaceSummaryDto>>) {
        final batch = result.data;
        all.addAll(batch);
        if (batch.length < pageSize) {
          break;
        }
        page += 1;
        continue;
      }
      if (result is Err<List<PlaceSummaryDto>>) {
        throw result.failure;
      }
      throw const UnknownFailure(
        'Unknown region filter result',
        code: 'unknown_region_filter',
      );
    }

    return all;
  }

  Future<List<PlaceGuideSummaryDto>> _fetchPlaceGuides(
    String placeId,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchPlaceGuides(
      placeId: placeId,
      page: page,
      size: size,
    );
    if (result is Success<List<PlaceGuideSummaryDto>>) {
      return result.data;
    }
    if (result is Err<List<PlaceGuideSummaryDto>>) {
      throw result.failure;
    }
    throw const UnknownFailure('Unknown place guides result');
  }

  Future<List<PlaceCommentDetailDto>> _fetchPlaceComments(
    String placeId,
    int page,
    int size,
  ) async {
    final result = await _remoteDataSource.fetchPlaceComments(
      placeId: placeId,
      page: page,
      size: size,
    );
    if (result is Success<List<PlaceCommentDetailDto>>) {
      return result.data;
    }
    if (result is Err<List<PlaceCommentDetailDto>>) {
      throw result.failure;
    }
    throw const UnknownFailure('Unknown place comments result');
  }

  Future<PlaceDetailDto> _fetchPlaceDetail(
    String projectId,
    String placeId,
  ) async {
    final result = await _remoteDataSource.fetchPlaceDetail(
      projectId: projectId,
      placeId: placeId,
    );

    if (result is Success<PlaceDetailDto>) {
      return result.data;
    }
    if (result is Err<PlaceDetailDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown place detail result',
      code: 'unknown_place_detail',
    );
  }

  Future<RegionFilterOptionsDto> _fetchRegionFilterOptions(
    String projectId,
    String language,
    int minPlaceCount,
    bool hierarchical,
  ) async {
    final result = await _remoteDataSource.fetchRegionFilterOptions(
      projectId: projectId,
      language: language,
      minPlaceCount: minPlaceCount,
      hierarchical: hierarchical,
    );

    if (result is Success<RegionFilterOptionsDto>) {
      return result.data;
    }
    if (result is Err<RegionFilterOptionsDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown region filter options result',
      code: 'unknown_region_filter_options',
    );
  }

  Future<PlaceStatsDto> _fetchPlaceStats(
    String projectId,
    String placeId,
  ) async {
    final result = await _remoteDataSource.fetchPlaceStats(
      projectId: projectId,
      placeId: placeId,
    );

    if (result is Success<PlaceStatsDto>) {
      return result.data;
    }
    if (result is Err<PlaceStatsDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown place stats result',
      code: 'unknown_place_stats',
    );
  }

  String _listCacheKey(
    String projectId,
    List<String> unitIds,
    int page,
    int size,
  ) {
    final units = unitIds.isEmpty ? 'all' : unitIds.join(',');
    return 'places_list:$projectId:$units:p$page:s$size';
  }

  String _allCacheKey(String projectId, List<String> unitIds) {
    final units = unitIds.isEmpty ? 'all' : unitIds.join(',');
    return 'places_all:$projectId:$units';
  }

  String _detailCacheKey(String projectId, String placeId) {
    return 'place_detail:$projectId:$placeId';
  }
}
