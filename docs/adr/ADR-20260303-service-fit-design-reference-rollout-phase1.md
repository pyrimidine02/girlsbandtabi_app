## ADR-20260303: Service-Fit Design Reference Rollout (Phase 1)

### Status
- Accepted

### Context
- User requested a stronger redesign because current UI looked cluttered and hard to use.
- Current app had mixed visual density across major surfaces (bottom navigation, segmented tabs, search bars, home entry points).
- The app domain (places + live events + community) needs fast scanning and low-friction thumb interactions.

### Decision
- Apply a first-pass redesign focused on high-frequency interaction primitives:
  - Rebuild bottom navigation into a floating, pill-accented bar with stronger active-state clarity and 44pt+ hit area.
  - Update shared search bars to use focus-visible styling (active border + glow) and cleaner iconography.
  - Refine shared segmented tabs with lower visual weight and clearer selected/unselected contrast.
  - Flatten intro summary block visuals further to reduce unnecessary card noise.
  - Add home quick-action chips (`장소`, `라이브`, `게시판`, `정보`) to reduce path depth for core journeys.
  - Reduce board/feed write CTA visual weight (extended FAB -> compact FAB) for timeline readability.
- Updated files:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/navigation/gbt_bottom_nav.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/inputs/gbt_search_bar.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/navigation/gbt_segmented_tab_bar.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/layout/gbt_page_intro_card.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/home/presentation/pages/home_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/feed_page.dart`

### Consequences
- Core navigation and search interactions are visually clearer and more consistent across major routes.
- Home now supports faster intent-driven entry into major sections.
- Timeline surfaces have less CTA dominance and better content-first balance.
- This is a phase-1 pass; remaining screen-by-screen refinements are tracked in TODO.

### Verification
- `flutter analyze` on modified files passed with no issues.

### References
- Material Design (Bottom navigation): https://m1.material.io/components/bottom-navigation.html
- Android UI guidance (lists/grids): https://developer.android.com/develop/ui/compose/quick-guides/content/display-list-or-grid
- Android UI guidance (content grouping/layout): https://developer.android.com/design/ui/mobile/guides/foundations/layout-and-content/content-grouping
- W3C WCAG 2.2 target size guidance: https://www.w3.org/WAI/WCAG22/quickref/#target-size-minimum
- UX reference baseline requested by user:
  - https://www.uxdnas.com/guide
  - https://www.uxdnas.com/posts/322
