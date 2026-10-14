# Scenario: backend+frontend, synthetic test-project profile.
# Spec: ../requirements.md
# User story: US-002. Use case: UC-003.
# Rejection requires a 1-500 character reason and is final in this test profile.

@test-profile
@f002-approval-workflow
Feature: Reject a project vacation request
    An authorized project approver can record a rejected outcome for an eligible request.

    @smoke @regression @US-002 @AC-002.2 @FR-007 @UC-003
    Scenario: Project approver records a rejection
        Given a vacation request is eligible for a project decision
        And the project approver is authorized to reject it
        When the project approver records a rejection
        Then a rejected outcome is recorded for the request

    @regression @US-002 @AC-002.2 @FR-007 @UC-003
    Scenario: Rejection without a reason is denied
        Given the project approver is authorized to reject an eligible request
        When the approver submits a rejection without a reason
        Then the system identifies the missing reason
        And no rejection is recorded

    @security @regression @US-002 @AC-002.2 @FR-007 @UC-003
    Scenario: Actor without rejection authority cannot reject
        Given an actor is not authorized to reject the request in its project scope
        When the actor attempts to record a rejection
        Then the action is denied
        And no rejection is recorded

    @regression @US-002 @AC-002.2 @FR-007 @UC-003
    Scenario: Stale or ineligible request cannot be rejected
        Given the request is no longer eligible for rejection
        When the project approver attempts to reject it
        Then the rejection is not recorded
        And the current request status is presented

    @regression @US-002 @AC-002.2 @FR-007 @UC-003
    Scenario: Failed persistence is not reported as a rejection
        Given an authorized project approver submits a rejection for an eligible request
        And the outcome cannot be persisted
        When the system processes the decision
        Then the system reports that the rejection was not recorded
        And the request is not represented as rejected