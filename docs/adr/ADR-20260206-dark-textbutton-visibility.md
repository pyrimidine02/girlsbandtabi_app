# ADR-20260206: Dark Mode TextButton Visibility

## Status
Accepted

## Context
The place review sheet uses a `TextButton.icon` for adding photos. In dark mode
the button text and icon became invisible because the shared TextButton theme
used a light theme foreground color.

## Decision
- Add a dedicated dark TextButton theme that uses `GBTColors.darkTextPrimary`
  for foreground color.
- Apply the dark theme override to the dark `ThemeData`.

## Alternatives Considered
- Override the button style locally in the review sheet.
- Change the global primary color to a light value in dark mode.

## Consequences
- All TextButtons are visible in dark mode.
- The review sheet photo upload action is consistently visible.
