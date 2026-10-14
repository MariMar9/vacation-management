# Azure DevOps Task Proposal

**Status:** Proposed import manifest; no Azure DevOps work items have been created.
**Scope:** The 24 User Stories present in F-001 through F-006, with two story-specific child-task candidates per story.
**Source status:** Feature specs/RFP/baseline are marked Draft. Story acceptance criteria are conditional; all proposed tasks remain blocked until the relevant requirements, models, contracts, architecture, and approvals are accepted.

## Import Readiness

The task proposal is grouped for the intended hierarchy `Epic → Feature → User Story → Task`. Logical F/US identifiers below are from local specs, not Azure DevOps IDs.

| Required ADO value                 | Current status                                                                                                                                                                                                                                          | Creation handling                                                                                                                                                               |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Organization / project             | Not available in local config or session.                                                                                                                                                                                                               | Must be discovered from an authenticated Azure DevOps connection.                                                                                                               |
| Epic ID/title                      | Not present in the repository artifacts read.                                                                                                                                                                                                           | Must be queried and verified before creating child Features or Tasks.                                                                                                           |
| Feature work item IDs              | No ADO IDs stored in the feature specs/task file.                                                                                                                                                                                                       | Resolve each local F-001..F-006 to the correct ADO Feature work item.                                                                                                           |
| User Story/PBI IDs                 | No ADO IDs stored in the feature specs/task file.                                                                                                                                                                                                       | Resolve each local `F-xxx/US-xxx` to an existing ADO User Story/PBI.                                                                                                            |
| Area Path                          | Not discoverable without reading the parent Feature work item.                                                                                                                                                                                          | Each Task should copy the exact Area Path from its parent Feature as requested.                                                                                                 |
| Iteration Path                     | Not discoverable without reading the parent Feature work item.                                                                                                                                                                                          | Each Task should copy the exact Iteration Path from its parent Feature as requested.                                                                                            |
| Authentication/write capability    | No ADO MCP connector was available. `AZURE_DEVOPS_EXT_PAT`, `AZURE_DEVOPS_ORG`, and `AZURE_DEVOPS_PROJECT` are not set; no project `.env` was found. `az devops configure --list` failed because the CLI could not access the local Azure session file. | No remote writes attempted. Do not paste a PAT into chat. Authenticate/configure locally or enable a supported ADO connector, then query and confirm hierarchy before creation. |
| Repository work-management setting | `.boltf/scopes.yaml` currently says `work-management-tool: github-projects`.                                                                                                                                                                            | This conflicts with the requested ADO target; update/approve the project setting if Azure Boards is now authoritative.                                                          |

Azure DevOps may have a GitHub repository connection in its hosted UI, but this session cannot verify that or use it to write Boards work items. This proposal leaves all ADO IDs and inherited paths explicitly unresolved rather than creating orphaned or misclassified Tasks.

## Estimate and Field Conventions

- Estimates are provisional **Original Estimate hours**, not commitments: implementation task = 6h; verification/documentation task = 3h. Re-estimate with the assigned team after approval and architecture/toolchain selection.
- Task Area Path: **inherit exact `System.AreaPath` from parent Feature** at import time; do not use a guessed project default.
- Task Iteration Path: **inherit exact `System.IterationPath` from parent Feature** at import time; do not assign a sprint without the parent's approved iteration.
- Parent link: `System.LinkTypes.Hierarchy-Reverse` to the corresponding User Story/PBI. The logical parent is recorded; numeric ADO ID is **TBD**.
- Task IDs below are local proposal keys only; Azure DevOps will allocate work item IDs.
- Proposed tags: `Bolt Framework; F-xxx; US-xxx`. No priority is invented because the approved backlog priority is absent.
- Acceptance criteria restate or operationalize only the story's current conditional AC. A task with an unresolved policy is blocked until its decision is approved.

## 1. Feature F-001 – Vacation Request Lifecycle

Feature status: Draft. The provisional feature plan has five Bolts; there is no approved F-001 model, API contract, or Gherkin. Only a draft requester list mockup exists. Request fields, lifecycle, cancellation eligibility/effects, history range/statuses, and alternative-period meaning remain unresolved.

### User Story F-001 / US-001 – Submit a vacation request

#### Task F001-US001-T01 – Implement approved request submission

- **Title:** F-001 US-001: Implement vacation request submission using the approved contract
- **Detailed description:** After the request fields, date semantics, validations, initial state, API contract, persistence model, identity policy, and UX are approved, implement the requester form and submission path. Use the selected application stack and module boundaries; do not infer any field or default from the mockups.
- **Acceptance Criteria:** Given the approved field/validation contract, a valid request is persisted once and made available to the approved review process; invalid requests receive only the approved validation response; no unapproved field/state is introduced.
- **Estimated effort:** 6h provisional; refine after design/stack approval.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** Approved F-001 model/contract; identity decision F-006; architecture/stack; feature design.
- **Tags:** `Bolt Framework; F-001; US-001`

