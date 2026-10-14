# Implementation Plan: F-001 Vacation Request Lifecycle

**Plan status:** Approved for the synthetic-data test project; readiness checks and application/test scaffolding are complete. Feature-code quality gates remain pending until implementation.
**Feature source status:** Draft; no formal RFP/baseline approval evidence.
**Test-profile scenario:** `backend+frontend`; .NET 8 ASP.NET Core Controllers, Angular 20, Azure SQL/EF Core, synthetic data only.
**Approval boundary:** T001/T002 and F-001 test decisions are approved for this workspace only; this does not approve production behavior or source RFP requirements.

## Readiness and Source Alignment

F-001 defines four stories: submit (US-001), cancel own request (US-002), view history/outcomes (US-003), and cancellation/alternative-period behavior (US-004). The synthetic test profile resolves these rules in [the decision register](../../test-project-feature-decisions.md). The source requirements remain Draft for real-world use; their original conditional criteria are preserved as provenance.

| Input requested for planning | Current artifact/status                                                                                               | Planning treatment                                                                                              |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Test-profile data model      | [F-001 model](../requirements/data-model.md) defines fields, states, validation, overlap and ownership.               | Approved for synthetic test scope; model/schema consistency review passed.                                      |
| Test-profile API contract    | [F-001 OpenAPI](../contracts/openapi.yaml) is derived from the data model.                                            | Redocly validation and model/schema traceability passed.                                                        |
| Test-profile Gherkin         | [F-001 scenarios](../tests/request-lifecycle-test-profile.feature) cover US-001–US-004 and test-profile rules.        | Gherkin parser and AC traceability passed (8/8).                                                                |
| Test architecture            | [ADR-002](../../../docs/docs/adr/ADR-002-test-project-architecture-and-controls.md) records the workspace-only stack. | The general solution architecture remains a proposal for any production system.                                 |
| UX reference                 | [F-001 mockup index](../mockups/README.md) includes submit/cancel states and earlier requester-list references.       | Submit/cancel mockups reflect test-profile decisions; refresh requester-list labels before implementing US-003. |
| Constitution                 | `.boltf/memory/constitution.md`, its digest, and ADR-002 record test-workspace decisions.                             | Test-project stack and controls are approved for this workspace only; production approval is not claimed.       |

**Scope gate:** The test profile may implement only the choices in the linked decision register. Do not treat these artifacts as real-world leave policy or production authorization. Bolt 1 readiness is complete; runtime coverage and mutation gates apply when feature logic is implemented.

## Constitution Check

| Principle / constraint    | Status               | Notes                                                                                                      |
| ------------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------- |
| Test-project constitution | Pass                 | T001/T002 choices are recorded; no production ratification is asserted.                                    |
| Backend/frontend stack    | Pass                 | .NET 8 Controllers and Angular 20 for the test workspace.                                                  |
| Persistence/API           | Pass                 | Azure SQL/EF Core and REST/OpenAPI.                                                                        |
| Quality thresholds        | Pass as test policy  | Local and CI commands are configured; feature coverage/mutation remain pending until feature logic exists. |
| Security/access           | Pass as test profile | Synthetic identities, scoped server-side checks, and no real data.                                         |
| Production operations     | Out of scope         | No cloud provisioning or production deployment is authorized.                                              |

## Technical Context

### Stack Selection

- Frontend: Angular 20 SPA; existing HTML mockups remain visual references.
- Backend/runtime: ASP.NET Core .NET 8 Controllers.
- Database/persistence: Azure SQL with EF Core as test-project target.
- API style/protocol: REST/OpenAPI; the F-001 contract is in `contracts/openapi.yaml`.
- Cloud/IaC: Azure test target only; provisioning and deployment are not authorized.
- Tests: .NET/xUnit and Angular projects exist; Angular unit and Playwright smoke tests run, and test-profile Gherkin is validated separately.

Do not add production provisioning or real external integrations. The test-project stack and technical architecture are approved by T001/T002; feature behavior remains bound to the test-profile decision register. Test scaffolds and CI/local gate routing exist; no feature logic Bolt has started.

### Feature Dependencies

- F-002 test-profile decisions define the outcome vocabulary and lifecycle handoff; consume its contract without adding approval behavior to F-001.
- F-004 defines a local event/outbox simulator for approval and cancellation; do not deliver email/Teams or call external providers.
- F-005 provides deterministic synthetic organization snapshots; F-001 uses fixture data and does not initiate scheduled external updates.
- F-006 defines local fake identities and server-side test scopes; Entra OIDC remains a hosted direction and is not needed for local implementation.

### Existing UX References

