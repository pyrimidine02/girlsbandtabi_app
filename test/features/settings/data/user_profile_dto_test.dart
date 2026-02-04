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
      'createdAt': '2026-01-28T00:00:00Z',
    };

    final dto = UserProfileDto.fromJson(json);
    expect(dto.id, 'user-1');
    expect(dto.email, 'tabi@example.com');
    expect(dto.displayName, '탭비');
    expect(dto.avatarUrl, 'https://example.com/avatar.png');
    expect(dto.role, 'USER');
    expect(dto.createdAt, isNotNull);
  });
}
