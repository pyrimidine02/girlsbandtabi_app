/// EN: Admin operations repository implementation.
/// KO: 운영/관리자 리포지토리 구현.
library;

import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_ops_entities.dart';
import '../../domain/repositories/admin_ops_repository.dart';
import '../datasources/admin_ops_remote_data_source.dart';
import '../dto/admin_ops_dto.dart';

class AdminOpsRepositoryImpl implements AdminOpsRepository {
  AdminOpsRepositoryImpl({
    required AdminOpsRemoteDataSource remoteDataSource,
    required CacheManager cacheManager,
  }) : _remoteDataSource = remoteDataSource,
       _cacheManager = cacheManager;

  final AdminOpsRemoteDataSource _remoteDataSource;
  final CacheManager _cacheManager;

  @override
  Future<Result<AdminDashboardSummary>> getDashboard({
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;

    try {
      final cacheResult = await _cacheManager.resolve<AdminDashboardDto>(
        key: 'admin_dashboard_summary',
        policy: policy,
        ttl: const Duration(minutes: 3),
        fetcher: _fetchDashboardWithFallback,
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => AdminDashboardDto.fromJson(json),
      );

      return Result.success(_toDashboardEntity(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<AdminCommunityReport>>> getCommunityReports({
    String? status,
    int page = 0,
    int size = 30,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.staleWhileRevalidate;
    final cacheKey = 'admin_reports:${status ?? 'ALL'}:$page:$size';

    try {
      final cacheResult = await _cacheManager
          .resolve<List<AdminCommunityReportDto>>(
            key: cacheKey,
            policy: policy,
            ttl: const Duration(minutes: 2),
            fetcher: () =>
                _fetchCommunityReports(status: status, page: page, size: size),
            toJson: (dtos) => {
              'items': dtos.map((dto) => dto.toJson()).toList(growable: false),
            },
            fromJson: (json) {
              final raw = json['items'];
              return AdminCommunityReportDto.listFromAny(raw);
            },
          );

      return Result.success(
        cacheResult.data.map(_toReportEntity).toList(growable: false),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<AdminCommunityReport>> getCommunityReportDetail({
    required String reportId,
    bool forceRefresh = false,
  }) async {
    final policy = forceRefresh
        ? CachePolicy.networkFirst
        : CachePolicy.cacheFirst;

    try {
      final cacheResult = await _cacheManager.resolve<AdminCommunityReportDto>(
        key: 'admin_report_detail:$reportId',
        policy: policy,
        ttl: const Duration(minutes: 5),
        revalidateAfter: const Duration(minutes: 1),
        fetcher: () => _fetchCommunityReportDetail(reportId),
        toJson: (dto) => dto.toJson(),
        fromJson: (json) => AdminCommunityReportDto.fromJson(json),
      );

      return Result.success(_toReportEntity(cacheResult.data));
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> assignCommunityReport({
    required String reportId,
    required String assigneeUserId,
  }) async {
    try {
      final result = await _remoteDataSource.assignCommunityReport(
        reportId: reportId,
        assigneeUserId: assigneeUserId,
      );

      if (result is Success<void>) {
        await _cacheManager.remove('admin_report_detail:$reportId');
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown assign report result',
          code: 'unknown_assign_report_result',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> updateCommunityReportStatus({
    required String reportId,
    required AdminReportStatus status,
    String? note,
  }) async {
    try {
      final result = await _remoteDataSource.updateCommunityReportStatus(
        reportId: reportId,
        status: status.apiValue,
        note: note,
      );

      if (result is Success<void>) {
        await _cacheManager.remove('admin_report_detail:$reportId');
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown update report status result',
          code: 'unknown_update_report_status_result',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  Future<AdminDashboardDto> _fetchDashboardWithFallback() async {
    final dashboardResult = await _remoteDataSource.fetchDashboard();
    if (dashboardResult is Success<AdminDashboardDto>) {
      return dashboardResult.data;
    }

    if (dashboardResult is Err<AdminDashboardDto>) {
      final fallbackResult = await _remoteDataSource.fetchModerationDashboard();
      if (fallbackResult is Success<AdminDashboardDto>) {
        return fallbackResult.data;
      }

      if (dashboardResult.failure is NotFoundFailure &&
          fallbackResult is Err<AdminDashboardDto>) {
        throw fallbackResult.failure;
      }
      throw dashboardResult.failure;
    }

    throw const UnknownFailure(
      'Unknown dashboard fetch result',
      code: 'unknown_admin_dashboard_result',
    );
  }

  Future<List<AdminCommunityReportDto>> _fetchCommunityReports({
    String? status,
    int page = 0,
    int size = 30,
  }) async {
    final result = await _remoteDataSource.fetchCommunityReports(
      status: status,
      page: page,
      size: size,
    );

    if (result is Success<List<AdminCommunityReportDto>>) {
      return result.data;
    }
    if (result is Err<List<AdminCommunityReportDto>>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown report list result',
      code: 'unknown_admin_report_list_result',
    );
  }

  Future<AdminCommunityReportDto> _fetchCommunityReportDetail(
    String reportId,
  ) async {
    final result = await _remoteDataSource.fetchCommunityReportDetail(
      reportId: reportId,
    );

    if (result is Success<AdminCommunityReportDto>) {
      return result.data;
    }
    if (result is Err<AdminCommunityReportDto>) {
      throw result.failure;
    }

    throw const UnknownFailure(
      'Unknown report detail result',
      code: 'unknown_admin_report_detail_result',
    );
  }

  AdminDashboardSummary _toDashboardEntity(AdminDashboardDto dto) {
    return AdminDashboardSummary(
      openReports: dto.openReports,
      inReviewReports: dto.inReviewReports,
      pendingRoleRequests: dto.pendingRoleRequests,
      pendingVerificationAppeals: dto.pendingVerificationAppeals,
      pendingMediaDeletionRequests: dto.pendingMediaDeletionRequests,
      activeSanctions: dto.activeSanctions,
      extraMetrics: dto.extraMetrics,
    );
  }

  AdminCommunityReport _toReportEntity(AdminCommunityReportDto dto) {
    return AdminCommunityReport(
      id: dto.id,
      targetType: dto.targetType,
      targetId: dto.targetId,
      reason: dto.reason,
      status: AdminReportStatusX.fromApiValue(dto.status),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      reporterId: dto.reporterId,
      reporterName: dto.reporterName,
      assigneeId: dto.assigneeId,
      assigneeName: dto.assigneeName,
      description: dto.description,
      previewText: dto.previewText,
    );
  }
}
