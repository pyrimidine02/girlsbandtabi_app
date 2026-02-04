# ADR-20260202 Verification Error Messaging

## Status
- Accepted

## Context
- Place verification failures often return actionable server messages (e.g.
  "Too far from place"), but the UI only displayed a generic validation
  message.
- The backend provides error codes in the `error.code` field, which were not
  propagated for validation failures.

## Decision
- Extract server error codes for 400/422 responses and keep them on
  `ValidationFailure`.
- In the verification sheet, prefer backend validation messages when present
  and localize known messages before displaying them.

## Alternatives Considered
- Keep generic validation messages (rejected: loses actionable feedback).
- Show raw server messages globally (deferred: scope to verification first).

## Consequences
- Verification failures now surface precise reasons such as distance errors.
- User-facing messaging is localized for known server messages.

## References
- lib/core/error/error_handler.dart
- lib/features/verification/presentation/widgets/verification_sheet.dart
