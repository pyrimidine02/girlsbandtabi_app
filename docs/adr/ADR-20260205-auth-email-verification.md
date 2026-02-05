# ADR-20260205: Email Verification in Registration

## Status
Accepted

## Context
The auth API now exposes email verification endpoints (`/api/v1/auth/email-verifications` and `/confirm`). The registration UI previously only collected username/password/nickname without verifying email.

## Decision
- Add an email field to registration and treat it as the username value sent to `/auth/register`.
- Add verification send + confirm actions in the registration screen.
- Gate registration submission until email verification is confirmed.

## Alternatives Considered
- Allow registration without verification and prompt later.
- Perform verification after successful registration.

## Consequences
- Users must confirm an email verification token before completing registration.
- Registration UI has extra steps and state handling for verification.
