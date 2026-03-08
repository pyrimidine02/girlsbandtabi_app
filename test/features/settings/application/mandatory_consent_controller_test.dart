import 'package:flutter_test/flutter_test.dart';
import 'package:girlsbandtabi_app/features/settings/application/mandatory_consent_controller.dart';

void main() {
  group('resolveMissingRequiredConsents', () {
    test('returns both required items when history is empty', () {
      final missing = resolveMissingRequiredConsents(records: const []);

      expect(missing, {
        RequiredConsentType.termsOfService,
        RequiredConsentType.privacyPolicy,
      });
    });

    test(
      'returns empty when both required consents are agreed with current versions',
      () {
        final missing = resolveMissingRequiredConsents(
          records: [
            ConsentHistoryRecord(
              type: RequiredConsentType.termsOfService.apiType,
              version: RequiredConsentType.termsOfService.currentVersion,
              agreed: true,
              agreedAt: '2026-03-08T01:00:00Z',
            ),
            ConsentHistoryRecord(
              type: RequiredConsentType.privacyPolicy.apiType,
              version: RequiredConsentType.privacyPolicy.currentVersion,
              agreed: true,
              agreedAt: '2026-03-08T01:01:00Z',
            ),
          ],
        );

        expect(missing, isEmpty);
      },
    );

    test('returns missing type when latest consent version is outdated', () {
      final missing = resolveMissingRequiredConsents(
        records: [
          ConsentHistoryRecord(
            type: RequiredConsentType.termsOfService.apiType,
            version: 'v2025.12.31',
            agreed: true,
            agreedAt: '2026-03-08T01:00:00Z',
          ),
          ConsentHistoryRecord(
            type: RequiredConsentType.privacyPolicy.apiType,
            version: RequiredConsentType.privacyPolicy.currentVersion,
            agreed: true,
            agreedAt: '2026-03-08T01:01:00Z',
          ),
        ],
      );

      expect(missing, {RequiredConsentType.termsOfService});
    });

    test('uses latest timestamp record for each consent type', () {
      final missing = resolveMissingRequiredConsents(
        records: [
          ConsentHistoryRecord(
            type: RequiredConsentType.termsOfService.apiType,
            version: RequiredConsentType.termsOfService.currentVersion,
            agreed: false,
            agreedAt: '2026-03-08T01:00:00Z',
          ),
          ConsentHistoryRecord(
            type: RequiredConsentType.termsOfService.apiType,
            version: RequiredConsentType.termsOfService.currentVersion,
            agreed: true,
            agreedAt: '2026-03-08T01:02:00Z',
          ),
          ConsentHistoryRecord(
            type: RequiredConsentType.privacyPolicy.apiType,
            version: RequiredConsentType.privacyPolicy.currentVersion,
            agreed: true,
            agreedAt: '2026-03-08T01:01:00Z',
          ),
        ],
      );

      expect(missing, isEmpty);
    });
  });
}
