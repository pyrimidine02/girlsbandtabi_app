## ADR-20260302: Community Post-Detail Comments Everytime-Style Alignment (Phase 4)

### Status
- Accepted

### Context
- The user requested a stronger comment UX alignment with Everytime-style reading flow in post detail.
- Existing Phase 3 comment UI improved contrast but still felt card/thumbnail-driven and visually heavier than the surrounding board/feed surfaces.
- Goal: maximize readability and reply scanning speed while preserving existing moderation and interaction capabilities.

### Decision
- Rebuild post-detail comments into a text-first list thread pattern:
  - remove per-comment avatar row in favor of compact author/meta line,
  - change sort controls from chip-like controls to slim text toggles,
  - add `글쓴이` badge when comment author matches post author,
  - keep nested depth with compact indentation + vertical reply lane,
  - keep divider-based separation and compact reply actions (`답글`, `답글 N개 보기`).
- Preserve existing behavior:
  - comment edit/delete/report menus,
  - thread open action for replies,
  - author profile tap navigation.

### Consequences
- Comment density and scanability improve on mobile; users can read more comments per viewport.
- Header/action rhythm across board and detail is now more consistent with forum-style interaction.
- Interaction capability is unchanged, so regression risk is mostly visual/layout-level.

### Verification
- `flutter analyze lib/features/feed/presentation/pages/post_detail_page.dart`
- `flutter test test/features/feed`

### References
- Everytime app listing (forum-first interaction baseline):
  https://play.google.com/store/apps/details?id=com.everytime.v2
- Updated file:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
