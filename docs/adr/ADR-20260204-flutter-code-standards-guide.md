# ADR-20260204 Flutter Code Standards Guide

## Status
- Accepted

## Context
- The existing code standards document targets Kotlin server code.
- The Flutter app needs a dedicated Dart/Flutter standards guide with
  bilingual (EN/KO) comment rules and project-specific conventions.

## Decision
- Add a Flutter-specific code standard document under `docs/`.
- Align the document with Effective Dart and current app architecture.

## Alternatives Considered
- Overwrite the Kotlin guide (rejected: server code still uses it).

## Consequences
- The Flutter team has a single source of truth for style and documentation.
- Kotlin guide remains unchanged for backend work.

## References
- docs/코드표준가이드_flutter_v1.0.0.md
