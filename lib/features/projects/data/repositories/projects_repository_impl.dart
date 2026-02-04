/// EN: Projects repository implementation with caching.
/// KO: 캐시를 포함한 프로젝트 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/project_entities.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';
import '../dto/project_dto.dart';
import '../dto/unit_dto.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({
    required ProjectsRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final ProjectsRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;
  Future<Result<List<Project>>>? _projectsRequest;

  @override
  Future<Result<List<Project>>> getProjects({bool forceRefresh = false}) {
    if (!forceRefresh) {
      final inFlight = _projectsRequest;
      if (inFlight != null) return inFlight;
    }

    final request = _getProjects(forceRefresh: forceRefresh);
    if (!forceRefresh) {
      _projectsRequest = request;
    }

    return request.whenComplete(() {
      if (_projectsRequest == request) {
        _projectsRequest = null;
      }
    });
  }

  Future<Result<List<Project>>> _getProjects({
    required bool forceRefresh,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<List<ProjectDto>>(
        key: _projectsCacheKey,
        policy: policy,
        ttl: const Duration(minutes: 30),
        fetcher: _fetchProjects,
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(ProjectDto.fromJson)
                .toList();
          }
          return <ProjectDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => Project.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<Unit>>> getUnits({
    required String projectId,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<List<UnitDto>>(
        key: _unitsCacheKey(projectId),
        policy: policy,
        ttl: const Duration(minutes: 15),
        fetcher: () => _fetchUnits(projectId),
        toJson: (dtos) => {'items': dtos.map((dto) => dto.toJson()).toList()},
        fromJson: (json) {
          final items = json['items'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(UnitDto.fromJson)
                .toList();
          }
          return <UnitDto>[];
        },
      );

      final entities = cacheResult.data
          .map((dto) => Unit.fromDto(dto))
          .toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<List<ProjectDto>> _fetchProjects() async {
    final result = await _remoteDataSource.fetchProjects();

    if (result is Success<List<ProjectDto>>) {
      return result.data;
    }
    if (result is Err<List<ProjectDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown projects result',
      code: 'unknown_projects',
    );
  }

  Future<List<UnitDto>> _fetchUnits(String projectId) async {
    final result = await _remoteDataSource.fetchUnits(projectId: projectId);

    if (result is Success<List<UnitDto>>) {
      return result.data;
    }
    if (result is Err<List<UnitDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure('Unknown units result', code: 'unknown_units');
  }

  static const String _projectsCacheKey = 'projects_list';

  String _unitsCacheKey(String projectId) => 'project_units:$projectId';
}
