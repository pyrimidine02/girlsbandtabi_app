import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/admin_ops/domain/entities/admin_ops_entities.dart';

void main() {
  group('hasAdminOpsAccessRole', () {
    test('returns true for admin/operator roles', () {
      expect(hasAdminOpsAccessRole('ADMIN'), isTrue);
      expect(hasAdminOpsAccessRole('app_manager'), isTrue);
      expect(hasAdminOpsAccessRole('OPERATOR'), isTrue);
    });

    test('returns false for user or empty role', () {
      expect(hasAdminOpsAccessRole('USER'), isFalse);
      expect(hasAdminOpsAccessRole(''), isFalse);
      expect(hasAdminOpsAccessRole(null), isFalse);
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
