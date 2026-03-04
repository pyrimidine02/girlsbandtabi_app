## ADR-20260303: Community Reference Redesign Phase 2 (Board/Post Detail)

### Status
- Accepted

### Context
- After phase 1 (profile/connections), board and post-detail still needed a
  clearer information hierarchy aligned with text-first community UX.
- User requested broad reference alignment across modern community products.
- Existing post-detail author interaction required opening menus/profile before
  relationship action, causing extra taps.

### Decision
- Apply phase-2 IA/UX updates without breaking existing routing/state contracts:
  - `BoardPage` community tab:
    - Add context intro card showing active mode/search context and visible
      post count for orientation.
  - `PostDetailPage`:
    - Add inline author interaction row with follow toggle and profile shortcut.
    - Keep block-aware guard: disable follow action when blocked relationship
      exists.

### Consequences
- Users can scan current feed context faster and perform author relationship
  actions directly from the post detail surface.
- Interaction cost is reduced in high-frequency actions (follow/profile move).
- Core architecture remains unchanged while phase-3 can focus on trust/safety
  consolidation and moderation UX.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
