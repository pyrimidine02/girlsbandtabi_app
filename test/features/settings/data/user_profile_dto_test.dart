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
      'baselineAccessLevel': 'PLATFORM_SUPER_ADMIN',
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
    expect(dto.baselineAccessLevel, 'PLATFORM_SUPER_ADMIN');
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

  test('UserProfileDto supports snake_case and role list aliases', () {
    final json = {
      'user_id': 'user-admin',
      'display_name': 'Admin Legacy',
      'email_address': 'admin@example.com',
      'roles': ['ROLE_ADMIN'],
      'effective_access_level': 'admin_non_sensitive',
      'created_at': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.id, 'user-admin');
    expect(dto.displayName, 'Admin Legacy');
    expect(dto.email, 'admin@example.com');
    expect(dto.accountRole, 'ADMIN');
    expect(dto.role, 'ADMIN');
    expect(dto.effectiveAccessLevel, 'ADMIN_NON_SENSITIVE');
    expect(dto.baselineAccessLevel, 'PLATFORM_SUPER_ADMIN');
  });

  test('UserProfileDto derives admin fallback when accountRole is missing', () {
    final json = {
      'userId': 'user-admin-2',
      'displayName': 'Role Admin',
      'emailAddress': 'role-admin@example.com',
      'role': 'ROLE_ADMIN',
      'createdAt': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.accountRole, 'ADMIN');
    expect(dto.effectiveAccessLevel, 'PLATFORM_SUPER_ADMIN');
    expect(dto.baselineAccessLevel, 'PLATFORM_SUPER_ADMIN');
  });

  test('UserProfileDto parses project role map payload', () {
    final json = {
      'userId': 'user-3',
      'displayName': 'Project Mod',
      'emailAddress': 'project-mod@example.com',
      'accountRole': 'USER',
      'projectRoles': {
        'girls-band-cry': ['COMMUNITY_MODERATOR', 'MEMBER'],
        'project-uuid-1': ['PLACE_EDITOR'],
      },
      'createdAt': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.projectRolesByProject['girls-band-cry'], isNotNull);
    expect(
      dto.projectRolesByProject['girls-band-cry'],
      contains('COMMUNITY_MODERATOR'),
    );
    expect(
      dto.projectRolesByProject['project-uuid-1'],
      contains('PLACE_EDITOR'),
    );
  });

  test('UserProfileDto parses project role list payload', () {
    final json = {
      'userId': 'user-4',
      'displayName': 'Project Admin',
      'emailAddress': 'project-admin@example.com',
      'accountRole': 'USER',
      'project_roles': [
        {
          'projectId': 'uuid-a',
          'roles': ['ADMIN', 'MEMBER'],
        },
        {'projectCode': 'girls-band-cry', 'role': 'COMMUNITY_MODERATOR'},
      ],
      'createdAt': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.projectRolesByProject['uuid-a'], contains('ADMIN'));
    expect(
      dto.projectRolesByProject['girls-band-cry'],
      contains('COMMUNITY_MODERATOR'),
    );
  });
}
