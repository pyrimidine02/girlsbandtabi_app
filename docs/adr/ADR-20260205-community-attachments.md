# ADR-20260205: Community Attachments via Upload URLs

## Status
Accepted

## Context
Community posts needed photo attachments, but the current API contract only accepts `title` and `content` with no attachment fields in request/response schemas.

## Decision
- Allow users to select and upload images using the existing presigned upload flow.
- Embed uploaded image URLs into the post content using markdown image syntax as a temporary fallback.
- Render embedded image markdown in the post detail UI to show attachments.

## Alternatives Considered
- Block attachments entirely until the backend exposes explicit attachment fields.
- Store attachments client-side only (not persisted in the post content).

## Consequences
- Attachments are visible immediately in the post detail view via markdown parsing.
- When the backend adds explicit attachment support, the markdown fallback can be removed.
