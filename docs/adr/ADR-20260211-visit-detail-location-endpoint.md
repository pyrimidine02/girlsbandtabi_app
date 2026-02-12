# ADR-20260211: Visit Detail Location Endpoint

## Status
Accepted

## Context
The visit list API does not include verification coordinates. The visit detail
screen needs latitude/longitude/accuracy to display the verification location.

## Decision
- Keep `/api/v1/users/me/visits` unchanged (id, placeId, visitedAt only).
- Add a visit detail API `/api/v1/users/me/visits/{visitId}` that returns
  location fields.
- Use a dedicated DTO (`VisitEventDetailDto`) for the detail response.

## Alternatives Considered
- Add location fields to the list endpoint (privacy concern).
- Reuse the existing place detail endpoint without visit-level coordinates.

## Consequences
- Visit detail can show verification location without exposing it in lists.
- Adds one additional request when opening visit detail.
