# ADR-20260202 Profile Update Payload

## Status
- Accepted

## Context
- `PATCH /api/v1/users/me` returns 500 on valid `displayName` updates.
- The backend appears to fail when optional fields are omitted or null.

## Decision
- Always include `avatarUrl` in the profile update payload.
- Use the current profile's `avatarUrl` when available, otherwise send an empty
  string to avoid null handling issues on the server.

## Alternatives Considered
- Send only `displayName` (rejected: triggers server 500).
- Block profile updates until backend fix (rejected: prevents editing).

## Consequences
- Profile updates keep the existing avatar URL when present.
- Backend still needs a fix to handle null/omitted fields properly.

## References
- lib/features/settings/data/datasources/settings_remote_data_source.dart
- lib/features/settings/presentation/pages/profile_edit_page.dart
