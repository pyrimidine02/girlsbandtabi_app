# ADR-20251117 Prevent pre-login network requests

## Status
Accepted

## Context
- Launching the app triggered `GET /api/v1/projects` because `selectedProjectProvider` eagerly depended on `projectsProvider`, which runs as soon as persistence initializes—even before the user authenticates.
- `checkAuthStatus()` also hit `GET /api/v1/users/me` on every cold start because `AuthLocalDataSource.getCachedUser` never returned real data; the cache stored a `Map.toString()` placeholder and deserialization was unimplemented, so the controller always fell back to the network.
- When the backend (10.0.2.2:8080) is offline, these automatic calls spam connection-refused errors before the login screen even renders.

## Decision
- Remove the implicit network dependency from `selectedProjectProvider` and let it start with a local `null` selection; UI that needs a project continues to fall back to `ApiConstants.defaultProjectId`, so no server call happens until an authenticated screen actually needs data.
- Persist the authenticated user as JSON in `SharedPreferences` and deserialize it when available so `GetCurrentUserUseCase` can satisfy `checkAuthStatus()` without invoking the remote data source when valid cache data exists.

## Consequences
- Cold starts no longer trigger `/api/v1/projects` requests while the user is unauthenticated; the first project fetch now occurs only after the user signs in and opens a screen that needs it.
- `checkAuthStatus()` becomes instant/offline-friendly because it resolves cached users before contacting `/api/v1/users/me`, which also eliminates connection-refused noise when the backend is down.
- We now rely on JSON encoding for the cached user; if the schema changes, this string must stay backward compatible or we should store a version for migrations.
