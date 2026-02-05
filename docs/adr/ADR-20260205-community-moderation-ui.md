# ADR-20260205: Community Moderation UI Wiring

## Status
Accepted

## Context
Community post detail screens already exposed menus for moderation actions, but the UI was not consistently wired to report/block endpoints and comment reporting lacked a UI path. Snackbar feedback for edit/delete actions also varied across posts and comments.

## Decision
- Wire post/report/block actions to the moderation repository and add a report bottom sheet with reason selection and optional description.
- Add comment-level reporting via the comment overflow menu for non-authors.
- Expose block/unblock toggles on community user profiles for authenticated viewers.
- Standardize snackbar messaging for post/comment edit and delete actions.

## Alternatives Considered
- Defer moderation UI until a dedicated moderation screen exists.
- Use a single dialog instead of a bottom sheet for report reasons.

## Consequences
- Users can report posts/comments and block authors directly from the post detail screen.
- Moderation actions now return consistent feedback via snackbars.
- Comment reporting is available without adding a separate moderation surface.
