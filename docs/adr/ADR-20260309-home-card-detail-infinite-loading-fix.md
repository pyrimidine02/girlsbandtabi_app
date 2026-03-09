# ADR-20260309 Home Card Detail Infinite Loading Fix

## Status
Accepted

## Context
- Home cards (`추천 장소`, `트렌딩 라이브`) route directly to detail pages.
- In some navigation paths, project context is not ready at detail controller
  startup.
- Existing detail controllers could return early while keeping `AsyncLoading`,
  causing apparent infinite loading.
- Place detail also had a places-tab activity gate that blocked load when
  entering from Home.

## Decision
- Remove places-tab active gate from `PlaceDetailController.load()`.
- For both place/live detail controllers:
  - resolve project context with fallback chain
    (`selectedProjectKey -> selectedProjectId -> selection state -> first project`)
  - surface explicit error when context is still unavailable
  - add mounted guards after async boundaries.
- If detail fetch fails for current project context, retry across remaining
  known projects (code/id candidates) to handle mixed-project home cards.

## Consequences
- Home card to detail navigation no longer sticks on loading due to missing
  project context.
- Cross-project detail resolution from home cards is more resilient.
- Additional fallback requests may occur only on initial detail fetch failure.

## Verification
- `flutter analyze lib/features/places/application/places_controller.dart lib/features/live_events/application/live_events_controller.dart`
- `flutter test test/features/places/application/places_controller_test.dart`
