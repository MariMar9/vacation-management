# Feature: Organizational Data and Integrations

## Metadata

| Property             | Value                                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Feature ID           | F-005                                                                                                          |
| Source status        | Draft; neither the RFP nor baseline has formal approval evidence                                               |
| Specification status | Draft for real-world use; synthetic test-project profile approved                                              |
| Issue                | Not created; tracker is unconfigured and issue creation is outside this catalog request                        |
| Scenario             | backend+integration; .NET 8 with local ServiceNow/AD simulators                                                |
| Test-project profile | Approved for synthetic-data test scope only; see [decision register](../test-project-feature-decisions.md)     |
| Sources              | [Requirements baseline](../../origin/Requirements-Baseline.md); [RFP](../../origin/RFP-Vacation-Management.md) |

## Goal and Business Value

Use agreed organizational and membership data to scope requests, identify approvers, support demand counts, and exchange approved vacation information with existing systems. This connects the application to the organization's current data. System ownership, fields, contracts, schedules, hierarchy, and error handling have not been fully defined.

## Actors

| Actor                         | Goal                                                                                 |
| ----------------------------- | ------------------------------------------------------------------------------------ |
| Department/data owner         | Confirm authoritative department membership and organizational structure             |
| Project approver / data owner | Confirm project membership and project approver mappings                             |
| Integration/system owner      | Define and operate agreed inbound and outbound exchanges                             |
| Employee / requester          | Have organizational context associated with their request                            |
| System                        | Retrieve approved source data and transmit only the agreed approved vacation records |

## In Scope / Out of Scope

**In scope**

- Retrieve department membership from ServiceNow and organizational/approver/project-member data from Active Directory, as stated in the baseline.
- Send approved vacations to ServiceNow, subject to required approver approval rules.
- Resolve nightly update scope and evaluate the uncertain “my scaturing” integration as an open proposal.
- Clarify organizational hierarchy and the initial single-department boundary.

**Out of scope**

- Selecting a cloud provider, application architecture, or integration technology based on unapproved source proposals.
- Defining API contracts, data fields, mapping, retry/reconciliation, or exact schedules without system-owner decisions.
- Approval workflow and demand presentation (F-002/F-003), notifications (F-004), and user entry/access (F-006).

## Functional Requirements Covered

| Baseline ID | Coverage                                                                | Baseline status                                   |
| ----------- | ----------------------------------------------------------------------- | ------------------------------------------------- |
| FR-017      | Organize the population by department                                   | Confirmed; source-of-truth details open           |
| FR-028      | Identify project approver from an approved source                       | Clarification needed; behavior covered with F-002 |
| INT-001     | Retrieve department membership from ServiceNow                          | Confirmed; interface and mapping open             |
| INT-002     | Retrieve organizational information from Active Directory               | Clarification needed                              |
| INT-003     | Retrieve project approver identity from Active Directory                | Confirmed; source field/cardinality open          |
| INT-004     | Retrieve people associated with or reporting to each project approver   | Clarification needed                              |
| INT-005     | Send approved vacations to ServiceNow                                   | Confirmed; interface and handling open            |
| INT-006     | Include only vacations approved by each required approver in the export | Confirmed; required approvals/finality open       |
| INT-009     | Download updates nightly from source systems                            | Clarification needed                              |
| INT-010     | Evaluate possible “my scaturing” integration                            | Draft                                             |

Related requirements: TC-003 to TC-006; NFR-007; FR-011, FR-015 to FR-016, FR-032 to FR-033; SEC-001 to SEC-003. INT-007 and INT-008 notification transports are linked to F-004.

## Non-Functional Requirements Applicable

| Baseline ID | Applicability                                                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------- |
| NFR-001     | The stated 500-user-at-a-time capacity may affect integration load; concurrency and performance targets need definition.          |
| NFR-005     | Seasonal usage variation may affect exchange and processing load; peak profile is open.                                           |
| NFR-006     | Low-use cost efficiency is stated without a budget or target.                                                                     |
| NFR-007     | Nightly update download is sufficient instead of real-time synchronization; exact systems, directions, and freshness remain open. |
| NFR-009     | Initial department size is approximately 500 people; authoritative membership and exact scope need confirmation.                  |

## User Stories

### US-001: Retrieve department membership

**As a** department/data owner, **I want** the system to retrieve the agreed department membership from ServiceNow, **so that** departmental views use an authoritative population.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                     | Type       | Classification |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-001.1 | Given an approved ServiceNow source, department identifier, field mapping, and sample membership, when the agreed exchange runs, then retrieved membership matches the agreed source records. | Functional | @smoke         |
| AC-001.2 | Schedule, freshness, and behavior on unavailable or inconsistent source data are verified against decisions made by the system owners; none are assumed.                                      | Functional | —              |

