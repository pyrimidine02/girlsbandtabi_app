# ADR-20260131 Home Loading Project Selector

## Status
- Accepted

## Context
- Home loads were blocked when no project key was selected because the home
  controller returned early and remained in a loading state.
- The project selection controller was only initialized when the project
  selector widget was built, but that widget only rendered after home data
  arrived.

## Decision
- Render the project selector during the home loading state so users can select
  a project and unblock the home summary request.

## Alternatives Considered
- Initialize the project selection controller at app/root scope (rejected for
  now: larger architectural change).
- Introduce a dedicated "project selection required" state in the home
  controller (deferred: broader state-model update and UI changes).

## Consequences
- Home loading UI now includes the project selector, enabling early selection.
- Home may show two loading indicators (projects + home) until data resolves.
- A widget test should cover the loading-to-selection flow.

## References
- lib/features/home/presentation/pages/home_page.dart
- lib/features/projects/presentation/widgets/project_selector.dart
- lib/features/home/application/home_controller.dart
