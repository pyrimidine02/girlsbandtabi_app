# ADR-20260204 Place Detail Categories + Related Bands

## Status
- Accepted

## Context
- The place detail screen showed place tags under "관련 밴드", which made
  place categories look like band information.
- Product requirement: show place categories separately and list unit names
  under "관련 밴드".

## Decision
- Add a dedicated "장소 분류" section that renders existing place tags.
- Fallback to `PlaceDetail.types` if tags are empty.
- Use the project unit list to populate "관련 밴드".

## Alternatives Considered
- Remove tags entirely (rejected: loses existing metadata visibility).

## Consequences
- Place detail now separates categories and related bands.
- Related bands reflect the project unit names rather than place tags.

## References
- lib/features/places/presentation/pages/place_detail_page.dart
- lib/features/places/domain/entities/place_entities.dart
