import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/core/providers/core_providers.dart';
import 'package:girlsbandtabi_app/features/settings/application/settings_controller.dart';

void main() {
  group('UserProfileController', () {
    test('emits null profile when unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [isAuthenticatedProvider.overrideWith((ref) => false)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(userProfileControllerProvider.notifier);
      await notifier.load();

      final state = container.read(userProfileControllerProvider);
      expect(state.valueOrNull, isNull);
      expect(state.hasError, isFalse);
    });
  });
}
