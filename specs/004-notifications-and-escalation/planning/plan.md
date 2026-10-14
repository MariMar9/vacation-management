# Implementation Plan: F-004 Notifications and Escalation

**Status:** Approved for synthetic test-project implementation only. Source requirements remain Draft for real-world use.
**Scenario:** backend-only with local simulator surface.
**Stack:** ASP.NET Core .NET 8, Azure SQL/EF Core; no broker and no outbound email/Teams.
**Decision source:** [test-profile decision register](../../test-project-feature-decisions.md).
**Artifacts:** [outbox model](../requirements/data-model.md), [event contract](../contracts/events.yaml), [simulator OpenAPI](../contracts/openapi.yaml), [Gherkin](../tests/notification-test-profile.feature).
**Task source:** [cross-feature Bolt tasks](../../../planning/tasks.md), T037–T043.

## Constitution Check

| Principle             | Status                     | Notes                                         |
| --------------------- | -------------------------- | --------------------------------------------- |
| Test-project stack    | Pass                       | Local simulator only.                         |
| No external messaging | Pass                       | SMTP and Teams disabled.                      |
| Data minimization     | Pass                       | Payload excludes reason text and credentials. |
| Quality gates         | Defined, execution pending | Requires .NET test manifest.                  |

## Approved Event Policy

Queue notifications for submission, project approval, final approval, rejection, and eligible cancellation. One reminder at 3 calendar days and one escalation at 5 days from the current approval-level start; suppress both after terminal outcomes. Event-key idempotency prevents duplicates. The local outbox is inspectable and expires after 90 days as test data; this is not legal retention policy.

## Bolt Plan

1. **Bolt 1: Event Catalogue and Contract** — validate event names, triggers, recipients, payload and Gherkin.
2. **Bolt 2: Local Notification Outbox and Escalation** — persist events, test-clock evaluator, idempotent delivery simulator, and tests.
3. **Bolt 3: Optional Channel Exclusion** — verify no Teams/adaptive-card dependencies exist in runtime paths; close as excluded for this test profile.

Detailed tasks and gates are T037–T043 in the cross-feature task list. No real notification endpoint or external message broker is part of this plan.

## Dependencies

- F-001 cancellation rules and F-002 project/department decision events.
- F-005 synthetic recipient/approver assignments.
- F-006 authorized test-user identity.

## Risks

- Final approval requires both F-002 outcomes; project approval alone does not notify the requester as finally approved.
- Reminder/escalation timing uses an injectable test clock; no production scheduler SLA is claimed.
