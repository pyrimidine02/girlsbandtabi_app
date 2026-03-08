# ADR-20260309 Xcode Cloud GoogleService-Info.plist Injection

## Status
Accepted

## Context
- `ios/Runner/GoogleService-Info.plist` is ignored by Git for secret hygiene.
- Runner target references this file in Xcode resources.
- Xcode Cloud clones repository without local secret files, causing archive
  failure:
  - `Build input file cannot be found: .../ios/Runner/GoogleService-Info.plist`

## Decision
- Extend root `ci_post_clone.sh` to guarantee plist presence before iOS build
  using secret-only sources:
  1. use `GOOGLE_SERVICE_INFO_PLIST` when provided
  2. decode `GOOGLE_SERVICE_INFO_PLIST_B64` when provided
  3. fail fast when neither secret is present or decoding fails
- Add `ci_scripts/ci_post_clone.sh` wrapper that forwards to root script to
  support Xcode Cloud configurations expecting the `ci_scripts/` path.

## Consequences
- Xcode Cloud archive no longer fails due to missing plist input file.
- Teams can keep Firebase config out of git while still building in CI.
- Build behavior is deterministic and secure:
  - no placeholder plist generation
  - no silent fallback from partial env configuration
  - missing secret is surfaced immediately in `ci_post_clone` logs.

## Verification
- `bash -n ci_post_clone.sh`
- Inspect Xcode Cloud logs for one of:
  - `Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST.`
  - `Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST_B64.`
  - or explicit fail-fast:
    - `Missing GoogleService-Info.plist secret.`
