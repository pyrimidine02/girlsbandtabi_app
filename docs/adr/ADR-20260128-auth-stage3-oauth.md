# ADR-20260128 Auth Stage 3 + OAuth Scaffolding

## Status
- Accepted

## Context
- Stage 3 requires authentication flows (login/register/refresh/logout).
- OAuth social login was requested, but backend OAuth start URLs and deep-link redirect wiring are not finalized.

## Decision
- Implement core auth layers (DTOs, repository, controller) for email/password flows.
- Add OAuth provider enum, launch service, and callback exchange endpoint integration.
- Provide configurable OAuth authorization URLs via `AppConfig.oauthAuthorizeUrls` and expose a callback route (`/auth/callback`).

## Alternatives Considered
- Integrate deep-link handling and app links now (rejected: requires native config changes and backend URL confirmation).
- Skip OAuth until backend spec is finalized (rejected: requirement to add OAuth scaffolding now).

## Consequences
- OAuth buttons are available but require configuration in `AppConfig.init` and backend readiness.
- Deep-link/native app-link configuration remains a follow-up task.

## References
- docs/GBT_Flutter_Implementation_Plan_v1.3.md (Stage 3)
- docs/프런트엔드개발자참고문서_v1.0.0.md (Auth endpoints)
