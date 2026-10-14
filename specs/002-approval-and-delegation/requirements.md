# Feature: Approval and Delegation

## Metadata

| Property             | Value                                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Feature ID           | F-002                                                                                                          |
| Source status        | Draft; neither the RFP nor baseline has formal approval evidence                                               |
| Specification status | Draft for real-world use; synthetic test-project profile approved                                              |
| Issue                | Not created; tracker is unconfigured and issue creation is outside this catalog request                        |
| Scenario             | backend+frontend; .NET 8 and Angular 20 test-project stack                                                     |
| Test-project profile | Approved for synthetic-data test scope only; see [decision register](../test-project-feature-decisions.md)     |
| Sources              | [Requirements baseline](../../origin/Requirements-Baseline.md); [RFP](../../origin/RFP-Vacation-Management.md) |

## Goal and Business Value

Enable project and department approvers to review requests and record their decisions, with delegation where authorized. This supports accountable project- and department-level vacation decisions. The approval sequence, required approvers, role assignment, and final-state rules are not yet settled.

## Actors

| Actor                                 | Goal                                                                                              |
| ------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Project approver / responsible person | See in-scope requests and assess, approve, reject, or possibly close them                         |
| Department approver                   | Make a department-level approval decision and see department demand (demand view itself is F-003) |
| Delegate                              | Act within an approved delegated scope and have the decision attributed according to agreed rules |
| Employee / requester                  | Receive a decision through the lifecycle and notification features                                |
| System                                | Identify approvers and preserve the agreed decision outcome                                       |

## In Scope / Out of Scope

**In scope**

- Project-level request visibility, assessment, approval, rejection, and possible close action.
- Department-level approval.
- Identification of the project approver and delegation, including the stated same-project case.
- Clarification of generic “responsible” roles and the proposed department-size approver rule.

**Out of scope**

- Defining approval sequence, business criteria, substitute approver policy, or approval timeout (F-004 handles escalation).
- Demand aggregation and capacity thresholds (F-003), external directory integration mechanics (F-005), and authentication/entry flow (F-006).
- Assuming “close” means reject or that one approval alone is final.

## Functional Requirements Covered

| Baseline ID | Coverage                                                           | Baseline status                                           |
| ----------- | ------------------------------------------------------------------ | --------------------------------------------------------- |
| FR-004      | Project approver views requests for their project                  | Confirmed; association and visibility rules open          |
| FR-005      | Project approver approves a request                                | Confirmed; relationship to other approvals open           |
| FR-006      | Department approver approves a request                             | Confirmed; approver assignment and sequence open          |
| FR-007      | Project approver rejects a request                                 | Confirmed; rejection details and “close” distinction open |
| FR-008      | Project approver assesses (“valorar”) a request                    | Clarification needed                                      |
| FR-009      | Project approver may close a request as a distinct action          | Clarification needed                                      |
| FR-010      | A responsible approver rejects requests                            | Clarification needed; actor identity unresolved           |
| FR-028      | System identifies a project approver                               | Clarification needed                                      |
| FR-029      | Project approver delegates approval to someone in the same project | Confirmed; delegation rules open                          |
| FR-030      | System supports vacation approver delegation                       | Clarification needed                                      |
| FR-031      | Departments of approximately 50 people have at least one approver  | Clarification needed; possible rule only                  |
| FR-032      | Responsible approver sees requested periods for users in scope     | Clarification needed; role and scope unresolved           |

Related requirements: FR-021 to FR-023 for notification/escalation; INT-003 to INT-004 for approver and project membership data; SEC-001 to SEC-003 for draft access proposals and unresolved controls.

## Non-Functional Requirements Applicable

| Baseline ID | Applicability                                                                                               |
| ----------- | ----------------------------------------------------------------------------------------------------------- |
| NFR-001     | Baseline states support for 500 users at a time; concurrency and response/error targets need definition.    |
| NFR-002     | Periods with excess requests should be visually apparent; calculation and visual criteria are open.         |
| NFR-003     | Approvers should see each user's requested vacations simply; usability criteria are open.                   |
| NFR-007     | Nightly rather than real-time synchronization is stated as sufficient; data and freshness details are open. |
| NFR-008     | General readability is requested; measurable legibility criteria are open.                                  |

## User Stories

### US-001: Review project requests

