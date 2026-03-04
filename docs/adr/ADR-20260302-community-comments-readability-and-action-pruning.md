## ADR-20260302: Community Comment Readability and Action Pruning

### Status
- Accepted

### Context
- The user requested:
  - higher readability and stronger visual consistency for comments,
  - removal of repost UI affordance because repost is not supported,
  - explicit copy for like/unlike failure feedback.
- Current action rows still included a repost icon from reference-inspired UX,
  which created a mismatch with actual product capabilities.

### Decision
- Remove repost action from community board/post action rows.
- Keep action bars aligned to real capabilities:
  - board: comment / like / share
  - post detail: comment / like / bookmark
- Improve comment readability and consistency by:
  - using a unified comment container surface with border/radius,
  - increasing content text contrast for body readability,
  - keeping nested reply depth cues (thread line + reply badge) within one
    visual language.
- Change like toggle error copy to cover both flows:
  - `좋아요/좋아요 취소를 반영하지 못했어요`

### Consequences
- UI affordances now match implemented features, reducing user confusion.
- Comment scanning speed improves on mobile due to stronger contrast and a more
  consistent container structure.
- Error feedback is clearer for like/unlike states.

### References
- Updated files:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
