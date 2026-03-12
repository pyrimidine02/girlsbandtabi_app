# ADR-20260312: Music Information + Live Setlist Frontend Integration

## Status
Accepted

## Context
- Backend delivered music-information endpoints and live setlist linkage:
  - `/api/v1/projects/{projectId}/music/...`
  - `/api/v1/projects/{projectId}/live-events/{liveEventId}/setlist`
- Existing app had no music feature module and Info > Songs tab was placeholder.
- Live detail page did not call setlist API and could not deep-link to song detail.

## Decision
- Added a new `music` feature module with Clean Architecture boundaries:
  - `domain/entities`
  - `domain/repositories`
  - `data/datasources`
  - `data/repositories`
  - `application` (Riverpod providers/controllers)
  - `presentation/pages/music_song_detail_page.dart`
- Implemented full API client wiring for:
  - album cursor list/detail
  - song cursor list/detail
  - lyrics / parts / call-guide
  - versions / version detail
  - credits / difficulty / media-links / availability
  - live-context (eventId required)
  - live setlist
- Replaced Info > Songs placeholder with real project-scoped album/song UI.
- Added song detail route + overlay route and router helper:
  - `/info/songs/:songId?projectId=...&eventId=...`
  - `/overlay/music/songs/:songId?...`
  - `context.goToSongDetail(...)`
- Added live detail setlist section:
  - renders `SCHEDULED | COMPLETED | INACTIVE`
  - keeps legacy `songId == null` items non-clickable
  - enables deep-link to song detail only when `songId` exists

## Consequences
- Info tab now triggers real network calls for songs/albums and supports cursor load-more.
- Live detail now consumes setlist endpoint and supports completed-live setlist UI.
- Song detail can render integrated music sections and optional live-context.
- Feature complexity increases, but module boundaries remain isolated under `features/music`.

## Validation
- `dart analyze` on changed files: pass.
- `flutter analyze` on music/info/router/live detail scope: pass.
- `flutter test test/core/constants/api_endpoints_contract_test.dart`: pass.
