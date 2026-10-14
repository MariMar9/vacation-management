@f005-integrations @test-profile
Feature: Organization and export simulator for the synthetic test profile
    Local fixtures simulate provider boundaries; no ServiceNow or Active Directory endpoint is called.

    @smoke @US-001 @AC-001.1 @INT-001
    Scenario: Atomically publish a valid synthetic organization snapshot
        Given a complete snapshot for "DEPT-TEST-001" has unique employees, projects, direct memberships, and approver assignments
        When the simulator validates and publishes the snapshot
        Then the new snapshot version becomes current atomically
        And its freshness timestamp is recorded

    @regression @US-001 @AC-001.2 @INT-001
    Scenario: Invalid snapshot retains the previous valid snapshot
        Given a current valid snapshot exists
        And a new snapshot contains a duplicate employee identifier
        When the simulator validates the new snapshot
        Then the snapshot is rejected with a validation error
        And the previous snapshot remains current

    @regression @US-002 @AC-002.1 @INT-002 @INT-003 @INT-004
    Scenario: Resolve direct project membership and unique approver assignments
        Given the snapshot contains direct project membership and exactly one assigned ProjectApprover per project
        When the application resolves project scope
        Then only directly assigned project members are returned
        And no reporting hierarchy is inferred

    @security @regression @US-002 @AC-002.2 @INT-003
    Scenario: Missing or ambiguous approver mapping blocks decisions
        Given the snapshot has no unique active ProjectApprover assignment for a project
        When the application attempts to resolve decision responsibility
        Then the decision is blocked with an assignment error
        And no arbitrary approver is selected

    @smoke @US-003 @AC-003.1 @AC-003.2 @INT-005 @INT-006
    Scenario: Export only requests with both final approvals
        Given a request has project and department approval and status Approved
        When the scheduled export evaluator runs
        Then one idempotent simulator outbox record is created for the request version
        And no external provider is called

    @security @regression @US-003 @AC-003.2 @INT-006
    Scenario Outline: Do not export requests missing required approval
        Given a request has status "<status>"
        When the scheduled export evaluator runs
        Then no export record is created
        Examples:
            | status                    |
            | PendingProjectApproval    |
            | PendingDepartmentApproval |
            | Rejected                  |
            | Cancelled                 |

    @regression @US-004 @AC-004.1 @AC-004.2 @INT-009 @INT-010
    Scenario: Apply test cadence and exclude unidentified source
        Given the test profile has a valid snapshot fixture
        When the scheduler runs at its configured test cadence
        Then inbound snapshot processing is scheduled daily at 02:00 Europe/Madrid
        And export evaluation is scheduled daily at 03:00 Europe/Madrid
        And no "my scaturing" source is contacted
