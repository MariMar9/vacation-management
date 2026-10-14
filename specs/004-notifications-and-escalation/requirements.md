# Feature: Notifications and Escalation

## Metadata

| Property             | Value                                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Feature ID           | F-004                                                                                                          |
| Source status        | Draft; neither the RFP nor baseline has formal approval evidence                                               |
| Specification status | Draft for real-world use; synthetic test-project profile approved                                              |
| Issue                | Not created; tracker is unconfigured and issue creation is outside this catalog request                        |
| Scenario             | backend-only; .NET 8 test-project stack; delivery uses a local notification simulator                          |
| Test-project profile | Approved for synthetic-data test scope only; see [decision register](../test-project-feature-decisions.md)     |
| Sources              | [Requirements baseline](../../origin/Requirements-Baseline.md); [RFP](../../origin/RFP-Vacation-Management.md) |

## Goal and Business Value

Inform requesters of request outcomes and alert the department approver when a request remains unapproved beyond an agreed time. This supports timely awareness and review. Email is named as a channel; Teams is optional/draft, and event, timing, delivery, and escalation policy details remain unresolved.

## Actors

| Actor                | Goal                                                                              |
| -------------------- | --------------------------------------------------------------------------------- |
| Employee / requester | Receive relevant approval and cancellation information                            |
| Department approver  | Receive an alarm about an eligible request that remains unapproved                |
| Project approver     | Act on requests before escalation, according to an approved workflow              |
| System               | Trigger agreed notification events and deliver messages through approved channels |

## In Scope / Out of Scope

**In scope**

- Notify users when their request is approved or cancelled.
- Email as the stated initial notification channel.
- Escalation/alarm to the department approver for requests unapproved beyond a stakeholder-defined time.
- Consider optional Teams notifications and later-stage adaptive cards without treating them as committed scope.

**Out of scope**

- Defining timeout, repeat cadence, channel delivery guarantees, message content, or final approval semantics.
- Approval decisions/delegation (F-002), cancellation lifecycle rules (F-001), and directory or messaging integration implementation (F-005).
- Treating Teams or adaptive cards as mandatory.

## Functional Requirements Covered

| Baseline ID | Coverage                                                                       | Baseline status                                            |
| ----------- | ------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| FR-021      | Alarm department approver when a request remains unapproved for a defined time | Clarification needed                                       |
| FR-022      | Notify users when requests are approved                                        | Confirmed; channel/content and final-approval trigger open |
| FR-023      | Notify users when requests are cancelled                                       | Confirmed; cancellation cases/channel open                 |
| FR-027      | Adaptive cards may be incorporated in a later stage                            | Draft                                                      |

Related integration requirements: INT-007 (email, confirmed but details open), INT-008 (optional Teams, Draft), INT-009 and NFR-007 (nightly exchange/freshness context). FR-005, FR-006, and FR-002 to FR-003 define source events and are covered by F-001/F-002.

## Non-Functional Requirements Applicable

| Baseline ID | Applicability                                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------------------------ |
| NFR-001     | 500 users at a time is stated; concurrency and response/error targets need clarification.                          |
| NFR-005     | Seasonal peak and low usage should be supported; load profile is not defined.                                      |
| NFR-007     | Nightly rather than real-time synchronization is stated for data updates; it does not define notification latency. |
| NFR-008     | General readability is requested; approved message and display legibility criteria are open.                       |

No notification delivery-time, availability, retry, or retention target is established in the baseline.

## User Stories

### US-001: Notify me of approval

**As an** employee, **I want** to be notified when my request is approved, **so that** I know its outcome.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                 | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-001.1 | Given an approval event that meets the stakeholder-approved notification trigger, when it occurs, then the requesting user receives the approved notification through the agreed channel. | Functional | @smoke         |
| AC-001.2 | Notification recipient, content, channel, and whether one or all required approvals trigger it are verified against an approved event definition.                                         | Functional | —              |

### US-002: Notify me of cancellation

**As an** employee, **I want** to be notified when my request is cancelled, **so that** I know the request no longer follows its prior path.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                  | Type       | Classification |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-002.1 | Given an agreed cancellation event and recipient rule, when the event occurs, then the requesting user receives the corresponding notification through the agreed channel. | Functional | @smoke         |
| AC-002.2 | User-initiated and any approver/system-initiated cancellation cases are included only as specified by the approved event definition.                                       | Functional | —              |

### US-003: Escalate an unapproved request

**As a** department approver, **I want** to receive an alarm when an eligible request remains unapproved beyond an agreed time, **so that** I can review the delay.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                      | Type       | Classification |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-003.1 | Given an approved timeout, eligible request state, recipient, and channel, when the timeout is reached without the required approval, then the department approver receives the defined alarm. | Functional | @smoke         |
| AC-003.2 | Repeat behavior, suppression after a decision, and whether an alarm grants or changes approval authority match the approved escalation policy.                                                 | Functional | —              |

### US-004: Use optional messaging channels when approved

**As a** user, **I want** any approved optional Teams or later adaptive-card message to follow the agreed channel policy, **so that** I can access relevant request information there.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                   | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-004.1 | If Teams is approved and enabled, then a stakeholder-approved event reaches its defined recipient with the approved content and application link (INT-008). | Functional | @smoke         |
| AC-004.2 | Adaptive cards are not considered accepted or required until their stage, channel, purpose, and behavior are approved (FR-027).                             | Functional | —              |

## Dependencies

- F-001 provides request/cancellation events; F-002 provides approval decisions and required approver sequence.
- INT-007 is the email integration dependency; INT-008 is optional and Draft. Channel implementation is within F-005 integration scope.
- FR-021 depends on approval state and approver assignment (FR-005 to FR-006, FR-028); F-002 and F-005 provide these.
- NFR-007 concerns data synchronization and must not be interpreted as a notification delivery-time target.
- No additional external dependency is stated.

## Open Questions

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

## Test-Project Acceptance Criteria

- **US-001/US-002:** Queue the event/recipient pairs defined in [events.yaml](contracts/events.yaml); only both-level final approval notifies the requester as approved. Eligible requester cancellation notifies requester and current approver.
- **US-003:** Reminder once after 3 calendar days and escalation once after 5 calendar days in the current pending level; suppress after terminal outcome. Use an injectable test clock.
- **US-004:** Teams/adaptive cards are excluded. The local simulator never sends external email or messages; its payload excludes credentials, reason text, and unnecessary personal data.
- Traced scenarios: [notification test profile](tests/notification-test-profile.feature); model and simulator API: [data model](requirements/data-model.md), [OpenAPI](contracts/openapi.yaml).

- Which approval outcome triggers FR-022: any approver decision, or completion of all required approvals?
- Which cancellation events and recipients trigger FR-023?
- What is the FR-021 timeout, start event, eligible request state, repetition/suppression rule, and escalation authority?
- What events, recipients, content, delivery expectation, failure handling, audit, and retention apply to INT-007 email?
- Is Teams in scope or optional, and which events and users apply (INT-008)?
- What stage and behavior are intended for adaptive cards (FR-027)?
- What notification latency and operational reliability targets should apply? The baseline does not specify them.

## Initial Acceptance Criteria

The criteria above require approved event and channel definitions before final acceptance. The catalog does not infer timeout values, delivery guarantees, final-approval semantics, or mandatory Teams/adaptive-card scope. Formal source approval remains outstanding.
