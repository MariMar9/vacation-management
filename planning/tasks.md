# Vacation Management: Cross-Feature Bolt Tasks

**Status:** Approved for synthetic test-project execution; not a formal external or production baseline.
**Blocker resolution:** [Dependency-ordered plan](blocker-resolution-plan.md) and [test-project feature decisions](../specs/test-project-feature-decisions.md); decisions apply only to this workspace.
**Scope:** F-001 through F-006, reconciled with available plans, Gherkin, mockups, domain artifacts, and architecture.
**Current branch:** `feature/vacation-request-lifecycle` (feature parent; no Bolt child branch created). Approved Bolt refs are siblings named `bolt/<feature-name>-bolt-<N>-<slug>`.
**Implementation stack:** .NET 8, Angular 20, Podman, Terraform, GitHub Actions, Azure test-target services, Azure SQL/EF Core, and REST/OpenAPI are approved for this test project only. Application/test scaffolds and gate routing are ready; no feature logic Bolt is complete.

## Readiness and Reconciliation

The source baseline/RFP remain Draft as source documents and are accepted only as test/discovery references. Feature test profiles are explicitly authorized in the decision register; no production/business policy is inferred from them.

| Feature                                    | Current plan/model/contract                                                                    | Gherkin                                                        | Mockups                                                                                                                       | Reconciliation result                                                     |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| F-001 Request Lifecycle                    | Test-profile plan, model, OpenAPI and Gherkin validated; 8/8 AC IDs trace.                     | Test-profile scenarios parse and trace all accepted ACs.       | Submit/cancel test mockups exist; requester-list references need status-label refresh.                                        | B1 readiness complete; B2 ready; later Bolts follow runtime dependencies. |
| F-002 Approval and Delegation              | Test-profile plan, model, lifecycle decisions, OpenAPI and six reconciled feature files exist. | Four existing mockup flows remain visual references.           | B1 readiness complete; B2 follows F-001 read implementation; B3 follows synthetic F-005 snapshot implementation; B4 excluded. |
| F-003 Demand and Capacity                  | Test-profile plan, query model, OpenAPI and Gherkin exist.                                     | Demand overview mockup remains a draft visual reference.       | B1 readiness complete; B2 can start against synthetic fixture contracts; capacity limits are advisory only.                   |
| F-004 Notifications and Escalation         | Test-profile plan, outbox/event model, simulator contract and Gherkin exist.                   | No UI mockup; email/Teams are not used by the local simulator. | B1 readiness complete; B2 can start against local event simulator; optional Teams scope excluded.                             |
| F-005 Organizational Data and Integrations | Test-profile plan, synthetic snapshot model, simulator OpenAPI and simulator policy exist.     | No application UI mockup.                                      | B1 readiness complete; B2 uses local snapshots; B3 uses a local export outbox, never real providers.                          |
| F-006 Application Entry and Access         | Test-profile plan, access model, role matrix, OpenAPI and Gherkin exist.                       | Entry mockups remain visual references.                        | B1 readiness complete; B2 can start with fake test identities; hosted Entra configuration remains environment-specific.       |

### Scenario and Architecture Status

The test-project stack and global architecture are recorded in the constitution and ADR-002; they do not approve production architecture. F-001–F-006 now have test-profile requirements decisions, model/contract/Gherkin/plan artifacts. A .NET 8 solution with API/domain/application/infrastructure and xUnit projects plus an Angular 20 workspace now exist under `src/` and `tests/`.

### Mandatory Inputs Before Code

1. T001/T002 user-authorized decisions are recorded for this test-project scope only; they are not formal sponsor approval or appointment of real-world authorities.
2. The constitution, active scopes, stack, and ADR-002 are approved for this test workspace only; they do not approve feature requirements or production use.
3. Test-profile rules, models, contracts, and Gherkin exist for all six features; real-world policy remains explicitly outside this approval.
4. Test data is synthetic and external integrations are simulated; no real credentials, provider calls, compliance claims, or deployments are allowed.
5. Create an implementation branch using feature parent `feature/<feature-name>` and sibling Bolt refs `bolt/<feature-name>-bolt-<N>-<slug>` before each code Bolt.

## Bolt Sizing and Quality Gate Policy

- Task sizes: **S** under 2 hours, **M** 2–4 hours, **L** 4–8 hours. These are relative planning estimates, not commitments.
- Keep each Bolt independently reviewable and normally within 2–3 working days after team capacity is known. Split if it exceeds eight tasks, has more than three L tasks, or exceeds five L-equivalents.
- No approved priority ranking exists. Do not infer priority from requirement order or `@smoke`; the Product Owner must prioritize after baseline approval.
- Every Bolt has a trackable `-QG` task. Test-project thresholds are lint errors 0, tests 100% passing, line coverage at least 80%, branch coverage at least 75%, and scoped mutation score at least 70%.
- For frontend/backend+frontend Bolts, include a discoverable executable Playwright `@smoke` test and run `npm run test:e2e:smoke`. `.feature` files in `specs/` are specifications, not executable tests. .NET solution, xUnit, Angular unit tests, Angular build, Playwright smoke and Gherkin parser commands are executable; feature coverage/mutation remain unmeasured until feature logic exists.
- Readiness-only Bolts gate approved artifacts, traceability, and Gherkin syntax. Code coverage and mutation are **N/A until code exists**, not passed; do not close an implementation Bolt on a documentation-only gate.
- `@slow` is not applied without an approved long-running performance/integration criterion. `@security` scenarios in F-002 are draft until access policy is approved.

## Task Format

Every task card carries objective, inputs, expected files/components, tests, documentation, dependencies, quality gate, and traceability. `[P]` means potentially parallel after listed dependencies clear. Cross-feature readiness and conditional scope are explicitly marked.

## Global Readiness Tasks

### Project Approval and Shared Inputs (not an implementation Bolt)

#### T001 [M] Obtain baseline approval and name decision authorities

**Execution status:** Complete for this test-project scope only. The RFP/Baseline are accepted only as test/discovery references, and `MariMar9` is recorded as the session/Git display identity assigned to all test-workspace roles. This is not formal external sign-off. See [.boltf/memory/test-project-approval.md](../.boltf/memory/test-project-approval.md).

- **Objective:** Record source approval status and appoint sponsor, Product Owner, workflow, data/system, security/privacy, architecture, release, and service authorities.
- **Inputs:** Draft RFP/baseline, clarification Q-001, current stakeholder list.
- **Expected files/components:** Source approval record, authority matrix, decision log; update `origin`/governance artifacts only with signed decisions.
- **Tests:** Review that approval evidence and named delegated authorities are present and versioned.
- **Documentation:** Approval record and stakeholder/RACI.
- **Dependencies:** Sponsor participation.
- **Quality gate:** No feature execution baseline until approval status and decision rights are explicit.
- **Traceability:** Q-001; all F-001–F-006; roadmap Phase 0.

#### T002 [M] Ratify constitution and architecture decision basis

**Execution status:** Complete for this test-project scope only. Active scopes, stack, cloud target, delivery/branch policy, security boundaries, and quality thresholds are recorded in the [constitution](../.boltf/memory/constitution.md), [merged refinement](../.boltf/memory/refinement-states/merged-refinement.yaml), and [ADR-002](../docs/docs/adr/ADR-002-test-project-architecture-and-controls.md). Feature readiness and local/CI gate routing are complete; feature-specific coverage/mutation remain pending until logic exists.

