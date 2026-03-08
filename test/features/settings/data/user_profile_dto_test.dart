import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/settings/data/dto/user_profile_dto.dart';

void main() {
  test('UserProfileDto parses swagger keys', () {
    final json = {
      'userId': 'user-1',
      'displayName': '탭비',
      'emailAddress': 'tabi@example.com',
      'profileImageUrl': 'https://example.com/avatar.png',
      'role': 'USER',
      'accountRole': 'ADMIN',
      'baselineAccessLevel': 'ADMIN_NON_SENSITIVE',
      'effectiveAccessLevel': 'PLATFORM_SUPER_ADMIN',
      'createdAt': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.id, 'user-1');
    expect(dto.email, 'tabi@example.com');
    expect(dto.displayName, '탭비');
    expect(dto.avatarUrl, 'https://example.com/avatar.png');
    expect(dto.role, 'USER');
    expect(dto.accountRole, 'ADMIN');
    expect(dto.baselineAccessLevel, 'ADMIN_NON_SENSITIVE');
    expect(dto.effectiveAccessLevel, 'PLATFORM_SUPER_ADMIN');
    expect(dto.createdAt, isNotNull);
  });

  test('UserProfileDto falls back to account-role baseline only', () {
    final json = {
      'userId': 'user-legacy',
      'displayName': 'Legacy Admin',
      'emailAddress': 'legacy@example.com',
      'accountRole': 'USER',
      'role': 'MODERATOR',
      'createdAt': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.accountRole, 'USER');
    expect(dto.effectiveAccessLevel, 'USER_BASE');
    expect(dto.baselineAccessLevel, 'USER_BASE');
  });
}
