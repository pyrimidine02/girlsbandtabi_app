## ADR-20260303: UXDNAS + 2025 Design Trends Rollout (Community · Places · Info)

### Status
- Accepted

### Context
- User requested a comprehensive design improvement pass informed by UXDNAS design archive (uxdnas.com) and internet research on 2025 mobile app design trends.
- The app has three core feature pillars: Community (SNS feed, board, posts), Places/Map (map view, place detail), Info/Wiki (news, units, members, songs tabs).
- Research findings applied:
  - Bento Grid (2×2) for home quick-action tiles — from 2025 Apple/Weverse design trend
  - Content-first minimalism: remove GBTPageIntroCard intro headers from secondary routes
  - App bar consistency: all routes should use GBTAppBarIconButton (not plain IconButton/PopupMenuButton)
  - Skeleton-first loading: replace spinner with GBTShimmerContainer in place detail page
  - Feed community post card: static more_horiz icon was non-interactive (UX gap)
  - User profile: font weight and avatar ring color violated design system tokens

### Decision
- **Home page (home_page.dart):** Replace `_HomeQuickActions` horizontal chip row with `_HomeBentoGrid` — a 2×2 GridView with color-coded tiles (places=teal, live=pink, board=blue, info=amber), consistent with 2025 bento grid design trend.
- **Notifications page (notifications_page.dart):** Replace plain `IconButton` (done_all) and `PopupMenuButton` (more_vert) with `GBTAppBarIconButton`; remove `GBTPageIntroCard` from `_NotificationsIntroCard`, keep only the `SegmentedButton<bool>` filter row.
- **Favorites page (favorites_page.dart):** Add `GBTAppBarIconButton(refresh)` action; remove `_FavoritesIntro` / `_CountBadge` classes and all `GBTPageIntroCard` usage.
- **Settings page (settings_page.dart):** Replace `leading: IconButton(arrow_back)` with `leading: GBTAppBarIconButton(arrow_back)`.
- **Info page (info_page.dart):** Add `GBTAppBarIconButton(refresh)` alongside existing `GBTProfileAction` in app bar; unify tab bar styling.
- **Place detail page (place_detail_page.dart):** Replace full-screen spinner in loading state with `GBTShimmer` + `GBTShimmerContainer` skeleton layout.
- **Feed page (feed_page.dart):** Convert `_CommunityPostCard` to `ConsumerWidget`; replace static `Icon(Icons.more_horiz)` with conditional `PopupMenuButton` that opens report flow via `CommunityReportSheet` — only visible to authenticated non-authors.
- **User profile page (user_profile_page.dart):** Fix avatar ring color from `colorScheme.surface` to explicit `isDark ? GBTColors.darkBackground : Colors.white`; fix display name font weight from `FontWeight.w800` to `FontWeight.w700`.

### Consequences
- Home quick-action section is more visually prominent and consistent with modern 2025 app design patterns.
- Secondary routes (notifications, favorites, settings, info) have full app bar chrome parity with primary routes.
- GBTPageIntroCard is removed from two more secondary routes, bringing the total to 6 pages cleaned (places, live, board already done in phase 4).
- Feed community post cards now surface a report action, matching the board page moderation capability.
- Place detail loading UX is skeleton-first, consistent with UXDNAS skeleton policy.
- User profile page now fully complies with GBT design system token constraints.
- Remaining pages still using GBTPageIntroCard (search, account_tools, visits, profile_edit, notification_settings) deferred to a future cleanup pass.

### References
- UXDNAS guide: https://www.uxdnas.com/guide
- UXDNAS reference post: https://www.uxdnas.com/posts/322
- 2025 bento grid trend: https://www.mockplus.com/blog/post/app-design-trends-2025
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/home/presentation/pages/home_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/notifications/presentation/pages/notifications_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/favorites/presentation/pages/favorites_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/presentation/pages/settings_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/info_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/places/presentation/pages/place_detail_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/feed_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/user_profile_page.dart`