#### Task F001-US001-T02 – Verify and document request submission

- **Title:** F-001 US-001: Test submission validation and publish requester guidance
- **Detailed description:** Add domain/API/UI tests for approved valid and invalid cases, date boundaries, authorization, duplicate behavior if defined, and persistence failure. Update field/help/error documentation and link tests to the accepted story AC. Deploy to the agreed UAT environment for business walkthrough when available.
- **Acceptance Criteria:** AC-001.1 passes with approved test data; AC-001.2 is closed only after field/validation decisions; tests pass and requester guidance matches the accepted contract.
- **Estimated effort:** 3h provisional; refine with QA/PO.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F001-US001-T01; approved AC/test data; QA and UAT access.
- **Tags:** `Bolt Framework; F-001; US-001`

### User Story F-001 / US-002 – Cancel my request

#### Task F001-US002-T01 – Implement eligible own-request cancellation

- **Title:** F-001 US-002: Implement cancellation for approved eligible request states
- **Detailed description:** Implement the cancel action and request-state transition only for states named by the approved cancellation policy. Enforce request ownership server-side and connect any approved cancellation event contract; do not infer confirmation, reversal, or notification behavior.
- **Acceptance Criteria:** An authorized requester can cancel an eligible own request and the approved cancelled outcome is persisted; ineligible state behavior follows the approved policy; another user's request cannot be cancelled.
- **Estimated effort:** 6h provisional; refine after lifecycle policy approval.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** Approved cancellation transitions/effects; F-001 request model; F-006 authorization; F-004 event contract if included.
- **Tags:** `Bolt Framework; F-001; US-002`

#### Task F001-US002-T02 – Verify cancellation ownership and outcomes

- **Title:** F-001 US-002: Test cancellation eligibility, ownership, and failure handling
- **Detailed description:** Add state-matrix tests for every approved cancellable/non-cancellable state, owner-versus-other-user authorization tests, stale/concurrent update and persistence-failure tests, plus an E2E/UAT case for the accepted cancellation path. Document the final state/effects and denial messages.
- **Acceptance Criteria:** AC-002.1 matches the approved cancellation rules; AC-002.2 proves one user cannot cancel another's request; failed or denied cancellation does not alter the record.
- **Estimated effort:** 3h provisional; refine after test matrix is baselined.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F001-US002-T01; approved eligible-state matrix; identity test fixtures.
- **Tags:** `Bolt Framework; F-001; US-002`

### User Story F-001 / US-003 – Consult my vacation history and outcomes

#### Task F001-US003-T01 – Implement requester history and outcome view

- **Title:** F-001 US-003: Implement own-request history and approved/non-approved views
- **Detailed description:** Implement a scoped query and responsive list/calendar presentation using approved status categories, history range, and “taken” definition. Materialize the draft `my-requests` default/empty/loading/error design states only after the user-visible labels and data contract are approved.
- **Acceptance Criteria:** The requester sees only their own records; approved/non-approved requests are separated according to approved status definitions; historical periods match the approved range and “taken” rule.
- **Estimated effort:** 6h provisional; refine after query and UX design.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** Approved status/history model, request query contract, identity scope, frontend design.
- **Tags:** `Bolt Framework; F-001; US-003`

#### Task F001-US003-T02 – Verify history, status mapping, and responsive states

- **Title:** F-001 US-003: Test history boundaries, status visibility, and requester states
- **Detailed description:** Test approved/non-approved mapping, date/history boundary cases, empty/loading/error responses, cross-user denial, keyboard/accessibility requirements, and representative responsive viewports. Update user guidance and UI-to-AC traceability; execute a UAT walkthrough.
- **Acceptance Criteria:** AC-003.1 and AC-003.2 pass using the stakeholder-approved reference dataset/range; no unknown status or out-of-scope user's history is displayed.
- **Estimated effort:** 3h provisional; refine with QA/UX.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F001-US003-T01; approved history reference data and accessibility criteria.
- **Tags:** `Bolt Framework; F-001; US-003`

### User Story F-001 / US-004 – Follow cancellation and alternative-period behavior

#### Task F001-US004-T01 – Implement approved cancellation/rejection follow-up boundary

- **Title:** F-001 US-004: Apply approved cancellation and alternative-period interpretation
- **Detailed description:** Implement only the stakeholder-approved cancellation lifecycle effects and FR-024 interpretation. If no alternative-period action is approved, ensure no such action is exposed; do not conflate rejection with cancellation or add resubmission behavior without a decision.
- **Acceptance Criteria:** AC-004.1 walkthrough shows the approved cancellation outcome; AC-004.2 matches the explicit FR-024 decision; no alternative-period behavior is inferred.
- **Estimated effort:** 6h provisional; conditional on policy scope.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F001-US002-T01; F-002 rejection contract; stakeholder disposition of FR-024.
- **Tags:** `Bolt Framework; F-001; US-004`

#### Task F001-US004-T02 – Validate and document cancellation process boundaries

