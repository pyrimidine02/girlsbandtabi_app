/// EN: Notification DTO for list items.
/// KO: 알림 목록 DTO.
library;

class NotificationItemDto {
  const NotificationItemDto({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  bool get isRead => read;

  factory NotificationItemDto.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'] as String? ?? '';
    final parsedCreatedAt =
        DateTime.tryParse(createdAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0);

    return NotificationItemDto(
      id: _string(json, ['id', 'notificationId']) ?? '',
      title: _string(json, ['title', 'headline']) ?? '알림',
      body: _string(json, ['body', 'message', 'content']) ?? '',
      createdAt: parsedCreatedAt,
      read: _bool(json, ['read', 'isRead'], false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }
}

class NotificationReadResponseDto {
  const NotificationReadResponseDto({required this.id, required this.read});

  final String id;
  final bool read;

  factory NotificationReadResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificationReadResponseDto(
      id: _string(json, ['id', 'notificationId']) ?? '',
      read: _bool(json, ['read', 'isRead'], false),
    );
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

bool _bool(Map<String, dynamic> json, List<String> keys, bool fallback) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == 'y' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == 'n' || normalized == 'no') {
        return false;
      }
    }
  }
  return fallback;
}
