import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

final projectServiceProvider = Provider<ProjectService>((ref) => ProjectService());

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final service = ref.watch(projectServiceProvider);
  final response = await service.getProjects(page: 0, size: 100); // Fetch a reasonable number of projects
  return response.items;
});

final selectedProjectIdentifierProvider = Provider<String>((ref) {
  // This is the ID the user provided as the 'actual ID'
  const String targetProjectId = '550e8400-e29b-41d4-a716-446655440001';

  final projectsAsyncValue = ref.watch(projectsProvider);

  return projectsAsyncValue.when(
    data: (projects) {
      final project = projects.firstWhere(
        (p) => p.id == targetProjectId,
        orElse: () => throw Exception('Target project not found'),
      );
      return project.id;
    },
    loading: () => targetProjectId, // Fallback to the target ID while loading
    error: (err, stack) => targetProjectId, // Fallback to the target ID on error
  );
});