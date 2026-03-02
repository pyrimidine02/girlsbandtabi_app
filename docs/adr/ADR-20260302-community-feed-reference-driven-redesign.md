## ADR-20260302: Community Feed/Post Reference-Driven Redesign

### Status
- Accepted

### Context
- The user requested a board/post redesign closer to familiar social + forum
  interaction patterns (timeline readability + dense threaded comments).
- Existing UI had strong card emphasis in comments and uneven visual rhythm
  between board list and post detail.
- Goal: improve scan speed and reply flow on small mobile screens while keeping
  current app theme tokens and existing feature behavior.

### Decision
- Apply a timeline-first composition to community feed cards:
  - left avatar + compact author/time line
  - text-first body hierarchy
  - full-width media preview
  - balanced four-action row for consistent gesture targets
- Align post detail header/action row with the same timeline rhythm.
- Replace card-style comment blocks with a compact thread list:
  - divider separation instead of boxed cards
  - depth indentation + thin thread line for nested replies
  - compact reply CTA and reduced vertical spacing
- Simplify comment composer to a quick-reply bar with lower height.

### Consequences
- Board list and detail screen now feel like one continuous interaction model.
- Comment reading density increases (more visible lines per viewport), with
  preserved author/moderation actions.
- Reduced vertical footprint in input/composer area improves reading space.

### References
- X app store product page (timeline interaction baseline):  
  https://apps.apple.com/us/app/x/id333903271
- Everytime app listing (forum/comment-first baseline):  
  https://play.google.com/store/apps/details?id=com.everytime.v2
- Material list guidance (dense list readability and hierarchy):  
  https://m3.material.io/components/lists/guidelines
