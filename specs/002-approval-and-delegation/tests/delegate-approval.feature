# Scenario: backend+frontend, synthetic test-project profile.
# Spec: ../requirements.md
# User story: US-004. Use case: UC-005.
# Only same-project project-approver delegation is supported; max validity is 30 calendar days.

@test-profile
@f002-approval-workflow
Feature: Delegate approval responsibility
    An authorized project approver can grant approval authority to an eligible person in the same project.

    @smoke @regression @US-004 @AC-004.1 @FR-029 @UC-005
    Scenario: Approver grants delegation to an eligible person in the same project
        Given the project approver is authorized to delegate under an approved policy
        And the proposed delegate is eligible and belongs to the same project
        And the delegation scope and validity follow the approved policy
        When the project approver records the delegation
        Then the delegation is active within its approved scope and validity
        And the delegate has no authority beyond that grant

    @security @regression @US-004 @AC-004.1 @FR-029 @UC-005
    Scenario: Person outside the project cannot receive the delegation
        Given the proposed delegate does not belong to the project
        When the project approver requests the delegation
        Then the system rejects the delegation
        And no authority change is recorded

    @security @regression @US-004 @FR-029 @UC-005
    Scenario: Unauthorized approver cannot grant delegation
        Given the actor is not authorized to delegate
        When the actor requests an approval delegation
        Then the request is denied
        And no delegation is recorded

    @regression @US-004 @FR-029 @UC-005
    Scenario: Unverified membership does not grant delegation
        Given the system cannot verify the proposed delegate's project membership
        When the project approver requests the delegation
        Then the system does not grant the delegation

    @regression @US-004 @FR-029 @UC-005
    Scenario: Delegation terms outside the approved policy are rejected
        Given the requested delegation exceeds the approved authority, scope, or validity
        When the project approver submits the delegation
        Then the system denies the request
        And no delegation is recorded

    @regression @US-004 @FR-029 @UC-005
    Scenario: Delegation expires at the end of its bounded validity
        Given an active same-project delegation has a 30-day validity
        When its expiresAt time is reached
        Then the delegation status becomes Expired
        And the delegate can no longer decide project requests

    @security @regression @US-004 @FR-030 @UC-005
    Scenario: Department delegation is not available in this test profile
        Given a DepartmentApprover attempts to delegate department authority
        When the delegation request is submitted
        Then the system denies the request
        And no department delegation is recorded

    @regression @US-004 @AC-004.2 @FR-029 @UC-005
    Scenario: Decision attribution follows the approved audit policy
        Given a delegate acts under a valid delegation
        And the approved audit policy requires actor and delegation attribution
        When the delegate records an approval decision
        Then the recorded action identifies the person who acted
        And it includes delegation context required by that policy

    @regression @US-004 @FR-029 @UC-005
    Scenario: Failed persistence does not activate delegation
        Given a valid same-project delegation request has been submitted
        And the delegation cannot be persisted
        When the system processes the request
        Then the system reports that the delegation was not recorded
        And no new delegation is active