- **Title:** F-001 US-004: Validate cancellation and no-alternative behavior with business users
- **Detailed description:** Add scenario/UAT coverage for approved cancellation outcomes and the accepted no-alternative or explicitly defined interpretation. Update the process guide and record open/declined cases for approver/requester support.
- **Acceptance Criteria:** Business walkthrough evidence exists for AC-004.1; AC-004.2 is verified against the signed FR-024 interpretation; no undocumented alternative action remains.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-001 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-001 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F001-US004-T01; approved process decision and UAT participants.
- **Tags:** `Bolt Framework; F-001; US-004`

## 2. Feature F-002 – Approval and Delegation

Feature work items and stories: ADO IDs are not locally recorded. Existing six Gherkin files are drafts; model/state artifacts are provisional. Each task depends on approval of the applicable role, scope, decision, delegation, and finality rule.

### User Story F-002 / US-001 – Review project requests

#### Task F002-US001-T01 – Implement project-scoped request review

- **Title:** F-002 US-001: Display requests within the approved project scope
- **Detailed description:** Implement project mapping resolution, request list/detail retrieval and role-scoped navigation against F-001/F-005/F-006 contracts. Use the accepted review mockup; do not expose data when the mapping is missing, stale, or outside scope.
- **Acceptance Criteria:** AC-001.1: an authorized approver sees requests associated with their mapped project. AC-001.2: out-of-scope records/details are never exposed.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** Approved project membership/approver mapping, F-001 request query, F-006 access contract.
- **Tags:** `Bolt Framework; F-002; US-001`

#### Task F002-US001-T02 – Verify review scope, errors, and documentation

- **Title:** F-002 US-001: Test in-scope review, empty data, and denied access
- **Detailed description:** Execute project-specific Gherkin cases for assigned project, empty list, multiple scopes, missing/ambiguous mapping, unavailable data and out-of-scope denial. Document filters/status display and support behavior.
- **Acceptance Criteria:** Every approved US-001 AC has passing scenario evidence; no unverified data is represented as complete; denied scope reveals no request details.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F002-US001-T01; approved F-005 mapping and test fixture.
- **Tags:** `Bolt Framework; F-002; US-001`

### User Story F-002 / US-002 – Record an approval or rejection

#### Task F002-US002-T01 – Record level-specific decision outcomes

- **Title:** F-002 US-002: Record authorized project and department decisions
- **Detailed description:** Implement approved project/department approval and project rejection commands, request eligibility checks, persistence, and outcome handoff. Keep level outcomes distinct; do not mark the request finally approved unless the approved required-approver rule says so.
- **Acceptance Criteria:** AC-002.1 records the outcome at its approved level; AC-002.2 records rejection only for an authorized project approver and follows the approved reason/follow-up policy.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F-002 workflow/finality decision; F-001 eligibility contract; F-006 authorization; F-004 event contract if applicable.
- **Tags:** `Bolt Framework; F-002; US-002`

#### Task F002-US002-T02 – Test decision authorization, persistence, and audit

- **Title:** F-002 US-002: Verify decision outcomes and denial/failure cases
- **Detailed description:** Test project and department outcomes, ineligible/stale request denial, unauthorized actor, persistence failure, and actor attribution required by approved policy. Update decision API docs, state model and story traceability.
- **Acceptance Criteria:** AC-002.1/002.2 pass with approved policy; unauthorized/stale decisions create no outcome; each persisted outcome is attributable as required.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F002-US002-T01; approved state/actor matrix; F-004 tests if event emitted.
- **Tags:** `Bolt Framework; F-002; US-002`

### User Story F-002 / US-003 – Assess or close if distinct

#### Task F002-US003-T01 – Implement only approved assess/close actions

- **Title:** F-002 US-003: Implement stakeholder-defined assessment or close behavior
- **Detailed description:** Do not code until “valorar” and “close” have approved meanings, actors, inputs, eligible states and outcomes. If either is out of scope, retain no action in UI/API and record the decision.
- **Acceptance Criteria:** AC-003.1/003.2 are demonstrated only after stakeholder definitions; undefined actions do not change request state or imply approval/rejection.
- **Estimated effort:** 4h provisional after decision; currently blocked.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** Approved Q-008 decision; F-001 request lifecycle; approved F-006 action policy.
- **Tags:** `Bolt Framework; F-002; US-003`

#### Task F002-US003-T02 – Verify approved or omitted assess/close actions

- **Title:** F-002 US-003: Add walkthrough, tests, and decision documentation
- **Detailed description:** For each action approved, add input/state/authorization tests and a business walkthrough; for each action rejected/deferred, test that it is not offered and document the omission.
- **Acceptance Criteria:** The walkthrough proves only the approved action/outcome; missing input or denied actor leaves the request unchanged; deferred behavior is not reported as complete.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F002-US003-T01; business sign-off on FR-008/FR-009.
- **Tags:** `Bolt Framework; F-002; US-003`

### User Story F-002 / US-004 – Delegate an approval

#### Task F002-US004-T01 – Grant same-project delegation under approved policy

