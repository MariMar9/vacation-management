# UC-003: Reject a Project Request

## Scenario

backend+frontend

## Scope

F-002 Approval and Delegation. The workflow crosses an approver-facing application capability and system-managed request data; the implementation stack is not decided.

## Level

User goal

## Primary Actor

Authorized project approver

## Secondary Actors

- System
- Employee/requester
- Responsible approver, if stakeholders confirm that role may reject
- Delegate, if rejection is permitted by the approved delegation policy

## Trigger

The project approver chooses to reject an eligible request.

## Preconditions

- The request exists and is eligible for a rejection decision under the approved lifecycle rules.
- The actor is authorized to reject the request within its project scope.
- The rejection action is distinct and available under the approved workflow.

## Main Success Scenario

1. The project approver opens an eligible request in their authorized project scope.
2. The system verifies the actor's rejection authority and the request's current eligibility.
3. The project approver selects the rejection action.
4. The system collects any rejection information required by the approved policy.
5. The system records a rejected outcome for the request.
6. The system exposes the outcome to the lifecycle and notification processes according to approved rules.

## Alternative Flows

- 4a. A rejection reason is optional under the approved policy: the approver records the rejection without a reason.
- 4b. A rejection reason is mandatory: the approver supplies the required information before the system records the outcome.
- 5a. The policy allows a delegate to reject: the system records the outcome only after validating the active delegation and request scope.

## Error Flows

- 2a. The actor lacks rejection authority: the system denies the action and records no rejection.
- 2b. The request is no longer eligible: the system declines the stale action and presents the current status.
- 4c. Required rejection information is missing or invalid: the system identifies the missing information and does not record the rejection.
- 5b. The outcome cannot be persisted: the system reports failure and does not present the request as rejected.

## Postconditions

- Success: the rejected outcome is recorded for the request.
- Failure: the request's decision state remains unchanged by the failed action.
- Reopening, correction, resubmission, and requester notification outcomes are not established by this use case.

## Business Rules

- FR-007 defines project-level rejection, but does not define rejection details or follow-up behavior.
- The actor meant by "responsible" in FR-010 is unresolved; this use case does not grant that role rejection authority.
- "Close" is not treated as a synonym for rejection (FR-009).

## Security and Authorization Rules

- Only an actor with approved rejection authority for the request's project scope may reject it.
- Department approvers and delegates receive no rejection authority unless the approved role and delegation policies grant it.
- SEC-002 and rejection audit requirements require stakeholder approval.

## Requirements Covered

- F-002 US-002, AC-002.2
- FR-007, FR-010
- FR-022 (requester notification behavior is specified by F-004)
- SEC-002 (draft; approval required)

## Open Questions

- Is a rejection reason required, and what information may it contain?
- Does a rejection end the request, allow correction/resubmission, or permit an alternative period?
- Who is the "responsible" approver in FR-010, and may that person reject?
- Can department approvers or delegates reject, or is rejection exclusive to project approvers?
- Is "close" a separate decision, and what notification follows rejection?
