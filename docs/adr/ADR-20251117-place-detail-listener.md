# ADR-20251117: Stabilize Place Detail project listener

## Status
Accepted

## Context
- `PlaceDetailScreen` listens to `selectedProjectProvider` to reload a place when the user switches projects.
- The listener was registered with `ref.listen` inside `initState`, which violates Riverpod's build-only constraint and triggered the runtime assertion (`ref.listen can only be used within the build method of a ConsumerWidget`).
- The failure prevented the detail view from mounting and also blocked retry handling for upstream API errors (e.g., temporary HTTP 500 responses from `/places/{id}`).

## Decision
- Replace the `ref.listen` usage with `ref.listenManual` so the subscription can be created during `initState` while still complying with Riverpod's lifecycle rules.
- Keep the latest `ProviderSubscription` reference and close it inside `dispose` to avoid leaks.
- Continue to rerun `_load` and reset the `placeVerificationControllerProvider` every time the project changes, ensuring the detail view refreshes immediately after a selection change.

## Consequences
- The screen now mounts without assertions and can gracefully display the existing error UI when the backend responds with HTTP 500, allowing the user to retry.
- Future project-dependent screens should follow the `listenManual` pattern when they need to react to provider changes outside the build phase.
