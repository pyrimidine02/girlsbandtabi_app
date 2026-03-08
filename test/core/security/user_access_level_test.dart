import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/core/security/user_access_level.dart';

void main() {
  group('UserAccessLevelX.resolve', () {
    test('uses explicit effective access level first', () {
      final resolved = UserAccessLevelX.resolve(
        effectiveAccessLevel: 'CONTENT_EDITOR',
        accountRole: 'USER',
      );
      expect(resolved, UserAccessLevel.contentEditor);
    });

    test('falls back to account role when access level is missing', () {
      final resolved = UserAccessLevelX.resolve(accountRole: 'ADMIN');
      expect(resolved, UserAccessLevel.adminNonSensitive);
    });

    test('returns unknown for unsupported values', () {
      final resolved = UserAccessLevelX.resolve(
        effectiveAccessLevel: 'SOMETHING_NEW',
        accountRole: 'UNKNOWN',
      );
      expect(resolved, UserAccessLevel.unknown);
    });
  });

  group('canModerateCommunity', () {
    test('requires community moderator level or higher', () {
      expect(canModerateCommunity(effectiveAccessLevel: 'USER_BASE'), isFalse);
      expect(
        canModerateCommunity(effectiveAccessLevel: 'COMMUNITY_MODERATOR'),
        isTrue,
      );
      expect(
        canModerateCommunity(effectiveAccessLevel: 'ADMIN_NON_SENSITIVE'),
        isTrue,
      );
    });
  });
}
