# ADR-20260204 User Visit Pages

## Status
- Accepted

## Context
- Settings needed visit history and statistics views for the signed-in user.
- API provides `/api/v1/users/me/visits` and `/api/v1/users/me/visits/summary`.

## Decision
- Add Visit History and Visit Statistics pages under Settings.
- Fetch visit events via `/api/v1/users/me/visits` and compute summary stats
  client-side (total visits, unique places, first/last visit, top places).
- Resolve place names using the current project’s place list when available.

## Consequences
- Visits list is cached per page and reused across pages.
- Stats are derived from visit events; summary endpoint remains available for
  future per-place detail views.

## References
- lib/features/visits/**
- lib/features/settings/presentation/pages/settings_page.dart
- lib/core/router/app_router.dart
