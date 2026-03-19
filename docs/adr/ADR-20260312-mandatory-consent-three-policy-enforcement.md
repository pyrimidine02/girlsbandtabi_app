# ADR-20260312: Mandatory Consent 3-Policy Enforcement

## Status
Accepted

## Context
- Backend mandatory-consent policy changed from 2 required policies to 3:
  - `TERMS_OF_SERVICE`
  - `PRIVACY_POLICY`
  - `LOCATION_TERMS`
- Service usage must be blocked while any required policy is not agreed.
- Consent submit API now requires all 3 policy records in one request.

## Decision
- Strengthened mandatory consent gate in app bootstrap flow:
  - enforce 3-type mandatory set resolution in
    `MandatoryConsentController`
  - block submission when required 3-type set cannot be built
  - submit payload with the 3 required records only
- Added refresh trigger after access-token refresh events by listening to
  `authTokenRefreshTickProvider`.
- Updated consent overlay labels/copy to include location terms.
- Updated register-page required consent section and signup payload to include
  `LOCATION_TERMS`.
- Updated legal policy constants version to `v2026.03.12`.

## Consequences
- Users cannot proceed unless all 3 required policy consents are satisfied.
- Consent status is revalidated on login and token-refresh boundaries.
- Register flow aligns with new backend consent type requirements.

## Validation
- `dart analyze` on modified consent/register/app/legal files: pass.
- `flutter test test/features/settings/application/mandatory_consent_controller_test.dart`: pass.
