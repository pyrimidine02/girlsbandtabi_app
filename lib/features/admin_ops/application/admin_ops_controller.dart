/// EN: Controllers for admin operations pages.
/// KO: 운영/관리자 페이지 컨트롤러.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/utils/result.dart';
import '../data/datasources/admin_ops_remote_data_source.dart';
import '../data/repositories/admin_ops_repository_impl.dart';
import '../domain/entities/admin_ops_entities.dart';
import '../domain/repositories/admin_ops_repository.dart';

/// EN: Admin operations repository provider.
/// KO: 운영/관리자 리포지토리 프로바이더.
final adminOpsRepositoryProvider = FutureProvider<AdminOpsRepository>((
  ref,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
  return AdminOpsRepositoryImpl(
    remoteDataSource: AdminOpsRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});

/// EN: Dashboard controller for admin metrics.
/// KO: 관리자 지표 대시보드 컨트롤러.
class AdminDashboardController
    extends StateNotifier<AsyncValue<AdminDashboardSummary>> {
  AdminDashboardController(this._ref) : super(const AsyncLoading()) {
    load();
  }

  final Ref _ref;

  Future<void> load({bool forceRefresh = false}) async {
    state = const AsyncLoading();
    final repository = await _ref.read(adminOpsRepositoryProvider.future);
    final result = await repository.getDashboard(forceRefresh: forceRefresh);

    if (result is Success<AdminDashboardSummary>) {
      state = AsyncData(result.data);
      return;
    }
    if (result is Err<AdminDashboardSummary>) {
      state = AsyncError(result.failure, StackTrace.current);
    }
  }
}

class AdminReportsState {
  const AdminReportsState({
    required this.filter,
    required this.reports,
    this.isMutating = false,
  });

  factory AdminReportsState.initial() {
    return const AdminReportsState(
      filter: AdminReportFilter.all,
      reports: AsyncLoading(),
      isMutating: false,
    );
  }

  final AdminReportFilter filter;
  final AsyncValue<List<AdminCommunityReport>> reports;
  final bool isMutating;

  AdminReportsState copyWith({
    AdminReportFilter? filter,
    AsyncValue<List<AdminCommunityReport>>? reports,
    bool? isMutating,
  }) {
    return AdminReportsState(
      filter: filter ?? this.filter,
      reports: reports ?? this.reports,
      isMutating: isMutating ?? this.isMutating,
    );
  }
}

/// EN: Community report list + actions controller.
/// KO: 커뮤니티 신고 목록/액션 컨트롤러.
class AdminReportsController extends StateNotifier<AdminReportsState> {
  AdminReportsController(this._ref) : super(AdminReportsState.initial()) {
    load();
  }

  final Ref _ref;

  Future<void> load({
    bool forceRefresh = false,
    AdminReportFilter? filter,
  }) async {
    final nextFilter = filter ?? state.filter;
    state = state.copyWith(filter: nextFilter, reports: const AsyncLoading());

    final repository = await _ref.read(adminOpsRepositoryProvider.future);
    final result = await repository.getCommunityReports(
      status: nextFilter.apiStatus,
      page: 0,
      size: 50,
      forceRefresh: forceRefresh,
    );

    if (result is Success<List<AdminCommunityReport>>) {
      state = state.copyWith(reports: AsyncData(result.data));
      return;
    }

    if (result is Err<List<AdminCommunityReport>>) {
      state = state.copyWith(
        reports: AsyncError(result.failure, StackTrace.current),
      );
    }
  }

  Future<Result<void>> assignToUser({
    required String reportId,
    required String assigneeUserId,
  }) async {
    state = state.copyWith(isMutating: true);
    final repository = await _ref.read(adminOpsRepositoryProvider.future);
    final result = await repository.assignCommunityReport(
      reportId: reportId,
      assigneeUserId: assigneeUserId,
    );
    state = state.copyWith(isMutating: false);

    if (result is Success<void>) {
      await load(forceRefresh: true);
      return const Result.success(null);
    }
    if (result is Err<void>) {
      return Result.failure(result.failure);
    }

    return const Result.success(null);
  }

  Future<Result<void>> updateStatus({
    required String reportId,
    required AdminReportStatus status,
    String? note,
  }) async {
    state = state.copyWith(isMutating: true);
    final repository = await _ref.read(adminOpsRepositoryProvider.future);
    final result = await repository.updateCommunityReportStatus(
      reportId: reportId,
      status: status,
      note: note,
    );
    state = state.copyWith(isMutating: false);

    if (result is Success<void>) {
      await load(forceRefresh: true);
      return const Result.success(null);
    }
    if (result is Err<void>) {
      return Result.failure(result.failure);
    }

    return const Result.success(null);
  }
}

/// EN: Dashboard controller provider.
/// KO: 운영 대시보드 컨트롤러 프로바이더.
final adminDashboardControllerProvider =
    StateNotifierProvider<
      AdminDashboardController,
      AsyncValue<AdminDashboardSummary>
    >((ref) {
      return AdminDashboardController(ref);
    });

/// EN: Reports controller provider.
/// KO: 운영 신고 목록 컨트롤러 프로바이더.
final adminReportsControllerProvider =
    StateNotifierProvider<AdminReportsController, AdminReportsState>((ref) {
      return AdminReportsController(ref);
    });

/// EN: Report detail provider.
/// KO: 신고 상세 프로바이더.
final adminReportDetailProvider = FutureProvider.autoDispose
    .family<AdminCommunityReport?, String>((ref, reportId) async {
      if (reportId.isEmpty) {
        return null;
      }

      final repository = await ref.read(adminOpsRepositoryProvider.future);
      final result = await repository.getCommunityReportDetail(
        reportId: reportId,
      );
      if (result is Success<AdminCommunityReport>) {
        return result.data;
      }
      return null;
    });
