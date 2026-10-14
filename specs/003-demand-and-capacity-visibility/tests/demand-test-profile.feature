@f003-demand @test-profile
Feature: Demand visibility for the synthetic test profile
    Counts are unique active members with an Approved request overlapping an inclusive period.

    @smoke @US-001 @AC-001.1 @FR-011
    Scenario: Count unique people with approved overlapping requests
        Given the selected project has 10 active synthetic members
        And 3 unique members have Approved requests overlapping the selected period
        And one of those members has two overlapping Approved requests
        When the DepartmentApprover requests demand for that period
        Then activeMemberCount is 10
        And peopleOnApprovedVacation is 3

    @smoke @US-002 @AC-002.1 @AC-002.2 @FR-015 @FR-018
    Scenario Outline: Query a supported direct scope and reporting period
        Given the approver is authorized for direct <scopeType> scope "<scopeId>"
        When the approver queries demand for <period> from "2026-12-01" through "2026-12-31"
        Then the summary identifies scope "<scopeId>" and period "<period>"
        And the result uses only direct membership for that scope
        Examples:
            | scopeType  | scopeId        | period |
            | Department | DEPT-TEST-001  | Week   |
            | Project    | PRJ-TEST-ALPHA | Day    |

    @regression @US-001 @FR-011 @FR-033
    Scenario: Exclude pending, rejected, and cancelled requests
        Given the selected scope has 10 active members
        And overlapping requests include PendingProjectApproval, Rejected, and Cancelled statuses
        When the DepartmentApprover requests demand for that period
        Then none of those requests contribute to peopleOnApprovedVacation

    @smoke @US-003 @AC-003.1 @AC-003.2 @FR-020
    Scenario: Seventy-percent marker is advisory and does not block requests
        Given 7 of 10 active members have Approved overlapping requests
        When the DepartmentApprover requests demand for the period
        Then demandPercentage is 70
        And thresholdExceeded is true
        And no request or approval action is blocked

    @regression @US-001 @FR-016
    Scenario: Empty scope returns zero count and null percentage
        Given the selected project has no active members
        When the DepartmentApprover requests demand for that project
        Then activeMemberCount is 0
        And peopleOnApprovedVacation is 0
        And demandPercentage is null

    @security @regression @US-002 @SEC-002
    Scenario: Approver cannot query a scope outside assigned membership
        Given the DepartmentApprover is assigned only to "DEPT-TEST-001"
        When the approver queries another department scope
        Then the API returns 403
        And no demand data is disclosed

    @regression @US-004 @AC-004.1 @AC-004.2 @FR-019
    Scenario: Capacity limit is advisory only
        Given an authorized DepartmentApprover sets a limit of 5 for the test period
        And 6 unique members have Approved overlapping requests
        When the DepartmentApprover reads demand
        Then capacityExceeded is true
        And the system does not change request acceptance or approval behavior

    @regression @US-001 @AC-001.2 @NFR-007
    Scenario: Stale snapshot is identified
        Given the latest valid organization snapshot is older than 36 hours
        When the DepartmentApprover requests demand
        Then stale is true
        And dataAsOf identifies the snapshot timestamp
