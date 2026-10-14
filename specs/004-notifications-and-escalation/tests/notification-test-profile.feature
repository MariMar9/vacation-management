@f004-notifications @test-profile
Feature: Notification and escalation simulator for the synthetic test profile
    Events are written to a local outbox; no external email or Teams messages are sent.

    @smoke @US-001 @AC-001.1 @AC-001.2 @FR-022
    Scenario: Notify requester only after final approval
        Given a request has a project approval but no department decision
        When the project approval event is processed
        Then a notification is queued for the assigned DepartmentApprover
        And no final-approval notification is queued for the requester
        When the department approver approves the request
        Then one final-approval notification is queued for the requester

    @smoke @US-002 @AC-002.1 @AC-002.2 @FR-023
    Scenario: Notify requester and current approver after eligible cancellation
        Given a request is cancelled by its requester before project review
        When the cancellation event is processed
        Then one notification is queued for the requester
        And one notification is queued for the assigned ProjectApprover

    @smoke @US-003 @AC-003.1 @FR-021
    Scenario: Escalate once after five calendar days in a pending level
        Given a request has remained PendingProjectApproval for 5 calendar days
        And the request has no terminal outcome
        When the test clock evaluates escalations
        Then one escalation is queued for the DepartmentApprover
        And the escalation does not grant approval authority

    @regression @US-003 @AC-003.2 @FR-021
    Scenario: Suppress reminders after a terminal outcome
        Given a request was finally Approved before its 5-day escalation time
        When the test clock evaluates reminders and escalations
        Then no reminder or escalation is queued for that request

    @regression @US-003 @FR-021
    Scenario: Reminder and escalation are each emitted at most once
        Given a request remains pending beyond 5 calendar days
        When the test clock evaluates escalations twice
        Then exactly one reminder and one escalation exist for each event key

    @security @regression @US-001 @INT-007
    Scenario: Notification payload excludes rejection reason and credentials
        Given a rejection event has a reason and an authenticated recipient
        When the local notification simulator queues the event
        Then the payload contains request and outcome references only
        And the payload contains no reason text, token, or credential

    @regression @US-004 @AC-004.1 @AC-004.2 @FR-027 @INT-008
    Scenario: Teams and adaptive cards are excluded
        Given the test profile has no Teams channel enabled
        When any approved test event is processed
        Then no Teams or adaptive-card delivery is attempted
