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

  /// EN: Returns members for a given unit, including voice actor info.
  /// KO: 주어진 유닛의 멤버 목록(성우 정보 포함)을 반환합니다.
  Future<Result<List<UnitMember>>> getUnitMembers({
    required String projectId,
    required String unitId,
    bool forceRefresh = false,
  });
}
