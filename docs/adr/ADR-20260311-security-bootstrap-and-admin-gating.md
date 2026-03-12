# ADR-20260311 Security Bootstrap and Admin Gating Hardening

## Status
- Accepted (2026-03-11)

## Context
- OAuth flow lacked explicit `state` nonce verification, leaving CSRF risk.
- SSE connections could start with stale access token.
- App bootstrap occasionally triggered Riverpod assertion by mutating profile
  state while provider initialization was in progress.
- Mandatory-consent controller directly depended on `ApiClient`, violating
  layer boundaries.
- Admin controllers could issue privileged API calls without controller-level
  authorization guard.
- Places map page scheduled frame callbacks on every build and did not dispose
  `GoogleMapController`.
- Visits repository contained an unsafe `as Success<...>` cast.

## Decision
1. OAuth state protection:
   - Generate secure random `state` nonce before launching OAuth authorize URL.
   - Persist pending `state` + `provider` in secure storage.
   - Validate and consume them in callback before token exchange.

2. SSE token freshness:
   - Inject `ensureFreshToken` callback into SSE client.
   - Execute proactive access-token refresh before opening SSE connection.

3. Bootstrap mutation timing:
   - Queue profile refresh from `userAuthorizationBootstrapProvider` to
     post-frame, avoiding provider-build mutation conflicts.

4. Consent architecture boundary:
   - Move mandatory-consent network access behind `SettingsRepository`.
   - Add repository/data-source contracts:
     - `getMandatoryConsentStatus()`
     - `submitMandatoryConsents(consents)`
   - Remove direct `ApiClient` dependency from mandatory-consent controller.

5. Admin API guard:
   - Add controller-level access check using current user profile access level.
   - Return authorization error state without calling admin APIs when denied.

6. Map lifecycle and callback pressure:
   - Dispose `GoogleMapController` on page dispose.
   - Add one-callback-per-frame guard for map-centering post-frame scheduling.

7. Type-safety hardening:
   - Replace unsafe cast in visits pagination path with explicit success-type
     guard and unknown-result failure fallback.

## Alternatives Considered
- Keep OAuth state validation only on backend:
  - Rejected: frontend callback guard is still required to prevent client-side
    confused-deputy flows and bad UX.
- Keep mandatory-consent direct `ApiClient` access:
  - Rejected: breaks repository boundary and complicates testing/cache policy.
- Guard admin access only in page UI:
  - Rejected: controller/provider can still be instantiated outside intended UI.

## Consequences
- Security posture improved for OAuth and SSE bootstrap timing.
- Provider initialization race reduced on app start.
- Settings layer consistency improved (controller -> repository -> datasource).
- Admin API traffic reduced for unauthorized sessions.
- Map lifecycle and callback behavior stabilized.
- Minor increase in repository interface surface area and test fixture updates.

## Validation
- `flutter analyze` passed.
- `flutter test test/features/settings/application/settings_controller_test.dart`
  passed.
- `flutter test test/features/settings/application/mandatory_consent_controller_test.dart`
  passed.

