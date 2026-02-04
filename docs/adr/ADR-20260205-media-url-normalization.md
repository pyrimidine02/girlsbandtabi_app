# ADR-20260205 Media URL Normalization

## Status
- Accepted

## Context
- Backend returns legacy R2 object URLs that are not publicly accessible.
- Client image loading fails with HTTP 400 when using the raw R2 API host.
- A public CDN host (`r2.pyrimidines.org`) is available for image delivery.

## Decision
- Normalize legacy R2 URLs on the client to the public CDN host.
- Apply normalization inside `GBTImage` so all image loads share the behavior.

## Alternatives Considered
- Update backend to return public URLs only (preferred long-term, not ready yet).
- Convert URLs ad hoc at each call site (rejected: error-prone and inconsistent).

## Consequences
- All image loads go through a centralized URL resolver.
- A TODO is required to remove normalization once backend outputs public URLs.

## References
- lib/core/utils/media_url.dart
- lib/core/widgets/common/gbt_image.dart