- **Title:** F-002 US-004: Grant eligible same-project approval delegation
- **Detailed description:** Implement the approved delegation scope, duration, acceptance/activation and permitted actions, verifying delegator authority and project membership. Preserve actual actor/delegation context only as required by approved audit rules.
- **Acceptance Criteria:** AC-004.1 allows an eligible same-project delegate only within approved scope; AC-004.2 attribution matches the approved audit policy; invalid/unverified membership makes no authority change.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F-002 delegation policy, F-005 project membership, F-006 access matrix.
- **Tags:** `Bolt Framework; F-002; US-004`

#### Task F002-US004-T02 – Test delegation boundaries and attribution

- **Title:** F-002 US-004: Verify same-project eligibility, denial, and audit behavior
- **Detailed description:** Add scenarios for valid grant, out-of-project/ineligible delegate, unauthorized delegator, unverifiable data, policy bounds, required confirmation, persistence failure, and delegated decision attribution. Update support/audit documentation.
- **Acceptance Criteria:** Delegation never activates outside approved scope/validity; denied grants change no authority; recorded decisions identify the acting delegate/context required by policy.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F002-US004-T01 and approved F-005 membership test set.
- **Tags:** `Bolt Framework; F-002; US-004`

### User Story F-002 / US-005 – Resolve approver responsibility

#### Task F002-US005-T01 – Resolve approver from approved assignment source

- **Title:** F-002 US-005: Resolve designated project approver from approved mapping
- **Detailed description:** Implement lookup against the owner-approved project-to-approver mapping and allowed cardinality. Do not invent department-size staffing policy, “responsible” role meaning, or behavior for unresolved assignments.
- **Acceptance Criteria:** AC-005.1 resolves the designated approver for an agreed project; missing/multiple/conflicting mappings follow the approved behavior and never select arbitrarily.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-005 ID TBD → this Task.
- **Dependencies:** F-005 INT-003/INT-004 contract; F-006 role/scope model; Q-007/Q-014 decisions.
- **Tags:** `Bolt Framework; F-002; US-005`

#### Task F002-US005-T02 – Verify mapping failures and staffing-rule disposition

- **Title:** F-002 US-005: Test approver mapping conflicts and document FR-030/FR-031 decisions
- **Detailed description:** Test missing, multiple, conflicting, stale and unavailable mappings plus denial when a source record does not grant authorization. Record whether FR-030/FR-031 are committed before testing those policies.
- **Acceptance Criteria:** AC-005.1 mapping behavior has reference-data evidence; AC-005.2 is tested only for stakeholder-approved delegation breadth/staffing rule; no arbitrary approver or access is granted.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-002 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-002 ID TBD → User Story US-005 ID TBD → this Task.
- **Dependencies:** F002-US005-T01; F-005 data-owner mapping; Q-005/Q-007/Q-014 decisions.
- **Tags:** `Bolt Framework; F-002; US-005`

## 3. Feature F-003 – Demand and Capacity Visibility

Feature status: Draft. No F-003 plan/Gherkin/model/contract exists; the demand mockup contains disabled scope/period controls and placeholder calculations.

### User Story F-003 / US-001 – View department vacation count

#### Task F003-US001-T01 – Calculate and display department count

- **Title:** F-003 US-001: Implement department count for an approved period
- **Detailed description:** Query source-owned department membership and approved request/vacation records using the approved “on vacation” definition, period boundaries, and freshness contract; render selected scope/period and count.
- **Acceptance Criteria:** AC-001.1 count matches the owner-approved reference dataset; AC-001.2 selected scope/period/freshness are visible according to approved rules.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** Approved F-003 count semantics; F-001 states; F-005 membership source; F-006 access.
- **Tags:** `Bolt Framework; F-003; US-001`

#### Task F003-US001-T02 – Validate department count and data states

- **Title:** F-003 US-001: Test department count against reference data and document freshness
- **Detailed description:** Add tests for approved period boundaries, membership changes, empty/stale/unavailable data and count parity. Document selected scope/period and support behavior.
- **Acceptance Criteria:** Approved reference dataset comparison passes; stale/unverified values are not represented as current; errors and empty results follow approved behavior.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F003-US001-T01; data owner sample set and NFR targets.
- **Tags:** `Bolt Framework; F-003; US-001`

### User Story F-003 / US-002 – Inspect demand by scope and period

#### Task F003-US002-T01 – Implement approved scope and period selection

- **Title:** F-003 US-002: Add approved organizational scope and period filters
- **Detailed description:** Implement only hierarchy levels and day/week/date semantics approved by business/data owners; connect filters to the demand query and display the selected scope/period.
- **Acceptance Criteria:** AC-002.1 count matches the agreed dataset; AC-002.2 selectable scopes and period behavior match the approved model.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** Approved organization hierarchy, period semantics, F-005 membership and F-006 scope authorization.
- **Tags:** `Bolt Framework; F-003; US-002`

#### Task F003-US002-T02 – Test scope/period filters and accessibility

