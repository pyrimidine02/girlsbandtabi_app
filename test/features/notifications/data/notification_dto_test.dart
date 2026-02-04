import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/notifications/data/dto/notification_dto.dart';

void main() {
  test('NotificationItemDto parses swagger keys', () {
    final json = {
      'notificationId': 'noti-1',
      'headline': '새 소식',
      'message': '새 뉴스가 도착했습니다',
      'createdAt': '2026-01-28T00:00:00Z',
      'read': false,
    };

    final dto = NotificationItemDto.fromJson(json);
    expect(dto.id, 'noti-1');
    expect(dto.title, '새 소식');
    expect(dto.body, '새 뉴스가 도착했습니다');
    expect(dto.createdAt, isNotNull);
    expect(dto.isRead, false);
  });
}