| F-001 flow               | Stories        | States                           | Candidate implementation component              | Gate/risk                                                                                                                                                                                                                                           |
| ------------------------ | -------------- | -------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `my-requests`            | US-003         | default, empty, loading, error   | Requester’s own request/outcome list            | Test-profile status/history rules are approved. References: [default](../mockups/my-requests-default.html), [empty](../mockups/my-requests-empty.html), [loading](../mockups/my-requests-loading.html), [error](../mockups/my-requests-error.html). |
| Request submission       | US-001         | default, loading, error, success | Request entry form and submit interaction       | Test-profile form mockups exist; implement against the authorized field/date rules.                                                                                                                                                                 |
| Own-request cancellation | US-002, US-004 | default, error, success          | Request action/confirmation and resulting state | Test-profile eligibility/effects and cancellation mockups exist.                                                                                                                                                                                    |

The loading mockup is a UI reference only. `GET /api/requests` supplies its data; frontend loading/error behavior is part of the UI Bolt.

## Data Model and API Contract

The test-profile [data model](../requirements/data-model.md), [OpenAPI contract](../contracts/openapi.yaml), and [Gherkin scenarios](../tests/request-lifecycle-test-profile.feature) are derived from the authorized decisions. They do not replace or rewrite the real-world source baseline.

## Bolt Breakdown

Complexity is relative. Durations are not estimated because team capacity has not been established. Each implementation Bolt should be sized to a reviewable 1–3 day micro-iteration; split further if a Bolt exceeds that limit. Branch names are recommendations only and are not created by this plan.

### Bolt 1: F-001 Lifecycle Baseline and Contract

- **Goal:** Establish the synthetic test-profile lifecycle model, contract, and AC-traceable Gherkin.
- **Dependencies:** T001/T002 test-project decisions; F-002 outcome and F-006 access contracts are defined in the shared decision register.
- **Artifacts:** `requirements/data-model.md`, `contracts/openapi.yaml`, `tests/request-lifecycle-test-profile.feature`, and traceability evidence.
- **Readiness checks:** Parse Gherkin; map every AC; verify every API schema field exists in the model; validate links and Markdown.
- **Runtime tests:** N/A for this documentation/readiness Bolt. The .NET/xUnit and Angular projects exist for implementation Bolts.
- **Status:** Complete for the test profile; Gherkin parsing, 8/8 AC mapping, OpenAPI lint, and model/schema readiness checks passed. Runtime coverage/mutation are N/A until feature code exists.
- **Branch:** No branch is required for this planning-only record. Implementation Bolts use ADR-002 sibling refs.

### Bolt 2: Requester Request and History Read View

- **Goal:** Deliver the requester’s own request/outcome list and history query against the approved status and date-range model.
- **Dependencies:** Bolt 1 approved model/contract/Gherkin; F-006 test access contract; architecture and frontend/backend stack; F-002 outcome semantics for approval labels.
- **Components/files affected:** Request query/read service and API, requester list/history UI, persistence query/index, and synthetic fixtures. Visual references: four `my-requests` HTML states linked above. Implement within the existing .NET and Angular projects.
- **Tests:** Query/service unit tests; API contract tests; requester-only authorization and cross-user denial tests; UI/component tests for default/empty/loading/error states; Gherkin/E2E for US-003 AC-003.1/AC-003.2; test history boundaries from approved rules.
- **Documentation:** Query/endpoint contract, status display mapping, history behavior, mockup-to-component traceability, support diagnostics.
- **Quality gates:** Approved statuses/range; own-data authorization passes; UI states represented; no unapproved status or historical data appears; apply the test-project accessibility/performance checks without making production claims.
- **Review/approval:** Product Owner accepts behavior; Technical Lead and QA approve technical/test evidence; Security Authority reviews access behavior.
- **Estimated complexity:** High.
- **Branch:** `bolt/vacation-request-lifecycle-bolt-2-request-history`.

### Bolt 3: Submit Vacation Request

- **Goal:** Allow an eligible employee to submit a valid request into the approved request lifecycle.
- **Dependencies:** Bolt 1 approved request fields, date rules, validation, initial state and API contract; Bolt 2 requester shell/read model; approved authentication/authorization; request UI design/mockups.
- **Components/files affected:** Angular request form; .NET command/application service, API endpoint, and persistence; validation and audit hooks specified by the test profile.
- **Tests:** Domain validation/date boundaries, overlap, idempotency, persistence, authorization, and contract tests. AC-001.2 is a source-provenance note; test-profile assertions use the approved fields in the decision register.
- **Documentation:** Approved field/help text mapping, validation/error catalogue, API usage and user/support guidance.
- **Quality gates:** No field/validation inferred from mockup; valid submission persists once and enters approved next state; invalid submissions have approved observable errors; audit and security controls pass.
- **Review/approval:** PO/business process owner; Technical Lead; QA; Security Authority for identity/data handling.
- **Estimated complexity:** High.
- **Branch:** `bolt/vacation-request-lifecycle-bolt-3-submit-request`.

### Bolt 4: Cancel Own Eligible Request