- **Objective:** Record the test-project constitution, active scopes, stack, cloud/deployment boundaries, and quality thresholds.
- **Inputs:** `.boltf/memory/constitution.md`, architecture proposal, baseline TC-001/TC-002, existing ADR index.
- **Expected files/components:** Ratified constitution/scopes or approved project ADRs; toolchain and gate commands.
- **Tests:** Governance review; verify selected scopes/stack and gates agree across constitution, ADRs, and CI configuration.
- **Documentation:** Ratification record, architecture/stack ADR links, quality-gate configuration.
- **Dependencies:** T001 and Architecture/Platform/Security authorities.
- **Quality gate:** No framework-specific path, package, API, or infrastructure work starts without approved technology decisions.
- **Traceability:** Constitution Articles I, X–XII, XVI, XIX; TC-001, SEC-001–SEC-003; architecture proposal.

## F-001 – Vacation Request Lifecycle

**Current plan:** Five Bolts in [F-001 plan](../specs/001-vacation-request-lifecycle/planning/plan.md). Test-profile requirements/model/OpenAPI/Gherkin are approved for this workspace; original source status remains Draft.

### F-001 Bolt 1 – Lifecycle Baseline and Contract

**Execution status:** Readiness complete for test scope. T003/T004 decisions and artifacts are recorded; Gherkin parsing and AC-tag traceability pass. No F-001 code Bolt has started. Coverage/mutation and feature-specific runtime gates remain pending until implementation tasks run.

#### T003 [L] Approve request fields, lifecycle, and acceptance rules

**Status:** Complete for the synthetic test profile in [decision register Q-010–Q-012](../specs/test-project-feature-decisions.md). Source rules remain Draft for real-world use.

- **Objective:** Resolve request fields/date semantics, validations, duplicate submission, states, cancellation eligibility/effects, history/taken meaning, status categories, and FR-024 alternative-period scope.
- **Inputs:** F-001 US-001–US-004/ACs, FR-001–FR-003/FR-012–FR-014/FR-024, clarification Q-008/Q-010/Q-011.
- **Expected files/components:** Approved `specs/001-vacation-request-lifecycle/requirements.md`, decision log, transition/rule table.
- **Tests:** Stakeholder walkthrough and acceptance examples for boundaries, invalid input, cancellation eligibility, and history.
- **Documentation:** Approved rules/glossary and disposition of every open F-001 question.
- **Dependencies:** T001 and Workflow Owner/PO decisions.
- **Quality gate:** No ambiguous required field, state, transition, or deferred rule remains in the committed F-001 scope.
- **Traceability:** US-001–US-004; FR-001–FR-003, FR-012–FR-014, FR-024; Q-008, Q-010, Q-011.

#### T004 [M] Produce F-001 model, contract, and Gherkin

**Status:** Test-profile model, OpenAPI, and Gherkin are validated. AC coverage (8/8), Gherkin parsing, Redocly, model/schema consistency, and local-link checks pass.

- **Objective:** Create the approved request model, contract-first API and Gherkin scenarios from T003 decisions.
- **Inputs:** T003 signed rules, F-001 dependencies on F-002/F-004/F-006, selected stack/API style from T002.
- **Expected files/components:** `requirements/data-model.md`, `contracts/openapi.yaml`, `tests/*.feature`, traceability links.
- **Tests:** Validate Gherkin syntax; each accepted US/AC maps to scenarios; every contract field maps to the approved model; contract validation.
- **Documentation:** Data dictionary, API/error semantics, scenario coverage map.
- **Dependencies:** T003 and T002.
- **Quality gate:** Artifacts reviewed by PO, Data Owner, Architecture and Security authorities; no invented schema fields or state names.
- **Traceability:** US-001–US-004; FR-001–FR-003, FR-012–FR-014, FR-024.

#### T005-QG [S] Close F-001 readiness Bolt

**Execution status:** Complete for test profile. Gherkin parses, 8/8 AC IDs trace, OpenAPI lint, model/schema consistency, and local links validate; coverage/mutation are N/A until F-001 runtime code exists.

- **Objective:** Verify T003/T004 approval, consistency, and traceability.
- **Inputs:** Approved requirements, model, contract, Gherkin, decision record.
- **Expected files/components:** Readiness review checklist and sign-off record; no runtime component.
- **Tests:** Gherkin parse; requirements-to-scenario-to-model/contract audit; link/Markdown checks.
- **Documentation:** Record gaps and approval evidence in the F-001 planning record.
- **Dependencies:** T003 and T004.
- **Quality gate:** All readiness checks pass. Code coverage/mutation are N/A until implementation.
- **Traceability:** F-001 US-001–US-004, AC-001.1–AC-004.2.

### F-001 Bolt 2 – Requester Read View

**Execution status:** Ready to start; T005 readiness is complete, and read/history rules, contracts, access policy, and test scaffold are available.

#### T006 [M] Implement own-request query and API

- **Objective:** Return the current user's requests/outcomes using approved status and history rules.
- **Inputs:** T003/T004; approved identity scope; F-002 outcome vocabulary.
- **Expected files/components:** Candidate request query/read service, API contract implementation, repository/query tests; exact paths/runtime TBD.
- **Tests:** Query unit/integration and contract tests; own-user scope and cross-user denial tests; history/date boundaries.
- **Documentation:** API/query behavior and status mapping.
- **Dependencies:** F-001 Bolt 1, T002, approved F-002 status dependency.
- **Quality gate:** QG-F001-B2; no status/history interpretation outside approved rules.
- **Traceability:** US-003; FR-012–FR-014; AC-003.1/AC-003.2.

#### T007 [M] Implement requester list states and executable smoke coverage

- **Objective:** Materialize the approved `my-requests` flow and its default/empty/loading/error states.
- **Inputs:** Approved UX and contract; [draft default](../specs/001-vacation-request-lifecycle/mockups/my-requests-default.html), [empty](../specs/001-vacation-request-lifecycle/mockups/my-requests-empty.html), [loading](../specs/001-vacation-request-lifecycle/mockups/my-requests-loading.html), [error](../specs/001-vacation-request-lifecycle/mockups/my-requests-error.html).
- **Expected files/components:** Requester list/history UI and component/E2E tests; concrete paths TBD by frontend stack.
- **Tests:** UI state tests, keyboard/accessibility checks and executable `@smoke` test for US-003.
- **Documentation:** UI-to-AC/mockup traceability and updated user help.
- **Dependencies:** T006 and approved UX/identity rules.
- **Quality gate:** QG-F001-B2; visible states match approved requirements, not draft assumptions.
- **Traceability:** US-003; AC-003.1/AC-003.2; F-001 mockup flow `my-requests`.

#### T008-QG [S] Close F-001 read-view Bolt

- **Objective:** Run and record the F-001 Bolt quality gate.
- **Inputs:** T006/T007 implementation and approved gate commands.
- **Expected files/components:** CI/test/coverage/mutation reports and review record.
- **Tests:** Lint 0; all tests pass; line >=80%, branch >=75%, scoped mutation >=70%; Playwright `@smoke` >=1.
- **Documentation:** Attach gate evidence to Bolt review.
- **Dependencies:** T006/T007 and approved stack tooling.
- **Quality gate:** All listed checks pass; thresholds remain subject to constitution ratification.
- **Traceability:** US-003; AC-003.1/AC-003.2.

### F-001 Bolt 3 – Submit Request

**Execution status:** Ready after F-001 Bolt 2. Submit field/date/overlap rules and API schema are approved for test scope; a form mockup is still needed for T010.

#### T009 [M] Implement approved submission command and persistence

