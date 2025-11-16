import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/project_service.dart';
import '../services/band_service.dart';
import '../models/project_model.dart';
import 'content_filter_provider.dart';

class BandInfo {
  final String id;
  final String name;
  const BandInfo({required this.id, required this.name});
}

final projectServiceProvider = Provider<ProjectService>(
  (ref) => ProjectService(),
);
final bandServiceProvider = Provider<BandService>((ref) => BandService());

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final svc = ref.watch(projectServiceProvider);
  final response = await svc.getProjects(page: 0, size: 50, sort: 'name,asc');
  return response.items.where((p) => p.status == 'ACTIVE').toList();
});

final bandsProvider = FutureProvider.family<List<BandInfo>, String>((
  ref,
  projectCode,
) async {
  final svc = ref.watch(bandServiceProvider);
  final list = await svc.getBands(
    projectCode,
    page: 0,
    size: 50,
    sort: 'displayName,asc',
  );
  return list.map((b) => BandInfo(id: b.id, name: b.displayName)).toList();
});

final bandsForSelectionProvider = Provider<AsyncValue<List<BandInfo>>>((ref) {
  final project = ref.watch(selectedProjectProvider);
  if (project == null) return const AsyncData([]);
  return ref.watch(bandsProvider(project));
});
