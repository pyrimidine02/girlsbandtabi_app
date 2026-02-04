# ADR-20260204 Places List Pagination

## Status
- Accepted

## Context
- The places list API is paginated and defaulted to 20 items, which meant the
  "전체 장소" view showed only the first page.

## Decision
- When in "전체" list mode, fetch all pages sequentially using the maximum
  page size and merge results into a single list.
- Apply the same full-page fetch strategy to region-filtered lists so the
  map/list always shows the complete set.

## Alternatives Considered
- Increase page size only (rejected: still truncates when data grows).
- Add UI pagination controls (rejected: user asked for full list visibility).

## Consequences
- Full list loads may take longer for large datasets.
- A safety cap prevents endless paging in case of server issues.

## References
- lib/features/places/data/repositories/places_repository_impl.dart
- lib/features/places/application/places_controller.dart