### US-002: Retrieve organizational and project approver data

**As a** project/data owner, **I want** the system to retrieve approved organizational structure, project approver, and project membership data, **so that** requests and approver views can be scoped correctly.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                               | Type       | Classification |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-002.1 | Given an approved directory source and attribute mapping, then an agreed test organization and project resolve to the expected organization/approver data.              | Functional | @smoke         |
| AC-002.2 | Project membership interpretation (membership, reporting relationship, or both) and behavior for missing or multiple mappings are explicitly approved and demonstrated. | Functional | —              |

### US-003: Export fully approved vacations

**As an** integration owner, **I want** the agreed approved vacation records sent to ServiceNow, **so that** the destination receives only records meeting the required approval policy.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                   | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-003.1 | Given an agreed final-approval rule and interface, when an eligible vacation is exported, then the destination receives the agreed record and its mapped fields.                            | Functional | @smoke         |
| AC-003.2 | A request missing any stakeholder-defined required approval is excluded from the export; acknowledgements, duplicates, failure handling, and reconciliation follow approved contract rules. | Functional | —              |

### US-004: Exchange updates on the agreed cadence

**As an** integration owner, **I want** source updates exchanged on an agreed schedule, **so that** the application uses sufficiently current organizational data without requiring real-time synchronization.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                          | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | -------------- |
| AC-004.1 | Given identified source systems, datasets, direction, and schedule, then a scheduled exchange updates the agreed dataset and can be reconciled against its source. | Functional | @smoke         |
| AC-004.2 | The possible “my scaturing” system is excluded from acceptance until its name, owner, and required preloading/validation interaction are confirmed (INT-010).      | Functional | —              |

## Dependencies

- TC-003 establishes integration with existing systems; TC-004 names Active Directory organizational information; neither supplies a full interface contract.
- F-002 depends on INT-003/INT-004 for approver and project scope; F-003 depends on INT-001 to INT-004 for population and request counts.
- INT-005 and INT-006 depend on F-001 request records and F-002's stakeholder-defined required approvers/final approval.
- F-004 depends on INT-007/INT-008 for message channels, which are cross-referenced but not specified as data exchanges in this feature.
- TC-002 limits the initial application to one department; exact department and “exclusive use” meaning are open.
- No additional external dependency is stated; ServiceNow and Active Directory are explicit source/destination systems.

## Open Questions

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

## Test-Project Acceptance Criteria

- **US-001/US-002:** Accept a complete synthetic organization snapshot only after validating unique IDs, references, direct membership, and exactly-one approver assignments; publish atomically and retain the last valid snapshot on error.
- **US-003:** Queue only final Approved requests with both F-002 decisions. Use `requestId:requestVersion` idempotency, retry three times, then mark `NeedsReconciliation`.
- **US-004:** Inbound snapshot runs daily at 02:00 and export evaluation at 03:00 Europe/Madrid. No external provider is called; “my scaturing” is excluded.
- Traced scenarios: [integration simulator test profile](tests/integration-simulator-test-profile.feature); model and contracts: [data model](requirements/data-model.md), [simulator OpenAPI](contracts/openapi.yaml), [simulator rules](contracts/simulator.yaml).

- Which ServiceNow and Active Directory products/interfaces, owners, environments, fields, identifiers, and mapping rules apply (INT-001 to INT-004)?
- Is Active Directory the source of truth for hierarchy and approvers, and what is the approved organizational hierarchy (INT-002, TC-005)?
- Does INT-004 mean direct reports, project membership, or both? How is project membership represented?
- Which approvers are required before export and what constitutes final approval (INT-005 to INT-006)?
- What does nightly update download include, from which systems, in which direction, and at what time/freshness target (INT-009, NFR-007)?
- What are the interface payload, acknowledgement, duplicate, retry, failure, reconciliation, and audit expectations?
- Which department is initially in scope, and how does the approximately 500-person context relate to that population (TC-002, NFR-009)?
- Resolve single-level versus multi-level organization and selectable-level requirements (TC-005; FR-015 to FR-017).
- Confirm whether “my scaturing” is a real system name and whether its possible integration is in scope (INT-010).
- Which privacy, security, retention, and compliance obligations apply (SEC-001 to SEC-003)?

## Initial Acceptance Criteria

The criteria above are conditional on approved source records, mappings, interface contracts, and final-approval rules. ServiceNow/Active Directory are named by baseline requirements, but no unapproved architecture, cloud choice, schedule, or data contract is imposed. Formal source approval remains outstanding.
