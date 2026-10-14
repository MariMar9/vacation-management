# UC-005: Delegate Approval

## Scenario

backend+frontend

## Scope

F-002 Approval and Delegation. The workflow crosses an approver-facing application capability and system-managed authority; the implementation stack is not decided.

## Level

User goal

## Primary Actor

Authorized project approver

## Secondary Actors

- Eligible person in the same project (delegate)
- System
- Department approver or data owner, if involved in the approved assignment policy

## Trigger

The project approver requests to delegate an approval responsibility to an eligible person in the same project.

## Preconditions

- The project approver is authorized to delegate under an approved delegation policy.
- The proposed delegate is eligible and belongs to the same project, as required by FR-029.
- Delegation scope, duration, and permitted actions are defined by the approved policy.

## Main Success Scenario

1. The project approver selects an approval responsibility to delegate.
2. The system presents eligible same-project people under the approved policy.
3. The project approver selects an eligible delegate and supplies any required scope or duration.
4. The system validates the delegator's authority, delegate eligibility, project membership, and requested delegation terms.
5. The system records the delegation according to the approved policy.
6. The delegate can act only within the granted scope and validity period.
7. The system attributes a resulting decision to the actual acting person and records delegation context as required by approved audit rules.

## Alternative Flows

- 3a. The policy allows delegation of a single request rather than an ongoing responsibility: the project approver selects the request and the system limits the delegation to it.
- 3b. The policy allows delegation of a defined set of approvals: the system applies the approved scope and duration.
- 5a. The delegation requires additional confirmation: the system activates it only after the required confirmation is completed.

## Error Flows

- 4a. The proposed delegate is outside the same project or otherwise ineligible: the system rejects the delegation and records no authority change.
- 4b. The delegator lacks authority, or the requested scope/duration exceeds policy: the system denies the request and explains the applicable constraint.
- 4c. Project membership or eligibility data cannot be verified: the system does not grant the delegation.
- 5b. The delegation cannot be persisted: the system reports failure and leaves the prior authority unchanged.

## Postconditions

- Success: an approved delegation exists for its defined scope and validity period; the delegate receives no authority beyond it.
- Failure: no new delegation is active.

## Business Rules

- FR-029 requires the project approver's delegate to be in the same project.
- FR-030 proposes support for vacation approver delegation but is clarification-needed; this use case does not presume that all approver types may delegate.
- Delegation authority does not determine the approval sequence or finality of the request.

## Security and Authorization Rules

- Validate delegator authority, same-project membership, delegate eligibility, scope, and validity at grant time and when the delegate acts.
- A delegate may not use the delegation outside its approved scope or duration.
- Preserve actual actor and delegation-context attribution only as specified by approved audit rules; SEC-002 remains a draft proposal.

## Requirements Covered

- F-002 US-004, AC-004.1 and AC-004.2
- FR-029, FR-030
- INT-004 (project membership data dependency)
- SEC-002 (draft; approval required)

## Open Questions

- Who may delegate project and department approvals, and may delegation be onward-delegated?
- Is delegation request-specific or responsibility-wide, and what start/end times apply?
- What approval actions, request states, projects, and departments are in scope?
- Is delegate acceptance or approval by another owner required?
- What attribution, audit, notification, revocation, and overlap rules apply?
- What is the source of truth for same-project membership and how fresh must it be?
