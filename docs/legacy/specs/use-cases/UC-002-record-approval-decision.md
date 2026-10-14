# UC-002: Record an Approval Decision

## Scenario

backend+frontend

## Scope

F-002 Approval and Delegation. The workflow crosses an approver-facing application capability and system-managed request data; the implementation stack is not decided.

## Level

User goal

## Primary Actor

Authorized project approver or department approver

## Secondary Actors

- System
- Employee/requester
- Other required approver, if the approved workflow requires another decision
- Delegate, if acting under an approved delegation

## Trigger

An authorized approver chooses to approve an eligible request at their approval level.

## Preconditions

- The request exists and is eligible for a decision under the approved lifecycle rules.
- The actor is authorized for the request's project or department scope.
- The applicable approval level and decision rules have been defined.

## Main Success Scenario

1. The approver opens an eligible request in their authorized scope.
2. The system verifies the actor's authority and the request's current eligibility.
3. The system presents the approval action permitted for that actor and request.
4. The approver records an approval decision.
5. The system records the approved outcome for the applicable project or department level.
6. The system exposes the recorded outcome to the workflow according to the approved lifecycle rules.

## Alternative Flows

- 4a. The actor is a delegate: the system accepts the action only if the delegation is valid for this request, scope, and time under the approved policy.
- 5a. Another required approval remains outstanding: the system records this level's outcome without treating the request as finally approved.
- 5b. All required approvals are complete: the system applies the stakeholder-approved final-state rule. Which approvals are required and what constitutes final approval remain unresolved.

## Error Flows

- 2a. The actor is not authorized for the request or approval level: the system denies the action and records no approval outcome.
- 2b. The request is no longer eligible or has changed since it was opened: the system declines the stale decision and presents the current status.
- 5c. The outcome cannot be persisted: the system reports that the decision was not recorded and does not represent it as successful.

## Postconditions

- Success: an approval outcome is recorded for the applicable level. Final approval is asserted only when the approved required-approver and finality rules establish it.
- Failure: no approval outcome is recorded for the failed action.

## Business Rules

- Project and department approval outcomes are distinct level-specific outcomes (FR-005, FR-006).
- Approval sequence, whether both levels are mandatory, conditional requirements, and the final state are not specified and must not be inferred.
- Notifications and escalation are handled by F-004, based on approved decision events.

## Security and Authorization Rules

- Enforce authorization for the specific request, approval level, and scope at decision time.
- A delegate may approve only within authority granted by an approved delegation policy.
- SEC-002 and actor attribution/audit requirements remain subject to stakeholder approval.

## Requirements Covered

- F-002 US-002, AC-002.1
- FR-005, FR-006
- FR-021 to FR-023 (dependent notification/escalation behavior is in F-004)
- SEC-002 (draft; approval required)

## Open Questions

- Are project and department decisions sequential, parallel, both mandatory, or conditional?
- What constitutes final approval, and which state makes the request eligible for downstream export?
- What does the approver see before deciding, and may an approval be withdrawn or changed?
- What actor identity, delegation context, timestamp, and decision evidence must be retained?
- What notification or escalation events follow each level-specific outcome?
