# Vacation Management Test Project Constitution

**Version:** 1.0.0  
**Status:** Approved for this test project only  
**Effective date:** 2026-10-09  
**Evidence:** User-authorized Copilot conversation; not a cryptographic signature  
**Active scopes:** backend, frontend, cloud-platform, integration

## Preamble

This constitution records decisions authorized for this test workspace only. The decision owner is `MariMar9`, the session/Git display identity; it is not a verified legal identity. This is not formal external sponsor, business, legal, regulatory, security, or production sign-off.

The RFP and Requirements Baseline are accepted only as test/discovery references. Unresolved feature policies remain conditional. This constitution does not approve F-001–F-006 requirements, business rules, API contracts, Gherkin, feature readiness, or implementation readiness.

## Article I: Scope and Authority

- Active scopes: `backend`, `frontend`, `cloud-platform`, and `integration`.
- The `data` scope is not active because this is a transactional application, not an analytics platform.
- GitHub Projects remains the work-management tool.
- For this test workspace only, the user assigns `MariMar9` as Sponsor, Product Owner, Workflow Owner, Data/Integration Owner, Security/Privacy Authority, Architecture/Platform Authority, Release Authority, and Service Owner.
- No external real-system owners are appointed; external systems and APIs remain simulated pending approved F-005 contracts.

## Article II: Application Stack and Architecture

### Backend

- C# and ASP.NET Core Web API on .NET 8, using Controllers (MVC), REST, and OpenAPI.
- Use a modular monolith and Azure SQL with Entity Framework Core.
- Use simple CQRS with native interfaces; do not add MediatR. Do not use event sourcing.
- No message broker for the initial test scope. Scheduled integration workers may be considered only after their contracts are approved.

### Frontend

- Use Angular 20 as a single-page application. No mobile application is in this test scope.

### Identity Direction

- Use Microsoft Entra ID with OIDC for user authentication; managed identity for application-to-Azure access; and OIDC federation for GitHub Actions.
- This identity direction does not decide F-006 population, roles, permissions, authorization rules, or feature access behavior.

## Article III: Integration Boundaries

- Use synchronous REST with OpenAPI for application contracts.
- Simulate external APIs, including ServiceNow and Active Directory, until F-005 contracts are separately approved.
- Consider scheduled integration workers only after approved contracts define data, identity, cadence, error handling, and ownership.
- T001/T002 do not approve feature payloads, business rules, events, schedules, or integration contracts.

## Article IV: Cloud and Delivery

- Azure is the target provider for a test environment only. No resource deployment is implied or authorized.
- Target hosting is Azure Container Apps with Azure SQL. Use Terraform for infrastructure as code and Podman for local orchestration.
- Use GitHub Actions for CI/CD and OpenTelemetry to Azure Monitor for test-environment observability.
- Use rolling deployment. Deploy to `dev` on merge. UAT and Prod stages require manual environment approval and are not auto-deployed; they are reserved stages, not authorization for real deployment.

### Branch Naming

- Feature parent: `feature/<feature-name>`.
- Bolt branch: `bolt/<feature-name>-bolt-<N>-<slug>`.
- Do not use `feature/<feature-name>/bolt-<N>` below a parent named `feature/<feature-name>`; Git cannot represent both refs simultaneously.

## Article V: Configuration and Secrets

- Use Azure Key Vault for hosted secrets and .NET User Secrets locally.
- Never commit credentials or secrets. Use environment-specific non-secret configuration.

## Article VI: Quality Gates

Where the corresponding executable projects exist, require lint/format errors `0`, test pass rate `100%`, line coverage at least `80%`, branch coverage at least `75%`, and mutation score at least `70%` using Stryker.NET where applicable. Frontend work additionally requires at least one passing executable Playwright smoke test.

Use `dotnet format --verify-no-changes`, `dotnet test` with Coverlet, and Stryker.NET for .NET; use Angular lint/test and `npx playwright test --grep @smoke` for the frontend. Actual project paths and runnable commands remain unverified until manifests and tests exist. A missing executable gate is pending, not passed.

## Article VII: Security and Data Handling

- Synthetic data only; do not use real personal, confidential, or regulated data.
- Require TLS in transit and Azure-managed encryption keys at rest for the test target. Apply least privilege and managed identities.
- VNet and private endpoints are target controls for a potential Azure test environment; WAF is off for this test environment.
- Compliance applicability is not determined and is not applicable to this synthetic-data-only test scope. Do not claim GDPR/HIPAA applicability, certification, or regulatory compliance.
- These test controls are not production security approval or evidence of deployed controls.

