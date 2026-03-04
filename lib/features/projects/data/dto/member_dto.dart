/// EN: DTO for a unit member (band character / voice actor).
/// KO: 유닛 멤버(밴드 캐릭터 / 성우) DTO.
library;

class MemberDto {
  const MemberDto({
    required this.id,
    required this.name,
    this.role,
    this.voiceActorName,
    this.imageUrl,
    this.order,
    this.birthdate,
    this.description,
    this.instrument,
    this.isActive,
  });

  final String id;
  final String name;
  final String? role;
  final String? voiceActorName;
  final String? imageUrl;
  final int? order;
  final String? birthdate;
  final String? description;
  final String? instrument;
  final bool? isActive;

  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      id: _string(json, ['id', 'memberId']) ?? '',
      name: _string(json, ['name', 'displayName', 'characterName']) ?? '?',
      role: _string(json, ['role', 'position', 'type']),
      voiceActorName:
          _string(json, ['voiceActorName', 'voiceActor', 'cv', 'seiyuu']),
      imageUrl: _string(json, ['imageUrl', 'image', 'avatarUrl', 'photoUrl']),
      order: json['order'] is int ? json['order'] as int : null,
      birthdate: _string(json, ['birthdate', 'birthday', 'birthDate']),
      description: _string(json, ['description', 'bio', 'profile']),
      instrument: _string(json, ['instrument', 'part']),
      isActive: json['active'] is bool
          ? json['active'] as bool
          : json['isActive'] is bool
          ? json['isActive'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (role != null) 'role': role,
    if (voiceActorName != null) 'voiceActorName': voiceActorName,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (order != null) 'order': order,
    if (birthdate != null) 'birthdate': birthdate,
    if (description != null) 'description': description,
    if (instrument != null) 'instrument': instrument,
    if (isActive != null) 'isActive': isActive,
  };
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
