import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' hide VerificationResult;

import 'package:girlsbandtabi_app/core/location/location_service.dart';
import 'package:girlsbandtabi_app/core/utils/result.dart';
import 'package:girlsbandtabi_app/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:girlsbandtabi_app/features/verification/data/dto/verification_dto.dart';
import 'package:girlsbandtabi_app/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:girlsbandtabi_app/features/verification/domain/entities/verification_entities.dart';

class MockVerificationRemoteDataSource extends Mock
    implements VerificationRemoteDataSource {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const VerificationRequestDto());
  });

  test('verifyPlace sends location payload from LocationService', () async {
    final remoteDataSource = MockVerificationRemoteDataSource();
    final locationService = MockLocationService();
    final repository = VerificationRepositoryImpl(
      remoteDataSource: remoteDataSource,
      locationService: locationService,
    );

    when(
      () => locationService.getCurrentLocation(),
    ).thenAnswer(
      (_) async => const LocationSnapshot(
        latitude: 35.0,
        longitude: 139.0,
        accuracy: 12.3,
      ),
    );

    when(
      () => remoteDataSource.verifyPlace(
        projectId: any(named: 'projectId'),
        placeId: any(named: 'placeId'),
        request: any(named: 'request'),
      ),
    ).thenAnswer(
      (_) async => const Result.success(
        VerificationResultDto(placeId: 'place-1', result: 'VERIFIED'),
      ),
    );

    final result = await repository.verifyPlace(
      projectId: 'project-1',
      placeId: 'place-1',
    );

    expect(result, isA<Success<VerificationResult>>());

    final capturedRequest =
        verify(
              () => remoteDataSource.verifyPlace(
                projectId: 'project-1',
                placeId: 'place-1',
                request: captureAny(named: 'request'),
              ),
            ).captured.single
            as VerificationRequestDto;

    expect(capturedRequest.latitude, 35.0);
    expect(capturedRequest.longitude, 139.0);
    expect(capturedRequest.accuracy, 12.3);
    expect(capturedRequest.token, isNull);
  });

  test('verifyLiveEvent uses verificationMethod without location lookup', () async {
    final remoteDataSource = MockVerificationRemoteDataSource();
    final locationService = MockLocationService();
    final repository = VerificationRepositoryImpl(
      remoteDataSource: remoteDataSource,
      locationService: locationService,
    );

    when(
      () => remoteDataSource.verifyLiveEvent(
        projectId: any(named: 'projectId'),
        liveEventId: any(named: 'liveEventId'),
        request: any(named: 'request'),
      ),
    ).thenAnswer(
      (_) async => const Result.success(
        VerificationResultDto(liveEventId: 'live-1', result: 'RECORDED'),
      ),
    );

    final result = await repository.verifyLiveEvent(
      projectId: 'project-1',
      liveEventId: 'live-1',
      verificationMethod: 'MANUAL',
    );

    expect(result, isA<Success<VerificationResult>>());
    verifyNever(() => locationService.getCurrentLocation());

    final capturedRequest =
        verify(
              () => remoteDataSource.verifyLiveEvent(
                projectId: 'project-1',
                liveEventId: 'live-1',
                request: captureAny(named: 'request'),
              ),
            ).captured.single
            as VerificationRequestDto;

    expect(capturedRequest.verificationMethod, 'MANUAL');
  });
}
