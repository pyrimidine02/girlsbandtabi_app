# ADR-20260205: Profile Edit Enhancements (Bio + Cover)

## Status
Accepted

## Context
The community profile UI now surfaces a cover image and bio, but the edit flow only supported display name and avatar. Users need to update bio/cover alongside existing profile fields.

## Decision
- Extend the profile edit page to include bio and cover image fields.
- Reuse the existing presigned upload flow for cover image uploads.
- Send optional `bio` and `coverImageUrl` values when updating the profile.

## Alternatives Considered
- Keep bio/cover read-only until backend tooling is finalized.
- Introduce a separate cover edit screen rather than extending the existing profile form.

## Consequences
- Users can update display name, avatar, bio, and cover image in one flow.
- Backend must accept optional bio/cover updates and return them on profile reads.
