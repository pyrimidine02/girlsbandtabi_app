## ADR-20260303: UXDNAS Core Rules Rollout (Global UI Consistency)

### Status
- Accepted

### Context
- User requested to apply the UXDNAS guide rules broadly across the app.
- Existing UI had mixed patterns across pages:
  - segmented tabs were split between plain `TabBar` and custom pill styles,
  - search fields were implemented differently per page,
  - intro summary sections used heavier boxed cards on some pages,
  - post-detail comment composer still had edge-inset inconsistency.

### Decision
- Apply a shared-rule rollout centered on reusable primitives:
  - Flatten `GBTPageIntroCard` from boxed `Card` to low-emphasis divider intro.
  - Use `GBTSegmentedTabBar` for tab consistency on major tabbed pages.
  - Use `GBTSearchBar` for search-field consistency on major search surfaces.
  - Normalize post-detail composer to true full-width bottom alignment.
- Updated pages/components:
  - `lib/core/widgets/layout/gbt_page_intro_card.dart`
  - `lib/core/widgets/navigation/gbt_segmented_tab_bar.dart`
  - `lib/features/admin_ops/presentation/pages/admin_ops_page.dart`
  - `lib/features/feed/presentation/pages/feed_page.dart`
  - `lib/features/feed/presentation/pages/user_connections_page.dart`
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
  - `lib/features/feed/presentation/pages/board_page.dart`
  - `lib/features/search/presentation/pages/search_page.dart`
  - `lib/features/feed/presentation/pages/post_detail_page.dart`

### Consequences
- Visual language is more consistent across navigation/search/intro surfaces.
- Touch-target and component behavior consistency improved without route changes.
- Existing page-level business logic remains unchanged.
- Additional on-device QA is still required to validate all edge cases and typography scaling.
- A full element-by-element applicability map is tracked in
  `docs/uxdnas-guide-59-audit.md`.
- Follow-up implementation methodology map is tracked in
  `docs/uxdnas-guide-59-implementation-plan.md`.

### References
- UX guideline source: https://www.uxdnas.com/guide
- UX reference post: https://www.uxdnas.com/posts/322
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/layout/gbt_page_intro_card.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/navigation/gbt_segmented_tab_bar.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/widgets/inputs/gbt_search_bar.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/theme/gbt_colors.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/admin_ops/presentation/pages/admin_ops_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/feed_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/user_connections_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/user_profile_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/search/presentation/pages/search_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
