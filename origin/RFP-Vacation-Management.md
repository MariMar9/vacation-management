# RFP / Discovery Analysis: Vacation Management

> **BOLT Framework Stage:** INCEPTION - Discovery & Analysis

**Document ID:** Not assigned  
**Project:** Vacation Management  
**Analyst:** Not specified in source material  
**Date:** 2026-10-07  
**Status:** Draft - source requirements require clarification

---

## 1. Executive Summary

### Overview

The source material describes a vacation-request and approval application for one department. It needs to support project-level and department-level review of requests and overlapping absences, retrieve organizational information from existing systems, and send approved vacation data to ServiceNow. Usage is expected to be seasonal, and real-time synchronization is not required.

### Key Findings

1. The discovery documents establish the business purpose, principal approval roles, candidate source systems, notifications, and an example over-requesting threshold. They do not settle a number of workflow and integration details.
2. The written requirements contain an unresolved conflict about organizational hierarchy depth: several requirements refer to multiple selectable levels, while another states that there is only one level.
3. The functional document includes an architecture proposal (Vue, Azure, and a modular monolith). It is explicitly presented as a proposal, not as an approved technical decision.

### Recommendation

No Go/No-Go or solution recommendation is recorded in the source material. Resolve the open questions in Section 8 before treating the requirements as implementation-ready.

---

## 2. Source Analysis

### Document Inventory

| Source ID | Document                                                                                 | Type                                                                                 | Relevance                                                                                     |
| --------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| S1        | [Documento Funcional de Requisitos.html](./Documento%20Funcional%20de%20Requisitos.html) | Functional discovery requirements, constraints, and unapproved architecture proposal | Primary source for requirement IDs RF-001 to RF-052, RNF-001 to RNF-010, and RT-001 to RT-005 |
| S2        | [RecordedTranscription.txt](./RecordedTranscription.txt)                                 | Discovery session transcript                                                         | Primary source for business context, clarifications, examples, and unresolved statements      |
| S3        | [rfp-analysis-template.md](../.boltf/docs/templates/rfp-analysis-template.md)            | Approved RFP/legacy analysis template                                                | Structure used for this report                                                                |

The `origin/rfp/`, `origin/business-notes/`, `origin/constraints/`, `origin/discovery/`, `origin/integrations/`, and `origin/reference-images/` folders contained no files at review time. No additional source was available from those locations.

### Traceability Convention

- `S1 / RF-nnn`, `S1 / RNF-nnn`, and `S1 / RT-nnn` refer to the identifiers in the functional requirements document.
- `S2 / transcript` refers to the client statements in the recorded discovery session. It is used alongside S1 where it confirms, narrows, or conflicts with a written requirement.
- Priority is not assigned because the sources do not provide a priority scheme or approved priorities.

---

## 3. Requirements Extraction

### Confirmed Business Needs

These are business needs stated in discovery. “Confirmed” here means present in the source record; it does not imply that unresolved details have been approved.

| ID     | Business need                                                                                                                       | Traceability                                    |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| BN-001 | Provide an application for requesting and approving vacation periods for a department.                                              | S1 / RF-008, RF-052; S2 / transcript            |
| BN-002 | Support oversight of vacation demand at project and department level.                                                               | S1 / RF-049 to RF-051; S2 / transcript          |
| BN-003 | Make periods with concentrated vacation requests visible to approvers. A July week with requests above 70% is given as an example.  | S1 / RF-009, RNF-002; S2 / transcript           |
| BN-004 | Serve one department in the initial scope; other departments may be considered later, but are not part of the stated initial scope. | S1 / RT-005; S2 / transcript                    |
| BN-005 | Support seasonal demand while avoiding unnecessary operating cost during low-use periods.                                           | S1 / RNF-007, RNF-008, RNF-010; S2 / transcript |

### Functional Requirements