- **Goal:** Let a requester cancel only their own request when its approved state/policy allows cancellation.
- **Dependencies:** Bolt 1 approved cancellation state transitions, eligibility, confirmation, side effects and event contract; Bolt 2 request view; Bolt 3 request identity/ownership; F-004 notification contract if cancellation notifications are part of this release.
- **Components/files affected:** Request cancellation action/confirmation UI; cancellation command and lifecycle transition; API contract; persistence/audit; event handoff to F-004 only if approved. No notification delivery implementation is assumed in F-001.
- **Tests:** State-transition and eligibility unit tests; owner-vs-other-user authorization tests; API integration/concurrency tests; Gherkin for US-002 AC-002.1/AC-002.2 and US-004 AC-004.1; event contract tests if a cancellation event is approved.
- **Documentation:** Cancellation policy mapping, state transition table, error/denial cases, F-004 handoff contract, support steps.
- **Quality gates:** Approved eligible-state matrix; cannot cancel another user’s request; permitted/denied cases verified; side effects and notifications match approved contracts; no cancellation occurs if persistence fails.
- **Review/approval:** Business process owner/PO; Technical Lead; QA; Security Authority; F-004 owner for event behavior.
- **Estimated complexity:** High; cancellation eligibility and effects are decided for the test profile. Keep notification delivery outside this Bolt.
- **Branch:** `bolt/vacation-request-lifecycle-bolt-4-cancel-request`.

### Bolt 5: Acceptance, Regression, and Cross-Feature Handoff

- **Goal:** Verify F-001 end-to-end against approved ACs and ensure lifecycle handoffs to approval, notification, and identity features remain consistent.
- **Dependencies:** Bolts 1–4; required F-002/F-004/F-006 contracts and test doubles or integrated environments; approved performance/accessibility targets.
- **Components/files affected:** F-001 Gherkin feature suite; E2E/integration tests; mockup traceability; CI quality gates; release notes and operational documentation. Test paths depend on selected stack.
- **Tests:** Full F-001 regression; cross-feature request-to-approval and cancellation-event contract scenarios where integrations are ready; identity denial tests; data consistency and duplicate submission behavior only as approved; accessibility and performance tests against approved targets.
- **Documentation:** AC-to-test evidence, known limitations, handoff contracts, runbook/user documentation, release readiness summary.
- **Quality gates:** All approved test-profile F-001 AC pass; no critical defects; cross-feature contract tests pass or dependencies are explicitly deferred; apply the test-project lint, test, coverage, mutation, and smoke thresholds.
- **Review/approval:** QA Lead recommends; PO accepts feature; Technical Lead and Security Authority sign applicable gates.
- **Estimated complexity:** High; depends on adjacent feature readiness.
- **Branch:** `bolt/vacation-request-lifecycle-bolt-5-acceptance-handoff`.

## Risks and Mitigations

| Risk                                                                             | Probability | Impact   | Mitigation                                                                                                  |
| -------------------------------------------------------------------------------- | ----------- | -------- | ----------------------------------------------------------------------------------------------------------- |
| Feature coverage and mutation scores are not measured until feature code exists. | High        | High     | Run the configured per-Bolt test/coverage/Stryker gates after each feature implementation increment.        |
| Source F-001 spec remains Draft for real-world use.                              | High        | Critical | Keep test-profile scope explicit; require new approval before real data, users, or production behavior.     |
| Test-profile branch policy must be used consistently.                            | Medium      | Medium   | Use feature parent refs and sibling Bolt refs from ADR-002; never nest a ref under its feature-parent name. |
| No production performance/accessibility target is approved.                      | High        | High     | Keep Q-023/Q-026 test targets non-production and require new approval before external rollout.              |
| External F-002/F-004/F-005/F-006 systems remain unowned/unconnected.             | High        | High     | Use the versioned simulator contracts; appoint real system owners before production integration.            |

## Dependencies and Next Steps

1. Start F-001 Bolt 2 on `bolt/vacation-request-lifecycle-bolt-2-request-history` after creating the sibling branch from the feature parent.
2. Use synthetic fixtures and the existing F-006 access contract; do not add real identity or provider integrations.
3. Refresh requester-list status labels from the test decision register before implementing US-003.
4. Run RED/GREEN tests and scoped quality gates; do not claim coverage or mutation thresholds until feature logic is present.
5. Keep real-world source requirements Draft and outside this test-project approval.

## Source References

- [F-001 requirements](../requirements.md)
- [F-001 mockup index](../mockups/README.md)
- [F-001 mockup changelog](../mockups/CHANGELOG.md)
- [F-001 default request view](../mockups/my-requests-default.html)
- [F-001 empty request view](../mockups/my-requests-empty.html)
- [F-001 loading request view](../mockups/my-requests-loading.html)
- [F-001 error request view](../mockups/my-requests-error.html)
- [F-002 Approval and Delegation](../../002-approval-and-delegation/requirements.md)
- [F-004 Notifications and Escalation](../../004-notifications-and-escalation/requirements.md)
- [F-006 Application Entry and Access](../../006-application-entry-and-access/requirements.md)
- [Project solution architecture proposal](../../../docs/design/architecture/solution-architecture.md)
- [Project constitution template](../../../.boltf/memory/constitution.md)
