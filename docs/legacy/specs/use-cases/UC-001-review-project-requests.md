# UC-001: Review Project Requests

## Scenario

backend+frontend

## Scope

F-002 Approval and Delegation. The workflow crosses an approver-facing application capability and system-managed request data; the implementation stack is not decided.

## Level

User goal

## Primary Actor

Project approver

## Secondary Actors

- System
- Employee/requester, as the owner of the reviewed request
- Department approver, where the approved process exposes a separate department-level review

## Trigger

The project approver opens the project request review capability.

## Preconditions

- The approver has an identity admitted under the access policy approved for F-006.
- An approved project-to-approver mapping and project scope are available.
- The system has requests associated with the project, or can determine that none are available.

## Main Success Scenario

1. The project approver opens the review capability for an assigned project.
2. The system resolves the approver's authorized project scope.
3. The system retrieves requests associated with that project and permitted by the approved review policy.
4. The system presents the available requests and their requested periods for review.
5. The project approver selects a request to inspect.
6. The system presents the request details allowed by the approved access policy.

## Alternative Flows

- 3a. No requests are associated with the project: the system indicates that there are no requests available; no request data is changed.
- 2a. The approver is authorized for multiple projects: the system limits results to the project scope selected or otherwise resolved under the approved scope policy.
- 3b. The approved policy permits a responsible approver or delegate to review the request: the system applies that policy's scope and authority; those rules must be defined before acceptance.

## Error Flows

- 2b. The approver's project mapping is missing or ambiguous: the system cannot establish the review scope; assignment and recovery behavior require stakeholder definition.
- 3c. Project membership or request data is unavailable or inconsistent: the system reports that the review data could not be loaded and does not present an unverified result as complete.
- 4a. The user requests a project outside their authorization: access is denied and the out-of-scope requests are not disclosed.

## Postconditions

- Success: the authorized project requests have been presented for review; no approval outcome is changed by viewing them.
- Failure: no decision is recorded and no unauthorized request data is disclosed.

## Business Rules

- A project approver may review requests only within the approved project scope (FR-004, FR-032).
- The system must use an approved source to identify the project approver (FR-028); source, cardinality, and missing-mapping behavior remain open.
- Department demand aggregation is outside this use case and belongs to F-003.

## Security and Authorization Rules

- Require an identity admitted under the approved F-006 policy; authentication details are not yet approved.
- Enforce project-scoped authorization on both the request list and request details. SEC-002 remains a draft proposal, so the exact role/action matrix must be approved.
- Do not expose requests outside the user's authorized scope.

## Requirements Covered

- F-002 US-001, AC-001.1 and AC-001.2
- FR-004, FR-028, FR-032
- SEC-002 (draft; approval required)

## Open Questions

- What is the authoritative project membership and approver source, and how are missing or multiple mappings handled?
- Who is the "responsible" approver in FR-032, and what scope may that role see?
- Can department approvers review individual requests through this capability, or only provide a separate decision?
- Which request fields may each role view, and what are the approved access and audit rules?
- What data freshness and usability criteria apply to the review view?
