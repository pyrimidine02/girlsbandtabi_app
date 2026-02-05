/// EN: Community moderation repository implementation.
/// KO: 커뮤니티 신고/차단 리포지토리 구현.
library;

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/community_moderation.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_data_source.dart';
import '../dto/community_moderation_dto.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl({required CommunityRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CommunityRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> createReport({
    required CommunityReportTargetType targetType,
    required String targetId,
    required CommunityReportReason reason,
    String? description,
  }) async {
    try {
      final request = ReportCreateRequestDto(
        targetType: targetType.apiValue,
        targetId: targetId,
        reason: reason.apiValue,
        description: description,
      );
      final result = await _remoteDataSource.createReport(request: request);

      if (result is Success<void>) {
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown report create result',
          code: 'unknown_report_create',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<BlockStatus>> getBlockStatus({required String userId}) async {
    try {
      final result = await _remoteDataSource.checkBlockStatus(userId: userId);
      if (result is Success<BlockCheckDto>) {
        final dto = result.data;
        return Result.success(
          BlockStatus(
            isBlocked: dto.isBlocked,
            blockedByMe: dto.blockedByMe,
            blockedMe: dto.blockedMe,
            blockedByAdmin: dto.blockedByAdmin,
          ),
        );
      }
      if (result is Err<BlockCheckDto>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown block status result',
          code: 'unknown_block_status',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> blockUser({
    required String targetUserId,
    String? reason,
  }) async {
    try {
      final request = BlockCreateRequestDto(
        targetUserId: targetUserId,
        reason: reason,
      );
      final result = await _remoteDataSource.blockUser(request: request);
      if (result is Success<void>) {
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown block user result',
          code: 'unknown_block_user',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }

  @override
  Future<Result<void>> unblockUser({required String targetUserId}) async {
    try {
      final result = await _remoteDataSource.unblockUser(userId: targetUserId);
      if (result is Success<void>) {
        return const Result.success(null);
      }
      if (result is Err<void>) {
        return Result.failure(result.failure);
      }

      return Result.failure(
        const UnknownFailure(
          'Unknown unblock user result',
          code: 'unknown_unblock_user',
        ),
      );
    } catch (e, stackTrace) {
      final failure = ErrorHandler.mapException(e, stackTrace);
      return Result.failure(failure);
    }
  }
}
