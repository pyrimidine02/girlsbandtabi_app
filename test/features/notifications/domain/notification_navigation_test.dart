import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/notifications/domain/entities/notification_navigation.dart';

void main() {
  test('normalizeNotificationType maps legacy aliases', () {
    expect(
      normalizeNotificationType('FOLLOWING_POST'),
      notificationTypePostCreated,
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
            'https://api.pyrimidines.org/api/v1/projects/girls-band-cry/posts/38f55757-6953-44d4-abb8-8ab0ec35003e',
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
    'resolveNotificationNavigationPath routes POST_CREATED without post id to board',
    () {
      final path = resolveNotificationNavigationPath(type: 'POST_CREATED');
      expect(path, '/board');
    },
  );
}
