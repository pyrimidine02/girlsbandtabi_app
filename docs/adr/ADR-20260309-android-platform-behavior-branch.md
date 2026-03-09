# ADR-20260309 Android Platform Behavior Branch

## Status
Accepted

## Context
- UI/interaction patterns were biased toward iOS styling and motion in several
  core surfaces (bottom navigation, back icons, and scroll physics).
- Android users expect Material-style navigation affordances, visible ripple,
  and clamping scroll behavior.
- Requirement: preserve current iOS feel while adapting Android behavior.

## Decision
- Add platform branching for navigation surfaces:
  - Android: Material `NavigationBar` for main bottom navigation.
  - Android: Material-style board sub bottom navigation.
  - iOS: keep existing blur/glass navigation style.
- Replace iOS-only back icons with platform-aware icon selection.
- Relax text scale cap for Android (`1.6`) while keeping iOS cap (`1.3`).
- Remove hard-coded bouncing parent in `AlwaysScrollableScrollPhysics` usages
  so platform defaults are applied consistently.
- For explicit bouncing-only screens, branch to `ClampingScrollPhysics` on
  Android and keep bouncing on iOS.
- Make shared `share` icon token platform-aware.
- Extend platform branching to modal interactions:
  - shared confirmation dialogs use Cupertino alert on iOS/macOS and Material
    alert dialog on Android.
  - shared action/bottom sheets use Cupertino action sheet/modal popup on
    iOS/macOS and Material bottom sheet on Android.
  - register final-consent confirmation follows the same platform split.

## Consequences
- Android users get interaction patterns closer to native expectations.
- iOS visual identity is preserved.
- Slightly different cross-platform rendering/behavior paths must be covered
  in QA.
- Modal interaction behavior is now consistent with each platform's native
  affordances, reducing UX mismatch in destructive and report flows.

## Verification
- `flutter analyze lib/app.dart lib/core/widgets/common/gbt_action_icons.dart lib/core/widgets/layout/gbt_carousel_section.dart lib/core/widgets/navigation/gbt_bottom_nav.dart lib/features/feed/presentation/pages/user_profile_page.dart lib/features/home/presentation/pages/home_page.dart lib/features/live_events/presentation/pages/live_attendance_history_page.dart lib/features/live_events/presentation/pages/live_event_detail_page.dart lib/features/search/presentation/pages/search_page.dart lib/features/settings/presentation/pages/account_tools_page.dart lib/features/settings/presentation/pages/community_settings_page.dart lib/features/settings/presentation/pages/consent_history_page.dart lib/features/settings/presentation/pages/notification_settings_page.dart lib/features/settings/presentation/pages/profile_edit_page.dart lib/features/settings/presentation/pages/settings_page.dart lib/features/visits/presentation/pages/visit_detail_page.dart lib/features/visits/presentation/pages/visit_history_page.dart lib/features/visits/presentation/pages/visit_stats_page.dart lib/shared/main_scaffold.dart`
- `flutter analyze lib/core/widgets/dialogs/gbt_adaptive_dialog.dart lib/core/widgets/sheets/gbt_bottom_sheet.dart lib/features/feed/presentation/pages/board_page.dart lib/features/feed/presentation/pages/feed_page.dart lib/features/feed/presentation/pages/post_detail_page.dart lib/features/settings/presentation/pages/privacy_rights_page.dart lib/features/auth/presentation/pages/register_page.dart`