| ID     | Functional requirement                                                                                                                                                                                                                                                 | Priority     | Traceability                                                         |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | -------------------------------------------------------------------- |
| FR-001 | Return the number of people in a selected organizational scope for a specified period. The population is described as department-structured, but the applicable levels and counting rules are unresolved.                                                              | Not assigned | S1 / RF-001, RF-004, RF-041, RF-042; S2 / transcript                 |
| FR-002 | Access organizational information and allow a user to select an organizational level of interest. The source conflicts on whether the hierarchy has one level or several.                                                                                              | Not assigned | S1 / RF-002, RF-003, RF-040, RF-043; S2 / transcript                 |
| FR-003 | Support configuring or viewing periods in days or weeks. The exact calendar, date boundaries, and configuration owner are unspecified.                                                                                                                                 | Not assigned | S1 / RF-005, RF-044; S2 / transcript                                 |
| FR-004 | Allow configuration or management of how many people may be on vacation at the same time during a period. Who configures this and how it applies across projects/departments are unspecified.                                                                          | Not assigned | S1 / RF-007; S2 / transcript                                         |
| FR-005 | Allow project approvers to view and act on vacation requests, including approval and rejection. The meaning of “valorar” and the separate “close” action are unclear.                                                                                                  | Not assigned | S1 / RF-016, RF-045 to RF-048; S2 / transcript                       |
| FR-006 | Support approval at both project and department level. The sequence, whether both approvals are always required, and the relationship between the two decisions are unspecified.                                                                                       | Not assigned | S1 / RF-023, RF-030, RF-033, RF-047, RF-050, RF-051; S2 / transcript |
| FR-007 | Allow approval to be delegated to another person in the same project and allow delegation of a vacation approver. The permitted scope and conditions are unspecified.                                                                                                  | Not assigned | S1 / RF-031, RF-035; S2 / transcript                                 |
| FR-008 | Allow a user to cancel their vacation request and provide a cancellation process. Whether approved requests may be cancelled and what the process entails are unspecified.                                                                                             | Not assigned | S1 / RF-015, RF-019; S2 / transcript                                 |
| FR-009 | Allow users to consult when they have taken vacation and which requests are approved or not approved. The historical scope and visibility rules are unspecified.                                                                                                       | Not assigned | S1 / RF-011 to RF-013; S2 / transcript                               |
| FR-010 | Allow department approvers to see how many people are on vacation across the department for a period.                                                                                                                                                                  | Not assigned | S1 / RF-049; S2 / transcript                                         |
| FR-011 | Notify users when requests are approved or cancelled.                                                                                                                                                                                                                  | Not assigned | S1 / RF-017, RF-018; S2 / transcript                                 |
| FR-012 | Notify the department approver when a request remains unapproved for a defined time. The time limit and notification behavior are unspecified.                                                                                                                         | Not assigned | S1 / RF-032; S2 / transcript                                         |
| FR-013 | Send the list of approved vacations to ServiceNow, including only requests approved by the required approver(s).                                                                                                                                                       | Not assigned | S1 / RF-021 to RF-023; S2 / transcript                               |
| FR-014 | Obtain department membership information from ServiceNow and organizational/project responsibility information from Active Directory. Exact attributes and ownership relationships are unspecified.                                                                    | Not assigned | S1 / RF-036 to RF-039; S2 / transcript                               |
| FR-015 | Provide an application link that users can use to access and try the application in an initial stage. Access conditions are unspecified.                                                                                                                               | Not assigned | S1 / RF-024, RF-026; S2 / transcript                                 |
| FR-016 | Send information or alarms by email; Teams notifications are optional. The source gives an example Teams message containing the requester's name, requested period, and a link to the application. The complete notification catalogue and recipients are unspecified. | Not assigned | S1 / RF-027 to RF-029; S2 / transcript                               |
| FR-017 | Consider adaptive cards in a later stage. This is a future-stage statement; its scope and timing are unspecified.                                                                                                                                                      | Not assigned | S1 / RF-025; S2 / transcript                                         |
| FR-018 | Do not propose alternative vacation periods as part of the process. The exact scope of this restriction is unspecified.                                                                                                                                                | Not assigned | S1 / RF-014; S2 / transcript                                         |

