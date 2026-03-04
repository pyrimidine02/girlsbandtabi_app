## ADR-20260303: Community Reference Redesign Phase 3 (Safety Unification)

### Status
- Accepted

### Context
- Phase 1/2 introduced profile/connections and board/detail IA refinements.
- Trust/safety affordances were still split:
  - report input UI duplicated per page,
  - board post card lacked non-author report/block quick actions.

### Decision
- Standardize safety entry and payload capture:
  - Extract shared `CommunityReportSheet` and use it in board/detail report flows.
  - Extend board post actions for non-authors with:
    - `신고`
    - `차단/차단 해제`
  - Reuse existing client cooldown (`ReportRateLimiter`) in board flow to keep
    behavior consistent with post-detail.

### Consequences
- Reporting UX is consistent regardless of entry point.
- Non-author safety actions are now reachable directly from board feed cards.
- Next phase can focus on comment-level safety/management parity and visual
  hierarchy tuning.

### References
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/widgets/community_report_sheet.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/board_page.dart`
- `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/post_detail_page.dart`
