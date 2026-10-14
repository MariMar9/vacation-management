@f001-request-lifecycle @test-profile
Feature: Vacation request lifecycle for the synthetic test profile
    Requests use inclusive calendar dates and the approved F-002 sequential approval workflow.

    @smoke @US-001 @AC-001.1 @FR-001
    Scenario: Submit a valid request
        Given an active synthetic requester belongs to project "PRJ-TEST-ALPHA"
        And today's Europe/Madrid date is "2026-10-09"
        When the requester submits a request from "2026-12-21" through "2026-12-30"
        Then the request is created with status "PendingProjectApproval"
        And the requester identity is taken from the authenticated principal

    @regression @US-001 @AC-001.2 @FR-001 @Q-011
    Scenario: Reject an invalid or reversed date range
        Given an active synthetic requester belongs to project "PRJ-TEST-ALPHA"
        When the requester submits a request from "2026-12-30" through "2026-12-21"
        Then the request is rejected with a validation error
        And no request is persisted

    @regression @US-001 @FR-001 @Q-010
    Scenario: Reject an overlapping active request for the same requester and project
        Given the requester has an overlapping request in status "PendingProjectApproval" for project "PRJ-TEST-ALPHA"
        When the requester submits another overlapping request for that project
        Then the submission is rejected as a conflict
        And the existing request is unchanged

    @smoke @US-002 @AC-002.1 @AC-004.1 @FR-002
    Scenario: Requester cancels before the project decision
        Given the requester owns a request in status "PendingProjectApproval"
        And no project decision exists for the request
        When the requester cancels the request
        Then its status becomes "Cancelled"

    @security @regression @US-002 @AC-002.2 @SEC-002
    Scenario: Requester cannot cancel another person's request
        Given a request belongs to a different synthetic requester
        When the current requester attempts to cancel it
        Then the API returns 404 without disclosing request details
        And the request remains unchanged

    @regression @US-002 @FR-002
    Scenario Outline: Cancellation is denied after project review starts
        Given the requester owns a request in status "<status>"
        When the requester attempts to cancel it
        Then the API returns 409
        And the request status remains "<status>"
        Examples:
            | status                    |
            | PendingDepartmentApproval |
            | Approved                  |
            | Rejected                  |
            | Cancelled                 |

    @smoke @US-003 @AC-003.1 @AC-003.2 @FR-012 @FR-013 @FR-014
    Scenario: History groups outcomes and derives taken status
        Given the requester owns Approved, Rejected, Cancelled, and PendingProjectApproval requests
        And today's Europe/Madrid date is "2026-10-09"
        When the requester opens request history
        Then all retained own requests are returned
        And only Approved requests with endDate before "2026-10-09" are marked taken
        And Rejected and Cancelled requests are grouped as non-approved

    @regression @US-004 @AC-004.2 @FR-024
    Scenario: No alternative-period action is offered
        Given a request has been rejected
        When the requester views the outcome
        Then no alternative-period proposal or action is shown
