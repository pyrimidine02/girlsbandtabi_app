# ADR-20260212: Report Sheet Keyboard Dismiss

## Status
Accepted

## Context
The report bottom sheet (`신고하기`) opened the software keyboard for the
description field, but users had no reliable way to dismiss it without
submitting or closing the sheet.

## Decision
- Add outside-tap keyboard dismissal at sheet level.
- Enable scroll drag keyboard dismissal on the report sheet scroll view.
- Set the description field to `TextInputAction.done` and dismiss on submit.

## Alternatives Considered
- Add a dedicated "keyboard close" button (extra UI complexity).
- Keep only one dismissal path (less robust across devices/keyboards).

## Consequences
- Users can dismiss keyboard naturally and continue editing options.
- No API/domain changes; impact is limited to report sheet interaction.
