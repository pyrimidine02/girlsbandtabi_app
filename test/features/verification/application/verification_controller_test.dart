import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/core/error/failure.dart';
import 'package:girlsbandtabi_app/core/providers/core_providers.dart';
import 'package:girlsbandtabi_app/features/verification/application/verification_controller.dart';
import 'package:girlsbandtabi_app/features/verification/domain/entities/verification_entities.dart';
import 'package:girlsbandtabi_app/core/utils/result.dart';

void main() {
  group('VerificationController', () {
    test('returns auth failure when user is unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [isAuthenticatedProvider.overrideWith((ref) => false)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(verificationControllerProvider.notifier);
      final result = await notifier.verifyPlace('place-1');

      expect(result, isA<Err<VerificationResult>>());
      expect(
        container.read(verificationControllerProvider).error,
        isA<AuthFailure>(),
      );
    });
  });
}