- **Objective:** Persist a valid request and place it in the approved initial lifecycle state.
- **Inputs:** T003/T004; approved persistence/architecture decision.
- **Expected files/components:** Candidate submission use case/handler, request aggregate/repository, API endpoint and migration as selected.
- **Tests:** Domain validation, date boundaries, duplicate/idempotency behavior if specified, persistence and transaction tests.
- **Documentation:** Request command contract and persistence decision.
- **Dependencies:** F-001 Bolt 1; T002.
- **Quality gate:** QG-F001-B3; no fields or state transitions beyond T003.
- **Traceability:** US-001; FR-001; AC-001.1/AC-001.2.

#### T010 [M] Implement request-entry form and validation states

- **Objective:** Present only approved request fields and errors and submit valid input.
- **Inputs:** T003 approved field/validation catalogue and accepted UX (new mockup required; current mockups omit this form).
- **Expected files/components:** Candidate request form, validation presentation, API client and E2E spec.
- **Tests:** Field/boundary validation, server-error state, role/access checks, Playwright `@smoke` for accepted submission.
- **Documentation:** Field/help/error mapping and mockup link.
- **Dependencies:** T009; UX review; identity from F-006.
- **Quality gate:** QG-F001-B3; no form field or validation inferred from examples.
- **Traceability:** US-001; FR-001; AC-001.1/AC-001.2.

#### T011-QG [S] Close F-001 submission Bolt

- **Objective:** Verify submission behavior, validation and release gates.
- **Inputs:** T009/T010 and approved model/contract.
- **Expected files/components:** Gate reports and accepted submission scenario.
- **Tests:** Lint 0, test pass 100%, line >=80%, branch >=75%, mutation >=70%, UI smoke E2E >=1.
- **Documentation:** Record gate evidence, AC mapping, and unresolved defects.
- **Dependencies:** T009/T010.
- **Quality gate:** All thresholds pass or approved written exception before Bolt close.
- **Traceability:** US-001; FR-001; AC-001.1.

### F-001 Bolt 4 – Cancel Own Eligible Request

**Execution status:** Ready after F-001 Bolt 2/3 and the F-004 local cancellation-event contract.

#### T012 [M] Implement cancellation transition and ownership authorization

- **Objective:** Apply only approved cancellation transitions for the authenticated request owner.
- **Inputs:** T003 transition/eligibility/side-effect decisions; F-006 access contract; F-004 event contract if applicable.
- **Expected files/components:** Candidate cancel command/API, domain transition, persistence/audit hook.
- **Tests:** Allowed/disallowed state matrix, request-owner vs other-user authorization, stale/concurrent transition, persistence failure.
- **Documentation:** Cancellation state/action mapping and F-004 event contract.
- **Dependencies:** F-001 Bolt 1/2; F-004/F-006 approved interfaces.
- **Quality gate:** QG-F001-B4; no cancellation eligibility or side effects inferred.
- **Traceability:** US-002/US-004; FR-002/FR-003/FR-024; AC-002.1/AC-002.2/AC-004.1/AC-004.2.

#### T013 [M] Implement cancellation interaction and outcome state

- **Objective:** Expose cancel action only when approved rules allow it and show the approved result/error.
- **Inputs:** T012, accepted UX, F-004 notification decision.
- **Expected files/components:** Candidate request-row action, confirmation/pending/result/error UI, accessible E2E tests.
- **Tests:** Eligible and ineligible states, unauthorized action denial, cancellation success/failure, notification handoff if approved.
- **Documentation:** Cancellation UI states and support guidance.
- **Dependencies:** T012; UX approval; F-006 identity/scope.
- **Quality gate:** QG-F001-B4; no cancel button/action outside the approved state matrix.
- **Traceability:** US-002/US-004; FR-002/FR-003; AC-002.1/AC-002.2/AC-004.1.

#### T014-QG [S] Close F-001 cancellation Bolt

- **Objective:** Verify transition, authorization, UI and event tests.
- **Inputs:** T012/T013; approved state/action/event rules.
- **Expected files/components:** Gate reports, state-matrix test evidence.
- **Tests:** Lint 0, tests 100%, line >=80%, branch >=75%, mutation >=70%, UI smoke E2E >=1.
- **Documentation:** Gate evidence and accepted exception list.
- **Dependencies:** T012/T013.
- **Quality gate:** All thresholds pass; F-004 handoff contract passes if included.
- **Traceability:** US-002/US-004; FR-002/FR-003/FR-024.

### F-001 Bolt 5 – Regression and Cross-Feature Handoff

**Execution status:** Deferred until F-001 Bolts 2–4 and dependent F-002/F-004/F-006 runtime work are complete.

#### T015 [M] Verify F-001 end-to-end and dependent contracts

- **Objective:** Verify request creation/history/cancellation through approved F-002/F-004/F-006 boundaries.
- **Inputs:** F-001 Bolts 1–4; adjacent contracts and test environments.
- **Expected files/components:** F-001 regression/E2E suite, test fixtures, contract checks.
- **Tests:** End-to-end request-to-review, cancellation and user-history journeys; denial/contract failures; no unapproved finality.
- **Documentation:** Traceability and known limitations.
- **Dependencies:** F-001 Bolts 1–4 and adjacent features available or contract doubles approved.
- **Quality gate:** QG-F001-B5; deferred cross-feature paths explicitly marked, not silently passed.
- **Traceability:** US-001–US-004; F-002/F-004/F-006 dependencies.

#### T016 [S] Complete F-001 release and support documentation

- **Objective:** Publish accepted behavior, API help, runbook, known limitations and rollout notes.
- **Inputs:** Approved requirements, contracts, test evidence and release decisions.
- **Expected files/components:** Feature docs, support runbook, release notes and traceability record.
- **Tests:** Link/consistency review against accepted AC and production support steps.
- **Documentation:** All F-001 user/technical/support docs updated.
- **Dependencies:** F-001 Bolts 1–5.
- **Quality gate:** PO and Service Owner accept docs; no unresolved draft behavior represented as fact.
- **Traceability:** US-001–US-004; all accepted F-001 FR/AC.

#### T017-QG [S] Close F-001 regression Bolt

- **Objective:** Record feature-scope quality and contract gate evidence.
- **Inputs:** T015/T016 and all prior Bolt reports.
- **Expected files/components:** F-001 release quality summary.
- **Tests:** Full F-001 tests pass; coverage/mutation meet ratified thresholds; E2E smoke passes; contracts pass.
- **Documentation:** Quality report and residual risks.
- **Dependencies:** T015/T016.
- **Quality gate:** Release gate passes or authorized exception is recorded.
- **Traceability:** US-001–US-004; F-001 release acceptance.

## F-002 – Approval and Delegation

**Inputs:** Six Gherkin files are reconciled to the synthetic test profile. See [F-002 plan](../specs/002-approval-and-delegation/planning/plan.md), [test-profile model](../specs/002-approval-and-delegation/requirements/data-model.md), [OpenAPI](../specs/002-approval-and-delegation/contracts/openapi.yaml), and [decision register](../specs/test-project-feature-decisions.md). Real-world policy remains Draft.

### F-002 Bolt 1 – Approve Workflow Model and BDD Baseline (Readiness Bolt)

**Execution status:** Readiness complete for the synthetic test profile. T018/T019 artifacts and decisions are recorded; AC traceability and Gherkin parsing pass. No F-002 runtime code is implemented, and real-world policies remain Draft.

#### T018 [L] Resolve F-002 approval, rejection and delegation policies

- **Objective:** Get approved decision sequence/finality, role/scope matrix, rejection follow-up, delegation authority and assessor/close semantics.
- **Inputs:** F-002 requirements, UC-001–UC-006, clarification Q-005–Q-009/Q-021, draft domain/state models.
- **Expected files/components:** Approved F-002 requirements, domain model, state lifecycle, access/delegation policy decision records.
- **Tests:** Business walkthrough and rule-by-rule acceptance review.
- **Documentation:** Approved model/ADR/rules and disposition of pending requirements.
- **Dependencies:** T001/T002 (complete for test-project scope) and separate workflow/security/data-owner decisions.
- **Quality gate:** No decision behavior inferred from conditional stories or provisional models.
- **Traceability:** F-002 US-001–US-005; FR-004–FR-010/FR-028–FR-032; Q-005–Q-009/Q-021.

