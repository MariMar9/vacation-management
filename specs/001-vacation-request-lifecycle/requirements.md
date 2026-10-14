# Feature: Vacation Request Lifecycle

## Metadata

| Property             | Value                                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Feature ID           | F-001                                                                                                          |
| Source status        | Draft; neither the RFP nor baseline has formal approval evidence                                               |
| Specification status | Draft for real-world use; synthetic test-project profile approved                                              |
| Issue                | Not created; tracker is unconfigured and issue creation is outside this catalog request                        |
| Scenario             | backend+frontend; .NET 8 and Angular 20 test-project stack                                                     |
| Test-project profile | Approved for synthetic-data test scope only; see [decision register](../test-project-feature-decisions.md)     |
| Sources              | [Requirements baseline](../../origin/Requirements-Baseline.md); [RFP](../../origin/RFP-Vacation-Management.md) |

## Goal and Business Value

Let employees submit and manage vacation requests and understand their own request outcomes. This establishes the core workflow that the approval, notification, and demand-visibility features depend on. The business value is a consistent, visible process for vacation requests; lifecycle states and policy details remain to be agreed.

## Actors

| Actor                                   | Goal                                                                                                  |
| --------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Employee / requesting user              | Submit a request, cancel their own request where permitted, and consult vacation history and outcomes |
| Project approver / responsible approver | Review a request and provide an approval decision (detailed decision behavior is covered in F-002)    |
| Department approver                     | Participate in the approval process where required (covered in F-002)                                 |
| System                                  | Maintain request outcomes and make them available to related approval and notification processes      |

## In Scope / Out of Scope

**In scope**

- Request submission and the requester's own cancellation process.
- Request cancellation lifecycle, request history, and views of approved and non-approved requests.
- Explicitly recording that the workflow does not propose alternative vacation periods, subject to clarification of what alternatives means.

**Out of scope**

- Defining required request fields, validation, leave policies, or final lifecycle states not present in the baseline.
- Approver decision rules and delegation (F-002), demand calculations (F-003), notifications (F-004), external data exchange (F-005), and entry/access policies (F-006).
- Implementing or choosing a technical architecture.

## Functional Requirements Covered

| Baseline ID | Coverage                                      | Baseline status                                               |
| ----------- | --------------------------------------------- | ------------------------------------------------------------- |
| FR-001      | Employee submits a vacation request           | Clarification needed                                          |
| FR-002      | Employee cancels their own request            | Confirmed; permitted states and effects unresolved            |
| FR-003      | A cancellation process exists                 | Clarification needed                                          |
| FR-012      | Employee consults previously taken vacation   | Confirmed; historical range and meaning of “taken” unresolved |
| FR-013      | Employee consults approved requests           | Confirmed; history and status rules unresolved                |
| FR-014      | Employee consults non-approved requests       | Confirmed; included states unresolved                         |
| FR-024      | Workflow does not propose alternative periods | Clarification needed                                          |

Related requirements: FR-005 to FR-007 and FR-022 to FR-023 (approval outcomes and notifications); SEC-001 to SEC-003 (draft security proposals and unresolved obligations).

## Non-Functional Requirements Applicable

| Baseline ID | Applicability                                                                                                                 |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------- |
| NFR-003     | Approvers should be able to see requested vacations simply; usability criteria need stakeholder definition.                   |
| NFR-004     | Users should be able to view calendars easily; calendar views and measurable criteria are open.                               |
| NFR-007     | Nightly update download is stated as sufficient instead of real-time synchronization; exact data and schedule are unresolved. |
| NFR-008     | Readability is a stated quality need; devices, browsers, and legibility criteria are open.                                    |

No response-time, availability, accessibility, or retention target is established for this feature. Do not infer one from the source proposals.

## User Stories

### US-001: Submit a vacation request