## Article VIII: Feature Readiness Boundary

T001 and T002 completion clears only global governance and technical prerequisites for this test project. All F-001–F-006 feature Bolts remain blocked until applicable feature rules, requirements, contracts, Gherkin, external ownership, and readiness evidence are separately completed. No feature business policy is inferred from this constitution or draft baseline content.

## Governance and Evidence

The approval record is [test-project-approval.md](test-project-approval.md). The structured decision source is [merged-refinement.yaml](refinement-states/merged-refinement.yaml), with per-scope refinements stored alongside it. The architecture decision is [ADR-002](../../docs/docs/adr/ADR-002-test-project-architecture-and-controls.md).

Any future real project, regulated-data use, or production deployment requires new, explicitly scoped authority and approval evidence.

<!-- Legacy unchecked template retained below for reference only. It is non-operative; the approved decisions above govern this test project.
## Article I: Project Scope & Type

> **⚠️ IMPORTANT**: Define the active scopes FIRST. This determines which articles and scope constitutions apply. The project type (Infrastructure / Application / Full Stack) is automatically derived from the selected scopes.

### Section 1.1: Active Scopes

Select ONE or MORE scopes. Each active scope injects its own constitution sections and activates the corresponding articles. Scopes are **combinable** — a typical project activates 2-4 scopes.

|     | Scope              | Description                                                  | Activates                                                                                             |
| --- | ------------------ | ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| [ ] | **backend**        | Server-side APIs, services, domain logic                     | Articles II §2.1, III §3.1/3.3/3.4, IV, V, VI, VII, VIII, XIII §13.1-13.3, XIV, XV (A-D), XVII, XVIII |
| [ ] | **frontend**       | Web/mobile UI, SPA, design system                            | Articles II §2.2-2.3, III §3.2, VII §7.3-7.4, XIII (E2E), XIV, XV (frontend)                          |
| [ ] | **cloud-platform** | Infrastructure, Landing Zones, IaC, platform engineering     | Articles VIII, IX, XII §12.3, XIII §13.4, XV (E-F)                                                    |
| [ ] | **data**           | Databases, ETL/ELT, analytics, data governance               | Articles V, VI                                                                                        |
| [ ] | **integration**    | API management, messaging, external system connectors        | Articles IV, XVII, XVIII                                                                              |
| [ ] | **ai**             | AI/ML models, agents, prompt engineering, responsible AI     | Article XIX §19.2 (emphasis) + AI-specific extensions                                                 |
| [ ] | **crm**            | Dynamics 365, Power Platform, Dataverse, business automation | Article VII                                                                                           |

> **Note**: The `work-management` scope (Azure DevOps, GitHub Projects, Jira synchronization) is **transversal** and managed separately. It does not appear here because it applies to all projects regardless of scope selection.

#### Common Scope Combinations

| Project Profile                     | Recommended Scopes                                                 |
| ----------------------------------- | ------------------------------------------------------------------ |
| REST API microservices              | `backend` + `cloud-platform` + `integration`                       |
| Full-stack web application          | `backend` + `frontend` + `data`                                    |
| AI-powered application              | `backend` + `ai` + `data`                                          |
| Enterprise CRM solution             | `crm` + `integration` + `data`                                     |
| Data platform / analytics           | `data` + `cloud-platform`                                          |
| Landing Zone / platform engineering | `cloud-platform`                                                   |
| Complete enterprise solution        | `backend` + `frontend` + `cloud-platform` + `data` + `integration` |

---

## Article X: Environments & Configuration

> **📋 Applies to**: ALL project types

### Section 10.1: Environment Strategy

| Environment | Purpose                      | Enabled | Auto-Deploy              |
| ----------- | ---------------------------- | ------- | ------------------------ |
| **dev**     | Development, rapid iteration | [ ] Yes | [ ] On commit to develop |
| **uat**     | User Acceptance Testing      | [ ] Yes | [ ] On PR merge          |
| **pre**     | Pre-production, staging      | [ ] Yes | [ ] Manual trigger       |
| **prod**    | Production                   | [ ] Yes | [ ] Manual approval      |

### Section 10.2: Configuration Management

Select strategy:

- [ ] **Azure App Configuration** - Centralized, feature flags (recommended)
- [ ] **Environment Variables** - Container/App Service config
- [ ] **appsettings.{Environment}.json** (.NET) / **.env files** (Node.js)
- [ ] **Combination** - App Config + Key Vault (recommended)

