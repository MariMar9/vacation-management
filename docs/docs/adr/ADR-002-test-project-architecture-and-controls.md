# ADR-002: Test-Project Architecture and Delivery Controls

## Status

Accepted for the Vacation Management test project only (2026-10-09). This is user-authorized evidence in the Copilot conversation, not formal external, production, legal, regulatory, or security sign-off.

## Context and Problem Statement

The workspace contains a draft RFP and requirements baseline, an unratified constitution template, architecture proposals, and conflicting wizard defaults. T001/T002 need global architecture and delivery decisions so that test-project preparation can proceed without interpreting those decisions as approval of F-001–F-006 business rules or feature readiness.

The user states they are responsible for all roles and delegates the decisions for this test project. The only recorded identity is `MariMar9`, the session/Git display identity; it is not a verified legal identity. The RFP and Requirements Baseline are accepted only as test/discovery references. The decisions below apply only to this test workspace and a possible test environment.

## Decision Drivers

- Keep the initial application understandable and executable as one transactional system.
- Reuse the current wizard candidates where they fit the user-authorized test scope.
- Avoid deploying real external integrations before their owners and contracts are established.
- Make quality and branch policies explicit and remove known configuration conflicts.
- Avoid representing test authorization as production, legal, or regulatory approval.

## Considered Options

- **Option 1: Leave the constitution and wizard choices unresolved.** This preserves proposal status but does not establish a consistent test-project baseline.
- **Option 2: Adopt the user-delegated technical choices for this test project only.** Record decisions with an explicit scope boundary and keep feature policies and production deployment gated.
- **Option 3: Treat source discovery and wizard defaults as formal business approval.** This would overstate the available approval evidence and implicitly decide feature rules.

## Decision Outcome

Chosen: **Option 2**, because the user explicitly authorized T001/T002 decisions for this test project while limiting their significance. The baseline/RFP remain test/discovery references; they do not approve feature policies.

- **Scopes:** backend, frontend, cloud-platform, integration. Do not activate `data` for this transactional application. Retain GitHub Projects.
- **Application:** .NET 8 ASP.NET Core Web API using Controllers, REST/OpenAPI; Angular 20 SPA; modular monolith; Azure SQL with EF Core; native simple CQRS without MediatR; no event sourcing or initial message broker.
- **Integration:** simulate external APIs until F-005 contracts are approved. Consider scheduled workers only after contract decisions. No external system owner is appointed.
- **Identity:** Microsoft Entra ID OIDC for users, managed identity for app-to-Azure access, and GitHub Actions OIDC federation. F-006 authorization policies remain open.
- **Test platform:** Azure Container Apps and Azure SQL as targets only; Terraform, Podman, GitHub Actions, OpenTelemetry to Azure Monitor, and rolling deployment. No resource deployment or real production/UAT deployment is authorized.
- **Promotion:** deploy dev on merge; UAT and Prod require manual environment approval and are not auto-deployed.
- **Branch refs:** `feature/<feature-name>` parent and `bolt/<feature-name>-bolt-<N>-<slug>` Bolt branch. Do not use a child path under the same feature ref because Git cannot represent both refs simultaneously.
- **Quality:** zero lint/format errors, all tests pass, line coverage >= 80%, branch coverage >= 75%, mutation >= 70%, and at least one executable Playwright smoke test for frontend work. Actual commands cannot be executed until manifests and tests exist.
- **Security:** synthetic data only; TLS; Azure-managed encryption at rest; least privilege; VNet/private endpoints as test targets; WAF off in this test scope. Compliance applicability is undetermined and not applicable to the synthetic-data-only test scope; make no GDPR/HIPAA or certification claim.

The canonical decisions are in the [constitution](../../.boltf/memory/constitution.md), the [merged refinement](../../.boltf/memory/refinement-states/merged-refinement.yaml), and the [T001/T002 approval record](../../.boltf/memory/test-project-approval.md).

## Consequences

- **Good:** Global test-project choices are consistent and traceable; sensitive external APIs and feature-specific behavior remain gated until their own contracts and policies are approved.
- **Good:** Manual UAT/Prod approvals, corrected mutation threshold, and a realizable branch naming scheme remove known governance conflicts.
- **Bad:** The stack and controls are not validated by an executable application, Azure deployment, or runnable CI pipeline yet.
- **Bad:** One person fills every RACI role for this test workspace; this is not a substitute for independent ownership or review in a real project.
- **Bad:** Azure Container Apps, VNet, and private endpoint decisions remain target architecture only; cost, sizing, network design, and production controls are not validated.

## More Information

- [T001/T002 test-project approval](../../.boltf/memory/test-project-approval.md)
- [Canonical constitution](../../.boltf/memory/constitution.md)
- [Dependency-ordered blocker plan](../../planning/blocker-resolution-plan.md)
