# ADR-20260309 Firebase Analytics Event Wiring

## Status
Accepted

## Date
2026-03-09

## Context
- Firebase Analytics SDK and wrapper service existed in the app, but runtime
  event wiring was mostly missing.
- Without explicit calls, GA DebugView did not provide actionable product
  signals for core user flows.

## Decision
- Keep using the existing `AnalyticsService` wrapper and wire core events in
  app/runtime layers:
  1. App-scope route-based `screen_view` logging on GoRouter path changes.
  2. Auth success logging:
     - login: `login(method=...)`
     - register: `signup(method=password)`
  3. Search submit logging: `search(query)`.
  4. Post create success logging: `post_create(category)`.
  5. Home-card interaction logging:
     - `place_visit`
     - `live_event_view`

## Consequences
### Positive
- GA starts receiving core conversion/funnel signals without backend contract
  changes.
- Event naming remains centralized through the wrapper, reducing direct SDK
  coupling.

### Trade-offs
- Route-based screen tracking is path-change oriented and may not capture every
  nested visual state transition.

## Scope
- `lib/app.dart`
- `lib/features/auth/application/auth_controller.dart`
- `lib/features/search/presentation/pages/search_page.dart`
- `lib/features/feed/presentation/pages/post_create_page.dart`
- `lib/features/home/presentation/pages/home_page.dart`

## Validation
- `flutter analyze lib/app.dart lib/features/auth/application/auth_controller.dart lib/features/search/presentation/pages/search_page.dart lib/features/feed/presentation/pages/post_create_page.dart lib/features/home/presentation/pages/home_page.dart`
- Firebase DebugView manual check for:
  - `screen_view`
  - `login`
  - `signup`
  - `search`
  - `post_create`
  - `place_visit`
  - `live_event_view`
