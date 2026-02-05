/// EN: Notification settings DTO for push/email preferences.
/// KO: 푸시/이메일 알림 설정 DTO.
library;

class NotificationSettingsDto {
  const NotificationSettingsDto({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.categories,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final List<String> categories;

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    final categoriesRaw = json['categories'];
    final categories = <String>[];
    if (categoriesRaw is List) {
      categories.addAll(categoriesRaw.whereType<String>());
    }

    return NotificationSettingsDto(
      pushEnabled: _bool(json, ['pushEnabled', 'push', 'push_enabled'], true),
      emailEnabled: _bool(json, [
        'emailEnabled',
        'email',
        'email_enabled',
      ], true),
      categories: categories,
    );
  }

  Map<String, dynamic> toJson() {
    final normalizedCategories = _normalizeCategories(categories);
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'categories': normalizedCategories,
    };
  }
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

List<String> _normalizeCategories(List<String> categories) {
  const allowed = <String>{'LIVE_EVENT', 'FAVORITE', 'COMMENT'};
  final normalized = <String>[];
  for (final raw in categories) {
    final upper = raw.toUpperCase();
    if (upper == 'LIVE_EVENTS') {
      if (!normalized.contains('LIVE_EVENT')) {
        normalized.add('LIVE_EVENT');
      }
      continue;
    }
    if (allowed.contains(upper) && !normalized.contains(upper)) {
      normalized.add(upper);
    }
  }
  return normalized;
}
