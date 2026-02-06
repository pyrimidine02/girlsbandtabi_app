# ADR-20260206: Community Post Attachment URL Fallback

## Status
Accepted

## Context
Community post attachments are embedded into `content` using markdown image syntax, but some backend responses store only the raw R2 URL lines. The post detail UI only parsed markdown images, so attachments were not rendered and the raw URL was shown in the body text.

## Decision
- Extend the post detail parser to recognize image URLs in markdown, HTML, and bare URL lines.
- Treat URLs from the R2 host (or with image extensions) as attachments and remove those lines from the visible body text.
- Normalize attachment URLs before rendering to avoid duplicate thumbnails.

## Alternatives Considered
- Block attachments until the backend exposes explicit `imageUrls` fields in create/update requests.
- Render markdown directly inside the content body.

## Consequences
- Attachments render even if the backend strips markdown.
- Non-image URLs remain visible unless they match the attachment heuristics.
- The fallback can be removed once the backend preserves markdown or ships explicit attachment fields.
