import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:girlsbandtabi_app/core/error/failure.dart';
import 'package:girlsbandtabi_app/core/utils/result.dart';
import 'package:girlsbandtabi_app/features/feed/data/datasources/community_remote_data_source.dart';
import 'package:girlsbandtabi_app/features/feed/data/dto/community_moderation_dto.dart';
import 'package:girlsbandtabi_app/features/feed/data/repositories/community_repository_impl.dart';
import 'package:girlsbandtabi_app/features/feed/domain/entities/community_moderation.dart';

class MockCommunityRemoteDataSource extends Mock
    implements CommunityRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AppealCreateRequestDto(
        targetType: 'POST',
        targetId: 'post-1',
        reason: '사유',
      ),
    );
  });

  test('getMySanctionStatus returns none when endpoint is not found', () async {
    final remoteDataSource = MockCommunityRemoteDataSource();
    final repository = CommunityRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    when(() => remoteDataSource.getMySanctionStatus()).thenAnswer(
      (_) async => const Result.failure(NotFoundFailure('Not found')),
    );

    final result = await repository.getMySanctionStatus();

    expect(result, isA<Success<UserSanctionStatus>>());
    final data = switch (result) {
      Success(:final data) => data,
      Err() => throw StateError('Expected success'),
    };
    expect(data.level, UserSanctionLevel.none);
    expect(data.isRestricted, false);
  });

  test('submitAppeal forwards target payload and returns success', () async {
    final remoteDataSource = MockCommunityRemoteDataSource();
    final repository = CommunityRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    when(
      () => remoteDataSource.submitAppeal(request: any(named: 'request')),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await repository.submitAppeal(
      targetType: CommunityReportTargetType.post,
      targetId: 'post-1',
      reason: '검토 요청',
    );

    expect(result, isA<Success<void>>());

    final captured =
        verify(
              () => remoteDataSource.submitAppeal(
                request: captureAny(named: 'request'),
              ),
            ).captured.single
            as AppealCreateRequestDto;
    expect(captured.targetType, 'POST');
    expect(captured.targetId, 'post-1');
    expect(captured.reason, '검토 요청');
  });
}
