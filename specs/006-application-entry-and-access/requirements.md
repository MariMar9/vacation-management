# Feature: Application Entry and Access

## Metadata

| Property             | Value                                                                                                          |
| -------------------- | -------------------------------------------------------------------------------------------------------------- |
| Feature ID           | F-006                                                                                                          |
| Source status        | Draft; neither the RFP nor baseline has formal approval evidence                                               |
| Specification status | Draft for real-world use; synthetic test-project profile approved                                              |
| Issue                | Not created; tracker is unconfigured and issue creation is outside this catalog request                        |
| Scenario             | backend+frontend; .NET 8 and Angular 20 test-project stack                                                     |
| Test-project profile | Approved for synthetic-data test scope only; see [decision register](../test-project-feature-decisions.md)     |
| Sources              | [Requirements baseline](../../origin/Requirements-Baseline.md); [RFP](../../origin/RFP-Vacation-Management.md) |

## Goal and Business Value

Provide a clear link-based entry point for the intended department users and establish the access requirements needed to use vacation workflows. This supports application discoverability and a controlled initial rollout. Authentication is only a Draft architecture proposal in the baseline; identity method, eligible population, and approved authorization rules remain unresolved.

## Actors

| Actor                      | Goal                                                                             |
| -------------------------- | -------------------------------------------------------------------------------- |
| Employee / requester       | Open the application through the provided link and access their own capabilities |
| Project approver           | Enter and access project-scoped review capabilities when authorized              |
| Department approver        | Enter and access department-scoped capabilities when authorized                  |
| Application/security owner | Define the approved identity, user population, and access matrix                 |
| System                     | Admit or deny access according to approved policy                                |

## In Scope / Out of Scope

**In scope**

- Navigate to the application through a link.
- Define and demonstrate the initially requested link-based trial once audience and meaning of “try” are clarified.
- Resolve authentication, role, department-boundary, and security/compliance requirements before access behavior is accepted.

**Out of scope**

- Selecting an identity provider or authentication protocol, or treating the proposed role model as approved.
- Implementing identity, hosting, routing, or security controls.
- Approval behavior (F-002), business notifications (F-004), and system integrations (F-005), except for their access dependencies.

## Functional Requirements Covered

| Baseline ID | Coverage                                                         | Baseline status                                            |
| ----------- | ---------------------------------------------------------------- | ---------------------------------------------------------- |
| FR-025      | Users navigate to the application through a link                 | Confirmed; distribution, audience, and authentication open |
| FR-026      | Users can try the application through a link in an initial stage | Clarification needed; “try” and trial scope undefined      |

Related constraints and security requirements: TC-002 (single-department initial use, confirmed but boundary details open), SEC-001 (authentication proposal, Draft), SEC-002 (role-based authorization proposal, Draft), SEC-003 (security/privacy/compliance obligations not established). FR-027 adaptive cards is covered by F-004 and is not an entry requirement.

## Non-Functional Requirements Applicable

| Baseline ID | Applicability                                                                                              |
| ----------- | ---------------------------------------------------------------------------------------------------------- |
| NFR-001     | 500 users at a time is stated; concurrency and response/error objectives need clarification.               |
| NFR-008     | Application readability is requested; supported browsers/devices and legibility criteria are open.         |
| NFR-009     | Approximately 500 people is the initial department-population context; not equivalent to concurrent usage. |

Security requirements SEC-001 to SEC-003 are tracked above as draft/unresolved requirements rather than accepted controls.

## User Stories

### US-001: Open the application from a link

**As an** intended department user, **I want** to open the application through a provided link, **so that** I can reach the vacation-management experience.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                  | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | -------------- |
| AC-001.1 | Given a stakeholder-approved link and an eligible user, when the user follows the link, then the application entry point is reached and access follows the approved authentication policy. | Functional | @smoke         |
| AC-001.2 | Link distribution, unauthenticated behavior, and the applicable user population are verified against the approved access requirements; no access method is presumed.                       | Functional | —              |

### US-002: Participate in the initial link-based trial

**As an** intended user, **I want** to try the application through a link during an initial stage, **so that** stakeholders can evaluate the agreed trial experience.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                                      | Type       | Classification |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-002.1 | Given stakeholders define whether “try” means pilot, test environment, or another trial and approve its audience, then an eligible participant can access that defined trial through the link. | Functional | @smoke         |
| AC-002.2 | Trial environment, data, duration, and permitted actions are not treated as accepted until explicitly defined; no production/test distinction is assumed.                                      | Functional | —              |

### US-003: Access only authorized capabilities

**As an** application/security owner, **I want** approved users and roles to have explicitly defined access, **so that** the application exposes only stakeholder-authorized capabilities.

#### Initial Acceptance Criteria

| ID       | Criterion                                                                                                                                                                             | Type       | Classification |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------- |
| AC-003.1 | Given an approved identity and role/action matrix, then tests demonstrate permitted and denied actions for the agreed requester, project approver, and department approver roles.     | Functional | @smoke         |
| AC-003.2 | Department isolation, cross-project visibility, delegation, and any security/privacy/audit controls are accepted only against stakeholder-approved requirements (SEC-002 to SEC-003). | Functional | —              |

## Dependencies

- SEC-001 to SEC-003 require security-owner decisions before access controls can be accepted; these are not approved identity or compliance decisions.
- TC-002 limits initial use to one department; exact department, meaning of exclusive use, and user population need confirmation.
- F-001, F-002, and F-003 require user identity and appropriate scoped access for request, approval, and demand capabilities.
- F-005 provides organizational and project membership data that may be used in access scoping; the source and mapping are unresolved.
- No additional external dependency is stated.

## Open Questions

**Test-project disposition:** The questions below are resolved for the synthetic test profile by [the decision register](../test-project-feature-decisions.md). They remain open for any real-world or production use.

## Test-Project Acceptance Criteria

- **US-001/US-002:** Entry is restricted to pre-provisioned synthetic test identities; no public signup or production trial. Hosted auth direction is Entra OIDC; automated tests use fake identities.
- **US-003:** Enforce Requester, ProjectApprover, and DepartmentApprover actions server-side. Multiple roles are permitted; self-approval and cross-scope access are denied. Missing identity returns 401; authenticated unauthorized action returns 403 (own-resource concealment may return 404).
- Traced scenarios: [access test profile](tests/access-test-profile.feature); model and contract: [data model](requirements/data-model.md), [OpenAPI](contracts/openapi.yaml).

- Who may use the link, how is it distributed, and what does “try” mean: pilot, test environment, or production use (FR-025 to FR-026)?
- Which identity source and authentication method are required, and are all users in the initial department eligible (SEC-001)?
- What is the approved role/action matrix, assignment process, and behavior for users with multiple roles (SEC-002)?
- What department boundary is enforced, and what does “exclusive use” mean technically and operationally (TC-002)?
- What are the approved privacy, data classification, audit, retention, encryption, and compliance obligations (SEC-003)?
- What browsers/devices and readable/accessible presentation criteria are expected (NFR-008)?
- Confirm whether the stated approximately 500-person department population is current and distinct from 500 concurrent users (NFR-009, NFR-001).

## Initial Acceptance Criteria

The criteria above are conditional on approved entry, identity, user-population, and authorization decisions. Authentication and RBAC are source architecture proposals marked Draft, not approved controls. No identity provider, protocol, cloud, or architecture is selected. Formal source approval remains outstanding.
