import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/settings/data/dto/notification_settings_dto.dart';

void main() {
  test('NotificationSettingsDto parses categories', () {
    final json = {
      'push': true,
      'email_enabled': 'false',
      'categories': ['LIVE_EVENTS', 'NEWS'],
    };

    final dto = NotificationSettingsDto.fromJson(json);
    expect(dto.pushEnabled, true);
    expect(dto.emailEnabled, false);
    expect(dto.categories.length, 2);
  });
}
