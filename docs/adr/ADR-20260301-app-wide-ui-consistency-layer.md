## ADR-20260301: App-Wide UI Consistency Layer

### Status
- Accepted

### Context
- The app has many feature pages with independent `Scaffold` bodies and local
  styling decisions, which causes visible inconsistency in spacing density,
  component surfaces, and interaction behavior.
- The current request requires a user-friendly and unified UX across all pages
  without risky large-scale route or feature refactors.
- We need a change that propagates to the entire app immediately and safely.

### Decision
- Introduce app-level background tokens/gradients in `GBTColors` and apply them
  globally via `MaterialApp.builder`.
- Add global tap-to-dismiss keyboard behavior in `MaterialApp.builder` to reduce
  interaction friction on form-heavy screens.
- Expand `GBTTheme` so core component families share one rule set:
  - navigation transitions
  - list tile defaults
  - icon/filled button defaults
  - popup menu, tooltip, scrollbar defaults
  - segmented button and selection controls (switch/checkbox/radio)
  - standardized card/input/app bar surfaces and radius/density.
- Add reusable page-level widgets for content routes:
  - `GBTPageIntroCard`
  - `GBTSegmentedTabBar`
- Apply the reusable widgets to high-traffic pages (`board`, `favorites`,
  `notifications`, `search`) as phase-2 rollout.
- Extend rollout to additional major routes (`live_events`, `places_map`,
  `visit_history`, `visit_stats`, `notification_settings`, `profile_edit`) as
  phase-3.
- Refresh brand primary palette from periwinkle to sky-blue for clearer
  hierarchy and lower purple bias while keeping existing semantic mappings.
- Align navigation semantics to stack-first behavior for detail routes by
  preferring `push` over `go` in navigation helpers.
- Use platform-friendly pages on iOS/macOS for detail/overlay navigation where
  interactive back gesture must be preserved.
- Make shell-level back handling dynamic (`GoRouter.canPop`) so pushed routes
  can pop naturally, while keeping Android root-level double-back exit logic.
- Move home top hero from gradient-only rendering to image-capable rendering
  with layered overlays and featured-live context to improve scanability.
- Apply the same consistency principle to post-detail comments by introducing
  structured metadata, card surfaces, and explicit sort controls for quicker
  scanning in long threads.
- Promote places-region filtering to a first-class interaction by exposing
  always-visible filter entry points and a searchable multi-select bottom sheet
  with explicit clear/apply actions.
- Treat persistent backend 5xx as non-retryable in high-traffic home summary
  loads (except transient classes) and apply short same-request cooldown to
  avoid retry storms and noisy logs during backend incidents.

### Alternatives Considered
- Per-page redesign only:
  - rejected because it is slow and leaves untouched pages inconsistent.
- Route-level shell/layout refactor:
  - rejected for now due higher regression risk across map/sliver/detail flows.
- Keep existing theme and patch only selected pages:
  - rejected because the requirement is app-wide consistency.

### Consequences
- All pages now inherit a single UX baseline from app/theme level.
- User-perceived consistency improves without changing feature boundaries.
- Future page work can focus on content/flows while reusing the same visual and
  interaction defaults.
- High-traffic pages now share the same top-context pattern (intro card) and
  segmented controls pattern, reducing feature-to-feature UI drift.
- Major route coverage for the shared pattern is expanded, reducing remaining
  styling divergence to a smaller set of long-tail pages.
- iOS back-swipe reliability improves on detail/overlay flows and back now
  returns to the immediate previous route in most user journeys.
- Home first-impression quality improves because live/poster imagery appears in
  the header when available instead of showing color-only surfaces.
- Comment readability improves in dense discussions due to card grouping,
  stable metadata placement, and predictable sort modes.
- Places filtering is easier to discover and adjust without losing map context,
  reducing repeated taps and accidental filter resets.
- During backend incidents, home screen behavior is more stable because
  non-transient failures do not trigger repeated retry loops.
- Some pages may still need fine-grained UX tuning (copy hierarchy, local
  layout polish), tracked in `TODO.md`.

### References
- Material Design 3: [https://m3.material.io/](https://m3.material.io/)
- Android adaptive UI guidance:
  [https://developer.android.com/design/ui/mobile/guides/foundations/adaptive-design/overview](https://developer.android.com/design/ui/mobile/guides/foundations/adaptive-design/overview)
- Apple Human Interface Guidelines:
  [https://developer.apple.com/design/human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines)
- NN/g 10 usability heuristics:
  [https://www.nngroup.com/articles/ten-usability-heuristics/](https://www.nngroup.com/articles/ten-usability-heuristics/)
- WCAG 2.2 target size:
  [https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)
- Inspiration benchmark (mobile patterns):
  [https://mobbin.com/browse/ios/apps](https://mobbin.com/browse/ios/apps)
  [https://dribbble.com/tags/mobile-app-design](https://dribbble.com/tags/mobile-app-design)
