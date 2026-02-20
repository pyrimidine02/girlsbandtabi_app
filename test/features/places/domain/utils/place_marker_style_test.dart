import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/places/domain/utils/place_marker_style.dart';

void main() {
  group('placeMarkerHueFromFirstType', () {
    test('uses first type only', () {
      final hue = placeMarkerHueFromFirstType(['station', 'live house']);

      expect(hue, 210.0);
    });

    test('maps known categories to hue buckets', () {
      expect(placeMarkerHueFromFirstType(['concert_hall']), 330.0);
      expect(placeMarkerHueFromFirstType(['restaurant']), 30.0);
      expect(placeMarkerHueFromFirstType(['park']), 120.0);
    });

    test('returns default hue for unknown or empty type', () {
      expect(placeMarkerHueFromFirstType(['unknown_type']), 0.0);
      expect(placeMarkerHueFromFirstType(const []), 0.0);
      expect(placeMarkerHueFromFirstType(['   ']), 0.0);
    });
  });
}
