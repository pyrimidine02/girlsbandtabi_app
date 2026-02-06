# ADR-20260206: Release Base URL Defaults

## Status
Accepted

## Context
The app was initialized with the development environment unconditionally, which points to `http://localhost:8080`. This breaks TestFlight builds that must target the production API host.

## Decision
- Select the environment at startup based on `kReleaseMode`.
- Release builds use `Environment.production` (production base URL).
- Debug builds keep `Environment.development` (localhost) for local testing.

## Alternatives Considered
- Hard-code production in all builds.
- Add a `dart-define` environment switch before release.

## Consequences
- TestFlight builds hit the production API without code edits.
- QA/staging targeting still requires a follow-up to add a configurable override.
