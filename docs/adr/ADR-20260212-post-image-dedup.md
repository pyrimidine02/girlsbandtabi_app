# ADR-20260212: Post Detail Image De-duplication

## Status
Accepted

## Context
Some posts embed image markdown inside the body, which is also parsed into
attachments for rendering. In edge cases, the same image appeared twice due to
URL extraction overlaps (full URLs plus bare R2 matches) and unnormalized URL
variants.

## Decision
- Normalize image URLs before rendering and de-duplicate while preserving order.
- Prevent bare R2 URL extraction from matching within full http/https URLs.

## Alternatives Considered
- Remove inline URL extraction entirely (would miss non-markdown image URLs).
- Only show API-provided image arrays (breaks older posts with markdown-only).

## Consequences
- Duplicate images are suppressed without changing the post authoring flow.
- URL parsing remains backward-compatible for legacy R2 references.
