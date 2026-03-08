# ADR-20260309 Post Edit Project Context Lock

## Status
- Accepted

## Context
- Editing a community post could fail with backend validation
  (`입력값이 올바르지 않습니다`) when users changed project context in the
  edit screen before submitting.
- Update endpoint path is project-scoped, so post ownership project and request
  project must match.

## Decision
- Lock project context during post edit:
  - capture the project code at edit session start,
  - always use that captured code for `updatePost`,
  - keep selector visible for context, but non-interactive with lock affordance.

## Consequences
- Prevents accidental cross-project update attempts.
- Edit UX becomes predictable: project is fixed while title/content/images/tags
  remain editable.

## Verification
- `flutter analyze lib/features/feed/presentation/pages/post_edit_page.dart`