**As a** project approver, **I want** to see the vacation requests for my project, **so that** I can review requests within my responsibility.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                          | Type       | Classification |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-001.1 | Given an approved project membership and approver mapping, when the project approver opens their review view, then requests associated with that project are available for review. | Functional | @smoke         |
| AC-001.2 | Given a request outside the approver's approved scope, then it is not exposed through this project review capability; exact access rules require approval under SEC-002.           | Functional | —              |

### US-002: Record an approval or rejection

**As a** project or department approver, **I want** to record my authorized decision, **so that** the request progresses according to the approved approval process.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                             | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-002.1 | Given an eligible request and an authorized approver, when the approver records an approved decision, then the corresponding project- or department-level outcome is recorded.                        | Functional | @smoke         |
| AC-002.2 | Given an eligible request and an authorized project approver, when the approver rejects it, then a rejected outcome is recorded; reason and follow-up behavior remain pending stakeholder definition. | Functional | —              |

### US-003: Assess or close a request if those are distinct actions

**As a** project approver, **I want** the meaning of assessment and close actions to be explicit, **so that** I can use them consistently without conflating them with approval or rejection.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                               | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-003.1 | Given stakeholders define “valorar,” then a walkthrough demonstrates its approved input and observable outcome before the action is accepted (FR-008).                                                  | Functional | @smoke         |
| AC-003.2 | Given stakeholders define whether “close” is distinct from reject, then a walkthrough demonstrates the approved action and resulting state; no close behavior is assumed before clarification (FR-009). | Functional | —              |

### US-004: Delegate an approval

**As an** authorized project approver, **I want** to delegate approval to an eligible person in the same project, **so that** review can continue when delegation is needed.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                        | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | -------------- |
| AC-004.1 | Given an approved delegation policy and same-project eligibility, when an approver delegates a request or approval responsibility, then the eligible delegate can act within the approved scope. | Functional | @smoke         |
| AC-004.2 | The recorded action identifies the actual actor and delegation context if required by the stakeholder-approved audit rules; attribution requirements are not yet defined.                        | Functional | —              |

### US-005: Resolve approver responsibility

**As a** stakeholder, **I want** project and department approver roles and assignment rules defined, **so that** requests reach the correct decision-makers.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                     | Type       | Classification |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-005.1 | Given an approved project-to-approver source, then an agreed project resolves to its designated approver; behavior for missing or multiple approvers is defined before acceptance (FR-028).   | Functional | @smoke         |
| AC-005.2 | Given stakeholders decide whether FR-030 and the approximately-50-person rule in FR-031 are committed, then the approved delegation and staffing rules are demonstrable; neither is presumed. | Functional | —              |

## Dependencies

- F-001 supplies requests and lifecycle state; F-005 supplies organizational/project approver and membership data (INT-003, INT-004).
- FR-028 and FR-032 depend on approved identity, scope, and authorization rules; SEC-001 and SEC-002 remain Draft proposals.
- FR-021 escalation and FR-022 notifications depend on agreed eligible approval events and outcomes (F-004).
- FR-011 and NFR-002 demand displays belong to F-003; they may inform a decision but their calculation is not defined here.
- No additional external dependency is stated.

## Open Questions

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

- Are project and department approvals sequential, parallel, both mandatory, or conditional? What constitutes final approval?
- Who is the “responsible” actor in FR-010 and FR-032, and what requests may that actor see?
- What does “valorar” mean, and is “close” a separate action or a synonym/transcription issue (FR-008 to FR-009)?
- Who assigns project and department approvers, how many can exist, and what happens when none is found (FR-028, INT-003)?
- Who may delegate, for what duration and scope, and how are actor identity and audit history handled (FR-029 to FR-030)?
- Is one approver mandatory for departments of approximately 50 people, and how is department size measured (FR-031)?
- What are rejection reason, correction, and post-decision rules?
- What access matrix and measurable usability criteria are approved (SEC-002, NFR-002 to NFR-003)?

## Initial Acceptance Criteria

The source criteria above remain draft for real-world use. For the synthetic test profile only, use these executable outcomes:

- **US-001/US-002:** Project approver reviews direct assigned-project requests; project approval is followed by department approval. Both are required for final Approved. Project rejection is terminal and requires a 1–500 character reason; department rejection is unavailable.
- **US-003:** Assessment is read-only review; there is no separate close mutation.
- **US-004/US-005:** Exactly one active project approver is required. Same-project project delegation is allowed for at most 30 calendar days and is revocable by the delegator; no chained or department delegation.
- Traced scenarios: six feature files under [tests](tests/); model and API: [data model](requirements/data-model.md), [OpenAPI](contracts/openapi.yaml).
