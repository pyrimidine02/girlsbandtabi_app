# ADR-20260204 OAuth Buttons Placeholder

## Status
- Accepted

## Context
- Login screen needs visible OAuth buttons for Google/Apple/Twitter.
- OAuth backend integration will be implemented later.

## Decision
- Render all OAuth provider buttons regardless of configuration.
- Button taps show a “준비 중” message instead of starting OAuth.

## Alternatives Considered
- Hide buttons until OAuth is configured (rejected: requirement wants buttons now).

## Consequences
- Users can see upcoming OAuth options.
- Actual OAuth flow remains a future task.

## References
- lib/features/auth/presentation/widgets/oauth_buttons.dart
