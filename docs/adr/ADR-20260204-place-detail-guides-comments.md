# ADR-20260204 Place Detail Guides + Comments

## Status
- Accepted

## Context
- The place detail page did not show visitor comments or place guides.
- Product requirement: display both sections and show a “준비중” message on 403.

## Decision
- Add guide and comment fetchers via Places repository.
- Render “장소 가이드” and “방문 후기” sections in the place detail page.
- When a 403 response is encountered, show “아직 준비중입니다.”

## Alternatives Considered
- Hide sections entirely when unavailable (rejected: user wanted visibility).

## Consequences
- Place detail surfaces guides and comments immediately.
- Users see a consistent 준비중 message if the backend restricts access.

## References
- lib/features/places/presentation/pages/place_detail_page.dart
- lib/features/places/application/places_controller.dart
- lib/features/places/data/datasources/places_remote_data_source.dart