- **Title:** F-003 US-002: Verify approved scope-period combinations and responsive controls
- **Detailed description:** Test permitted scope choices, invalid combinations, period boundaries, time zones if defined, data freshness and keyboard/screen-reader behavior; update user help and filter rules.
- **Acceptance Criteria:** Only approved scope/period combinations are available; selected context is clear; results conform to reference dataset and accessibility criteria.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F003-US002-T01; approved hierarchy and usability criteria.
- **Tags:** `Bolt Framework; F-003; US-002`

### User Story F-003 / US-003 – Identify concentrated demand

#### Task F003-US003-T01 – Implement approved demand threshold visualization

- **Title:** F-003 US-003: Highlight periods meeting the approved excess-demand rule
- **Detailed description:** Implement the approved numerator/denominator, request-state inclusion and threshold interpretation; visually distinguish only periods satisfying that rule. Do not encode 70% unless accepted as policy.
- **Acceptance Criteria:** AC-003.1 periods meeting the approved calculation are distinguishable; AC-003.2 July example follows its approved fixed/illustrative disposition.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** Approved calculation/threshold; F-001 statuses; F-005 membership; F-003 US-001/US-002.
- **Tags:** `Bolt Framework; F-003; US-003`

#### Task F003-US003-T02 – Validate threshold boundaries and visual distinction

- **Title:** F-003 US-003: Test threshold boundary data and document the July example
- **Detailed description:** Add reference cases below/at/above the approved threshold and excluded statuses; validate visual distinction with approvers, accessibility and responsive presentation; record whether 70% is binding.
- **Acceptance Criteria:** Calculation matches approved dataset for each boundary; only qualifying periods receive the approved indicator; July treatment is documented.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F003-US003-T01; approved threshold/reference data and visual acceptance criteria.
- **Tags:** `Bolt Framework; F-003; US-003`

### User Story F-003 / US-004 – Manage concurrent-vacation capacity

#### Task F003-US004-T01 – Implement approved capacity configuration

- **Title:** F-003 US-004: Configure the approved concurrent-vacation limit
- **Detailed description:** Implement only if an owner, scope, period, authorized actor and limit behavior are approved. Store/apply the limit according to the accepted policy; do not assume blocking, warning, or display-only behavior.
- **Acceptance Criteria:** AC-004.1 approved actor changes the value for the defined scope/period; persisted value is reflected in the demand view.
- **Estimated effort:** 6h provisional; blocked until policy approved.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** Approved FR-019 ownership/scope/enforcement; F-006 authorization; F-003 calculation model.
- **Tags:** `Bolt Framework; F-003; US-004`

#### Task F003-US004-T02 – Test limit authorization and exceeded behavior

- **Title:** F-003 US-004: Verify capacity limit updates and approved exceedance response
- **Detailed description:** Test role denial, scope/period boundaries, update persistence and the specifically approved response when a limit is exceeded; document the operational owner and configuration procedure.
- **Acceptance Criteria:** AC-004.2 outcome matches explicit stakeholder decision; unauthorized actors cannot change limits; failure does not leave partial configuration.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-003 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-003 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F003-US004-T01; approved authorization and capacity rules.
- **Tags:** `Bolt Framework; F-003; US-004`

## 4. Feature F-004 – Notifications and Escalation

Feature status: Draft. Email is named; Teams is optional/draft. Event, finality, recipient, timeout, retry/delivery and retention policies need approval.

### User Story F-004 / US-001 – Notify requester of approval

#### Task F004-US001-T01 – Deliver approved approval notifications

- **Title:** F-004 US-001: Send approval notification for the approved event trigger
- **Detailed description:** Consume the approved approval event, resolve the requester recipient, render approved content and send through the approved channel with deduplication/failure behavior.
- **Acceptance Criteria:** AC-001.1/001.2: the defined approval event reaches the defined requester through the accepted channel; notification timing is tied to the approved intermediate/final decision.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F-001 request event, F-002 approval/finality decision, F-005 email contract.
- **Tags:** `Bolt Framework; F-004; US-001`

#### Task F004-US001-T02 – Test recipient, delivery, and approval event documentation

- **Title:** F-004 US-001: Verify approval notification trigger and delivery evidence
- **Detailed description:** Test eligible/non-trigger approval outcomes, recipient resolution, duplicate/failure paths and approved content; update event catalog and support/replay instructions.
- **Acceptance Criteria:** Only the approved trigger sends a message; recipient/content/channel match signed event definition; delivery evidence is observable under approved retention.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F004-US001-T01; event and email owner acceptance.
- **Tags:** `Bolt Framework; F-004; US-001`

### User Story F-004 / US-002 – Notify requester of cancellation

#### Task F004-US002-T01 – Deliver approved cancellation notifications

