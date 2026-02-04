# ADR-20260204 Uploads Contract Sync

## Status
- Accepted

## Context
- Swagger now exposes `/api/v1/uploads/*` endpoints with a different request/
  response shape than the client used previously.
- Upload requests were failing with 500 due to mismatched field names.

## Decision
- Match Swagger contract:
  - Request field `size` (not `fileSize`)
  - Presigned response uses `url` + `headers`
  - Confirm response uses `status` only
  - Upload list returns `uploadId`, `filename`, `url`, `isApproved`

## Alternatives Considered
- Keep legacy DTOs and map on server (rejected: backend contract is canonical).

## Consequences
- Client upload DTOs + helpers updated to follow the API docs.
- Presigned upload now forwards server-provided headers.

## References
- lib/features/uploads/data/dto/upload_dto.dart
- lib/features/uploads/utils/presigned_upload_helper.dart
