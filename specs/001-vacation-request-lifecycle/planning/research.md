# F-001 Technical Context and Decision Register

**Status:** No external technology research is approved or required to fill business-policy gaps. Items below are decision blockers for the F-001 plan.

## Confirmed Planning Context

- F-001 is marked Draft; source baseline/RFP do not have formal approval evidence.
- Scenario is cross-functional (`backend+frontend` functional boundary); runtime/framework is undecided.
- The current constitution is an unratified template with no active scopes selected; the digest file is absent.
- `src/backend/` and `src/frontend/` are empty. No backend project file, production frontend package, F-001 model, OpenAPI contract, or F-001 `.feature` file was found.
- F-001 mockups contain a requester `my-requests` collection only. Submission fields and cancellation UI are deliberately omitted.
- The architecture document is explicitly a proposal and cannot supply an approved stack or interface contract.

## Blocking Decisions (Stakeholder/Architecture Decisions, Not Desk Research)

| Item        | Required decision/input                                                              | Blocks                                                   | Owner to appoint                        |
| ----------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------- | --------------------------------------- |
| F001-DEC-01 | Required request fields, date semantics, validation and duplicate-submit behavior.   | Data model, API contract, submission Bolt.               | Product Owner / Business Process Owner  |
| F001-DEC-02 | Request states, transitions, cancellation eligibility/effects and failure behavior.  | Model, Gherkin, submit/cancel Bolts.                     | Workflow Owner                          |
| F001-DEC-03 | Meaning of “taken”, status categories, history range and requester-visible outcomes. | Query contract, history Bolt, UI acceptance.             | Product Owner                           |
| F001-DEC-04 | Meaning/scope of “alternative periods” in FR-024.                                    | US-004 acceptance and cancellation/rejection boundary.   | Business Sponsor                        |
| F001-DEC-05 | Identity, own-request authorization, retention, privacy and audit rules.             | Security model and production readiness.                 | Security/Privacy Authority              |
| F001-DEC-06 | Stack, active constitution scopes, persistence, API and test frameworks.             | File paths, implementation components, CI/test commands. | Architecture Authority / Technical Lead |
| F001-DEC-07 | F-002 approval events and F-004 cancellation/approval notification contracts.        | Cross-feature handoff and Bolt 5.                        | F-002/F-004 Owners                      |

## Plan Use

Do not generate OpenAPI schemas, persistence fields, state enums, executable tests, or code until the corresponding decisions are recorded and approved. When the architecture authority selects a stack, load its backend/frontend skills and replace candidate component paths in `plan.md` with concrete repository paths.

## Test-Project Addendum (2026-10-09)

The earlier inventory above is preserved as a dated historical snapshot. T001/T002 and the feature decisions were subsequently authorized for the synthetic-data test project only. Current artifacts are in [test-project decisions](../../test-project-feature-decisions.md), [F-001 data model](../requirements/data-model.md), [F-001 OpenAPI](../contracts/openapi.yaml), and [F-001 Gherkin](../tests/request-lifecycle-test-profile.feature). The global stack/scopes are in the [test-project constitution](../../../.boltf/memory/constitution.digest.md). These decisions do not approve source RFP requirements for real-world or production use.
