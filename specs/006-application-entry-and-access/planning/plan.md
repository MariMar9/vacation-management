# Implementation Plan: F-006 Application Entry and Access

**Status:** Approved for synthetic test-project implementation only; Entra integration remains a hosted direction, not configured credentials.
**Scenario:** backend+frontend.
**Stack:** ASP.NET Core .NET 8, Angular 20; local automated tests use fake identities.
**Decision source:** [test-project decisions](../../test-project-feature-decisions.md).
**Artifacts:** [access model](../requirements/data-model.md), [access-profile OpenAPI](../contracts/openapi.yaml), [Gherkin](../tests/access-test-profile.feature).
**Task source:** [cross-feature Bolt tasks](../../../planning/tasks.md), T050–T054.

## Constitution Check

| Principle                 | Status                     | Notes                                                     |
| ------------------------- | -------------------------- | --------------------------------------------------------- |
| Authentication direction  | Pass                       | Entra OIDC for hosted identity; fake principal for tests. |
| Server-side authorization | Required                   | UI visibility is never the enforcement boundary.          |
| Least privilege           | Pass                       | Direct department/project scope, deny self-approval.      |
| Quality gates             | Defined, execution pending | Requires application, test, and Playwright manifests.     |

## Approved Test Access Matrix

- Requester: create/read own/cancel eligible own request.
- ProjectApprover: read assigned project, project decision, same-project delegation grant/revoke.
- DepartmentApprover: read department queue, department decision, demand view, advisory capacity settings.
- Multiple roles are allowed. Self-approval and cross-department/cross-project access are denied. Missing/invalid identity returns 401; authenticated unauthorized action returns 403 (ownership-concealing own-request lookups return 404).
- “Try” means pre-provisioned test users in isolated synthetic test data; no public signup, trial clock, or production trial.

## Bolt Plan

1. **Bolt 1: Identity, Access and Entry Rules** — access model, role matrix, contract, denial scenarios and approved test-user fixtures.
2. **Bolt 2: Link Entry and Scoped Access** — test identity adapter, access profile, route protection, server-side policy enforcement and executable smoke E2E.

Detailed tasks and gates are T050–T054 in the cross-feature task list. No production identity tenant or user credentials are provisioned by this plan.

## Dependencies

- F-001 requester ownership, F-002 approver/delegate actions and F-003 scope queries.
- F-005 synthetic project membership and approver assignment fixtures.
- Hosted Entra registration is a separate environment task; local TDD uses fake identities.

## Risks

- Fake identity fixtures must be test-only and impossible to enable in hosted environments.
- A scope in the UI is not authorization; API endpoints enforce each role/action/scope.
- No legal/compliance/security certification is asserted.
