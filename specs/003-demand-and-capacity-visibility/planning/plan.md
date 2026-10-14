# Implementation Plan: F-003 Demand and Capacity Visibility

**Status:** Approved for synthetic test-project implementation only. Source requirements remain Draft for real-world use.
**Scenario:** backend+frontend.
**Stack:** ASP.NET Core .NET 8, Angular 20, Azure SQL/EF Core; F-001/F-005 data are synthetic/test-only.
**Decision source:** [test-profile decision register](../../test-project-feature-decisions.md).
**Artifacts:** [data model](../requirements/data-model.md), [OpenAPI](../contracts/openapi.yaml), [Gherkin](../tests/demand-test-profile.feature).
**Task source:** [cross-feature Bolt tasks](../../../planning/tasks.md), T029–T036.

## Constitution Check

| Principle          | Status                     | Notes                                                 |
| ------------------ | -------------------------- | ----------------------------------------------------- |
| Test-project stack | Pass                       | No deployment implied.                                |
| Synthetic data     | Pass                       | Single synthetic department and direct projects only. |
| Authorization      | Pass with fixtures         | F-006 enforces server-side scope.                     |
| Quality gates      | Defined, execution pending | Requires project/test manifests.                      |

## Approved Test Calculation

Count unique active members in the selected direct scope with at least one Approved request overlapping the inclusive date range. Exclude pending, rejected, and cancelled requests. Divide by active member count; return null percentage for zero denominator. The 70% threshold and configured limits are visual advisories only and never block workflow actions.

## Bolt Plan

1. **Bolt 1: Demand Rules and Test Contract** — data model, OpenAPI, reference fixtures, and Gherkin are the readiness baseline.
2. **Bolt 2: Read-Only Demand Overview** — scoped query, freshness/empty/error behavior, Angular view, advisory threshold, and executable smoke E2E.
3. **Bolt 3: Advisory Capacity Management** — set/read per-scope and period limits; verify no enforcement behavior.

Detailed tasks and gates are T029–T036 in the cross-feature task list. Bolt 3 is bounded to advisory-only behavior.

## Dependencies

- F-001 approved request statuses and inclusive date model.
- F-005 latest valid synthetic membership snapshot and freshness status.
- F-002/F-006 scope authorization fixtures.

## Risks

- Duplicate requests do not inflate unique-person counts.
- Stale snapshots are displayed as stale; missing snapshots return a defined error.
- No production capacity policy, threshold enforcement, or cost target is implied.
