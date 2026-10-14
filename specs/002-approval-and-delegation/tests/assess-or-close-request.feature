# Scenario: backend+frontend, synthetic test-project profile.
# Spec: ../requirements.md
# User story: US-003. Use case: UC-004.
# Review/assessment is read-only; no separate close mutation is supported in this test profile.

@test-profile
@f002-approval-workflow
Feature: Assess or close a vacation request
    Assessment and close behavior is available only after its meaning and outcome are approved.

    @regression @US-003 @AC-003.1 @FR-008 @UC-004
    Scenario: Undefined assessment action is not offered
        Given stakeholders have not approved the meaning and outcome of assessment
        When a project approver reviews an eligible request
        Then no assessment action is offered
        And the request is not changed by an assessment

    @regression @US-003 @AC-003.2 @FR-009 @UC-004
    Scenario: Undefined close action is not offered
        Given stakeholders have not approved whether close is distinct from rejection
        When a project approver reviews an eligible request
        Then no close action is offered
        And the request is not changed by a close action

    @security @regression @US-003 @FR-008 @FR-009 @UC-004
    Scenario: Unauthorized or ineligible action leaves the request unchanged
        Given the actor is not authorized for the defined action or the request is ineligible
        When the actor attempts the assessment or close action
        Then the action is denied
        And the request remains unchanged

    @smoke @regression @US-003 @AC-003.1 @FR-008 @UC-004
    Scenario: Assessment is read-only review and records no independent outcome
        Given the project approver is authorized to review an eligible request
        When the approver assesses the request
        Then the request details are displayed without a mutation action
        And no assessment outcome is persisted

    @regression @US-003 @AC-003.2 @FR-009 @UC-004
    Scenario: Close action is not offered separately from rejection
        Given the project approver reviews an eligible request
        When the review actions are displayed
        Then no separate close action is offered
        And rejection remains the only project-level negative decision