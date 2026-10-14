# T001/T002 Test Project Approval

**Status:** Approved for this test project only  
**Effective date:** 2026-10-09  
**Evidence:** User authorization in this GitHub Copilot conversation; no cryptographic signature or external approval record is asserted.

## Approval Scope

The user states they are responsible for all roles and delegates the T001/T002 decisions to the assistant because this workspace is a test project for exercising functionality. This authorization approves the baseline only as a test/discovery reference and approves the project-level technical decisions captured in [the constitution](constitution.md), [the merged refinement](refinement-states/merged-refinement.yaml), and [ADR-002](../../docs/docs/adr/ADR-002-test-project-architecture-and-controls.md).

This is not formal sponsor, business, legal, regulatory, security, production, or external-system-owner sign-off. No F-001–F-006 feature policy, contract, requirement, Gherkin scenario, or readiness gate is approved by this record.

## Decision Owner and RACI

The only named decision owner for this test workspace is `MariMar9`, recorded as the session/Git display identity from `git config user.name`. This is not a verified legal identity. The user assigns this same decision owner accountability and responsibility for the following test-project roles:

| Decision area                                | Accountable | Responsible | Consulted / informed                |
| -------------------------------------------- | ----------- | ----------- | ----------------------------------- |
| Test-project baseline/reference              | MariMar9    | MariMar9    | None appointed                      |
| Product ownership and feature prioritization | MariMar9    | MariMar9    | None appointed                      |
| Workflow policy                              | MariMar9    | MariMar9    | None appointed                      |
| Data and integration decisions               | MariMar9    | MariMar9    | No external system owners appointed |
| Security and privacy decisions               | MariMar9    | MariMar9    | None appointed                      |
| Architecture and platform                    | MariMar9    | MariMar9    | None appointed                      |
| Release and service ownership                | MariMar9    | MariMar9    | None appointed                      |

No real ServiceNow, Active Directory, email, or other external system owner is appointed. External APIs and systems remain simulated until F-005 contracts and applicable feature behavior are separately approved.

## Baseline Disposition

- `origin/RFP-Vacation-Management.md` and `origin/Requirements-Baseline.md` are accepted only as test/discovery reference inputs.
- Their draft status and unresolved or conditional policies remain unchanged. A baseline statement does not approve a feature rule.
- The project uses synthetic data only. No regulated data, GDPR/HIPAA applicability, certification, or production control compliance is asserted.
- Azure architecture choices apply only to a potential test environment. This record does not authorize real production deployment or provisioning.

## T001/T002 Outcome

- T001 is complete for this test-project scope: the owner, authority assignments, reference-baseline disposition, effective date, and evidence pointer are recorded here.
- T002 is complete for global test-project constitution and architecture decisions: active scopes, stack, target hosting, deployment policy, identity direction, security baseline, branch naming, and quality thresholds are recorded in the linked artifacts.
- Completion clears only these global prerequisites. Every feature-specific Bolt and readiness gate remains blocked pending its own requirements, rules, contracts, scenarios, ownership, and evidence.
