## ADR-20260305: Relocate Board/Live AppBar Actions to Bottom FAB Menus

### Status
- Accepted

### Context
- User requested no broad design change, but action placement adjustments for reachability:
  - Live page calendar action should move from AppBar to bottom area.
  - Board page AppBar report/sanction actions should be available from the write
    button flow via upward expansion.
- Restricted actions must remain visible only to eligible accounts.

### Decision
- Live page:
  - remove AppBar calendar icon,
  - add bottom-right calendar FAB that opens the same calendar sheet.
- Board page:
  - remove `내 신고 내역` / `커뮤니티 제재 관리` from AppBar,
  - replace single write FAB with an upward-expanding action FAB menu,
  - include actions by tab/role:
    - community tab: 게시글 작성 (+ 내 신고 내역 for authenticated users, + 제재 관리 for admin),
    - travel-review tab: 여행 후기 작성 only.

### Consequences
- AppBar remains cleaner and visually stable without widening top action area.
- Thumb reachability improves for high-frequency actions.
- Role gating is preserved while consolidating action entry points.

### Verification
- `dart format lib/features/feed/presentation/pages/board_page.dart lib/features/live_events/presentation/pages/live_events_page.dart`
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart lib/features/live_events/presentation/pages/live_events_page.dart`
- `flutter test test/features/feed test/features/live_events`

### Updated Files
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/live_events/presentation/pages/live_events_page.dart`
