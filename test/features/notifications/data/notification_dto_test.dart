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
      'notificationType': 'FOLLOWING_POST',
      'actionUrl': '/api/v1/projects/girls-band-cry/posts/abc-123',
      'deeplink': '/board/posts/abc-123',
      'entityId': 'abc-123',
      'projectCode': 'girls-band-cry',
    };

    final dto = NotificationItemDto.fromJson(json);
    expect(dto.id, 'noti-1');
    expect(dto.title, '새 소식');
    expect(dto.body, '새 뉴스가 도착했습니다');
    expect(dto.createdAt, isNotNull);
    expect(dto.isRead, false);
    expect(dto.type, 'FOLLOWING_POST');
    expect(dto.actionUrl, '/api/v1/projects/girls-band-cry/posts/abc-123');
    expect(dto.deeplink, '/board/posts/abc-123');
    expect(dto.entityId, 'abc-123');
    expect(dto.projectCode, 'girls-band-cry');
  });

  test('NotificationItemDto parses snake_case action/deeplink keys', () {
    final json = {
      'id': 'noti-2',
      'title': '공지',
      'body': '운영 공지',
      'createdAt': '2026-03-07T00:00:00Z',
      'isRead': true,
      'type': 'SYSTEM_BROADCAST',
      'action_url': '/notifications',
      'deep_link': '/notifications',
      'entity_id': 'entity-1',
      'project_code': 'girls-band-cry',
    };

    final dto = NotificationItemDto.fromJson(json);
    expect(dto.id, 'noti-2');
    expect(dto.type, 'SYSTEM_BROADCAST');
    expect(dto.actionUrl, '/notifications');
    expect(dto.deeplink, '/notifications');
    expect(dto.entityId, 'entity-1');
    expect(dto.projectCode, 'girls-band-cry');
  });
}
