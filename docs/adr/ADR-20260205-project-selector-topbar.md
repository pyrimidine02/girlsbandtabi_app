# ADR-20260205: Project Selector Top Bar on Places/Live/Feed

## Status
Accepted

## Context
Users need to switch project context while browsing places, live events, and feed content. The project selection exists on the Home page, but those feature pages lacked an at-a-glance control for switching context.

## Decision
Add the existing `ProjectSelector` widget to the top of Places, Live Events, and Feed pages so users can change project scope directly on each page.

## Alternatives Considered
- Add a global selector in the app shell only.
- Use a segmented control for projects instead of the shared dropdown.

## Consequences
- Project context can be changed without returning to Home.
- Feature lists refresh based on the selected project provider.
