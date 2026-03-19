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
- Extend root `ci_post_clone.sh` and `ios/ci_scripts/ci_post_clone.sh` to
  guarantee plist presence before iOS build with resilient resolution order:
  1. use `GOOGLE_SERVICE_INFO_PLIST` when provided
  2. decode `GOOGLE_SERVICE_INFO_PLIST_B64` (including whitespace-normalized
     retry)
  3. if `*_B64` contains raw plist by mistake, use it as-is
  4. compose plist from `FIREBASE_IOS_*` discrete values when fully provided
  5. fail fast when none of the above sources are valid
- Keep path compatibility for Xcode Cloud script discovery (`ci_post_clone.sh`,
  `ios/ci_scripts/ci_post_clone.sh`, and `ci_scripts/` wrapper).
- Harden `ios/ci_scripts/ci_post_clone.sh` execution preconditions:
  - require `CI_PRIMARY_REPOSITORY_PATH` explicitly,
  - quote repository path before `cd`,
  - use `pod install --repo-update` for better pod spec consistency.
- Add runtime diagnostics/fallback in `ios/ci_scripts/ci_post_clone.sh`:
  - auto-resolve repository root from script location/workspace defaults when
    CI env variables are missing,
  - emit `[ci_post_clone]` step logs to pinpoint failure stage quickly.

## Consequences
- Xcode Cloud archive no longer fails due to missing plist input file.
- Teams can keep Firebase config out of git while still building in CI.
- Build behavior stays strict enough for correctness:
  - no placeholder plist generation
  - no silent fallback from partial `FIREBASE_IOS_*` configuration
  - missing/invalid input is surfaced in `ci_post_clone` logs with hints.

## Verification
- `bash -n ci_post_clone.sh`
- Inspect Xcode Cloud logs for one of:
  - `Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST.`
  - `Generated GoogleService-Info.plist from GOOGLE_SERVICE_INFO_PLIST_B64.`
  - or explicit fail-fast:
    - `Missing GoogleService-Info.plist secret.`
