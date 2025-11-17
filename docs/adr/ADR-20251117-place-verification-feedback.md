# ADR-20251117: Improve Place Verification feedback

## Status
Accepted

## Context
- Place verification requests often return non-`VERIFIED` results (e.g., out-of-range, low accuracy, cooldown), but the client only displayed the generic label "인증에 실패했습니다" with no actionable reason.
- The backend includes a `result` code (e.g., `FAILED_DISTANCE_TOO_FAR`) and sometimes a `message`, yet most responses leave `message` empty, causing the UI to omit the cause entirely.
- Support agents and users asked for clearer feedback so they know whether to move closer, wait out a cooldown, or review their location permissions.

## Decision
- Extend `PlaceVerificationState` with a `resultCode` field to preserve the server result for UI display and debugging.
- Introduce `_mapResultToMessage` in `PlaceVerificationController` to translate known result patterns (distance/range, accuracy, token, cooldown, spoofing, duplicates) into localized guidance, falling back to the raw code when unknown.
- Show the resolved message inside the verification sheet and append the normalized error code for transparency, ensuring progress/error messaging survives provider resets.

## Consequences
- Users now see concrete instructions such as "측정된 위치가 성지 반경을 벗어났습니다" instead of the generic failure banner, reducing repeated support tickets.
- QA/support can reference the surfaced error code when triaging backend issues.
- Future backend result codes only require an update to `_mapResultToMessage` to keep UX aligned; until then, the fallback displays the code string so we never hide the failure reason again.
