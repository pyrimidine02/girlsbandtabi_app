# ADR-20260206: Android Emulator Localhost Base URL

## Status
Accepted

## Context
Android emulators resolve `localhost` to the emulator itself, so development
builds failed to reach the host machine's Dockerized API when using
`http://localhost:8080`.

## Decision
- For `Environment.development` on Android emulator builds, use
  `http://10.0.2.2:8080` as the default base URL.
- Keep `http://localhost:8080` for other platforms in development.

## Alternatives Considered
- Require developers to manually override the base URL for Android.
- Introduce `dart-define` overrides only.

## Consequences
- Android emulator builds can reach the host machine API without manual edits.
- Physical Android devices still require a LAN IP override.
