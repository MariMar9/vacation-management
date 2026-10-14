# Scenario: backend+frontend, synthetic test-project profile.
# Spec: ../requirements.md
# User story: US-005. Use case: UC-006.
# A valid test snapshot has exactly one active project approver per project.

@test-profile
@f002-approval-workflow
Feature: Resolve approver responsibility
    The system resolves project approvers from the approved source and scope rules.

    @smoke @regression @US-005 @AC-005.1 @FR-028 @UC-006
    Scenario: System resolves the designated project approver
        Given a request is associated with a project
        And the approved source maps that project to a designated approver
        When the system resolves approver responsibility
        Then the designated project approver is resolved
        And the request is available only within authorized scope

    @regression @US-005 @AC-005.1 @FR-028 @UC-006
    Scenario: Multiple active project approvers create a mapping error
        Given the source provides more than one active project approver for the project
        When the system resolves approver responsibility
        Then the system reports an assignment conflict
        And it does not select an arbitrary approver

    @regression @US-005 @AC-005.1 @FR-028 @UC-006
    Scenario: Missing project approver leaves responsibility unresolved
        Given the approved source has no project approver mapping
        When the system resolves approver responsibility
        Then the system reports unresolved responsibility
        And it does not select an approver
        And it does not expose requests based on an unverified mapping

    @regression @US-005 @AC-005.1 @FR-028 @UC-006
    Scenario: Conflicting mappings do not select an arbitrary approver
        Given multiple project mappings conflict with the approved mapping rule
        When the system resolves approver responsibility
        Then the system reports an assignment conflict
        And it does not select an arbitrary approver

    @regression @US-005 @FR-028 @UC-006
    Scenario: Unavailable or stale source data does not establish responsibility
        Given project approver data is unavailable or cannot be verified as current
        When the system resolves approver responsibility
        Then the system does not treat the mapping as verified
        And no request is exposed or decision authority granted from that mapping

    @security @regression @US-005 @FR-028 @UC-006
    Scenario: Resolved mapping alone does not grant access
        Given a person appears in the project approver source
        And the person lacks approved access for the request scope
        When the person attempts to review or decide the request
        Then access or the decision is denied

    @regression @US-005 @AC-005.2 @FR-030 @FR-031
    Scenario: Delegation and department staffing rules stay within test scope
        Given the test profile enables only same-project project-approver delegation
        And the test fixture has one explicit DepartmentApprover assignment
        When approver responsibility is resolved
        Then no department delegation or department-size staffing rule is inferred