#### T019 [M] Reconcile F-002 Gherkin, plan, and contract

- **Objective:** Map six current feature files to approved stories/ACs, create missing scenarios/contracts, and author a feature plan.
- **Inputs:** T018; `tests/*.feature`; six UC files; F-002 mockup index and HTML states.
- **Expected files/components:** `specs/002-approval-and-delegation/planning/plan.md`, approved `contracts/` and model references, updated feature files; no implementation code.
- **Tests:** Gherkin parse; every approved AC mapped; every `@smoke` story has implementation owner; pending tags/conditions resolved or excluded.
- **Documentation:** Scenario-to-AC/UC matrix and plan/feature dependency map.
- **Dependencies:** T018.
- **Quality gate:** Each scenario has approved expected behavior; `@pending-clarification` cases remain non-executable until decision.
- **Traceability:** F-002 US-001–US-005; UC-001–UC-006; existing six feature files.

#### T020-QG [S] Close F-002 readiness Bolt

**Execution status:** Complete for test profile. Six Gherkin files parse, 10/10 AC IDs trace, OpenAPI and model links validate; real-world policy remains Draft.

**Execution status:** Complete for test profile. Six Gherkin files parse, 10/10 AC tags trace, OpenAPI lint/model review pass; runtime coverage/mutation are N/A.

- **Objective:** Verify approved model/contract/Gherkin/plan alignment.
- **Inputs:** T018/T019 artifacts and approvals.
- **Expected files/components:** Readiness sign-off and gap disposition.
- **Tests:** Gherkin parser, AC/UC traceability, contract-model validation, link checks.
- **Documentation:** Record unresolved exclusions and owners.
- **Dependencies:** T018/T019.
- **Quality gate:** Artifact readiness passes; code coverage/mutation N/A until implementation.
- **Traceability:** F-002 US-001–US-005; FR-004–FR-010/FR-028–FR-032.

### F-002 Bolt 2 – Request Review and Decision Outcomes

**Execution status:** Ready after F-001 Bolt 2 publishes its read implementation. F-001 request, F-005 membership-simulator, and F-006 access contracts are available; implement against synthetic fixtures only.

#### T021 [L] Implement scoped request review and level decisions

- **Objective:** Deliver approved project review and project/department decision outcomes without assuming overall finality.
- **Inputs:** F-002 Bolt 1; F-001 request read/eligibility contract; F-005 membership data; F-006 authorization contract.
- **Expected files/components:** Candidate review query/UI, decision commands/API/domain state, persistence and authorization checks.
- **Tests:** Project scope list/detail; project and department approval; rejection; stale/ineligible and unauthorized paths.
- **Documentation:** Decision/view contracts and role-action behavior.
- **Dependencies:** F-001 Bolt 2; F-002 Bolt 1; F-005/F-006 contracts.
- **Quality gate:** QG-F002-B2; no non-project rejection or overall finality unless approved.
- **Traceability:** US-001/US-002; FR-004–FR-007; UC-001–UC-003; `project-review`, `record-approval-decision`, `reject-project-request` features.

#### T022 [M] Implement F-002 review/decision UI states and E2E

- **Objective:** Materialize approved project review and separate project/department decision mockups.
- **Inputs:** T021; F-002 mockups and accepted UX; approved error and success outcomes.
- **Expected files/components:** Candidate UI review list, decision panels, loading/empty/error/success states and Playwright smoke specs.
- **Tests:** UI state tests, role-specific actions, scope denial, project and department success/error E2E.
- **Documentation:** Mockup-to-component/AC traceability.
- **Dependencies:** T021 and approved identity/access rules.
- **Quality gate:** QG-F002-B2; UI has no role action outside approved matrix.
- **Traceability:** US-001/US-002; AC-001.1/001.2/002.1/002.2; UC-001–UC-003.

#### T023-QG [S] Close F-002 review/decision Bolt

- **Objective:** Verify feature tests and quality gates for review/decisions.
- **Inputs:** T021/T022; approved stack and gate commands.
- **Expected files/components:** Bolt quality report.
- **Tests:** Lint 0, test pass 100%, line >=80%, branch >=75%, mutation >=70%, Playwright smoke >=1.
- **Documentation:** Gate results and residual risks.
- **Dependencies:** T021/T022.
- **Quality gate:** All ratified thresholds pass; F-004 notification trigger is not assumed.
- **Traceability:** US-001/US-002; UC-001–UC-003.

### F-002 Bolt 3 – Approver Resolution and Delegation

**Execution status:** Ready after F-005 Bolt 2 supplies the local membership snapshot fixture and F-002 Bolt 2 supplies decision handlers. Same-project scope, 30-day expiry, revocation, actor attribution, simulator contract, and F-006 authorization are defined for test scope; no real AD integration.

#### T024 [L] Implement approved approver resolution and same-project delegation

- **Objective:** Resolve responsibility and grant/validate delegation under approved scope, duration, eligibility and attribution rules.
- **Inputs:** F-002 Bolt 1; F-005 approved project membership/approver contract; F-006 security policy.
- **Expected files/components:** Candidate approver resolution service, delegation aggregate/command/API/repository, UI form, audit record.
- **Tests:** Missing/multiple/conflicting mappings; same-project eligibility; unauthorized delegator; scope/validity boundaries; persistence failure.
- **Documentation:** Assignment/delegation contract, audit and support guide.
- **Dependencies:** F-002 Bolt 1 and F-005/F-006 integration contracts.
- **Quality gate:** QG-F002-B3; same-project condition enforced; no expiry/revocation/department delegation invented.
- **Traceability:** US-004/US-005; FR-028/FR-029/FR-030; UC-005/UC-006; `delegate-approval`, `resolve-approver-responsibility` features.

#### T025 [M] Verify delegation attribution and E2E cases

- **Objective:** Implement approved delegation test scenarios and actor/context attribution behavior.
- **Inputs:** Approved delegation/audit policy and T024.
- **Expected files/components:** Delegation/approver-resolution integration tests, audit verification, frontend E2E specs.
- **Tests:** Same-project/denial/unverified membership and attributed delegated decision scenarios.
- **Documentation:** Test-to-UC/AC evidence.
- **Dependencies:** T024 and F-005 membership test environment.
- **Quality gate:** QG-F002-B3; attribution tests assert only approved audit fields.
- **Traceability:** US-004 AC-004.1/004.2; US-005 AC-005.1; FR-029; UC-005/UC-006.

#### T026-QG [S] Close F-002 delegation Bolt

- **Objective:** Verify delegation/assignment feature gates.
- **Inputs:** T024/T025 and approved contracts.
- **Expected files/components:** Bolt gate report.
- **Tests:** Lint 0, test pass 100%, line >=80%, branch >=75%, mutation >=70%, Playwright smoke >=1.
- **Documentation:** Gate report and any Q-009 decision references.
- **Dependencies:** T024/T025.
- **Quality gate:** No unresolved delegation permission or mapping rule in shipped scope.
- **Traceability:** US-004/US-005; FR-028–FR-030; UC-005/UC-006.

### F-002 Bolt 4 – Assess/Close (Conditional)

**Execution status:** Explicitly excluded for the test profile by Q-008. Review is read-only; no separate close action is implemented. Verify absence only; this is not feature implementation completion.

