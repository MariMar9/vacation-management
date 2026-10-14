@f006-access @test-profile
Feature: Entry and scoped access for synthetic test identities
    Hosted authentication uses the approved Entra OIDC direction; automated tests use fake identities.

    @smoke @US-001 @AC-001.1 @FR-025
    Scenario: Active test user opens the application
        Given an active synthetic user has a valid test identity
        When the user opens the application link
        Then the access profile is returned for "DEPT-TEST-001"
        And only assigned roles and direct project scopes are included

    @security @regression @US-001 @AC-001.2 @SEC-001
    Scenario: Missing identity is rejected
        Given the request has no valid bearer identity
        When the user requests an application access profile
        Then the API returns 401
        And no user or scope data is disclosed

    @smoke @US-003 @AC-003.1 @SEC-002
    Scenario: Requester can access only own request operations
        Given a user has the Requester role
        When the user requests their own history
        Then the operation is allowed
        When the user attempts to cancel another requester's request
        Then the API returns 404 without disclosing the other request

    @security @regression @US-003 @AC-003.2 @SEC-002
    Scenario: Project approver is limited to direct assigned projects
        Given a user is assigned ProjectApprover for "PRJ-TEST-ALPHA"
        When the user requests review for "PRJ-TEST-BETA"
        Then the API returns 403
        And no request data is disclosed

    @security @regression @US-003 @SEC-002
    Scenario: User cannot approve their own request
        Given a user has both Requester and ProjectApprover roles
        And the request belongs to that user
        When the user attempts to decide the request
        Then the API returns 403
        And no decision is recorded

    @regression @US-002 @AC-002.1 @AC-002.2 @FR-026
    Scenario: Test participation uses pre-provisioned synthetic users
        Given a synthetic test user is provisioned in the isolated test fixture
        When the user opens the application link
        Then the user can access only the approved test capabilities
        And no public signup or production trial is offered

    @security @regression @US-003 @SEC-003
    Scenario: Cross-department scope is always denied
        Given the current user belongs to "DEPT-TEST-001"
        When the user requests data for another department
        Then the API returns 403
        And no cross-department data is disclosed