- **Title:** F-004 US-002: Send requester cancellation notification for approved cancellation events
- **Detailed description:** Consume only stakeholder-approved cancellation events and notify the defined requester through the approved channel; do not infer whether approver/system cancellation is included.
- **Acceptance Criteria:** AC-002.1/002.2: defined cancellation event maps to the approved recipient/channel/content; excluded cancellation types do not notify.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F-001 cancellation event policy; F-005 email contract; F-004 event catalogue.
- **Tags:** `Bolt Framework; F-004; US-002`

#### Task F004-US002-T02 – Verify cancellation event recipients and failure handling

- **Title:** F-004 US-002: Test cancellation notification cases and update support guidance
- **Detailed description:** Test user-initiated and any explicitly approved non-user cancellation event, recipient mapping, duplicate/failure recovery and audit evidence. Document excluded event classes.
- **Acceptance Criteria:** Requester receives only defined cancellation notifications; failure/delivery evidence follows the approved contract; no unapproved case is messaged.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F004-US002-T01; F-001 event contract.
- **Tags:** `Bolt Framework; F-004; US-002`

### User Story F-004 / US-003 – Escalate an unapproved request

#### Task F004-US003-T01 – Implement approved unapproved-request timeout evaluator

- **Title:** F-004 US-003: Detect requests exceeding the approved approval timeout
- **Detailed description:** Implement the scheduled/event-driven evaluator with approved start state, timeout, required approval predicate, department approver recipient and escalation action.
- **Acceptance Criteria:** AC-003.1 alarm is produced only after the approved timeout for an eligible request lacking required approval; alarm does not change decision authority.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F-002 approval/finality/assignment; F-005 data; approved timeout and channel contract.
- **Tags:** `Bolt Framework; F-004; US-003`

#### Task F004-US003-T02 – Test timeout, suppression, repeat, and recovery

- **Title:** F-004 US-003: Validate escalation timing and operational recovery
- **Detailed description:** Test clock boundaries, decision suppression, repeat limits, schedule drift, retry/idempotency and missing-recipient handling; document operator runbook and metrics.
- **Acceptance Criteria:** AC-003.2 suppression/repeat/authority match the approved escalation policy; failed processing is visible and safely recoverable.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F004-US003-T01; scheduler/operations environment and approved NFRs.
- **Tags:** `Bolt Framework; F-004; US-003`

### User Story F-004 / US-004 – Use optional channels when approved

#### Task F004-US004-T01 – Implement approved optional Teams/card delivery

- **Title:** F-004 US-004: Add Teams or adaptive-card delivery only if approved
- **Detailed description:** Implement only the optional channel/capability explicitly approved, including event, recipient, content/link, identity, enablement and retention settings. Otherwise record explicit exclusion and add no runtime dependency.
- **Acceptance Criteria:** AC-004.1 reaches approved recipient/content only when Teams is approved/enabled; AC-004.2 cards are not treated as accepted before stage/purpose/behavior approval.
- **Estimated effort:** 6h provisional; conditional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F-004 event catalogue; F-006 identity; F-005 channel interface and Q-019 decision.
- **Tags:** `Bolt Framework; F-004; US-004`

#### Task F004-US004-T02 – Validate optional-channel controls or exclusion

- **Title:** F-004 US-004: Test optional channel policy and document rollout decision
- **Detailed description:** If approved, test enable/disable, recipient, payload, deep link, failure, privacy and audit; if deferred, verify no mandatory Teams/card dependency and document the decision.
- **Acceptance Criteria:** Optional channel is off/absent unless approved; enabled delivery satisfies approved content and recipient policy; release docs state its status.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-004 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-004 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F004-US004-T01; channel/system owner and security review.
- **Tags:** `Bolt Framework; F-004; US-004`

## 5. Feature F-005 – Organizational Data and Integrations

Feature status: Draft. ServiceNow/AD are named sources/destination, but product APIs, field mappings, system owners, cadence, security and reconciliation are unresolved.

### User Story F-005 / US-001 – Retrieve department membership

#### Task F005-US001-T01 – Import approved ServiceNow department membership

- **Title:** F-005 US-001: Retrieve and map approved department membership records
- **Detailed description:** Implement the owner-approved interface and mapping for department membership, including schedule/freshness only after signed contract. Store/refresh the agreed dataset without inventing identifiers or fields.
- **Acceptance Criteria:** AC-001.1 retrieved membership matches the approved ServiceNow reference records for the agreed department; no unapproved mapping is used.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** ServiceNow owner, F-003/F-006 department boundary, approved INT-001 contract.
- **Tags:** `Bolt Framework; F-005; US-001`

#### Task F005-US001-T02 – Test membership mapping and unavailable-source behavior

- **Title:** F-005 US-001: Validate membership reconciliation, freshness, and failure documentation
- **Detailed description:** Test reference membership, missing/inconsistent records, schedule/freshness and recovery; document source mapping, runbook and data exceptions.
- **Acceptance Criteria:** AC-001.2 schedule/freshness/error behavior matches system-owner approval; mismatches are visible and reconcilable.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F005-US001-T01; approved sample dataset and integration test environment.
- **Tags:** `Bolt Framework; F-005; US-001`

