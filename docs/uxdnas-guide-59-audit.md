# UXDNAS Guide 59-Element Audit (2026-03-03)

Source: [UXDNAS App Guide](https://www.uxdnas.com/guide)

Status legend:
- `Applied`: Used in product and standardized.
- `Partial`: Used but not fully standardized across all screens.
- `N/A`: Not required for current IA/product scope.

| # | Element | Status | Product Mapping / Evidence |
|---|---|---|---|
| 1 | Accordion | N/A | No accordion interaction in current core routes |
| 2 | Anatomy & size of chips | Applied | Chips in board/search/live filters (`lib/features/feed/presentation/pages/board_page.dart`) |
| 3 | Anatomy & specs of text field | Applied | Global input theme + `GBTTextField` (`lib/core/theme/gbt_theme.dart`, `lib/core/widgets/inputs/gbt_text_field.dart`) |
| 4 | Badge | Applied | Notification/count badges in multiple cards and status pills |
| 5 | Bento menu | N/A | Not part of current mobile IA |
| 6 | Breadcrumb | N/A | Mobile app depth uses back stack, not breadcrumb |
| 7 | Button | Applied | Unified button theme (`lib/core/theme/gbt_theme.dart`) |
| 8 | Buttons analysis | Applied | Primary/filled/tonal/outlined usage normalized in major flows |
| 9 | Card | Applied | Global card theme + list cards (`lib/core/theme/gbt_theme.dart`) |
| 10 | Carousel | Applied | Post image carousel (`lib/features/feed/presentation/pages/post_detail_page.dart`) |
| 11 | Checkbox | Applied | Themed checkbox (`lib/core/theme/gbt_theme.dart`) |
| 12 | Chips | Applied | Feed mode/filter chips and tags |
| 13 | Chip states | Applied | Selected/unselected chip states in board filters |
| 14 | Chips in popular design systems | Applied | Rounded pill chips + state color hierarchy |
| 15 | Dropdown | Applied | Filter/select sheets and menu controls |
| 16 | Drawer (side bar) | N/A | Current IA uses bottom tabs + stack routing |
| 17 | Dropdown styles | Applied | Popup menu + filter modal styles (`lib/core/theme/gbt_theme.dart`) |
| 18 | Doner menu | N/A | Not in current app navigation model |
| 19 | Dividers | Applied | Global divider theme + timeline/list separators |
| 20 | Empty data | Applied | `GBTEmptyState` across feature pages |
| 21 | Form | Applied | Auth/profile/create/edit forms |
| 22 | Floating action button | Applied | Feed/board create FAB patterns |
| 23 | Hamburger menu | N/A | Not used in current bottom-tab IA |
| 24 | Icon | Applied | Themed icon sizes/colors (`GBTSpacing`, `GBTTheme`) |
| 25 | Icon metrics | Applied | Icon sizing tokens (`lib/core/theme/gbt_spacing.dart`) |
| 26 | Icon corner | Applied | Rounded icon containers and avatar/icon pills |
| 27 | Icon stroke | Applied | Outline-first action icon policy + shared icon set (`lib/core/widgets/common/gbt_action_icons.dart`) |
| 28 | Icon types | Applied | Outline/filled semantics used by action type |
| 29 | Input field | Applied | Global input decoration + custom input widgets |
| 30 | Kebab menu | Applied | Post/comment overflow actions |
| 31 | Keyline shapes | Applied | Radius token system (`lib/core/theme/gbt_spacing.dart`) |
| 32 | Meatballs menu | Applied | Horizontal overflow variants in content rows |
| 33 | Modal | Applied | Bottom sheets/dialogs standardized |
| 34 | Mobile grid system | Applied | 8pt spacing + consistent page insets |
| 35 | Navigation types (tab bar) | Applied | `GBTSegmentedTabBar` rollout |
| 36 | Onboarding | N/A | No onboarding flow currently shipped |
| 37 | Pagination | Applied | Paging/list load-more in feed/list controllers |
| 38 | Picker | Applied | Date/calendar and selection sheets |
| 39 | Progress bar | Applied | Circular/linear progress indicators in loading flows |
| 40 | Placeholder | Applied | Placeholder/empty/loading states |
| 41 | Principles of chip design | Applied | Selected contrast + touchable chips |
| 42 | Radio button | Applied | Global radio theme |
| 43 | Splash | N/A | Native/platform splash managed outside current scope |
| 44 | Search field | Applied | `GBTSearchBar` rollout (`board`, `search`, `connections`, `places`) |
| 45 | Slider controls | Applied | Global `SliderThemeData` defined in light/dark theme (`lib/core/theme/gbt_theme.dart`) |
| 46 | Stepper | N/A | No multi-step wizard flow currently |
| 47 | Skeleton screen | Applied | List loading switched to skeleton presets on feed/board/live/search core lists |
| 48 | Tab bar | Applied | Segmented tab pattern standardized |
| 49 | The popover style | Applied | Popup menu and sheet action surfaces |
| 50 | Throbber | Applied | Global loading indicator usage (`GBTLoading`) |
| 51 | Toast-pop up | Applied | SnackBar usage for transient feedback |
| 52 | Toggle | Applied | Global switch theme |
| 53 | Text fields types | Applied | Search/password/multiline/profile/editor variants |
| 54 | Text fields states | Applied | Enabled/focused/error/disabled themed states |
| 55 | Text fields styles | Applied | Global input theme and shared widgets |
| 56 | Walkthroughs | N/A | Not in current release scope |
| 57 | Web & mobile grids | Applied | Mobile-first spacing/grid tokens |
| 58 | Web & mobile color | Applied | Light/dark color schemes |
| 59 | Web & mobile shadow | Applied | Controlled elevation/shadow tokens |

## Applied in this rollout
- Search UI unified via `GBTSearchBar`:
  - `lib/features/feed/presentation/pages/board_page.dart`
  - `lib/features/search/presentation/pages/search_page.dart`
  - `lib/features/feed/presentation/pages/user_connections_page.dart`
- Tab UI unified via `GBTSegmentedTabBar`:
  - `lib/features/feed/presentation/pages/feed_page.dart`
  - `lib/features/admin_ops/presentation/pages/admin_ops_page.dart`
  - `lib/features/feed/presentation/pages/user_profile_page.dart`
  - `lib/features/feed/presentation/pages/user_connections_page.dart`
- Intro card surface de-emphasis:
  - `lib/core/widgets/layout/gbt_page_intro_card.dart`
- Full-width comment composer refinement:
  - `lib/features/feed/presentation/pages/post_detail_page.dart`
