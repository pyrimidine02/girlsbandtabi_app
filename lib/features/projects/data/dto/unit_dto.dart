/// EN: Unit DTO for project units.
/// KO: 프로젝트 유닛 DTO.
library;

class UnitDto {
  const UnitDto({
    required this.id,
    required this.code,
    required this.displayName,
  });

  final String id;
  final String code;
  final String displayName;

  factory UnitDto.fromJson(Map<String, dynamic> json) {
    return UnitDto(
      id: _string(json, ['id', 'unitId']) ?? '',
      code: _string(json, ['code', 'bandCode']) ?? '',
      displayName: _string(json, ['displayName', 'name', 'title']) ?? '유닛',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'displayName': displayName};
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