#### T027 [M] Implement assess/close only if stakeholders approve the action definitions

- **Objective:** Add only the action(s) explicitly defined by approved FR-008/FR-009 outcomes; otherwise record formal deferral and omit runtime behavior.
- **Inputs:** Q-008 decision; approved actor, input, eligibility, state effect and reversibility.
- **Expected files/components:** Conditional UI/command/API/state changes, or approved out-of-scope record; no changes before decision.
- **Tests:** Approved action and denial/error scenarios only; update `assess-or-close-request.feature` accordingly.
- **Documentation:** Decision, AC, state model and Gherkin update.
- **Dependencies:** F-002 Bolt 1 and PO/workflow approval.
- **Quality gate:** No interpretation of “valorar”/“close” inferred; if deferred, verify code/UI does not expose actions.
- **Traceability:** US-003; FR-008/FR-009; UC-004; Q-008.

#### T028-QG [S] Close conditional assess/close Bolt or verify deferral

- **Objective:** Gate approved implementation or auditable no-action deferral.
- **Inputs:** T027 decision and scenario updates.
- **Expected files/components:** Test evidence or signed deferral record.
- **Tests:** If built, standard code tests; if deferred, static/UI check that undefined actions are absent.
- **Documentation:** Capture approved interpretation or explicit out-of-scope decision.
- **Dependencies:** T027.
- **Quality gate:** Code gates apply only if implementation is authorized; deferred status is not counted as feature completion.
- **Traceability:** US-003; FR-008/FR-009; UC-004; Q-008.

## F-003 – Demand and Capacity Visibility

**Current inputs:** Test-profile calculation decisions, model, OpenAPI, Gherkin, and plan exist. The `demand-overview` mockup is a visual reference; no production capacity policy is approved.

### F-003 Bolt 1 – Approve Demand Rules and Test Contract (Readiness Bolt)

**Execution status:** Readiness complete for test profile. T029/T030 decisions, model, query contract, Gherkin, and AC coverage are recorded and validated; no runtime code is implied.

#### T029 [L] Approve scope, periods, counts, thresholds and capacity policy

- **Objective:** Decide source data, hierarchy, period semantics, count states, denominator, threshold, limit ownership and exceeded-limit behavior.
- **Inputs:** F-003 US-001–US-004/ACs, Q-002–Q-005/Q-013–Q-016/Q-026.
- **Expected files/components:** Updated approved F-003 rules, data model, calculation specification and API/query contract.
- **Tests:** Reference datasets and boundary examples agreed by business/data owners.
- **Documentation:** Calculation glossary, source/refresh rules, decision log.
- **Dependencies:** T001/T002; ServiceNow/AD and business data owners.
- **Quality gate:** No counts, percentage, scope or enforcement policy are assumed from the draft mockup.
- **Traceability:** US-001–US-004; FR-011/FR-015–FR-020/FR-033; NFR-001/NFR-002/NFR-005/NFR-006.

#### T030 [M] Create F-003 plan and Gherkin coverage

- **Objective:** Produce a feature-specific plan and scenarios after T029 decisions.
- **Inputs:** Approved rules/data contract, draft `demand-overview` mockup.
- **Expected files/components:** F-003 `planning/plan.md`, `tests/*.feature`, requirements-to-scenario map.
- **Tests:** Gherkin parse; every accepted AC maps; scenarios compare counts with owner-approved reference data.
- **Documentation:** Bolt plan and mockup/state mapping.
- **Dependencies:** T029.
- **Quality gate:** No executable threshold/limit scenario without approved calculation and action.
- **Traceability:** US-001–US-004; FR-011/FR-015–FR-020/FR-033.

#### T031-QG [S] Close F-003 readiness Bolt

**Execution status:** Complete for test profile. Gherkin parses, 8/8 AC IDs trace, query model/OpenAPI and synthetic fixture JSON validate; runtime coverage/mutation are N/A.

**Execution status:** Complete for test profile. Gherkin parse, 8/8 AC tags, OpenAPI lint and reference-fixture/model review pass; runtime coverage/mutation are N/A.

- **Objective:** Verify demand contract/model/scenarios and approvals.
- **Inputs:** T029/T030 approved artifacts.
- **Expected files/components:** Readiness checklist and sign-off.
- **Tests:** Gherkin parse, data-model-to-contract consistency, scenario/AC coverage.
- **Documentation:** Record approved calculation and remaining exclusions.
- **Dependencies:** T029/T030.
- **Quality gate:** Readiness-only checks pass; code metrics N/A until implementation.
- **Traceability:** F-003 US-001–US-004; FR-011/FR-015–FR-020/FR-033.

### F-003 Bolt 2 – Read-Only Demand Overview

**Execution status:** Ready to start against approved F-001/F-005 test contracts and F-002/F-006 scope policy. Use deterministic synthetic fixtures.

#### T032 [M] Implement approved scoped demand query

- **Objective:** Calculate approved counts for the selected scope/period from F-001 request and F-005 membership data.
- **Inputs:** F-003 Bolt 1; F-001 request contract; F-005 source contract; F-002 scope policy.
- **Expected files/components:** Candidate demand query/API, calculation service, reference-data fixtures.
- **Tests:** Reference dataset comparison, count boundaries, freshness, empty/data failure cases.
- **Documentation:** Query contract and calculation provenance.
- **Dependencies:** F-001/F-002/F-003/F-005 approved contracts.
- **Quality gate:** QG-F003-B2; no final threshold or capacity effect beyond approved rules.
- **Traceability:** US-001–US-003; FR-011/FR-016/FR-017/FR-020/FR-033; F-003 Gherkin created in T030.

#### T033 [M] Implement responsive demand view and states

- **Objective:** Materialize scope/period selection and display approved demand view.
- **Inputs:** Approved UX; [draft demand overview](../specs/003-demand-and-capacity-visibility/mockups/README.md); T032 API.
- **Expected files/components:** Candidate filters, summary panels/chart, default/empty/loading/error UI, smoke E2E spec.
- **Tests:** Count/reference rendering, control validation, responsive/accessibility states, Playwright smoke.
- **Documentation:** UI-to-AC/mockup map.
- **Dependencies:** T032 and approved UX/data semantics.
- **Quality gate:** QG-F003-B2; no disabled placeholder controls treated as approved options.
- **Traceability:** US-001–US-003; FR-011/FR-015–FR-018/FR-020/FR-033; flow `demand-overview`.

#### T034-QG [S] Close F-003 demand-view Bolt

- **Objective:** Run per-Bolt functional and frontend quality gates.
- **Inputs:** T032/T033.
- **Expected files/components:** Gate reports.
- **Tests:** Lint 0, tests 100%, line >=80%, branch >=75%, mutation >=70%, smoke E2E >=1.
- **Documentation:** Evidence and deferred issues.
- **Dependencies:** T032/T033.
- **Quality gate:** All ratified gates pass; do not apply 70% as policy unless accepted by T029.
- **Traceability:** F-003 US-001–US-003; FR-011/FR-015–FR-018/FR-020/FR-033.

### F-003 Bolt 3 – Capacity Management (Conditional)

**Execution status:** Approved for advisory-only test behavior after Bolt 2. Limits and the 70% marker never block requests or approval.

#### T035 [M] Implement concurrent limit management only if approved

- **Objective:** If T029 approves ownership/scope and whether excess blocks, warns or displays only, implement exactly that behavior; otherwise defer.
- **Inputs:** Approved FR-019 policy, authorized actor/scope, period contract.
- **Expected files/components:** Conditional configuration UI/API/model and audit record, or signed deferral.
- **Tests:** Authorized change, period/scope application, exceeded-limit behavior, denial and persistence failure.
- **Documentation:** Capacity rule and runbook.
- **Dependencies:** T029, F-006 auth, architecture approval.
- **Quality gate:** No limit or enforcement action fabricated; deferral is not represented as complete implementation.
- **Traceability:** US-004; FR-019; AC-004.1/AC-004.2; Q-004.