### User Story F-005 / US-002 – Retrieve organization and approver data

#### Task F005-US002-T01 – Import approved organizational/project responsibility data

- **Title:** F-005 US-002: Map approved Active Directory organization and approver attributes
- **Detailed description:** Build the agreed AD connector and mapping for organizational hierarchy, project approver, and project membership/reporting relationships; require explicit attribute ownership and cardinality decisions.
- **Acceptance Criteria:** AC-002.1 agreed test organization/project resolves to expected records; only approved attributes/relationships are consumed.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** AD/system owner; F-002 approver responsibility; approved hierarchy and INT-002–INT-004 mappings.
- **Tags:** `Bolt Framework; F-005; US-002`

#### Task F005-US002-T02 – Verify directory mapping cardinality and data errors

- **Title:** F-005 US-002: Test approved directory mapping and document conflict handling
- **Detailed description:** Test expected hierarchy/members, missing/multiple/conflicting mappings and stale/unavailable source; reconcile with F-002 resolver and F-003 scope filters; document recovery and mapping evidence.
- **Acceptance Criteria:** AC-002.2 approved membership interpretation/cardinality/failure behavior is demonstrated; no arbitrary approver or relationship is selected.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F005-US002-T01; F-002/F-003 contracts and owner-approved data fixture.
- **Tags:** `Bolt Framework; F-005; US-002`

### User Story F-005 / US-003 – Export fully approved vacations

#### Task F005-US003-T01 – Implement approved-only ServiceNow export

- **Title:** F-005 US-003: Export vacations that meet the approved final-approval rule
- **Detailed description:** Implement the agreed export selector, mapping, destination call and durable delivery status. Exclude any request missing a stakeholder-defined required approval; do not infer finality or cadence.
- **Acceptance Criteria:** AC-003.1 mapped eligible record reaches the approved destination; AC-003.2 records missing any required approval are excluded.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F-001 request data; F-002 approved finality/required approver policy; ServiceNow export contract; identity/secret approval.
- **Tags:** `Bolt Framework; F-005; US-003`

#### Task F005-US003-T02 – Test export acknowledgements, duplicates, and reconciliation

- **Title:** F-005 US-003: Verify approved-only export and document recovery procedure
- **Detailed description:** Test eligible/ineligible inclusion, payload mapping, acknowledgements, duplicate/idempotency, failure replay, correction and reconciliation; document operator and data-owner responsibilities.
- **Acceptance Criteria:** AC-003.1/003.2 pass against reference records; retries do not create unapproved duplicates; all rejected/unmatched results are actionable.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F005-US003-T01; ServiceNow test endpoint; F-001/F-002 test data.
- **Tags:** `Bolt Framework; F-005; US-003`

### User Story F-005 / US-004 – Exchange updates on agreed cadence

#### Task F005-US004-T01 – Implement approved scheduled exchange

- **Title:** F-005 US-004: Schedule approved organizational data update flows
- **Detailed description:** Implement only the owner-approved sources, datasets, directions, and schedule, keeping outbound export cadence separate unless explicitly combined. Exclude “my scaturing” unless identified and approved.
- **Acceptance Criteria:** AC-004.1 scheduled exchange updates the agreed dataset and records source/destination reconciliation; AC-004.2 uncertain source remains excluded until confirmed.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F-005 US-001/US-002 contracts, environment/scheduler, data owners and NFR-007 freshness decision.
- **Tags:** `Bolt Framework; F-005; US-004`

#### Task F005-US004-T02 – Verify schedule, idempotency, and source reconciliation

- **Title:** F-005 US-004: Test scheduled exchange recovery and document operations
- **Detailed description:** Test timing, restart/replay, repeated run, partial failure, stale source and reconciliation; document schedule ownership, alerting and recovery. Record a formal exclusion for unidentified “my scaturing.”
- **Acceptance Criteria:** AC-004.1 updates and reconciles the approved dataset; AC-004.2 candidate integration is not silently enabled.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-005 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-005 ID TBD → User Story US-004 ID TBD → this Task.
- **Dependencies:** F005-US004-T01; operations and external source owners.
- **Tags:** `Bolt Framework; F-005; US-004`

## 6. Feature F-006 – Application Entry and Access

Feature status: Draft. Link entry is described; authentication/role policies and trial meaning/audience are unapproved. Existing mockups cover entry default/error only.

### User Story F-006 / US-001 – Open the application from a link

#### Task F006-US001-T01 – Implement approved link entry and identity handoff

- **Title:** F-006 US-001: Route an eligible user from the approved application link
- **Detailed description:** Configure the approved entry URL and selected identity handoff, reaching only the entry point/capabilities allowed by the approved user population and authentication policy.
- **Acceptance Criteria:** AC-001.1 stakeholder-approved link opens the entry point for an eligible user and applies the approved authentication behavior; AC-001.2 uses the approved unauthenticated/access behavior.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-006 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F-006 identity/eligible population decision, platform routing and security contract.
- **Tags:** `Bolt Framework; F-006; US-001`

