/// EN: Notification settings domain entity.
/// KO: 알림 설정 도메인 엔티티.
library;

import '../../data/dto/notification_settings_dto.dart';

class NotificationSettings {
  const NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.categories,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final List<String> categories;

  static const String categoryLiveEvents = 'LIVE_EVENT';
  static const String categoryFavorites = 'FAVORITE';
  static const String categoryComments = 'COMMENT';

  bool get liveEventsEnabled =>
      _hasCategory(categories, categoryLiveEvents);
  bool get favoritesEnabled => _hasCategory(categories, categoryFavorites);
  bool get commentsEnabled => _hasCategory(categories, categoryComments);

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    List<String>? categories,
    bool? liveEventsEnabled,
    bool? favoritesEnabled,
    bool? commentsEnabled,
  }) {
    final updatedCategories = categories ?? List<String>.from(this.categories);

    if (liveEventsEnabled != null) {
      _toggleCategory(updatedCategories, categoryLiveEvents, liveEventsEnabled);
    }
    if (favoritesEnabled != null) {
      _toggleCategory(updatedCategories, categoryFavorites, favoritesEnabled);
    }
    if (commentsEnabled != null) {
      _toggleCategory(
        updatedCategories,
        categoryComments,
        commentsEnabled,
      );
    }

    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      categories: updatedCategories,
    );
  }

  factory NotificationSettings.fromDto(NotificationSettingsDto dto) {
    return NotificationSettings(
      pushEnabled: dto.pushEnabled,
      emailEnabled: dto.emailEnabled,
      categories: dto.categories,
    );
  }

  factory NotificationSettings.initial() {
    return const NotificationSettings(
      pushEnabled: true,
      emailEnabled: true,
      categories: <String>[
        categoryLiveEvents,
        categoryFavorites,
        categoryComments,
      ],
    );
  }
}

bool _hasCategory(List<String> categories, String target) {
  return categories.any((value) => value.toUpperCase() == target);
}

void _toggleCategory(
  List<String> categories,
  String target,
  bool enabled,
) {
  final existingIndex = categories.indexWhere(
    (value) => value.toUpperCase() == target,
  );
  if (enabled) {
    if (existingIndex == -1) {
      categories.add(target);
    }
    return;
  }
  if (existingIndex != -1) {
    categories.removeAt(existingIndex);
  }
}
