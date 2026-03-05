import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:girlsbandtabi_app/features/places/application/places_controller.dart';

void main() {
  group('PlacesListController', () {
    test('keeps loading state when project is not selected', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(placesListControllerProvider.notifier);
      await notifier.load();

      final state = container.read(placesListControllerProvider);
      expect(state.isLoading, isTrue);
      expect(state.hasError, isFalse);
      expect(state.hasValue, isFalse);
    });
  });
}
