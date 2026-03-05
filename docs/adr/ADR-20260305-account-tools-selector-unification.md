## ADR-20260305: Account Tools Selector Unification

### Status
- Accepted

### Context
- The Account Tools page mixed multiple selector styles (`SegmentedButton`,
  `DropdownButtonFormField`, custom target selector) and looked inconsistent
  with other major pages using shared segmented/tab and picker patterns.
- User requested selector UX/design consistency with the rest of the app.

### Decision
- Replace Account Tools top selector with shared `GBTSegmentedTabBar`.
- Replace dropdown-based selectors with one shared selection field pattern plus
  bottom-sheet picker list:
  - project selector,
  - requested role selector,
  - appeal target-type selector,
  - appeal reason selector.
- Keep existing target-record picker behavior, but align the field visual style
  to the same shared selection field component.

### Consequences
- Selector visual language is unified across settings and other feature pages.
- Interaction model is consistent: tap field -> bottom sheet -> pick option.
- Existing business logic/validation remains unchanged.

### Verification
- `dart format lib/features/settings/presentation/pages/account_tools_page.dart`
- `flutter analyze lib/features/settings/presentation/pages/account_tools_page.dart`
- `flutter test test/features/settings`

### Updated File
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/settings/presentation/pages/account_tools_page.dart`