### Non-Functional Requirements

| ID      | Category               | Requirement as stated                                                                                                                               | Target / qualification                                                                                                                                                               | Traceability                             |
| ------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------- |
| NFR-001 | Capacity               | Support 500 users concurrently.                                                                                                                     | Explicitly stated in S1; S2 also describes a department of approximately 500 people but does not confirm concurrency. Validate whether 500 means concurrent, total, or active users. | S1 / RNF-001, RNF-009; S2 / transcript   |
| NFR-002 | Usability / visibility | Calendars and each user's requests should be easy for users and responsible approvers to view; periods with excess requests should be very visible. | Qualitative only; no usability or visual acceptance criteria are defined.                                                                                                            | S1 / RNF-002 to RNF-005; S2 / transcript |
| NFR-003 | Synchronization        | Real-time synchronization is not required; a nightly download of updates is sufficient.                                                             | The exact schedule, data set, and acceptable delay are not defined.                                                                                                                  | S1 / RNF-006, RF-020; S2 / transcript    |
| NFR-004 | Scalability            | The system should scale with seasonal demand, with higher use before summer, Easter, and Christmas and low or occasional use outside those periods. | No peak profile, response-time objective, or scaling target is stated.                                                                                                               | S1 / RNF-007, RNF-010; S2 / transcript   |
| NFR-005 | Cost                   | Avoid unnecessary operating costs during low-use periods.                                                                                           | No budget, cost ceiling, or measurable cost target is stated.                                                                                                                        | S1 / RNF-008; S2 / transcript            |

### Constraints

| ID    | Type            | Constraint                                                                                                                                           | Impact / unresolved detail                                                                                                                     | Traceability                                         |
| ----- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| C-001 | Scope           | The initial application is for one department only.                                                                                                  | Department boundary and whether the application must technically prevent access by other departments are unspecified.                          | S1 / RT-005; S2 / transcript                         |
| C-002 | Hosting         | The application is to use existing cloud infrastructure; Azure and Amazon are named as examples/options, and the transcript says Azure is available. | Azure is not stated as an approved exclusive platform. No hosting service or deployment model is selected.                                     | S1 / RT-003; S2 / transcript                         |
| C-003 | Integration     | The application must integrate with existing systems/infrastructure and have access to Active Directory organizational information.                  | Specific protocols, permissions, owners, and data contracts are not supplied.                                                                  | S1 / RT-001, RT-004; S2 / transcript                 |
| C-004 | Data structure  | The population is described as having one organizational level.                                                                                      | This conflicts with requirements to access a multi-level hierarchy and select a level. Do not implement either interpretation until clarified. | S1 / RF-002, RF-003, RF-043, RT-002; S2 / transcript |
| C-005 | Synchronization | Real-time synchronization is not required; updates may be downloaded nightly.                                                                        | The direction and exact scope of each nightly exchange are not fully defined.                                                                  | S1 / RNF-006, RF-020; S2 / transcript                |

### Integrations

| System / channel                         | Intended interaction                                                                                             | Status and traceability                                                                                                                                                  |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ServiceNow                               | Read department membership information and receive the list of approved vacations.                               | Stated in discovery. Data format, interface, cadence, acknowledgement/error handling, and exact department data are open. S1 / RF-021 to RF-023, RF-036; S2 / transcript |
| Active Directory                         | Read organizational/project responsibility information, including project leads and people associated with them. | Stated in discovery. Exact attributes, hierarchy, and mapping are open. S1 / RF-037 to RF-039, RT-001; S2 / transcript                                                   |
| Email                                    | Send user notifications and alarms. Email is the initial notification channel requested in the discussion.       | Channel stated; events, recipients, content, delivery expectations, and audit/retention requirements are open. S1 / RF-027, RF-029, RF-032; S2 / transcript              |
| Microsoft Teams                          | Optional notification channel. A chat message with request context and an application link is discussed.         | Optional, not a mandatory baseline. S1 / RF-028, RF-029; S2 / transcript                                                                                                 |
| “my scaturing” (transcription uncertain) | Mentioned as a possible source for preloading vacation information or validating something.                      | Unconfirmed candidate only; system name and integration need must be verified. S2 / transcript                                                                           |

