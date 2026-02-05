# ADR-20260205: Place Detail Pull-to-Refresh

## Status
Accepted

## Context
Users need to refresh place detail data (visit/favorite stats, guides, comments) without leaving the screen.

## Decision
- Add pull-to-refresh to the place detail screen.
- Refresh place detail, guides, comments, and favorites on demand.

## Alternatives Considered
- Add a manual refresh button in the app bar.
- Refresh only the detail payload without guides/comments.

## Consequences
- Users can swipe down to refresh counts and recent content.
- Network usage increases slightly on manual refresh actions.
