import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

@freezed
class Project with _$Project {
  factory Project({
    required String id,
    required String name,
    required String code,
    required String status,
    @JsonKey(name: 'defaultTimezone') required String defaultTimezone,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}

@freezed
class PageResponseProject with _$PageResponseProject {
  const factory PageResponseProject({
    required List<Project> items,
    required int page,
    required int size,
    required int total,
    int? totalPages,
    @Default(false) bool hasNext,
    @Default(false) bool hasPrevious,
  }) = _PageResponseProject;

  factory PageResponseProject.fromJson(Map<String, dynamic> json) => _$PageResponseProjectFromJson(json);
}