#### T036-QG [S] Close conditional F-003 capacity Bolt

- **Objective:** Verify approved behavior or record explicit deferral.
- **Inputs:** T035 and T029 decision.
- **Expected files/components:** Gate evidence or scope exclusion.
- **Tests:** Policy scenario tests if built; static/authorization check if deferred.
- **Documentation:** Decision/deferral and residual risk.
- **Dependencies:** T035.
- **Quality gate:** Standard code thresholds if implemented; otherwise readiness/absence verification only.
- **Traceability:** US-004; FR-019; Q-004.

## F-004 – Notifications and Escalation

**Current inputs:** Test-profile event catalogue, outbox model, event/simulator contracts, plan, and Gherkin are defined. SMTP and Teams delivery are disabled; real-world notification policy remains Draft.

### F-004 Bolt 1 – Notification/Event Catalogue and Contract (Readiness Bolt)

**Execution status:** Readiness complete for test profile; event triggers, recipients, test-clock thresholds, suppression, payload, and AC traceability are validated.

#### T037 [L] Approve notification and escalation rules

- **Objective:** Define approval/cancellation events, finality trigger, recipient, channel, content, timeout/repeat/suppression, delivery and audit policy.
- **Inputs:** F-004 US-001–US-004; F-001 cancellation, F-002 decision/finality, Q-006/Q-018/Q-019/Q-022.
- **Expected files/components:** Approved event catalogue, integration contract, feature plan, Gherkin scenarios.
- **Tests:** Stakeholder walkthrough/reference event matrix and Gherkin parse/AC coverage.
- **Documentation:** Event/recipient matrix, retries/retention decision, feature plan.
- **Dependencies:** F-001/F-002 test event contracts and T001/T002; no SMTP/Teams owner is required because delivery is disabled.
- **Quality gate:** Event triggers/recipients match the simulator contract; no unapproved finality or external delivery is assumed.
- **Traceability:** US-001–US-004; FR-021–FR-023/FR-027; INT-007/INT-008; Q-006/Q-018/Q-019.

#### T038-QG [S] Close F-004 readiness Bolt

**Execution status:** Complete for test profile. Event/OpenAPI contracts and 8/8 AC IDs validate; SMTP/Teams are disabled; runtime coverage/mutation are N/A.

**Execution status:** Complete for test profile. Event/OpenAPI contracts and 8/8 AC tags validate; external email/Teams delivery remains disabled; runtime coverage/mutation are N/A.

- **Objective:** Verify event contract, source approval and scenario traceability.
- **Inputs:** T037 and signed owner decisions.
- **Expected files/components:** Readiness report and contract/Gherkin references.
- **Tests:** Contract/Gherkin validation and event matrix completeness review.
- **Documentation:** Approved event definitions and unresolved exclusions.
- **Dependencies:** T037.
- **Quality gate:** Documentation/contract gate passes; code metrics N/A.
- **Traceability:** F-004 US-001–US-004; FR-021–FR-023/FR-027.

### F-004 Bolt 2 – Local Notification Outbox and Escalation

**Execution status:** Ready after F-001/F-002 event producers are available. Implement only the local notification outbox/simulator; do not configure SMTP, Teams, or a message broker.

#### T039 [M] Implement local event outbox consumer

- **Objective:** Queue only test-profile events/recipients in the local notification simulator.
- **Inputs:** F-004 Bolt 1; F-001/F-002 event contracts; synthetic recipient fixtures.
- **Expected files/components:** Local event handler, minimal content mapping, idempotent outbox and delivery status record; no SMTP adapter.
- **Tests:** Event/recipient mapping, duplicates, failure/retry behavior and no-send for non-trigger states.
- **Documentation:** Support/replay and delivery diagnostics.
- **Dependencies:** F-001/F-002; F-004 Bolt 1; F-005 integration/security contract.
- **Quality gate:** QG-F004-B2; local outbox only, with test-clock evaluation and idempotent event keys.
- **Traceability:** US-001/US-002; FR-022/FR-023; INT-007; Q-018.

#### T040 [M] Implement approved timeout escalation

- **Objective:** Generate department-approver alarm only after approved timeout and eligible state.
- **Inputs:** Approved timeout, eligible request definition, assigned recipient, repeat/suppression rules.
- **Expected files/components:** Test-clock evaluator, escalation event/handler and simulator status; no production scheduler.
- **Tests:** Clock/boundary, suppress after decision, repeat behavior, timezone, job retry/idempotency.
- **Documentation:** Scheduler operations/runbook and timeout policy.
- **Dependencies:** F-002 approval-state/approver assignment; F-004 Bolt 1; F-005 source data if required.
- **Quality gate:** QG-F004-B2; alert does not grant/change approval authority.
- **Traceability:** US-003; FR-021; Q-006/Q-018.

#### T041-QG [S] Close F-004 email/escalation Bolt

- **Objective:** Verify event and scheduled processing gates.
- **Inputs:** T039/T040, approved event policy and system contract.
- **Expected files/components:** Gate/test report and operational evidence.
- **Tests:** Lint 0, tests 100%, line >=80%, branch >=75%, mutation >=70%; contract, retry/replay and schedule tests.
- **Documentation:** Gate evidence and message/event audit.
- **Dependencies:** T039/T040.
- **Quality gate:** All executable test-scope checks pass; no external delivery SLO is asserted.
- **Traceability:** FR-021–FR-023; US-001–US-003.

### F-004 Bolt 3 – Optional Teams/Adaptive Cards

**Execution status:** Excluded for this test profile by Q-019. T042/T043 verify absence of Teams/adaptive-card dependencies; exclusion is not implementation completion.

#### T042 [M] Add Teams/adaptive-card support only after scope approval

- **Objective:** Implement optional channels only if channel, event, recipient, content, stage and retention policies are approved.
- **Inputs:** Q-019, FR-027, INT-008, channel owner contract.
- **Expected files/components:** Conditional Teams adapter/card template/preferences or signed deferral.
- **Tests:** Approved event/channel mapping, access token/identity and delivery failures if enabled.
- **Documentation:** Optionality, rollout and support guide.
- **Dependencies:** F-004 Bolt 1; F-006 identity; platform/channel approval.
- **Quality gate:** No Teams/adaptive card work enters committed release scope without approval.
- **Traceability:** US-004; FR-027; INT-008; Q-019.

#### T043-QG [S] Close optional channel Bolt or verify exclusion

- **Objective:** Confirm approved support or audited exclusion.
- **Inputs:** T042 decision.
- **Expected files/components:** Test evidence or signed deferral.
- **Tests:** Channel contract/security tests if enabled; otherwise verify no mandatory Teams dependency.
- **Documentation:** Scope decision and release note.
- **Dependencies:** T042.
- **Quality gate:** No unapproved external channel in production path.
- **Traceability:** US-004; FR-027; INT-008.

## F-005 – Organizational Data and Integrations

**Current inputs:** Synthetic snapshot/export simulator schemas, model, plan, and Gherkin exist. No external system owners or provider APIs are approved; all external calls remain disabled.

### F-005 Bolt 1 – Source Ownership and Integration Contracts (Readiness Bolt)

**Execution status:** Readiness complete for the local test simulators. T044/T045 validate synthetic schemas, mapping, atomic publish, freshness, idempotency, error policy, and AC traceability; they do not approve real ServiceNow/AD contracts.

