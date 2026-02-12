# ADR-20260212: Non-Blocking App Bootstrap

## Status
Accepted

## Context
The app performed storage and authentication checks before `runApp`, which can
delay the first frame on iOS and leave a white screen at startup. During this
window, Flutter may emit a debug assertion about `FrameTiming` callbacks when
no frame has been sent yet.

## Decision
- Run `runApp` immediately after binding/config setup.
- Move local storage initialization and auth status checks into a non-blocking
  bootstrap task after `runApp`.
- Log bootstrap failures so issues are visible without blocking UI.

## Alternatives Considered
- Keep synchronous pre-run initialization (causes a blank first frame).
- Defer the first frame explicitly (`deferFirstFrame`) and allow it later
  (still blocks UI and adds complexity).

## Consequences
- First frame is rendered immediately, reducing startup blank screens.
- Auth state may update shortly after launch; routing reacts via provider state.
- Bootstrap failures are logged but do not prevent UI from rendering.
