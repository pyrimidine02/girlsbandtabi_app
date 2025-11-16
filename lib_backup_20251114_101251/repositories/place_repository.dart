import 'package:girlsbandtabi_app/core/constants/api_constants.dart';
import 'package:girlsbandtabi_app/core/data/dummy_data.dart';
import 'package:girlsbandtabi_app/core/network/api_client.dart';
import 'package:girlsbandtabi_app/models/place.dart' as simple;

class PlaceRepository {
  PlaceRepository();

  List<simple.Place>? _placesCache;
  final ApiClient _api = ApiClient.instance;

  Future<List<simple.Place>> getPlaces() async {
    if (_placesCache != null) {
      return _placesCache!;
    }

    try {
      final envelope = await _api.get(
        ApiConstants.places(ApiConstants.defaultProjectId),
        queryParameters: {
          'page': 0,
          'size': 10,
        },
      );

      final data = envelope.data;
      final items = data is List
          ? data
          : (data is Map<String, dynamic>
              ? (data['items'] as List?) ??
                  data['places'] as List? ??
                  const <dynamic>[]
              : const <dynamic>[]);

      final mapped = items
          .whereType<Map<String, dynamic>>()
          .map(
            (m) => simple.Place(
              id: m['id'].toString(),
              name: m['name']?.toString() ?? 'Unknown',
              description: m['description']?.toString() ?? '',
              imageUrl:
                  'https://via.placeholder.com/400x300.png/007AFF/FFFFFF?text=Place',
              latitude: (m['latitude'] as num).toDouble(),
              longitude: (m['longitude'] as num).toDouble(),
            ),
          )
          .toList(growable: false);

      _placesCache = mapped;
      return _placesCache!;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
      _placesCache = DummyData.places;
      return _placesCache!;
    }
  }

  Future<simple.Place?> getPlaceById(String id) async {
    if (_placesCache == null) {
      await getPlaces();
    }

    try {
      return _placesCache!.firstWhere((place) => place.id == id);
    } catch (_) {
      return null;
    }
  }
}
