# ADR-20260204 Unit Filter Name + Description

## Status
- Accepted

## Context
- The unit filter sheet only showed `displayName`, which currently contains
  long descriptive text from the backend response.
- The unit name is provided via `code`, so users could not see the actual unit
  name in the filter list.

## Decision
- Display `code` as the unit name in the filter list.
- Render `displayName` as the subtitle when it differs from the name.
- Truncate long descriptions to keep the list readable.

## Alternatives Considered
- Rename the DTO fields (rejected: requires broader refactor and backend
  contract updates).

## Consequences
- Users can see both the unit name and description in the filter sheet.
- Existing data mapping remains intact, minimizing API surface changes.

## References
- lib/features/projects/presentation/widgets/project_selector.dart
- lib/features/projects/domain/entities/project_entities.dart
- lib/features/projects/data/dto/unit_dto.dart
