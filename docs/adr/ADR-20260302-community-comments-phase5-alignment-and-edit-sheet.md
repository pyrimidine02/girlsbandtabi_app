## ADR-20260302: Community Comments Phase 5 Alignment and Edit-Sheet Unification

### Status
- Accepted

### Context
- After the Phase 4 redesign, user feedback identified three practical issues:
  - comments looked left-shifted,
  - author-name to content spacing felt too loose,
  - edit UI did not feel visually consistent with current comment compose patterns.
- Additional requirement: show comment author avatar on the left and navigate to profile on tap.

### Decision
- Normalize indentation depth from API to support both contracts:
  - root depth as `0`, or root depth as `1`.
- Tighten vertical rhythm between author metadata and content body.
- Restore left-side comment avatar and keep tap-to-profile behavior.
- Replace alert-dialog style comment edit UI with a bottom-sheet editor that
  matches current comment input tone (filled field + cancel/save action row).

### Consequences
- Root comments remain visually aligned regardless of backend depth convention.
- Readability improves through denser metadata-to-content spacing.
- Avatar affordance and profile navigation are restored without losing current
  moderation actions.
- Edit interaction feels consistent with the rest of feed/comment surfaces.

### Verification
- `dart format lib/features/feed/presentation/pages/post_detail_page.dart`
- `flutter analyze lib/features/feed/presentation/pages/post_detail_page.dart`
- `flutter test test/features/feed`

### Updated File
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
