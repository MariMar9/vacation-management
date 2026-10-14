# Scenario: backend+frontend, synthetic test-project profile.
# Spec: ../requirements.md
# User story: US-002. Use case: UC-002.
# Both project and department approval are required, sequentially; department approval is final.

@test-profile
@f002-approval-workflow
Feature: Record an approval decision
    Authorized approvers can record an outcome for their applicable approval level.

    @smoke @regression @US-002 @AC-002.1 @FR-005 @UC-002
    Scenario: Project approver records a project-level approval
        Given a vacation request is eligible for a project-level decision
        And the project approver is authorized for the request and project scope
        When the project approver records an approval
        Then a project-level approved outcome is recorded

    @smoke @regression @US-002 @AC-002.1 @FR-006 @UC-002
    Scenario: Department approver records a department-level approval
        Given a vacation request is eligible for a department-level decision
        And the department approver is authorized for the request and department scope
        When the department approver records an approval
        Then a department-level approved outcome is recorded

    @regression @US-002 @AC-002.1 @UC-002
    Scenario: One approval is recorded without asserting overall finality
        Given an approved workflow requires another approval level
        And that other approval remains outstanding
        And the current approver is authorized for an eligible request at their level
        When the approver records an approval
        Then the outcome for the current level is recorded
        And the request is not represented as finally approved

    @smoke @regression @US-002 @AC-002.1 @FR-006 @UC-002
    Scenario: Department approval makes a twice-approved request final
        Given a request has an Approved project-level decision
        And the department approver is authorized and is not the requester
        When the department approver records an approval
        Then the request status becomes Approved
        And exactly one final-approved event is emitted

    @regression @US-002 @AC-002.1 @UC-002
    Scenario: Delegate records an approval within an approved delegation
        Given a delegate has a valid approved delegation for the request and approval scope
        And the request is eligible for the delegated decision
        When the delegate records an approval
        Then the outcome for the applicable approval level is recorded

    @security @regression @US-002 @AC-002.1 @UC-002
    Scenario: Unauthorized actor cannot record an approval
        Given an actor is not authorized for the request or approval level
        When the actor attempts to record an approval
        Then the action is denied
        And no approval outcome is recorded

    @regression @US-002 @AC-002.1 @UC-002
    Scenario: Stale or ineligible request cannot receive an approval
        Given a request is no longer eligible or has changed since it was reviewed
        When the approver attempts to record an approval
        Then the decision is not recorded
        And the current request status is presented

    @regression @US-002 @AC-002.1 @UC-002
    Scenario: Failed persistence is not reported as a recorded approval
        Given an authorized approver submits an approval for an eligible request
        And the outcome cannot be persisted
        When the system processes the decision
        Then the system reports that the decision was not recorded
        And the approval is not represented as successful