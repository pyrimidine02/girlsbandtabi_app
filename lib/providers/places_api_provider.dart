import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/place_service.dart';
import '../models/place_model.dart' as model;
import '../core/constants/api_constants.dart';
import 'content_filter_provider.dart';

final placeServiceProvider = Provider<PlaceService>((ref) => PlaceService());

final placesPageProvider = FutureProvider.autoDispose<model.PaginatedPlaceResponse>((ref) async {
  final service = ref.watch(placeServiceProvider);
  final project = ref.watch(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
  return service.getPlaces(projectId: project, page: 0, size: 1000, sort: 'createdAt,desc');
});