#### Task F006-US001-T02 – Test link routing and access/error behavior

- **Title:** F-006 US-001: Verify approved link, eligible audience, and denied entry
- **Detailed description:** Test link route, eligible/unauthenticated/ineligible actor paths and accessible error response; document user support/recovery and supported clients.
- **Acceptance Criteria:** Entry behavior matches approved authentication/access policy; no role chooser or sign-in method is assumed; denied users see no protected capability.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-006 ID TBD → User Story US-001 ID TBD → this Task.
- **Dependencies:** F006-US001-T01; security-approved test accounts and supported-client list.
- **Tags:** `Bolt Framework; F-006; US-001`

### User Story F-006 / US-002 – Participate in initial link-based trial

#### Task F006-US002-T01 – Configure the approved trial entry

- **Title:** F-006 US-002: Enable the approved trial audience and environment
- **Detailed description:** Only after “try” is defined as pilot/test/other and audience, environment, data, duration and permitted actions are approved, configure the trial link/access boundary.
- **Acceptance Criteria:** AC-002.1 approved participants reach the defined trial; AC-002.2 no environment, dataset, duration or capability is treated as accepted before explicit definition.
- **Estimated effort:** 4h provisional; blocked until trial policy is approved.
- **Area Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-006 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F-006 US-001 entry; sponsor/security approval; environment and trial data readiness.
- **Tags:** `Bolt Framework; F-006; US-002`

#### Task F006-US002-T02 – Validate trial scope, duration, and exit

- **Title:** F-006 US-002: Test trial eligibility and document pilot controls
- **Detailed description:** Verify approved audience, environment separation, data restrictions, permitted actions, duration/expiry and trial exit/feedback process; create operator/user guidance.
- **Acceptance Criteria:** Only approved participants/capabilities are available for the signed duration; no production/test distinction or trial rule is inferred.
- **Estimated effort:** 3h provisional.
- **Area Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-006 ID TBD → User Story US-002 ID TBD → this Task.
- **Dependencies:** F006-US002-T01; security/privacy and business pilot owner.
- **Tags:** `Bolt Framework; F-006; US-002`

### User Story F-006 / US-003 – Access only authorized capabilities

#### Task F006-US003-T01 – Enforce approved identity and role/action policy

- **Title:** F-006 US-003: Apply approved role, scope, and department access controls
- **Detailed description:** Implement server-side authorization for requester, project approver, department approver and delegate actions from the approved matrix; integrate approved identity and department/project scope source.
- **Acceptance Criteria:** AC-003.1 each approved role/action permission is implemented; AC-003.2 department isolation, cross-project visibility, delegation and security controls match approved decisions.
- **Estimated effort:** 6h provisional.
- **Area Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-006 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F-006 approved identity/RBAC; F-005 membership mapping; F-001/F-002/F-003 protected operation contracts.
- **Tags:** `Bolt Framework; F-006; US-003`

#### Task F006-US003-T02 – Test authorization matrix, isolation, and audit evidence

- **Title:** F-006 US-003: Verify permitted/denied role actions and document access controls
- **Detailed description:** Execute positive/negative tests for all approved roles, department boundary, cross-project access and delegation; verify audit/privacy controls and write role/support guidance.
- **Acceptance Criteria:** Every role/action matrix row has test evidence; unauthorized requests/actions are denied without data disclosure; approved audit controls are evidenced.
- **Estimated effort:** 4h provisional.
- **Area Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Iteration Path:** Inherit exact value from parent Feature F-006 (ADO value TBD).
- **Parent-child:** Epic ID TBD → Feature F-006 ID TBD → User Story US-003 ID TBD → this Task.
- **Dependencies:** F006-US003-T01; approved privacy/security obligations; QA/security test identities.
- **Tags:** `Bolt Framework; F-006; US-003`

## Creation and Validation Gate

This proposal has 24 User Story groups and 48 candidate child Tasks. Before any Azure DevOps writes:

1. Authenticate/configure the Azure DevOps client locally (do not share a PAT in chat); restore or grant access to the local CLI profile or use an authorized ADO connector.
2. Identify and confirm the Epic ID, all six Feature IDs, all 24 User Story IDs, and the ADO process work item types.
3. Read each parent Feature's exact Area Path and Iteration Path and copy those values into its child tasks; verify the team/project accepts inheritance as requested.
4. Resolve the repository setting discrepancy (`github-projects` vs requested Azure Boards) with the project owner.
5. Review provisional hour estimates and candidate acceptance criteria with the assigned team/PO. Do not create items while the specs remain unapproved unless the business owner explicitly authorizes draft backlog creation.
6. Dry-run the generated create payloads, inspect duplicates/parent-child links, then create Tasks and verify each `System.Parent`, Area Path, Iteration Path, tags and work item type.

**Remote write status:** Not performed. No work item was created because the Azure DevOps organization/project, Epic/Feature/User Story IDs, inherited paths and authenticated write connection could not be resolved from this session.
