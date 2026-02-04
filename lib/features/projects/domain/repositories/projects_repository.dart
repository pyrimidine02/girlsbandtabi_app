/// EN: Projects repository interface.
/// KO: 프로젝트 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/project_entities.dart';

abstract class ProjectsRepository {
  Future<Result<List<Project>>> getProjects({bool forceRefresh = false});

  Future<Result<List<Unit>>> getUnits({
    required String projectId,
    bool forceRefresh = false,
  });
}
