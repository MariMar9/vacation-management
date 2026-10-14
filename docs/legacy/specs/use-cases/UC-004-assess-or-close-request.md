# UC-004: Assess or Close a Request

## Scenario

backend+frontend

## Scope

F-002 Approval and Delegation. This is a conditional use-case placeholder: "assess" (FR-008) and "close" (FR-009) have no agreed operational meaning, so no runtime behavior is presumed.

## Level

User goal, pending stakeholder definition

## Primary Actor

Project approver

## Secondary Actors

- System
- Employee/requester
- Other approver, if the approved workflow defines a review relationship

## Trigger

The project approver attempts to use an assessment or close action after stakeholders have defined and approved its meaning.

## Preconditions

- Stakeholders have defined the action, permitted actor, input, eligibility conditions, and observable result.
- The request is eligible for that action under the approved lifecycle rules.
- The project approver is authorized for the request's scope.

## Main Success Scenario

1. The project approver opens an eligible request in their authorized scope.
2. The system presents only the assessment or close action defined by the approved policy.
3. The project approver supplies any required input and confirms the action.
4. The system validates the actor, request state, and required input against the approved policy.
5. The system records the defined action and its agreed observable outcome.

## Alternative Flows

- 2a. Stakeholders define "assess" as a distinct action: the system offers it separately from approval and rejection and applies only its approved outcome.
- 2b. Stakeholders define "close" as a distinct action: the system offers it separately from rejection and applies only its approved outcome.
- 2c. Stakeholders determine that either term is not a supported action: the action is not offered.

## Error Flows

- 2d. The meaning or outcome has not been approved: the action is unavailable; the system does not guess or change the request state.
- 4a. The actor is not authorized or the request is ineligible: the system denies the action and leaves the request unchanged.
- 4b. Required input is missing or invalid: the system identifies the validation failure and records no action.
- 5a. The action cannot be persisted: the system reports failure and does not represent the action as complete.

## Postconditions

- Success: only the stakeholder-defined action and outcome are recorded.
- Failure or undefined behavior: no assessment/close outcome is recorded and the request is not implicitly approved or rejected.

## Business Rules

- FR-008 ("valorar") and FR-009 ("close") are clarification-needed requirements.
- Assessment, close, approval, and rejection must not be conflated until stakeholders define their relationship and resulting states.

## Security and Authorization Rules

- Enforce the actor and request-scope permissions defined for the approved action.
- Do not expose or enable an undefined action.
- Audit and attribution requirements for these actions remain open under SEC-002.

## Requirements Covered

- F-002 US-003, AC-003.1 and AC-003.2
- FR-008, FR-009
- SEC-002 (draft; approval required)

## Open Questions

- What does "valorar" mean: a review note, recommendation, rating, or decision?
- Is "close" a distinct action, a synonym for rejection, or a transcription issue?
- Which actor may perform each action, and at what request lifecycle state?
- What inputs, state changes, reversibility, follow-up, and notifications apply?
- How do these actions interact with project and department approvals and final approval?
