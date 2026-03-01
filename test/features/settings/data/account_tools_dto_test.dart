import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/settings/data/dto/account_tools_dto.dart';

void main() {
  group('account tools dto', () {
    test('UserBlockDto parses blocked user payload', () {
      final dto = UserBlockDto.fromJson({
        'id': 'block-1',
        'blockedUser': {
          'id': 'user-1',
          'displayName': '테스트유저',
          'avatarUrl': 'https://cdn.example.com/a.png',
        },
        'reason': '스팸',
        'createdAt': '2026-03-01T05:00:00Z',
      });

      expect(dto.id, 'block-1');
      expect(dto.blockedUser.id, 'user-1');
      expect(dto.blockedUser.displayName, '테스트유저');
      expect(dto.reason, '스팸');
      expect(dto.createdAt.toUtc().year, 2026);
    });

    test('ProjectRoleRequestDetailDto parses optional review fields', () {
      final dto = ProjectRoleRequestDetailDto.fromJson({
        'id': 'req-1',
        'projectSlug': 'girls-band-cry',
        'projectName': '걸즈 밴드 크라이',
        'requestedRole': 'EDITOR',
        'status': 'IN_REVIEW',
        'justification': '운영 기여를 위해 요청합니다.',
        'reviewDecision': 'PENDING',
        'adminMemo': '검토 예정',
        'reviewedAt': '2026-03-01T06:00:00Z',
        'createdAt': '2026-03-01T05:00:00Z',
      });

      expect(dto.id, 'req-1');
      expect(dto.projectSlug, 'girls-band-cry');
      expect(dto.requestedRole, 'EDITOR');
      expect(dto.status, 'IN_REVIEW');
      expect(dto.reviewDecision, 'PENDING');
      expect(dto.reviewedAt, isNotNull);
    });
  });
}
