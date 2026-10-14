# Scenario: backend+frontend, synthetic test-project profile.
# Decision source: ../../test-project-feature-decisions.md; no real organizational data is used.
# Spec: ../requirements.md
# Use case: UC-001

@test-profile
@f002-approval-workflow
Feature: Review project vacation requests
    Project approvers can review requests only within their approved project scope.

    @smoke @regression @US-001 @AC-001.1 @FR-004 @UC-001
    Scenario: Project approver sees requests associated with an assigned project
        Given a project approver has an approved project-to-approver mapping
        And a vacation request is associated with that project
        When the project approver opens the review view for that project
        Then the request is available for review
        And its requested period is presented for review

    @regression @US-001 @UC-001
    Scenario: Project approver sees no requests when the project has none
        Given a project approver has an approved project-to-approver mapping
        And no vacation requests are associated with that project
        When the project approver opens the review view for that project
        Then the system indicates that no requests are available
        And no request data is changed

    @regression @US-001 @UC-001
    Scenario: Review is limited to the selected authorized project
        Given a project approver is authorized for more than one project
        And an approved scope policy defines the project being reviewed
        And requests are associated with the selected and another project
        When the approver opens the review view for the selected project
        Then only requests in the selected authorized project scope are available

    @security @regression @US-001 @AC-001.2 @UC-001
    Scenario: Request outside the approver's scope is not exposed
        Given a vacation request belongs to a project outside the approver's approved scope
        When the approver attempts to access that request through project review
        Then access to the request is denied
        And the request details are not disclosed

    @regression @US-001 @UC-001
    Scenario: Missing or ambiguous project mapping prevents scoped review
        Given the system cannot resolve a unique approved project mapping for the approver
        When the approver opens project review
        Then the system reports that the review scope cannot be established
        And no project requests are exposed

    @regression @US-001 @UC-001
    Scenario: Unavailable project or request data is not presented as complete
        Given project membership or request data cannot be verified
        When the approver opens project review
        Then the system reports that review data could not be loaded
        And the system does not present an unverified result as complete