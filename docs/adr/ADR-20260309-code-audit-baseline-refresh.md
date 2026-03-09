# ADR-20260309: Code Audit Baseline Refresh Policy

- Date: 2026-03-09
- Status: Accepted
- Scope: `docs/CODE_AUDIT.md`

## Context
- Existing `docs/CODE_AUDIT.md` contained stale findings that no longer
  matched the repository state (for example test file count and gradient claim).
- This made prioritization less trustworthy for implementation planning.

## Decision
- Treat `docs/CODE_AUDIT.md` as a living, evidence-based document.
- Audit entries must satisfy both:
  1. file/line-level evidence
  2. current-state verification (same-day `rg`/manual confirmation)
- Findings should be grouped by execution priority (P1/P2/P3) and be directly
  actionable by sprint.

## Alternatives Considered
1. Keep historical findings untouched.
   - Rejected: causes false positives and wastes engineering time.
2. Move all findings to TODO only.
   - Rejected: loses severity context and architectural rationale.

## Consequences
- Audit document becomes more reliable for planning and triage.
- Additional maintenance cost exists, but reduced confusion outweighs it.

## Validation
- Verified current counts and claims with repository scan commands and
  refreshed `docs/CODE_AUDIT.md` accordingly.