#### T044 [L] Approve system ownership, data mapping and cadence

- **Objective:** Define and validate test-only synthetic snapshot and export simulator rules; real provider definitions are deferred.
- **Inputs:** Test-project decisions Q-013–Q-017 and F-001/F-002/F-003 contracts.
- **Expected files/components:** Synthetic data model, local simulator schemas, feature plan, Gherkin, and traceability map.
- **Tests:** Deterministic test fixtures, schema checks, snapshot validation, idempotency and reconciliation scenarios.
- **Documentation:** Mapping catalog, interface contracts, operational ownership and data-flow diagram.
- **Dependencies:** T001/T002 test decisions; no real external owner is assumed.
- **Quality gate:** Simulator-only schemas and failure behavior match the test decision register; no provider mapping is represented as real.
- **Traceability:** F-005 US-001–US-004; INT-001–INT-010; Q-013–Q-017.

#### T045-QG [S] Close F-005 contract readiness Bolt

**Execution status:** Complete for local simulators. OpenAPI/YAML, 8/8 AC IDs, synthetic snapshot schema and export eligibility validate; no real provider contract/owner is asserted.

**Execution status:** Complete for synthetic simulators only. OpenAPI/YAML, 8/8 AC tags, atomic snapshot/export decision traceability pass; no real provider contract is approved.

- **Objective:** Validate contracts and scenario traceability before adapter work.
- **Inputs:** T044 signed system-owner decisions.
- **Expected files/components:** Contract/readiness evidence; no runtime adapter.
- **Tests:** Contract/schema validation, source-field mapping review, Gherkin parse/coverage.
- **Documentation:** Decision record and unsupported integration exclusions.
- **Dependencies:** T044.
- **Quality gate:** All local simulators have schemas, security boundary and failure policy; real target systems are explicitly out of scope.
- **Traceability:** F-005 US-001–US-004; INT-001–INT-010.

### F-005 Bolt 2 – Inbound Membership and Organization Data

**Execution status:** Ready to implement a local synthetic snapshot importer and fixture store. No ServiceNow/AD adapter or credential is authorized.

#### T046 [M] Implement approved scheduled source ingestion

- **Objective:** Validate and atomically publish synthetic organization snapshots through the local simulator.
- **Inputs:** F-005 Bolt 1; synthetic snapshot schema, fixture data and configured test cadence; no provider credentials.
- **Expected files/components:** Local snapshot importer, last-valid snapshot store, validation report and freshness status.
- **Tests:** Contract/integration, mapping/reference, stale/missing/conflicting data, retry and replay.
- **Documentation:** Job operations, freshness and recovery runbook.
- **Dependencies:** F-005 Bolt 1 and F-002/F-003 simulator contracts; no cloud scheduler or provider secrets.
- **Quality gate:** QG-F005-B2; unverified data not treated as current or authoritative.
- **Traceability:** US-001/US-002/US-004; INT-001–INT-004/INT-009; Q-014/Q-016/Q-017.

#### T047-QG [S] Close inbound integration Bolt

- **Objective:** Verify source import/reconciliation quality gates.
- **Inputs:** T046 and local simulator test fixtures.
- **Expected files/components:** Simulator contract and snapshot validation test report.
- **Tests:** Lint 0, tests 100%, coverage line >=80%, branch >=75%, mutation >=70%; mapping, stale data, replay, failure tests.
- **Documentation:** Evidence, reconciliation checklist, unresolved data exceptions.
- **Dependencies:** T046.
- **Quality gate:** Atomic publish, validation errors, last-valid retention, freshness, and no-provider-call behavior pass.
- **Traceability:** INT-001–INT-004/INT-009; US-001/US-002/US-004.

### F-005 Bolt 3 – ServiceNow Approved-Vacation Export

**Execution status:** Ready after F-001/F-002 decision handlers; implement only the local approved-export outbox, not a ServiceNow connection.

#### T048 [L] Implement approved-only outbound export

- **Objective:** Queue only final Approved requests meeting both test-profile decisions into the local export simulator.
- **Inputs:** F-001 request model, F-002 finality/required-approver rule, F-005 export schema/ack/idempotency contract.
- **Expected files/components:** Export selector, idempotent local outbox, delivery/reconciliation state; no external service identity.
- **Tests:** Include/exclude matrix, duplicate/idempotency, acknowledgement, retry/replay, correction and reconciliation.
- **Documentation:** Export mapping, runbook and audit trail.
- **Dependencies:** F-001/F-002 decisions; F-005 Bolt 1 and platform/security credentials.
- **Quality gate:** Both required test decisions must exist; no real provider call or production export occurs.
- **Traceability:** US-003; INT-005/INT-006; Q-006/Q-015/Q-017.

#### T049-QG [S] Close export Bolt

- **Objective:** Verify approved-only export and recovery evidence.
- **Inputs:** T048 and local export simulator contract.
- **Expected files/components:** Approved-only export and reconciliation test report.
- **Tests:** Lint 0, tests 100%, coverage/mutation thresholds; contract, duplicate, failure and approved-only tests.
- **Documentation:** Data-owner acceptance and recovery instructions.
- **Dependencies:** T048.
- **Quality gate:** Simulator outbox filter and idempotency match the test profile; real provider contract remains out of scope.
- **Traceability:** INT-005/INT-006; F-001/F-002 approval dependencies.

## F-006 – Application Entry and Access

**Current inputs:** Test-profile access matrix, model, access-profile contract, plan, and Gherkin exist. Local automation uses fake identities; hosted Entra OIDC remains an environment direction, not configured.

### F-006 Bolt 1 – Approve Identity, Access and Entry Rules (Readiness Bolt)

**Execution status:** Readiness complete for test profile; role/action/scope rules, fake identity contract, 401/403 behavior, and AC coverage are recorded and validated.

#### T050 [L] Define test identity, role/scope and trial boundary

- **Objective:** Define pre-provisioned synthetic users, test auth behavior, role/actions, department/project scope, delegation and no-public-trial boundary.
- **Inputs:** F-006 US-001–US-003/ACs, SEC-001–SEC-003, TC-002, Q-021/Q-022.
- **Expected files/components:** Approved access matrix, identity/security contract, updated requirements, feature plan and Gherkin.
- **Tests:** Test-profile role matrix review; permitted/denied scenarios for requester, project/department approver and delegate.
- **Documentation:** Identity/access decision, account lifecycle and trial record.
- **Dependencies:** T001/T002 test-project authorization and feature decision register.
- **Quality gate:** Fake identities are test-only; no public signup, real user data, or production identity behavior is enabled.
- **Traceability:** US-001–US-003; FR-025/FR-026; SEC-001–SEC-003; Q-021/Q-022.

#### T051-QG [S] Close F-006 readiness Bolt

**Execution status:** Complete for fake-identity test profile. Access matrix, OpenAPI and 6/6 AC IDs validate; Entra tenant/production security review are not claimed.

**Execution status:** Complete for fake-identity test profile. Access matrix, OpenAPI, Gherkin and 6/6 AC tags validate; no Entra tenant or compliance review is claimed.

**Execution status:** Readiness evidence complete for this test profile; runtime security controls still require implementation tests.

- **Objective:** Verify access policy approval, plan and scenario coverage.
- **Inputs:** T050 decisions and mockup index.
- **Expected files/components:** Readiness checklist and approved role/action matrix.
- **Tests:** Gherkin parse, authorization matrix coverage, requirement-to-scenario traceability.
- **Documentation:** Record omitted trial/auth decisions or approved acceptance.
- **Dependencies:** T050.
- **Quality gate:** User-authorized test-profile access record and traceability are present; no external security/compliance sign-off is claimed; code coverage/mutation are N/A until implementation.
- **Traceability:** F-006 US-001–US-003; FR-025/FR-026; SEC-001–SEC-003.