**As an** employee, **I want** to submit a vacation request, **so that** it can enter the agreed review process.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                     | Type       | Classification |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-001.1 | Given the request fields and validation rules have been approved, when an employee submits a valid request, then the request is recorded and made available to the applicable review process. | Functional | @smoke         |
| AC-001.2 | Given required fields or validation rules have not been approved, then this criterion remains blocked from final acceptance; no field set or validation behavior is assumed.                  | Functional | —              |

### US-002: Cancel my request

**As an** employee, **I want** to cancel my own vacation request, **so that** a request I no longer need is handled by the agreed cancellation process.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                   | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-002.1 | Given an eligible request and approved cancellation rules, when its requesting employee cancels it, then the request reflects the agreed cancelled outcome. | Functional | @smoke         |
| AC-002.2 | A user cannot cancel another employee's request through this capability; the authorization rule and verification method require approval under SEC-002.     | Functional | —              |

### US-003: Consult my vacation history and outcomes

**As an** employee, **I want** to consult my past vacations and approved or non-approved requests, **so that** I can understand my vacation record and request outcomes.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                     | Type       | Classification |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-003.1 | Given agreed status definitions and history rules, when the employee opens their request view, then the view distinguishes approved and non-approved requests according to those definitions. | Functional | @smoke         |
| AC-003.2 | Given an agreed historical range and definition of “taken,” when the employee consults vacation history, then the view contains the matching vacation periods for that employee.              | Functional | —              |

### US-004: Follow the agreed cancellation and alternative-period behavior

**As an** employee, **I want** cancellation and rejection outcomes to follow a defined process, **so that** I know what happens when a request changes or is declined.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                                       | Type       | Classification |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-004.1 | Given stakeholders have defined what may be cancelled and its lifecycle effects, then a walkthrough demonstrates the approved cancellation process and its outcomes.                                            | Functional | @smoke         |
| AC-004.2 | Given stakeholders have clarified FR-024, then the workflow either has no alternative-period action or follows the explicitly approved interpretation; no alternative behavior is assumed before that decision. | Functional | —              |

## Dependencies

- FR-001 depends on SEC-001 authentication being resolved for the applicable user population; SEC-001 is currently Draft.
- FR-002 depends on FR-001 and FR-003; cancellation rules and eligible states need clarification.
- Approval outcomes depend on F-002 (FR-004 to FR-010); notification behavior depends on F-004 (FR-022 to FR-023).
- NFR-007 and INT-001 to INT-009 affect freshness of related employee and request views; exact data flow is unresolved.
- No additional external dependency is stated for this feature.

## Open Questions

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

## Test-Project Acceptance Criteria

- **US-001:** Accept only `projectId`, inclusive `startDate`/`endDate`, and optional 500-character `reason`; enforce today-or-later, ordered range, and no overlapping active request in the same project. New request starts in `PendingProjectApproval`.
- **US-002:** Requester may cancel only their own request before a project decision while status is `PendingProjectApproval`; deny all other states and identities without mutation.
- **US-003:** Return all retained own requests. Distinguish pending, Approved, and non-approved (Rejected/Cancelled); derive `taken` only for Approved requests whose end date is before today's Europe/Madrid date.
- **US-004:** No alternative-period action exists. F-002 decisions own approval/rejection transitions.
- Traced scenarios: [request lifecycle test profile](tests/request-lifecycle-test-profile.feature); model and API: [data model](requirements/data-model.md), [OpenAPI](contracts/openapi.yaml).

- What fields, date rules, validations, and request states are required to submit a request (FR-001)?
- Which states can be cancelled, can an approved request be cancelled, and what side effects follow (FR-002 to FR-003)?
- What does “vacation taken” mean, what history range is visible, and how are cancellations represented (FR-012 to FR-014)?
- What is meant by “alternative periods,” and at which workflow stage does FR-024 apply?
- Which authentication and authorization requirements are approved (SEC-001 to SEC-003)?
- Which calendar views, devices, and readability criteria are required (NFR-004, NFR-008)?

## Initial Acceptance Criteria

The criteria above are initial and conditional. Final acceptance requires stakeholder resolution of the linked clarification-needed items and formal approval of the source baseline. No policy values or lifecycle transitions are inferred here.
