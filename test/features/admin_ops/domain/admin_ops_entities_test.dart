import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/admin_ops/domain/entities/admin_ops_entities.dart';

void main() {
  group('hasAdminOpsAccess', () {
    test('prefers effective access level from new policy', () {
      expect(
        hasAdminOpsAccess(effectiveAccessLevel: 'ADMIN_NON_SENSITIVE'),
        isTrue,
      );
      expect(
        hasAdminOpsAccess(effectiveAccessLevel: 'COMMUNITY_MODERATOR'),
        isFalse,
      );
    });

    test('falls back to account role when access level is missing', () {
      expect(hasAdminOpsAccess(accountRole: 'ADMIN'), isTrue);
      expect(hasAdminOpsAccess(accountRole: 'USER'), isFalse);
    });
  });

  group('AdminReportStatusX', () {
    test('maps fallback API states', () {
      expect(
        AdminReportStatusX.fromApiValue('PENDING'),
        AdminReportStatus.open,
      );
      expect(
        AdminReportStatusX.fromApiValue('UNDER_REVIEW'),
        AdminReportStatus.inReview,
      );
      expect(
        AdminReportStatusX.fromApiValue('CLOSED'),
        AdminReportStatus.resolved,
      );
    });
  });
}
