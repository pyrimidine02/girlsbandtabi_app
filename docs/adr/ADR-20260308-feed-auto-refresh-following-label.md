# ADR-20260308 Feed Auto Refresh + Following Label

## Status
Accepted (2026-03-08)

## Context
- Feed write flows (post create, comment, reply) did not always update board feed
  immediately.
- Re-entering `/board` feed could show stale data until manual refresh.
- Post card follow CTA always showed `팔로우`, even for already-followed authors.

## Decision
- Force community feed reload when `_FeedSection` is entered and already in
  recommended mode.
- On successful post creation, trigger both:
  - `communityFeedControllerProvider.notifier.reload(forceRefresh: true)`
  - `postListControllerProvider.notifier.load(forceRefresh: true)`
- On successful comment/reply creation in post detail, trigger the same feed
  refresh pair asynchronously.
- Resolve card-level follow label using the current user following list and
  display `팔로잉` when the author is already followed.

## Alternatives Considered
- RouteObserver-based global visibility tracking for all feed re-entry cases.
  - Rejected for now: higher integration cost versus immediate UX fix.
- Per-card follow-status API lookup.
  - Rejected for now: more request overhead than a shared following-list lookup.

## Consequences
- Feed freshness improves after write actions and feed re-entry.
- Follow CTA status is more accurate in feed cards.
- There is additional refresh traffic on feed entry and write success paths.

## Validation
- `flutter analyze` passed after the change.
