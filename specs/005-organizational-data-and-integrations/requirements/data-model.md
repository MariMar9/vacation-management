# F-005 Data Model: Synthetic Organization Snapshot

**Status:** Approved for the synthetic-data test profile only. These schemas do not represent real ServiceNow or Active Directory payloads. See [feature decisions](../../test-project-feature-decisions.md).

## Snapshot Envelope

| Field                 | Type      | Required | Constraints                                                                  |
| --------------------- | --------- | -------- | ---------------------------------------------------------------------------- |
| `snapshotVersion`     | string    | Yes      | Monotonically increasing test-fixture version.                               |
| `generatedAt`         | date-time | Yes      | UTC source-fixture time.                                                     |
| `department`          | object    | Yes      | Exactly `DEPT-TEST-001`.                                                     |
| `employees`           | array     | Yes      | Unique `employeeId`; all synthetic `EMP-TEST-*`.                             |
| `projects`            | array     | Yes      | Unique `projectId`; synthetic `PRJ-TEST-*`.                                  |
| `memberships`         | array     | Yes      | Direct employee-to-project membership only.                                  |
| `approverAssignments` | array     | Yes      | Exactly one active project approver per project and one department approver. |

## Validation and Publish

Validate all IDs, uniqueness, project/employee references, one-department membership, and unique approver assignments before publish. Publish the complete snapshot atomically. If invalid, retain the last valid snapshot, report validation errors, and do not expose partial data. A snapshot older than 36 hours is marked stale and cannot authorize new decisions or exports.

## Export Outbox

| Field                         | Type           | Required | Constraints                                    |
| ----------------------------- | -------------- | -------- | ---------------------------------------------- |
| `id`                          | UUID           | Yes      | Server generated.                              |
| `requestId`                   | UUID           | Yes      | F-001 request reference.                       |
| `requestVersion`              | integer        | Yes      | Source version.                                |
| `idempotencyKey`              | string         | Yes      | Unique `requestId:requestVersion`.             |
| `status`                      | enum           | Yes      | `Pending`, `Delivered`, `NeedsReconciliation`. |
| `attemptCount`                | integer        | Yes      | Maximum 3 automatic simulator attempts.        |
| `createdAt` / `lastAttemptAt` | date-time/null | Yes      | UTC timestamps.                                |

Queue only final `Approved` requests with both F-002 decisions. Simulator retries three times, then marks `NeedsReconciliation`; it never contacts an external provider. Inbound snapshots are daily at 02:00 Europe/Madrid and export outbox evaluation is daily at 03:00 Europe/Madrid.
