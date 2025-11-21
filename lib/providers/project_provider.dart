import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_model.dart';
import '../services/project_service.dart';

final projectServiceProvider = Provider<ProjectService>(
  (ref) => ProjectService(),
);

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final service = ref.watch(projectServiceProvider);
  final response = await service.getProjects(
    page: 0,
    size: 100,
  ); // EN: Fetch a reasonable number of projects / KO: 적정한 수의 프로젝트 조회
  return response.items;
});