### Assumptions

No additional assumptions have been promoted to requirements or technical decisions. The following source statements should be treated as working context only until validated:

- The department population is described as approximately 500 people, but it is not consistently distinguished from the 500-concurrent-user requirement. (S1 / RNF-001, RNF-009; S2 / transcript)
- “At least one approver in departments of approximately 50 people” appears as an imprecise example, not a confirmed threshold or staffing rule. (S1 / RF-034; S2 / transcript)
- The reference to a single hierarchy level is explicitly uncertain in the source and conflicts with other hierarchy statements. (S1 / RF-043, RT-002; S2 / transcript)
- The architecture proposal in S1 (Vue frontend, Azure deployment, modular monolith, layered application/API/integration design) is not treated as approved. It requires an explicit decision before becoming a technical constraint. (S1 / Sections 5.1-5.3)

### Open Questions

1. **Users and access:** Who may submit, view, approve, reject, or cancel requests? How is identity established, and what are the access boundaries for users, project approvers, and department approvers?
2. **Request lifecycle:** Is request creation in scope? Can users edit a request? Can a user cancel a request after approval? What states and transitions are required, and what does “close” mean?
3. **Approval policy:** Must every request receive both project and department approval? In what order? What happens when approvers disagree? Who is the department approver, and how many project approvers may exist?
4. **Delegation:** Who may delegate, to whom, for what period, and with what audit trail? Does delegation apply to project approvals, department approvals, or both?
5. **Timeout and alerts:** What is the approval time limit? Who receives reminders/escalations, through which channel, and how often?
6. **Capacity and over-requesting:** What is the denominator for the 70% example? Does the threshold apply to a project, department, or selected organizational unit? Is it a warning, a blocking rule, or visualization only? Who configures concurrent-vacation limits?
7. **Periods and calendars:** Which dates/calendars define a request period? Are weeks and days display granularities, request units, or both? Which year/context does the July example refer to?
8. **Organization model:** Is the hierarchy one level or multi-level? What are the levels, and which system is authoritative for each relationship? Resolve the conflict between S1 / RF-002, RF-003, RF-040 and S1 / RF-043, RT-002.
9. **ServiceNow:** Which ServiceNow product/API and records are involved? What fields identify department membership and approved vacations? Is the exchange inbound, outbound, or both, and what does “approved by each responsible person” mean operationally?
10. **Active Directory:** Which directory and attributes provide project ownership and membership? How are changes and missing/inconsistent records handled?
11. **Nightly processing:** What exactly is downloaded, from which systems, and when? Should the approved-vacation export be part of the same nightly job? What retry, reconciliation, and failure reporting are required?
12. **Notifications:** Which events require email? Who receives each message? Is Teams optional per user, per event, or for the whole system? Are rejection notifications required? What retention/audit expectations apply to messages?
13. **Capacity and performance:** Does the system need 500 concurrent users or 500 department members? What are peak concurrent load, response-time targets, availability expectations, and load-test conditions?
14. **Cost and scaling:** What is the operating budget or acceptable cost target? Which seasonal periods and demand profile should drive scaling?
15. **Cloud and architecture:** Is Azure selected, or is AWS also acceptable? Is the S1 Vue/Azure/modular-monolith proposal approved, rejected, or still under evaluation?
16. **Future scope:** What is the confirmed purpose of adaptive cards, and is the possible “my scaturing” integration in scope? Verify the transcribed system name.
17. **Usability and accessibility:** What observable acceptance criteria define “easy to see,” “easy to use,” and “very visual”? Are there required accessibility standards or supported devices/browsers?

---

## 4. Technical Assessment

### Source Proposals - Not Approved Decisions