### Section 10.3: Secrets Management

| Secret Type        | Storage         |
| ------------------ | --------------- |
| Connection Strings | Azure Key Vault |
| API Keys           | Azure Key Vault |
| Certificates       | Azure Key Vault |

Local Development Secrets:

- [ ] **User Secrets** (.NET) - `dotnet user-secrets`
- [ ] **.env files** (Node.js) - gitignored
- [ ] **Local Key Vault** - Azure Key Vault dev instance

### Section 10.4: Feature Flags

Feature Flag Provider:

- [ ] **None**
- [ ] **Azure App Configuration** - Native integration
- [ ] **LaunchDarkly** - Enterprise features
- [ ] **Unleash** - Open-source

---

## Article XI: CI/CD Pipeline

> **📋 Applies to**: ALL project types

### Section 11.1: CI/CD Platform

Select ONE:

- [x] **GitHub Actions** - GitHub-native
- [ ] **Azure DevOps Pipelines** - Azure-native

### Section 11.2: Pipeline Stages

#### For Application Development

| Stage                  | Enabled | Threshold                          |
| ---------------------- | ------- | ---------------------------------- |
| **Build**              | [ ] Yes | Warnings as errors: [ ] Yes [ ] No |
| **Lint/Format**        | [ ] Yes | -                                  |
| **Unit Tests**         | [ ] Yes | Coverage >= \_\_%                  |
| **Integration Tests**  | [ ] Yes | -                                  |
| **Architecture Tests** | [ ] Yes | -                                  |
| **Mutation Tests**     | [ ] Yes | Score >= \_\_%                     |
| **Security Scan**      | [ ] Yes | 0 Critical                         |
| **Container Build**    | [ ] Yes | -                                  |
| **Container Scan**     | [ ] Yes | 0 Critical                         |

#### For Infrastructure

| Stage                | Enabled | Threshold           |
| -------------------- | ------- | ------------------- |
| **IaC Lint**         | [ ] Yes | Bicep lint / tflint |
| **IaC Validation**   | [ ] Yes | what-if / plan      |
| **Security Scan**    | [ ] Yes | Checkov / tfsec     |
| **Cost Estimation**  | [ ] Yes | Infracost           |
| **Compliance Check** | [ ] Yes | Azure Policy        |

#### Deployment Stages

| Stage           | Enabled | Trigger            |
| --------------- | ------- | ------------------ |
| **Deploy Dev**  | [ ] Yes | Auto on develop    |
| **Deploy UAT**  | [ ] Yes | Auto on release/\* |
| **Deploy Pre**  | [ ] Yes | Manual trigger     |
| **Deploy Prod** | [ ] Yes | Manual approval    |

### Section 11.3: Deployment Strategy

Select ONE:

- [ ] **Rolling Update** - Gradual replacement
- [ ] **Blue-Green** - Azure Deployment Slots / K8s
- [ ] **Canary** - Gradual traffic shift
- [ ] **Feature Flags** - Deploy dark, enable via flags

### Section 11.4: Branch Strategy

Select ONE:

- [ ] **GitFlow** - feature/, develop, release/, main
- [ ] **GitHub Flow** - feature/, main
- [ ] **Trunk-Based** - Short-lived branches, main

---

## Article XII: Observability

> **📋 Applies to**: ALL project types

### Section 12.1: Observability Strategy

Select ONE:

- [ ] **Azure-Native** - Azure Monitor + Application Insights
- [ ] **OpenTelemetry → Azure** - OTel SDK → Azure Monitor Exporter
- [ ] **OpenTelemetry → Grafana Stack** - Self-hosted Grafana/Loki/Tempo

### Section 12.2: Health Checks

```text
/health       - Full health check
/health/ready - Readiness probe
/health/live  - Liveness probe
```

### Section 12.3: Infrastructure Monitoring (if Infrastructure scope)

| Component       | Tool                      | Enabled |
| --------------- | ------------------------- | ------- |
| Resource Health | Azure Resource Health     | [ ] Yes |
| Activity Logs   | Azure Monitor             | [ ] Yes |
| Diagnostics     | Log Analytics             | [ ] Yes |
| Alerts          | Azure Monitor Alerts      | [ ] Yes |
| Dashboards      | Azure Workbooks / Grafana | [ ] Yes |

---

## Article XVI: Security Policies

> **📋 Applies to**: ALL project types

### Section 16.1: Network Security

