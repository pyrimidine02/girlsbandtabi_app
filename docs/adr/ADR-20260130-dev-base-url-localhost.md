# ADR-20260130 Dev Base URL to localhost

## Status
- Accepted

## Context
- We need to validate backend endpoints against a local development server.
- The app defaulted all environments to the production API host, slowing local iteration.

## Decision
- Set the development default base URL to `http://localhost:8080`.
- Keep staging/production defaults unchanged.

## Alternatives Considered
- Pass the base URL via runtime config/env each launch (deferred until endpoint checks are complete).
- Add a UI toggle for base URL (rejected for now: unnecessary for the current validation pass).

## Consequences
- Local endpoint checks become the default in development builds.
- Android emulator/local device networking may require a host alias or port forwarding.

## References
- lib/core/config/app_config.dart
