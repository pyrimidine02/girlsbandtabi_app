# ADR-20260206: Verification Error Sanitization

## Status
Accepted

## Context
When verification fails due to being too far from a place, the backend may
return messages containing raw distance or location details. The UI showed those
messages directly, exposing sensitive information and producing inconsistent
copy ("너무 멀어요", "알 수 없는 오류", or the raw value).

## Decision
- Normalize "too far" failures by code or message patterns.
- Suppress raw error messages that contain distance/coordinate details.
- Normalize duplicate verification, simulated location, and invalid token
  failures to safe localized copy without exposing sensitive details.
- Fall back to a generic verification failure message for unknown validation
  errors.

## Alternatives Considered
- Keep raw error messages to aid debugging.
- Add server-side changes only.

## Consequences
- Users no longer see raw distance/coordinate values.
- Verification messaging is consistent even when backend responses vary.
- Common verification failures (duplicate requests, simulated location, invalid
  tokens) are explained in Korean without leaking internal details.