| Component                | Configuration                     |
| ------------------------ | --------------------------------- |
| Virtual Network          | [ ] Azure VNet [ ] None           |
| Private Endpoints        | [ ] Enabled [ ] Disabled          |
| Web Application Firewall | [ ] Azure Front Door WAF [ ] None |

### Section 16.2: Data Protection

| Policy                | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Encryption at Rest    | [ ] Azure-managed keys [ ] Customer-managed keys      |
| Encryption in Transit | TLS 1.2+ (mandatory)                                  |
| PII Handling          | [ ] Anonymization [ ] Pseudonymization [ ] Encryption |

### Section 16.3: Compliance Requirements

| Standard | Required       |
| -------- | -------------- |
| GDPR     | [ ] Yes [ ] No |
| HIPAA    | [ ] Yes [ ] No |
| SOC 2    | [ ] Yes [ ] No |
| PCI-DSS  | [ ] Yes [ ] No |

---

## Article XIX: Governance

> **📋 Applies to**: ALL project types

### Section 19.1: Constitution Amendments

1. **Proposal**: Any team member may propose amendments
2. **Review**: Tech Lead + Architect review required
3. **Approval**: Majority approval from signatories
4. **Implementation**: Update constitution + notify AI agents
5. **Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)

### Section 19.2: AI Agent Compliance

All AI agents operating in this project MUST:

1. **Read** this constitution before any operation
2. **Validate** all decisions against constitution principles
3. **FAIL** operations that violate constitution
4. **Request** amendment for justified exceptions
5. **Log** all constitution checks for audit

### Agent Checklist

Before generating code or making changes:

#### Base Constitution (always apply)

- [ ] Project scope and selected scopes match Article I / Section 1.1
- [ ] Environment config per Article X
- [ ] CI/CD per Article XI
- [ ] Observability per Article XII
- [ ] Security policies per Article XVI
- [ ] Governance compliance per Article XIX

#### Scope-Specific (apply per selected scopes)

> Load the relevant scope constitution(s) from `.boltf/scopes/<scope>/memory/constitution.md`

| Scope               | Key Checks                                                                                                                                                                                                                                                                                                                 |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **backend**         | Language/Runtime (Art. II), Architecture (Art. III), CQRS (§3.3), Communication (Art. IV), Data Storage (Art. V), Caching (Art. VI), Identity (Art. VII), Containers (Art. VIII), Testing (Art. XIII), Code Standards (Art. XIV), Project Structure (Art. XV), Legacy & Migration (Art. XVII), API Management (Art. XVIII) |
| **frontend**        | Framework (§2.2), Mobile (§2.3), Architecture (§3.2), Auth Flows (§7.3), Authorization (§7.4), Testing (Art. XIII), Code Standards (Art. XIV), Legacy & Migration (Art. XVII)                                                                                                                                              |
| **cloud-platform**  | Containers & Orchestration (Art. VIII), IaC (Art. IX), Infra Monitoring (§12.3), Infra Testing (§13.4), Project Structure Templates (Art. XV)                                                                                                                                                                              |
| **data**            | Data Storage (Art. V), Caching (Art. VI)                                                                                                                                                                                                                                                                                   |
| **integration**     | Communication (Art. IV), Containers/Dapr (Art. VIII), Legacy & Migration (Art. XVII), API Management (Art. XVIII)                                                                                                                                                                                                          |
| **ai**              | Scope-specific AI/ML decisions                                                                                                                                                                                                                                                                                             |
| **crm**             | Identity & Access (Art. VII), CRM-specific integrations                                                                                                                                                                                                                                                                    |
| **work-management** | Artefact mapping, sync strategy, traceability                                                                                                                                                                                                                                                                              |

---

## Signatories

| Role         | Name   | Date   | Signature |
| ------------ | ------ | ------ | --------- |
| Project Lead | [NAME] | [DATE] |           |
| Tech Lead    | [NAME] | [DATE] |           |
| Architect    | [NAME] | [DATE] |           |

---

## Revision History

| Version | Date   | Author   | Changes                                                                                    |
| ------- | ------ | -------- | ------------------------------------------------------------------------------------------ |
| 2.1.0   | [DATE] | [AUTHOR] | Added Project Scope (App/Infra/Full Stack), Landing Zone templates, Infrastructure testing |
| 2.0.0   | [DATE] | [AUTHOR] | Complete rewrite with C#/Node.js options                                                   |
| 1.0.0   | [DATE] | [AUTHOR] | Initial constitution                                                                       |
-->
