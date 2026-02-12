# ADR-20260212: Staggered List Item MediaQuery Access

## Status
Accepted

## Context
`StaggeredListItem` accessed `MediaQuery` in `initState`, which violates Flutter
rules for inherited widgets and triggered assertions during list build on iOS.

## Decision
- Initialize animation controller in `initState`.
- Read `MediaQuery.maybeDisableAnimationsOf` in `didChangeDependencies` and
  update the animation duration/start behavior there.

## Alternatives Considered
- Keep `MediaQuery` access in `initState` (causes inherited widget assertion).
- Remove staggered animations entirely (hurts UX).

## Consequences
- No inherited-widget access before dependencies are established.
- Animation behavior still respects reduce-motion settings.