### F-006 Bolt 2 – Link Entry and Scoped Access

**Execution status:** Ready to start with the local fake-identity adapter and server-side test role/scope checks. Entra tenant setup is not a prerequisite for local TDD.

#### T052 [M] Implement approved link entry and identity handoff

- **Objective:** Route pre-provisioned synthetic test users through the fake local identity adapter to allowed test capabilities.
- **Inputs:** F-006 Bolt 1; fake identity contract; test navigation shell. Hosted Entra tenant configuration is not a local TDD prerequisite.
- **Expected files/components:** App entry/router/fake-auth adapter and access profile; entry mockups remain visual references.
- **Tests:** Fake authenticated/unauthenticated/denied cases, session/identity error handling and Playwright smoke E2E.
- **Documentation:** Entry/access help and support procedure.
- **Dependencies:** F-006 Bolt 1; platform; F-001–F-003 scoped authorization.
- **Quality gate:** No capability becomes accessible before approved authentication/authorization succeeds.
- **Traceability:** US-001/US-003; FR-025; SEC-001/SEC-002.

#### T053 [M] Enforce approved feature scopes and test denial paths

- **Objective:** Apply the approved role/action matrix consistently across requester, project approver, department approver and delegate operations.
- **Inputs:** F-006 Bolt 1 matrix; downstream F-001/F-002/F-003 route/actions.
- **Expected files/components:** Candidate authorization policies/middleware and end-to-end role fixtures.
- **Tests:** Allowed/denied matrix, department/project isolation, cross-user access, delegate-scope and Playwright smoke.
- **Documentation:** Access-control test evidence and role administration guide.
- **Dependencies:** T052 and relevant feature Bolts/contracts.
- **Quality gate:** Every protected operation checks server-side authority; UI hiding alone is insufficient.
- **Traceability:** US-003; SEC-002/SEC-003; F-001/F-002/F-003 access dependencies.

#### T054-QG [S] Close F-006 access Bolt

- **Objective:** Verify entry/access security and frontend quality gates.
- **Inputs:** T052/T053, approved security policy and toolchain.
- **Expected files/components:** Security/QA report, access matrix results.
- **Tests:** Lint 0, tests 100%, line >=80%, branch >=75%, mutation >=70%, Playwright smoke >=1; security suite has no unaccepted critical/high findings.
- **Documentation:** Gate report and accepted exceptions.
- **Dependencies:** T052/T053.
- **Quality gate:** Test identity/scope cases pass; no production identity provider or external security sign-off is implied.
- **Traceability:** F-006 US-001–US-003; FR-025/FR-026; SEC-001–SEC-003.

## Quality Gate Summary

Every implementation Bolt above has a distinct `-QG` task. Test-project thresholds are lint errors 0, tests 100% passing, line coverage >=80%, branch coverage >=75%, and scoped mutation >=70%; frontend Bolts additionally require an executable Playwright `@smoke` test. .NET build/xUnit/Coverlet, Angular lint/build/unit, Playwright smoke, Gherkin parser, Redocly, and local Stryker configuration are available. Scaffold checks pass; feature line/branch coverage and mutation score remain unmeasured because feature logic is not implemented. The Angular dev dependency tree reports 14 high audit findings; production dependencies (`npm audit --omit=dev`) report 0. No forced upgrade was applied.

## Readiness and Deferred Scope

- All six features have test-profile requirements decisions, models/contracts/Gherkin/plans, and complete AC-to-scenario mapping. Final local-link/schema validation has passed for the readiness artifacts.
- Source RFP/Baseline and production feature policies remain Draft; do not use synthetic defaults with real users/data or production.
- External ServiceNow/AD/email/Teams integrations remain simulated. “my scaturing”, department delegation, separate close behavior, public signup, and real Entra tenant configuration are excluded.
- Code Bolts are not complete. Begin only with the dependency order below, create the approved sibling Bolt branch, and run the matching RED/GREEN/code gates before proceeding.
- Stryker.NET is installed and configured for Domain/Application scope; feature coverage/mutation gates remain pending until a Bolt adds feature logic.

## Progress Tracking

| Feature/Bolt                         | Tasks     | Status                  | Blocker                                                                             |
| ------------------------------------ | --------- | ----------------------- | ----------------------------------------------------------------------------------- |
| Global source/architecture readiness | T001-T002 | Complete (test only)    | No formal external or production approval is claimed.                               |
| F-001 B1-B5                          | T003-T017 | B1 Complete / B2 Ready  | Code Bolts remain unstarted; follow F-001 plan.                                     |
| F-002 B1-B4                          | T018-T028 | B1 Complete / Sequenced | B2 after F-001 B2; B3 after F-005 B2 and F-002 B2; B4 explicitly excluded.          |
| F-003 B1-B3                          | T029-T036 | B1 Complete / B2 Ready  | B3 follows B2; threshold/limits remain advisory only.                               |
| F-004 B1-B3                          | T037-T043 | B1 Complete / Sequenced | B2 after F-001/F-002 event producers; B3 excluded.                                  |
| F-005 B1-B3                          | T044-T049 | B1 Complete / B2 Ready  | B3 after F-001/F-002 decision handlers; simulator only.                             |
| F-006 B1-B2                          | T050-T054 | B1 Complete / B2 Ready  | Fake identities locally; T053 cross-feature enforcement follows implemented routes. |

**Task count:** 54 numbered tasks including per-Bolt gates. T001/T002 and feature readiness Bolts are complete for test scope; no feature code Bolt is marked complete.

## Work Management Sync

GitHub Projects is the selected tracker for this test project. No issue sync or implementation branch is claimed. Local test-project code Bolts may start; create sibling Bolt refs using `bolt/<feature-name>-bolt-<N>-<slug>` and follow the dependency order in [the resolution plan](blocker-resolution-plan.md).

## Source References

- [F-001 provisional plan](../specs/001-vacation-request-lifecycle/planning/plan.md)
- [F-001 research/decision register](../specs/001-vacation-request-lifecycle/planning/research.md)
- [F-001 requirements](../specs/001-vacation-request-lifecycle/requirements.md)
- [F-001 mockup index](../specs/001-vacation-request-lifecycle/mockups/README.md)
- [F-001 test-profile data model](../specs/001-vacation-request-lifecycle/requirements/data-model.md)
- [F-001 submit/cancel Gherkin](../specs/001-vacation-request-lifecycle/tests/request-lifecycle-test-profile.feature)
- [Synthetic test-profile decisions](../specs/test-project-feature-decisions.md)
- [F-002 requirements](../specs/002-approval-and-delegation/requirements.md)
- [F-002 draft use cases](../docs/legacy/specs/use-cases/UC-001-review-project-requests.md)
- [F-002 provisional domain model](../specs/F-002-approval-workflow/data-model.md)
- [F-002 test-profile domain model](../specs/002-approval-and-delegation/requirements/data-model.md)
- [F-002 Gherkin features](../specs/002-approval-and-delegation/tests/project-request-review.feature)
- [F-002 mockup index](../specs/002-approval-and-delegation/mockups/README.md)
- [F-003 requirements and mockups](../specs/003-demand-and-capacity-visibility/requirements.md)
- [F-004 requirements](../specs/004-notifications-and-escalation/requirements.md)
- [F-005 requirements](../specs/005-organizational-data-and-integrations/requirements.md)
- [F-006 requirements and mockups](../specs/006-application-entry-and-access/requirements.md)
- [Proposed project architecture](../docs/design/architecture/solution-architecture.md)
