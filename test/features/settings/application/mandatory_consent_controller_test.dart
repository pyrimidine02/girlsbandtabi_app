import 'package:flutter_test/flutter_test.dart';
import 'package:girlsbandtabi_app/features/settings/application/mandatory_consent_controller.dart';

void main() {
  group('parseMandatoryConsentStatusPayload', () {
    test('parses canUseService and required consent list', () {
      final payload = parseMandatoryConsentStatusPayload({
        'canUseService': false,
        'requiredConsents': [
          {
            'type': 'TERMS_OF_SERVICE',
            'requiredVersion': 'v2026.03.10',
            'policyUrl': 'https://example.com/policies/terms/v2026.03.10',
            'agreed': false,
            'agreedVersion': null,
            'agreedAt': null,
            'needsReconsent': true,
          },
          {
            'type': 'PRIVACY_POLICY',
            'requiredVersion': 'v2026.03.10',
            'policyUrl': 'https://example.com/policies/privacy/v2026.03.10',
            'agreed': true,
            'agreedVersion': 'v2026.03.01',
            'agreedAt': '2026-03-01T03:10:00Z',
            'needsReconsent': true,
          },
        ],
      });

      expect(payload.canUseService, isFalse);
      expect(payload.requiredConsents, hasLength(2));
      expect(payload.requiredConsents.first.type, 'TERMS_OF_SERVICE');
      expect(payload.requiredConsents.first.requiredVersion, 'v2026.03.10');
    });

    test('falls back to blocking payload on invalid response shape', () {
      final payload = parseMandatoryConsentStatusPayload('invalid');

      expect(payload.canUseService, isFalse);
      expect(payload.requiredConsents, isEmpty);
    });
  });

  group('resolveBlockingRequiredConsents', () {
    test('returns needsReconsent entries', () {
      final blocking = resolveBlockingRequiredConsents(
        consents: const [
          RequiredConsentStatusItem(
            type: 'TERMS_OF_SERVICE',
            requiredVersion: 'v2026.03.10',
            policyUrl: 'https://example.com/terms',
            agreed: true,
            agreedVersion: 'v2026.03.10',
            agreedAt: '2026-03-10T10:30:00Z',
            needsReconsent: false,
          ),
          RequiredConsentStatusItem(
            type: 'PRIVACY_POLICY',
            requiredVersion: 'v2026.03.10',
            policyUrl: 'https://example.com/privacy',
            agreed: true,
            agreedVersion: 'v2026.03.01',
            agreedAt: '2026-03-01T03:10:00Z',
            needsReconsent: true,
          ),
        ],
      );

      expect(blocking, hasLength(1));
      expect(blocking.first.type, 'PRIVACY_POLICY');
    });

    test('treats not-agreed entries as blocking even if needsReconsent=false', () {
      final blocking = resolveBlockingRequiredConsents(
        consents: const [
          RequiredConsentStatusItem(
            type: 'TERMS_OF_SERVICE',
            requiredVersion: 'v2026.03.10',
            policyUrl: 'https://example.com/terms',
            agreed: false,
            agreedVersion: null,
            agreedAt: null,
            needsReconsent: false,
          ),
        ],
      );

      expect(blocking, hasLength(1));
      expect(blocking.first.type, 'TERMS_OF_SERVICE');
    });
  });
}
