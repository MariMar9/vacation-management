# Implementation Plan: F-005 Organizational Data and Integrations

**Status:** Approved for synthetic test-project implementation only. No external owner or provider contract is approved.
**Scenario:** backend+integration.
**Stack:** ASP.NET Core .NET 8, Azure SQL/EF Core; local simulator only.
**Decision source:** [test-profile decision register](../../test-project-feature-decisions.md).
**Artifacts:** [synthetic data model](../requirements/data-model.md), [simulator OpenAPI](../contracts/openapi.yaml), [simulator policy](../contracts/simulator.yaml), [Gherkin](../tests/integration-simulator-test-profile.feature).
**Task source:** [cross-feature Bolt tasks](../../../planning/tasks.md), T044–T049.

## Constitution Check

| Principle         | Status                     | Notes                                                                          |
| ----------------- | -------------------------- | ------------------------------------------------------------------------------ |
| External boundary | Pass                       | No ServiceNow/AD network calls or credentials.                                 |
| Synthetic data    | Pass                       | IDs are `EMP-TEST-*`, `PRJ-TEST-*`, `DEPT-TEST-001`.                           |
| Reliability       | Pass                       | Snapshot validates then publishes atomically; last valid snapshot is retained. |
| Quality gates     | Defined, execution pending | Requires .NET test manifest.                                                   |

## Approved Test Exchange

- Daily complete snapshot at 02:00 `Europe/Madrid`; stale after 36 hours.
- One department, direct project membership, exactly one active project approver per project and one department approver.
- Invalid snapshots are rejected atomically; preserve the last valid snapshot and report validation errors.
- Daily export evaluator at 03:00 creates local outbox records only for final Approved requests. Idempotency key is `requestId:requestVersion`; retry three times, then `NeedsReconciliation`.
- “my scaturing” remains excluded.

## Bolt Plan

1. **Bolt 1: Source Ownership and Simulator Contracts** — approve test-only fixtures, mappings, snapshot validation, export eligibility and schemas.
2. **Bolt 2: Inbound Synthetic Snapshot Ingestion** — implement validation, atomic publish, freshness and failure/replay behavior.
3. **Bolt 3: Approved-Vacation Export Simulator** — produce eligible outbox records, enforce idempotency/retry and reconciliation.

Detailed tasks and gates are T044–T049 in the cross-feature task list. Real provider adapters remain out of scope until provider owners supply contracts.

## Dependencies

- F-001 request model and F-002 final approval rule.
- F-006 role/scope policy and managed test identity.
- F-003 consumes snapshot freshness and membership.

## Risks

- Never represent simulated data as authoritative external data.
- Snapshot errors preserve the previous valid data but mark it stale when over age limit.
- Export eligibility is final F-002 approval only; no delivery to ServiceNow occurs.
