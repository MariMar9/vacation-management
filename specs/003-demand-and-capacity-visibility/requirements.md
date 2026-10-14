# Feature: Demand and Capacity Visibility

## Metadata

| Property             | Value                                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Feature ID           | F-003                                                                                                          |
| Source status        | Draft; neither the RFP nor baseline has formal approval evidence                                               |
| Specification status | Draft for real-world use; synthetic test-project profile approved                                              |
| Issue                | Not created; tracker is unconfigured and issue creation is outside this catalog request                        |
| Scenario             | backend+frontend; .NET 8 and Angular 20 test-project stack                                                     |
| Test-project profile | Approved for synthetic-data test scope only; see [decision register](../test-project-feature-decisions.md)     |
| Sources              | [Requirements baseline](../../origin/Requirements-Baseline.md); [RFP](../../origin/RFP-Vacation-Management.md) |

## Goal and Business Value

Show approvers how vacation requests overlap within relevant project, team, department, or organizational scopes. This helps stakeholders identify concentrated demand and make informed decisions. The baseline has not defined the denominator, counted request states, period boundaries, or whether the stated 70% is a fixed threshold.

## Actors

| Actor                                 | Goal                                                                                           |
| ------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Department approver                   | See the number of people on vacation across the department for a period                        |
| Project approver / responsible person | Identify concentrated requested vacation periods within an agreed project/team scope           |
| Employee                              | Consult own history/calendar where supported by F-001                                          |
| System                                | Retrieve membership and request data and present counts using stakeholder-approved definitions |

## In Scope / Out of Scope

**In scope**

- Department-level count of people on vacation for a period.
- Selecting organizational scope and period, showing population and request counts, and configuring/managing concurrent-vacation limits if approved.
- Showing periods above an agreed demand threshold, including evaluation of the July-week 70% example.

**Out of scope**

- Defining the denominator, capacity policy, threshold, request statuses, or headcount semantics without stakeholder decision.
- Approver decisions and delegation (F-002), source-system integration implementation (F-005), and calendar/history lifecycle behavior (F-001).
- Assuming “on vacation” means approved/current leave or that 70% is a binding threshold.

## Functional Requirements Covered

| Baseline ID | Coverage                                                                | Baseline status                                                          |
| ----------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| FR-011      | Department approver sees number of people on vacation for a period      | Confirmed; count meaning and period open                                 |
| FR-015      | Select an organizational level                                          | Clarification needed; conflicts with single-level organization statement |
| FR-016      | Return population count for selected organizational level and period    | Clarification needed; may be request count rather than headcount         |
| FR-017      | Organize population by department                                       | Confirmed; canonical source and hierarchy details open                   |
| FR-018      | Configure/select period in days or weeks                                | Clarification needed                                                     |
| FR-019      | Manage concurrent-vacation limit for a period                           | Clarification needed                                                     |
| FR-020      | Show July weeks whose team vacation requests exceed 70%                 | Clarification needed; 70% may be illustrative                            |
| FR-033      | Return number of people in scope who requested vacation during a period | Clarification needed; counted states open                                |

Related requirements: BR-004 to BR-006; FR-004 and FR-032 for approver visibility; INT-001 to INT-004 for membership data.

## Non-Functional Requirements Applicable

| Baseline ID | Applicability                                                                                     |
| ----------- | ------------------------------------------------------------------------------------------------- |
| NFR-001     | Support for 500 users at a time is stated; concurrency and response/error targets are unresolved. |
| NFR-002     | Excess-request periods should be very visually apparent; criteria and calculation are unresolved. |
| NFR-003     | Approvers should see requested vacations simply; usability criteria are unresolved.               |
| NFR-004     | Calendar viewing should be easy; supported views and measurable criteria are unresolved.          |
| NFR-005     | Usage is seasonal; peak profile and scale objectives are unresolved.                              |
| NFR-006     | Avoid unnecessary low-period operating costs; no budget or target is stated.                      |
| NFR-009     | Initial department population is approximately 500; exact population and scope need confirmation. |

## User Stories

### US-001: View department vacation count

