# Constitution Digest: Vacation Management Test Project

**Status:** Approved for this test project only  
**Effective:** 2026-10-09  
**Evidence:** User-authorized Copilot conversation; not a cryptographic signature  
**Active scopes:** backend, frontend, cloud-platform, integration

## Authority and Scope

- Decision owner for this test workspace: `MariMar9` (session/Git display identity only; not verified legal identity).
- RFP and Requirements Baseline are test/discovery references only; unresolved feature policies remain conditional.
- No formal external sponsor, business, legal, regulatory, security, production, or system-owner sign-off is claimed.
- T001/T002 completion does not approve F-001–F-006 policies, contracts, Gherkin, readiness, or implementation.
- No external real-system owners are appointed; simulate external APIs until F-005 contracts are separately approved.

## Refinement Decision IDs

- Backend: `B-02-03-05-13`.
- Frontend: `FE-02-07-13`.
- Cloud platform: `CP-08-10-11-12-13-16-19`.
- Integration: `INT-04-08`.

## Backend

- C# / ASP.NET Core Web API, .NET 8, Controllers (MVC), REST, OpenAPI.
- Modular monolith; Azure SQL with EF Core.
- Simple CQRS with native interfaces; no MediatR; no event sourcing; no initial message broker.
- Scheduled workers may be considered only after approved contracts.

## Frontend and Identity

- Angular 20 single-page application; no mobile app in this test scope.
- Microsoft Entra ID OIDC for user authentication. This does not resolve F-006 users, roles, authorization, or feature access rules.
- Managed identity for application-to-Azure access; GitHub Actions OIDC federation for CI.

## Cloud and Delivery

- Azure Container Apps and Azure SQL are target services for a test environment only; no resources are implied deployed or authorized.
- Terraform; Podman local orchestration; GitHub Actions; OpenTelemetry to Azure Monitor; GitHub Projects.
- Rolling deployment. Dev deploys on merge. UAT and Prod require manual environment approval and are not auto-deployed; no real UAT/Prod deployment is authorized.
- Branch refs: `feature/<feature-name>` for feature parents and `bolt/<feature-name>-bolt-<N>-<slug>` for Bolt branches. Do not nest Bolt refs beneath feature refs.

## Security and Quality

- Synthetic data only; no real personal, confidential, or regulated data.
- TLS in transit, Azure-managed encryption at rest, least privilege. VNet/private endpoints are test targets; WAF is off in this test scope.
- Compliance is not determined and not applicable to the synthetic-data-only test scope. No GDPR/HIPAA or certification claim.
- Gates where executable projects exist: lint errors 0; tests 100% passing; line coverage >= 80%; branch coverage >= 75%; mutation >= 70%; at least one executable Playwright smoke test for frontend work.
- Candidate commands: `dotnet format --verify-no-changes`, `dotnet test` with Coverlet, Stryker.NET, Angular lint/test, and `npx playwright test --grep @smoke`.
- Actual commands and gates remain unverified until project manifests and tests exist; absent gates are pending, not passed.

**Canonical source:** [.boltf/memory/constitution.md](constitution.md). Read it for governance and amendments. Structured source: [merged-refinement.yaml](refinement-states/merged-refinement.yaml). Approval record: [test-project-approval.md](test-project-approval.md).
