# Implementation Plan: F-002 Approval and Delegation

**Status:** Approved for synthetic test-project implementation only. Source requirements remain Draft for real-world use.
**Scenario:** backend+frontend.
**Stack:** ASP.NET Core .NET 8 Controllers, Angular 20, modular monolith, Azure SQL/EF Core; external organization data is simulated.
**Decision source:** [test-profile decision register](../../test-project-feature-decisions.md).
**Contracts:** [F-002 OpenAPI](../contracts/openapi.yaml), [F-001 request lifecycle](../../001-vacation-request-lifecycle/contracts/openapi.yaml), [F-005 simulator](../../005-organizational-data-and-integrations/contracts/simulator.yaml), [F-006 access](../../006-application-entry-and-access/contracts/openapi.yaml).
**Task source:** [cross-feature Bolt tasks](../../../planning/tasks.md), T018–T028.

## Constitution Check

| Principle            | Status                       | Notes                                                           |
| -------------------- | ---------------------------- | --------------------------------------------------------------- |
| Test-project stack   | Pass                         | T002 test-only choices; no production claim.                    |
| Scope authorization  | Pass with synthetic fixtures | F-006 test profile denies self-approval and cross-scope access. |
| External integration | Pass with simulator          | F-005 external calls are disabled.                              |
| Quality thresholds   | Defined, execution pending   | Run when solution/test manifests exist.                         |

## Decisions

- Project approval precedes department approval; both are required for final approval.
- Project rejection is terminal and requires a 1–500 character reason; department rejection is not available.
- Exactly one active ProjectApprover mapping per project and one DepartmentApprover per test department. Missing/ambiguous assignment blocks decisions.
- Assessment/review is read-only; no separate close mutation exists.
- Same-project project delegation only; maximum 30 calendar days, revocable by delegator, no chaining or department delegation.

## Bolt Plan

1. **Bolt 1: Workflow Model and BDD Baseline** — approve this test profile, update model/lifecycle, reconcile all six feature files and validate contracts/traceability. Readiness only.
2. **Bolt 2: Scoped Review and Decisions** — implement project review, project decision, department decision, rejection, stale/concurrent conflict handling and UI. No production data.
3. **Bolt 3: Approver Resolution and Delegation** — resolve unique assignments from the last valid synthetic snapshot; implement same-project grant/revoke/expiry and actor attribution.
4. **Bolt 4: Assess/Close Exclusion Verification** — verify no separate assess/close action is exposed; close this conditional scope as explicitly excluded for the test profile.

Detailed tasks and per-Bolt quality gates are T018–T028 in the cross-feature task list. Feature smoke E2E must be executable before closing UI Bolts.

## Dependencies

- F-001 request contract/state transitions and application shell.
- F-005 valid synthetic membership/approver snapshot; no provider credentials.
- F-006 server-side role/scope policies and fake identity fixtures.
- F-004 consumes only the documented final approval/rejection events.

## Risks

- A stale snapshot or ambiguous assignment blocks new decisions rather than guessing.
- F-004/F-005 consume finality only after both decisions; project approval alone is never export eligible.
- User decisions are scoped to a test project and do not establish real approver policy.
