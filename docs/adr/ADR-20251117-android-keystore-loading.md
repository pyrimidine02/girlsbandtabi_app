# ADR-20251117 Android keystore loading fix

## Status
Accepted

## Context
- Running `flutter build appbundle` failed (`android/app/build.gradle.kts:11`) because `java.util.Properties` was referenced without importing the package in the Kotlin DSL script.
- The release keystore loader also referenced the `load` function implicitly, which Kotlin could not resolve without the type import, blocking every release build attempt.

## Decision
- Import `java.util.Properties` at the top of `android/app/build.gradle.kts` and instantiate it via `Properties()` so Kotlin resolves both the package and the `load` function.
- Keep the existing `signingConfigs.release` logic so production signing remains unchanged once the keystore file is supplied.

## Consequences
- Release builds now progress past script compilation; the remaining failure is the expected missing keystore file (`android/upload-keystore.jks`), which the team must supply when signing for production.
- No runtime behavior changes occur for debug/development builds.
