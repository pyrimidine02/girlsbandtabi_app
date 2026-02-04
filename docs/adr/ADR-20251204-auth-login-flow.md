# ADR-20251204: Auth-First Navigation and Real Data Wiring

## Status
**Accepted** – Implemented on 2025-12-04

## Context
- QA confirmed the API base URL should remain `http://localhost:8080`, but both the documentation and runtime constants drifted to the staging hostname, so the app was still pointing at production mocks.
- The app booted straight into the home shell with cached dummy data, meaning authentication was never enforced and the dashboard/live events tabs never hit the backend.
- LiveEvents UI, login/logout flows, and settings all relied on hard-coded placeholders (`_mockEvents`, fake profile names, "Coming soon" dialogs), preventing end-to-end verification.

## Decision
1. Re-align `AppConfig`/`ApiEndpoints` and the published API guide to `http://localhost:8080`, and add a sanity test so future edits keep the runtime/documentation URLs in sync.
2. Introduce dedicated `/auth/login` and `/auth/register` routes driven by Riverpod/GoRouter; block navigation to the tab shell until `authController` reports an authenticated state, and funnel logout actions back to the login screen.
3. Replace the home dashboard mocks with real `HomeRemoteDataSource` calls backed by `ApiClient`, including a new `homeQuickAccess` endpoint to source quick actions from the API.
4. Remove the unused enhanced live events screen and build a real repository/use-case/controller stack so the primary live events tab consumes the backend instead of `_mockEvents`.
5. Surface actual user profile data inside Settings (with working logout) so QA can validate authenticated flows with the new entry point.

## Consequences
### Positive
- Every feature that previously used placeholder data (home summary, quick access, live events, settings profile) now exercises the real backend running at `localhost:8080`.
- GoRouter guards ensure that unauthenticated users land on the login form, registration is reachable, and logout tears down state without dangling shells.
- Removing the legacy enhanced live events file eliminates duplicate `LiveEvent` models and lingering mock references.

### Negative / Risks
- The new `homeQuickAccess` endpoint contract must exist on the backend; until it's deployed the UI will show an empty quick access section.
- The live events controller currently fetches a single list and filters on the client; future pagination/filters may require additional use cases.
- Android builds still require environment-specific `MAPS_API_KEY` injection, tracked separately in `TODO.md`.
