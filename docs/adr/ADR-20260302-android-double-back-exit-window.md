## ADR-20260302: Android Double-Back Exit Window on Main Shell

### Status
- Accepted

### Context
- User requested Android behavior where pressing back on the main screen does
  not immediately close the app.
- Existing shell behavior already supported double-back exit but used a 2-second
  window and less clear guidance copy.

### Decision
- Keep behavior Android-only in `MainScaffold` root pop handling.
- Change exit confirmation window from 2 seconds to 3 seconds.
- Update snackbar copy to a clearer sentence:
  - `뒤로 버튼을 한 번 더 누르면 앱이 종료됩니다`
- Ensure only one snackbar is visible at a time by hiding previous snackbar
  before showing a new one.

### Consequences
- Matches expected Android UX for accidental-back prevention.
- Maintains normal back behavior for non-root routes (in-stack pop unaffected).
- No behavioral change on iOS/web/desktop.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/shared/main_scaffold.dart`