The functional requirements document proposes a layered web application with a Vue frontend, business API, integration module, persistence, scheduled processing, role-based access, Azure hosting, and a modular monolith. These are source-document recommendations only; neither the transcript nor an approval record confirms them as binding decisions. They are therefore excluded from the constraints and integration requirements above except where a separate business need independently supports the capability.

No technology stack, database, identity provider, hosting service, interface protocol, security standard, availability target, or recovery target is confirmed in the reviewed source material.

---

## 5. Risk Analysis

| Risk                                                                                                  | Evidence                                                 | Follow-up needed                                                             |
| ----------------------------------------------------------------------------------------------------- | -------------------------------------------------------- | ---------------------------------------------------------------------------- |
| Conflicting organization model could produce incorrect scope counts and approvals.                    | S1 / RF-002, RF-003, RF-040, RF-043, RT-002              | Confirm authoritative hierarchy and level behavior.                          |
| Approval and delegation rules could result in requests being exported before all necessary approvals. | S1 / RF-023, RF-030 to RF-035, RF-050, RF-051            | Define states, approver sequence, delegation, and export eligibility.        |
| Unspecified integration contracts could prevent reliable synchronization.                             | S1 / RF-020 to RF-023, RF-036 to RF-039; S2 / transcript | Identify system owners, fields, mechanisms, cadence, and failure handling.   |
| Capacity and seasonal objectives are not sufficiently measurable for validation.                      | S1 / RNF-001, RNF-007 to RNF-010; S2 / transcript        | Confirm concurrency, peak profile, response, availability, and cost targets. |
| Subjective visual/usability needs cannot be accepted consistently.                                    | S1 / RNF-002 to RNF-005; S2 / transcript                 | Define observable UI and accessibility acceptance criteria.                  |

---

## 6. Effort Estimation

Not estimated. The sources do not provide validated scope, integration contracts, acceptance criteria, delivery assumptions, staffing, or cost inputs sufficient for a defensible estimate.

---

## 7. Proposed Solution

No solution is approved by this report. The source architecture proposal is recorded in Section 4 for traceability and requires an explicit stakeholder decision. Detailed architecture, implementation phases, and technology recommendations are deferred until the relevant open questions are answered.

---

## 8. Go/No-Go Recommendation and Next Steps

### Recommendation

Not assessed. The reviewed documents do not include a formal Go/No-Go decision or scorecard inputs.

### Next Steps

1. Resolve the open questions for hierarchy, approval lifecycle, delegation, capacity rules, and integrations with the relevant business and system owners.
2. Confirm measurable non-functional acceptance criteria, especially concurrency, seasonal peaks, availability, usability, accessibility, and cost.
3. Record explicit decisions for cloud platform and architecture separately from the unapproved proposal in S1.
4. Update this draft with approved decisions and acceptance criteria before using it as an implementation baseline.

---

## 9. Appendices

### A. Glossary

| Term                  | Meaning in this report                                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Project approver      | Person responsible for reviewing vacation requests for a project; exact authority and source data remain to be confirmed. |
| Department approver   | Person responsible for department-level approval or oversight; exact authority and assignment remain to be confirmed.     |
| Over-requested period | Source term for a period with concentrated vacation requests; the calculation and action threshold require clarification. |
| ServiceNow            | External system identified as a source of department membership and a destination for approved vacation data.             |
| Active Directory      | External directory identified as a source of organizational/project responsibility information.                           |

### B. References

| Document                                          | Location                                                                                              |
| ------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Functional requirements and architecture proposal | [origin/Documento Funcional de Requisitos.html](./Documento%20Funcional%20de%20Requisitos.html)       |
| Recorded discovery session                        | [origin/RecordedTranscription.txt](./RecordedTranscription.txt)                                       |
| Approved RFP analysis template                    | [`.boltf/docs/templates/rfp-analysis-template.md`](../.boltf/docs/templates/rfp-analysis-template.md) |

---

_Prepared from the source documents listed in Section 2. No unverified technical choices or unstated thresholds have been added._
