# F-002 Data Model: Approval Workflow

**Status:** Approved for the synthetic-data test profile only; supersedes the candidate model in `specs/F-002-approval-workflow/data-model.md` for this workspace. See [feature decisions](../../test-project-feature-decisions.md).

## Entity: ApprovalDecision

| Field            | Type        | Required    | Constraints                                                               |
| ---------------- | ----------- | ----------- | ------------------------------------------------------------------------- |
| `id`             | UUID        | Yes         | Server generated.                                                         |
| `requestId`      | UUID        | Yes         | References F-001 request.                                                 |
| `level`          | enum        | Yes         | `Project`, `Department`.                                                  |
| `outcome`        | enum        | Yes         | `Approved`, `Rejected`.                                                   |
| `actorId`        | string      | Yes         | Authenticated approver/delegate.                                          |
| `delegationId`   | UUID/null   | No          | Required when acting through delegation.                                  |
| `reason`         | string/null | Conditional | Required for rejection; 1–500 characters. Optional for approval; max 500. |
| `decidedAt`      | date-time   | Yes         | Server-generated UTC timestamp.                                           |
| `requestVersion` | integer     | Yes         | F-001 version observed when decision was recorded.                        |

At most one decision exists per request and level. Decisions are immutable; stale or duplicate commands return conflict. Project approval precedes department approval. Project rejection is terminal; department rejection is not available in the test profile. Final `Approved` requires both levels approved.

## Entity: ApprovalDelegation

| Field         | Type           | Required | Constraints                                                |
| ------------- | -------------- | -------- | ---------------------------------------------------------- |
| `id`          | UUID           | Yes      | Server generated.                                          |
| `projectId`   | string         | Yes      | Same project for delegator and delegate.                   |
| `delegatorId` | string         | Yes      | Active ProjectApprover for the project.                    |
| `delegateId`  | string         | Yes      | Active member of the same project; cannot equal delegator. |
| `startsAt`    | date-time      | Yes      | Server generated at grant.                                 |
| `expiresAt`   | date-time      | Yes      | After start; maximum 30 calendar days.                     |
| `revokedAt`   | date-time/null | No       | Set by delegator; revoke is idempotent.                    |
| `status`      | enum           | Yes      | `Active`, `Expired`, `Revoked`.                            |

No chained or department delegation. A delegate may decide only project-level requests within the grant interval. Record both actual actor and delegator context.

## References

Project membership and unique approver assignments come from the F-005 synthetic snapshot. Authorization is enforced by F-006. Requests and lifecycle remain owned by F-001.
