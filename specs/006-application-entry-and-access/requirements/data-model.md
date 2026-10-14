# F-006 Data Model: Test Identity and Access

**Status:** Approved for the isolated synthetic-data test profile only. Hosted Entra OIDC is a direction; tests use fake identities. See [feature decisions](../../test-project-feature-decisions.md).

## Entity: TestPrincipal

| Field          | Type            | Required | Constraints                                                                   |
| -------------- | --------------- | -------- | ----------------------------------------------------------------------------- |
| `subjectId`    | string          | Yes      | Synthetic stable `EMP-TEST-*`; never accepted from an untrusted request body. |
| `roles`        | array of enum   | Yes      | `Requester`, `ProjectApprover`, `DepartmentApprover`; multiple roles allowed. |
| `departmentId` | string          | Yes      | Exactly `DEPT-TEST-001`.                                                      |
| `projectIds`   | array of string | Yes      | Direct membership from the last valid F-005 snapshot.                         |
| `active`       | boolean         | Yes      | Inactive identities receive 403.                                              |

## Access Rules

- Requester: create requests, read own requests, cancel own eligible requests.
- ProjectApprover: read requests in assigned projects, decide at project level, grant/revoke same-project delegation.
- DepartmentApprover: read department requests awaiting department decision, decide at department level, read demand, manage advisory capacity limits.
- Self-approval is denied even when a principal has approver role. Department/project scope is enforced server-side; cross-department is always denied.
- Missing/invalid identity returns 401. Authenticated principal lacking role/scope returns 403. Missing/stale assignment denies decisions and exports while read-only existing records remain accessible within authorized scope.

## AuditEvent

Record `eventId`, `actorId`, `action`, `resourceId`, `scopeId`, UTC `occurredAt`, outcome, and optional `delegatorId`. Do not store access tokens, credentials, or real personal data.
