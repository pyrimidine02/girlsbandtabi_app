import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:girlsbandtabi_app/models/place.dart';
import 'package:girlsbandtabi_app/repositories/place_repository.dart';

/// Provider for the PlaceRepository instance.
/// As per the planning document, repositories are singletons.
final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository();
});

/// Provider to fetch the list of all places.
///
/// This uses a FutureProvider to handle the asynchronous operation and
/// automatically manage loading/error states in the UI.
final placesProvider = FutureProvider<List<Place>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getPlaces();
});

/// Provider to fetch a single place by its ID.
/// It uses a .family modifier to pass the ID.
final placeDetailProvider = FutureProvider.family<Place?, String>((ref, id) {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getPlaceById(id);
});
