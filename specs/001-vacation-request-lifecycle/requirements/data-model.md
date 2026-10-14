# F-001 Data Model: Vacation Request

**Status:** Approved for the synthetic-data test profile only; see [feature decisions](../../test-project-feature-decisions.md). Not a real-world leave policy.

## Entity: VacationRequest

| Field          | Type        | Required | Constraints                                                                                 |
| -------------- | ----------- | -------- | ------------------------------------------------------------------------------------------- |
| `id`           | UUID        | Yes      | Server generated; immutable.                                                                |
| `requesterId`  | string      | Yes      | Authenticated synthetic user; not client-editable.                                          |
| `departmentId` | string      | Yes      | Must equal `DEPT-TEST-001`.                                                                 |
| `projectId`    | string      | Yes      | Must reference a project with verified direct membership.                                   |
| `startDate`    | date        | Yes      | Inclusive; today or later in `Europe/Madrid`.                                               |
| `endDate`      | date        | Yes      | Inclusive; must be >= `startDate`.                                                          |
| `reason`       | string/null | No       | Maximum 500 characters.                                                                     |
| `status`       | enum        | Yes      | `PendingProjectApproval`, `PendingDepartmentApproval`, `Approved`, `Rejected`, `Cancelled`. |
| `createdAt`    | date-time   | Yes      | Server-generated UTC timestamp.                                                             |
| `updatedAt`    | date-time   | Yes      | Server-generated UTC timestamp.                                                             |
| `version`      | integer     | Yes      | Starts at 1; increments on state transition.                                                |

## Invariants

- A requester has no overlapping requests in `PendingProjectApproval`, `PendingDepartmentApproval`, or `Approved` for the same project. Rejected/cancelled requests do not block a new request.
- The requester, department, project, dates, and optional reason are immutable after submission in this test profile.
- Only the requester may cancel, and only while `PendingProjectApproval` before a project decision exists.
- Approval outcomes are owned by F-002. F-001 status changes only from F-002 decisions or eligible requester cancellation.
- “Taken” is a derived history label: status `Approved` and `endDate` earlier than today's `Europe/Madrid` date. It is not persisted as a request state.
- Date ranges are inclusive calendar dates; no half-days, holidays, or working-day calculations.

## Ownership

F-001 owns `VacationRequest`. F-002 owns approval decisions and delegations; F-005 owns synthetic organization snapshots; F-006 owns test identity/role fixtures. Cross-context IDs are references, not cascaded aggregates.
