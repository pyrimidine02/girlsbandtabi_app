import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/notifications/domain/entities/notification_navigation.dart';

void main() {
  test('normalizeNotificationType maps legacy aliases', () {
    expect(
      normalizeNotificationType('FOLLOWING_POST'),
      notificationTypePostCreated,
    );
    expect(
      normalizeNotificationType('FOLLOWING_POST_CREATED'),
      notificationTypePostCreated,
    );
    expect(
      normalizeNotificationType('MY_POST_COMMENT_CREATED'),
      'COMMENT_CREATED',
    );
    expect(
      normalizeNotificationType('MY_COMMENT_REPLY_CREATED'),
      'COMMENT_REPLY_CREATED',
    );
    expect(
      normalizeNotificationType('SYSTEM_BROADCAST'),
      notificationTypeSystemNotice,
    );
  });

  test(
    'resolveNotificationNavigationPath resolves post detail via deeplink',
    () {
      final path = resolveNotificationNavigationPath(
        type: 'POST_CREATED',
        deeplink: '/board/posts/38f55757-6953-44d4-abb8-8ab0ec35003e',
        actionUrl: '/notifications',
      );

      expect(path, '/board/posts/38f55757-6953-44d4-abb8-8ab0ec35003e');
    },
  );

  test(
    'resolveNotificationNavigationPath converts API actionUrl to app path',
    () {
      final path = resolveNotificationNavigationPath(
        type: 'POST_CREATED',
        actionUrl:
            'https://api.noraneko.cc/api/v1/projects/girls-band-cry/posts/38f55757-6953-44d4-abb8-8ab0ec35003e',
      );

      expect(path, '/board/posts/38f55757-6953-44d4-abb8-8ab0ec35003e');
    },
  );

  test(
    'resolveNotificationNavigationPath routes SYSTEM_NOTICE without link to inbox',
    () {
      final path = resolveNotificationNavigationPath(type: 'SYSTEM_NOTICE');
      expect(path, '/notifications');
    },
  );

  test(
    'resolveNotificationNavigationPath prioritizes deeplink over actionUrl',
    () {
      final path = resolveNotificationNavigationPath(
        type: 'SYSTEM_NOTICE',
        deeplink: '/board/posts/abc-123',
        actionUrl: '/notifications',
      );
      expect(path, '/board/posts/abc-123');
    },
  );

  test(
    'resolveNotificationNavigationPath routes POST_CREATED without post id to board',
    () {
      final path = resolveNotificationNavigationPath(type: 'POST_CREATED');
      expect(path, '/board');
    },
  );

  test(
    'resolveNotificationNavigationPath converts /community/posts to /board/posts',
    () {
      final path = resolveNotificationNavigationPath(
        type: 'COMMENT_CREATED',
        deeplink: '/community/posts/38f55757-6953-44d4-abb8-8ab0ec35003e',
      );
      expect(path, '/board/posts/38f55757-6953-44d4-abb8-8ab0ec35003e');
    },
  );

  test(
    'resolveNotificationNavigationPath routes comment-like types using entity id',
    () {
      final path = resolveNotificationNavigationPath(
        type: 'COMMENT_REPLY_CREATED',
        entityId: '38f55757-6953-44d4-abb8-8ab0ec35003e',
      );
      expect(path, '/board/posts/38f55757-6953-44d4-abb8-8ab0ec35003e');
    },
  );
}