**As a** department approver, **I want** to see how many people are on vacation in a selected period, **so that** I can understand department-level demand.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                     | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-001.1 | Given an agreed definition of “on vacation,” department scope, and period, when the approver requests the view, then the displayed count matches an agreed reference dataset. | Functional | @smoke         |
| AC-001.2 | The view identifies the selected scope and period; freshness and period boundary behavior are defined and approved before final acceptance.                                   | Functional | —              |

### US-002: Inspect demand by organizational scope and period

**As a** project or department approver, **I want** to inspect vacation requests across an agreed organizational scope and period, **so that** I can identify overlapping demand.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                     | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-002.1 | Given approved scope membership and request-counting rules, when an approver selects a scope and period, then the returned request count matches an agreed reference dataset. | Functional | @smoke         |
| AC-002.2 | Given the organization-level model is approved, then the selectable scope options and day/week period behavior match that model; neither is assumed beforehand.               | Functional | —              |

### US-003: Identify periods of concentrated demand

**As a** project approver, **I want** periods exceeding an approved demand threshold to be apparent, **so that** I can focus review on concentrated requests.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                           | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-003.1 | Given stakeholder-approved numerator, denominator, request states, scope, and threshold, when a period meets the agreed excess-demand rule, then it is distinguishable in the view. | Functional | @smoke         |
| AC-003.2 | The July-week 70% example is tested only if stakeholders confirm it as a fixed rule; otherwise the agreed illustrative interpretation is documented and tested.                     | Functional | —              |

### US-004: Manage concurrent-vacation capacity

**As an** authorized stakeholder, **I want** to manage an approved concurrent-vacation limit, **so that** approvers can assess demand against an agreed capacity policy.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | -------------- |
| AC-004.1 | Given approved ownership, scope, and limit behavior, when an authorized actor configures the limit, then the agreed value is reflected for the defined period and scope. | Functional | @smoke         |
| AC-004.2 | Whether an exceeded limit blocks, warns, or only displays information is verified against an explicit stakeholder decision; no enforcement is presumed.                  | Functional | —              |

## Dependencies

- FR-011, FR-016, FR-017, and FR-033 depend on authoritative department/organizational membership and request data (F-005; INT-001 to INT-004).
- Request records and states depend on F-001; approver access and project/team scope depend on F-002 and SEC-002.
- Period and freshness behavior relates to FR-018 and NFR-007; source systems and nightly exchange remain unresolved.
- NFR-001, NFR-005, and NFR-006 need measurable scale, seasonal-load, and cost objectives before verification.
- No additional external dependency is stated.

## Open Questions

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

## Test-Project Acceptance Criteria

- **US-001/US-002:** Count unique active members with an Approved request overlapping the selected inclusive period. Exclude pending/rejected/cancelled; support Department or direct Project scope only.
- **US-003:** `demandPercentage = peopleOnApprovedVacation / activeMemberCount * 100`; return null for zero denominator. The 70% marker is advisory only.
- **US-004:** Authorized DepartmentApprover may set a scoped/period limit; exceedance is visible only and never blocks request submission or approval.
- **Freshness:** Include `dataAsOf` and mark snapshots older than 36 hours stale.
- Traced scenarios: [demand test profile](tests/demand-test-profile.feature); model and API: [data model](requirements/data-model.md), [OpenAPI](contracts/openapi.yaml).

- Is the count a department headcount, count of requesters, or count of approved/current vacations (FR-011, FR-016, FR-033)?
- What numerator, denominator, scope, period boundaries, and request states define demand percentage?
- Is 70% a fixed policy or an example, and which year/team/week does the July example concern (FR-020)?
- Which organizational levels are selectable given the conflict in FR-015 to FR-017 and TC-005?
- Do day/week periods represent request duration, display granularity, or reporting filters, and who configures them (FR-018)?
- Who owns the concurrent limit, at what scope does it apply, and does exceeding it block or warn (FR-019)?
- What are the measurable visual/usability criteria, seasonal load profile, concurrency definition, and cost objective (NFR-001 to NFR-006)?
- Confirm the initial department population separately from simultaneous-user capacity (NFR-009 vs NFR-001).

## Initial Acceptance Criteria

All criteria are conditional on the unresolved counting and policy definitions above. No threshold, denominator, capacity behavior, or scale target is introduced by this catalog. Formal approval of the RFP/baseline remains outstanding.
