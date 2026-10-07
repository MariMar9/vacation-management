# BOLT Framework Constitution Template - Stack: Go Backend

> Preconfigured backend template for Go.
> This file intentionally preserves the same article and section structure as the canonical backend constitution in `.boltf/scopes/backend/memory/constitution.md`.

---

## Preamble 🔄

This template locks mandatory stack-implied backend decisions and suggests editable defaults for a Go project while keeping article numbering and order stable.

**Cloud Provider**: not fixed by this template.

## Decision Model For Refinement

- **🔒 Mandatory (fixed)**: do not ask again.
- **✅ Recommended (editable)**: suggested default (left unmarked), user can change.
- **❓ User must choose**: always ask.

### Mandatory in this stack template

- Backend language: **Go**
- Runtime: **Go 1.22**
- Framework: **No external framework (stdlib `net/http`)**

### Resolution lock for refinement

When `backend-stack-template: go` is selected, these decisions are **locked** and must be
persisted as resolved-from-template before asking any backend question:

- `backend-language = go`
- `backend-version = go122`
- `backend-framework = stdlib`

Do not ask runtime/framework again unless the user explicitly requests an override.

Expected wizard behavior:

- The framework question is skipped in normal flow because it is already locked by template.
- If an explicit override is requested, available options are: `stdlib` (default), `chi`, `gin`, `fiber`, `echo`, `azure-functions`.

### Recommended defaults in this stack template

- API style: **net/http handlers (stdlib)**
- Architecture: **Modular Monolith** (with **Hexagonal/Clean Architecture** available as optional convention)
- CQRS: **Enabled (Simple CQRS)**
- Communication: **Hybrid** + **REST** + **Service Bus compatible broker**
- Data: **PostgreSQL** + **sqlc + pgx**
- Caching: **L1 memory + L2 Redis + Cache-Aside**
- IAM baseline: **OIDC/OAuth2 + JWT**
- Delivery baseline: **GitHub Actions** + quality gates

### User must choose in refinement

- Additional scopes and organization constraints.
- Production identity provider and authorization model details.
- Environment auto-deploy policy and approvals.
- Cloud-managed service choices.

---

## Article II: Application Configuration

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 2.1: Backend Language & Runtime 🔴 CRITICAL

Decision class: **🔒 Mandatory (fixed)**

Select ONE:

- [ ] **C# / .NET** (N/A for this stack)
  - Version: [ ] .NET 8 (LTS) [ ] .NET 10

- [ ] **Node.js / TypeScript** (N/A for this stack)
  - Version: [ ] Node.js 20 LTS [ ] Node.js 22
  - Framework: [ ] Express [ ] Fastify [ ] NestJS [ ] Azure Functions

- [x] **Go**
  - Version: [x] Go 1.22 **(LOCKED for go template)** [ ] Go 1.23 *(only if user explicitly overrides template)*
  - Framework: [x] net/http (stdlib, no external framework) **(LOCKED for go template)** [ ] net/http + chi [ ] Gin [ ] Fiber [ ] Echo [ ] Azure Functions *(only if user explicitly overrides template)*

---

## Article III: Application Architecture

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 3.1: Backend Architecture Style 🔴 CRITICAL

Decision class: **✅ Recommended (editable)**

Select ONE (primary style):

- [ ] **Microservices**
- [ ] **Modular Monolith** (recommended for this stack)
- [ ] **Traditional Monolith**
- [ ] **Serverless**
- [ ] **Event-Driven / CQRS+ES**

Additional architectural convention:

- [ ] **Hexagonal / Clean Architecture**

### Section 3.3: CQRS Configuration 🟡 IMPORTANT

Decision class: **✅ Recommended (editable)**

CQRS Enabled: [x] Yes [ ] No

If Yes, select pattern:

- [ ] **Full CQRS**
- [ ] **CQRS + Event Sourcing**
- [ ] **Simple CQRS** (recommended for this stack)

#### For Go: Native CQRS Pattern

```go
package cqrs

import "context"

type Command interface{}

type CommandHandler[T Command] interface {
	Handle(ctx context.Context, cmd T) error
}

type Query[R any] interface{}

type QueryHandler[Q Query[R], R any] interface {
	Handle(ctx context.Context, query Q) (R, error)
}

type DomainEvent interface {
	EventName() string
}
```

### Section 3.4: Event Sourcing Configuration 🔴 CRITICAL

Decision class: **❓ User must choose**

Event Sourcing Enabled: [ ] Yes [ ] No

If Yes, select Event Store:

- [ ] **EventStoreDB**
- [ ] **Azure Cosmos DB**
- [ ] **SQL Server / PostgreSQL**

---

## Article IV: Communication

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 4.1: Communication Style 🔴 CRITICAL

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **Synchronous only**
- [ ] **Asynchronous only**
- [ ] **Hybrid** (recommended for this stack)

### Section 4.2: Synchronous Communication 🟡 IMPORTANT

Decision class: **✅ Recommended (editable)**

- [ ] **REST API** (recommended for this stack)
- [ ] **gRPC**
- [ ] **GraphQL**

### Section 4.3: Asynchronous Communication

Decision class: **✅ Recommended (editable)**

Message Broker - Select ONE:

- [ ] **None**
- [ ] **Azure Service Bus**
- [ ] **Azure Event Hubs**
- [ ] **RabbitMQ**
- [ ] **Service Bus compatible broker** (recommended for this stack)

Background Processing - Select ONE or more:

- [ ] **None**
- [ ] **.NET BackgroundService** / **Node.js Worker Threads** / **Python Celery or RQ** / **Go Goroutines + Worker Pools**
- [ ] **Azure Functions**
- [ ] **Hangfire** (.NET) / **BullMQ** (Node.js) / **Celery Beat** (Python) / **Asynq** (Go) - Persistent jobs

---

## Article V: Data Storage

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 5.1: Primary Database 🔴 CRITICAL

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **Azure SQL Database**
- [ ] **SQL Server**
- [ ] **PostgreSQL** (recommended for this stack)
- [ ] **Azure Cosmos DB**
- [ ] **MongoDB**

### Section 5.2: Data Access Pattern 🟡 IMPORTANT

Decision class: **✅ Recommended (editable)**

For C#/.NET (N/A for this stack):

- [ ] **Entity Framework Core**
- [ ] **Dapper**
- [ ] **EF Core + Dapper**

For Node.js/TypeScript (N/A for this stack):

- [ ] **Prisma**
- [ ] **TypeORM**
- [ ] **Drizzle**
- [ ] **Knex.js**

For Go:

- [ ] **sqlc + pgx** (recommended for this stack)
- [ ] **GORM**
- [ ] **Ent**
- [ ] **sqlx**

Repository Pattern: [x] Yes [ ] No
Unit of Work Pattern: [x] Yes [ ] No

### Section 5.3: Database Migrations 🟢 LOW-PRIO

Decision class: **✅ Recommended (editable)**

For C#/.NET (N/A for this stack):

- [ ] **EF Core Migrations**
- [ ] **DbUp**
- [ ] **FluentMigrator**

For Node.js/TypeScript (N/A for this stack):

- [ ] **Prisma Migrate**
- [ ] **TypeORM Migrations**
- [ ] **Knex Migrations**

For Go:

- [ ] **golang-migrate**
- [ ] **Atlas**
- [ ] **Goose**

---

## Article VI: Caching Strategy

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 6.1: Cache Levels 🟡 IMPORTANT (Enabled) / 🟢 LOW-PRIO (TTL values)

Decision class: **✅ Recommended (editable)**

| Level                | Technology                                 | Enabled        | TTL Default |
| -------------------- | ------------------------------------------ | -------------- | ----------- |
| **L1 - In-Memory**   | IMemoryCache (.NET) / node-cache (Node.js) / cachetools (Python) / patrickmn/go-cache (Go) | [x] Yes [ ] No | ___ minutes |
| **L2 - Distributed** | (see below)                                | [x] Yes [ ] No | ___ minutes |
| **L3 - CDN**         | (see below)                                | [ ] Yes [x] No | ___ hours   |

### Section 6.2: Distributed Cache (L2) 🟡 IMPORTANT

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **None**
- [ ] **Azure Cache for Redis**
- [ ] **Redis**

### Section 6.3: CDN (L3) 🟡 IMPORTANT

Decision class: **❓ User must choose**

Select ONE:

- [ ] **None**
- [ ] **Azure CDN**
- [ ] **Azure Front Door**

### Section 6.4: Cache Patterns 🟢 LOW-PRIO

Decision class: **✅ Recommended (editable)**

- [ ] **Cache-Aside** (recommended for this stack)
- [ ] **Read-Through**
- [ ] **Write-Through**
- [ ] **Write-Behind**

---

## Article VII: Identity & Access Management

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 7.1: Identity Provider (Production) 🔴 CRITICAL

Decision class: **❓ User must choose**

Select ONE:

- [ ] **Microsoft Entra ID (Azure AD)**
- [ ] **Azure AD B2C**
- [ ] **Duende IdentityServer**
- [ ] **Keycloak**
- [ ] **Auth0**

### Section 7.2: Identity Provider (Development/Testing) 🟢 LOW-PRIO

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **Mock IDP**
- [ ] **Azure AD Test Tenant**
- [ ] **Local IdentityServer/Keycloak**

### Section 7.3: Authentication Flows

Decision class: **✅ Recommended (editable)**

| Scenario           | Flow                      | Enabled        |
| ------------------ | ------------------------- | -------------- |
| SPA Frontend       | Authorization Code + PKCE | [x] Yes [ ] No |
| Mobile App         | Authorization Code + PKCE | [ ] Yes [x] No |
| Service-to-Service | Client Credentials        | [x] Yes [ ] No |
| Backend API        | JWT Bearer Validation     | [x] Yes [ ] No |

### Section 7.4: Authorization Model

Decision class: **❓ User must choose**

Select ONE:

- [ ] **RBAC**
- [ ] **Claims-Based**
- [ ] **Policy-Based**
- [ ] **ABAC**

---

## Article VIII: Containers & Orchestration

> **📋 Applies to**: Application Development, Full Stack (workload infra)
> **⏭️ Skip if**: Infrastructure Only (platform level)

### Section 8.1: Container Strategy

Decision class: **✅ Recommended (editable)**

- [ ] **Docker**
- [ ] **None**

### Section 8.2: Orchestration Platform

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **Azure Kubernetes Service (AKS)**
- [ ] **Azure Container Apps**
- [ ] **Azure App Service**
- [ ] **On-premises Kubernetes**
- [ ] **Docker Compose**

### Section 8.3: Kubernetes Configuration (if AKS/K8s selected)

Decision class: **❓ User must choose**

Package Manager:

- [ ] **Helm**
- [ ] **Kustomize**

Ingress Controller:

- [ ] **NGINX Ingress**
- [ ] **Azure Application Gateway Ingress (AGIC)**
- [ ] **Traefik**

### Section 8.4: Cloud-Native Extensions

Decision class: **❓ User must choose**

KEDA Enabled: [ ] Yes [ ] No
Dapr Enabled: [ ] Yes [ ] No

---

## Article X: Environments & Configuration 🔄

> **📋 Applies to**: ALL project types

### Section 10.1: Environment Strategy

Decision class: **❓ User must choose**

| Environment | Purpose                      | Enabled        | Auto-Deploy              |
| ----------- | ---------------------------- | -------------- | ------------------------ |
| **dev**     | Development, rapid iteration | [ ] Yes [ ] No | [ ] On commit to develop |
| **uat**     | User Acceptance Testing      | [ ] Yes [ ] No | [ ] On PR merge          |
| **pre**     | Pre-production, staging      | [ ] Yes [ ] No | [ ] Manual trigger       |
| **prod**    | Production                   | [ ] Yes [ ] No | [ ] Manual approval      |

### Section 10.2: Configuration Management

Decision class: **✅ Recommended (editable)**

Select strategy:

- [ ] **Azure App Configuration**
- [ ] **Environment Variables**
- [ ] **appsettings.{Environment}.json**
- [ ] **Combination**

### Section 10.3: Secrets Management

Decision class: **✅ Recommended (editable)**

| Secret Type        | Storage         |
| ------------------ | --------------- |
| Connection Strings | Azure Key Vault |
| API Keys           | Azure Key Vault |
| Certificates       | Azure Key Vault |

Local Development Secrets:

- [ ] **User Secrets** (.NET)
- [ ] **Env vars + local config files** (Go) - gitignored
- [ ] **Local Key Vault**

### Section 10.4: Feature Flags

Decision class: **❓ User must choose**

Feature Flag Provider:

- [ ] **None**
- [ ] **Azure App Configuration**
- [ ] **LaunchDarkly**
- [ ] **Unleash**

---

## Article XI: CI/CD Pipeline 🔄

> **📋 Applies to**: ALL project types

### Section 11.1: CI/CD Platform

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **GitHub Actions** (recommended for this stack)
- [ ] **Azure DevOps Pipelines**

### Section 11.2: Pipeline Stages

Decision class: **✅ Recommended (editable)**

#### For Application Development

| Stage                  | Enabled | Threshold                          |
| ---------------------- | ------- | ---------------------------------- |
| **Build**              | [x] Yes | Warnings as errors: [x] Yes [ ] No |
| **Lint/Format**        | [x] Yes | -                                  |
| **Unit Tests**         | [x] Yes | Coverage >= 80%                    |
| **Integration Tests**  | [x] Yes | -                                  |
| **Architecture Tests** | [x] Yes | -                                  |
| **Mutation Tests**     | [x] Yes | Score >= 70%                       |
| **Security Scan**      | [x] Yes | 0 Critical                         |
| **Container Build**    | [x] Yes | -                                  |
| **Container Scan**     | [x] Yes | 0 Critical                         |

#### Deployment Stages

| Stage           | Enabled | Trigger           |
| --------------- | ------- | ----------------- |
| **Deploy Dev**  | [x] Yes | Auto on develop   |
| **Deploy UAT**  | [x] Yes | Auto on release/* |
| **Deploy Pre**  | [x] Yes | Manual trigger    |
| **Deploy Prod** | [x] Yes | Manual approval   |

### Section 11.3: Deployment Strategy

Decision class: **❓ User must choose**

Select ONE:

- [ ] **Rolling Update**
- [ ] **Blue-Green**
- [ ] **Canary**
- [ ] **Feature Flags**

### Section 11.4: Branch Strategy

Decision class: **❓ User must choose**

Select ONE:

- [ ] **GitFlow**
- [ ] **GitHub Flow**
- [ ] **Trunk-Based**

---

## Article XII: Observability 🔄

> **📋 Applies to**: ALL project types

### Section 12.1: Observability Strategy

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **Azure-Native**
- [ ] **OpenTelemetry → Azure**
- [ ] **OpenTelemetry → Grafana Stack**

### Section 12.2: Health Checks

```text
/health       - Full health check
/health/ready - Readiness probe
/health/live  - Liveness probe
```

---

## Article XIII: Testing Standards

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 13.1: Testing Philosophy 🟢 LOW-PRIO (thresholds are configurable)

Decision class: **✅ Recommended (editable)**

| Metric          | Minimum | Recommended | Tool                                 |
| --------------- | ------- | ----------- | ------------------------------------ |
| Line Coverage   | >= 80%  | >= 90%      | coverlet (.NET) / istanbul (Node.js) |
| Branch Coverage | >= 75%  | >= 85%      | coverlet (.NET) / istanbul (Node.js) |
| Mutation Score  | >= 70%  | >= 80%      | Stryker.NET / Stryker Mutator        |

### Section 13.2: Testing Frameworks 🟡 IMPORTANT

Decision class: **✅ Recommended (editable)**

For C#/.NET (N/A for this stack):

| Type               | Framework              |
| ------------------ | ---------------------- |
| Unit Tests         | xUnit                  |
| Integration Tests  | xUnit + Testcontainers |
| Architecture Tests | NetArchTest            |
| BDD/Gherkin        | SpecFlow / Reqnroll    |
| E2E Tests          | Playwright             |
| Performance Tests  | NBomber / k6           |

For Node.js/TypeScript (N/A for this stack):

| Type               | Framework             |
| ------------------ | --------------------- |
| Unit Tests         | Jest / Vitest         |
| Integration Tests  | Jest + Testcontainers |
| Architecture Tests | dependency-cruiser    |
| BDD/Gherkin        | Cucumber.js           |
| E2E Tests          | Playwright / Cypress  |
| Performance Tests  | k6 / Artillery        |

For Go:

| Type               | Framework                |
| ------------------ | ------------------------ |
| Unit Tests         | testing + testify        |
| Integration Tests  | testcontainers-go        |
| Architecture Tests | go vet + staticcheck     |
| BDD/Gherkin        | godog                    |
| E2E Tests          | Playwright / k6 browser  |
| Performance Tests  | k6 / vegeta              |

### Section 13.3: Test Project Structure

Decision class: **✅ Recommended (editable)**

```text
src/
├── modules/
│   └── {module}/
│       ├── tests/
│       │   ├── unit/
│       │   └── integration/
│       └── ...
tests/
├── e2e/
├── architecture/
└── fixtures/
```

---

## Article XIV: Code Standards 🟢 LOW-PRIO

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 14.1: Naming Conventions

Decision class: **✅ Recommended (editable)**

For Go:

| Element         | Convention       | Example                    |
| --------------- | ---------------- | -------------------------- |
| Packages        | lowercase        | `billing`                  |
| Files           | snake_case       | `create_order_handler.go`  |
| Exported names  | PascalCase       | `OrderService`             |
| Unexported names| camelCase        | `orderRepository`          |
| Constants       | PascalCase       | `MaxRetries`               |
| Interfaces      | -er suffix       | `OrderRepository`          |

### Section 14.2: Code Formatting

Decision class: **✅ Recommended (editable)**

| Setting     | Value                      |
| ----------- | -------------------------- |
| Indentation | tabs / gofmt default           |
| Line Length | gofmt default (no hard limit)  |
| Strict mode | [x] `go vet` [x] staticcheck   |
| Tooling     | gofmt + golangci-lint          |

---

## Article XV: Project Structure Templates

> **📋 Applies to**: Application Development, Full Stack
> **Auto-generated based on selections above.**

Decision class: **✅ Recommended (editable)**

### Template A: Go + Modular Monolith

```text
project-root/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── modules/
│   ├── shared/
│   └── platform/
├── pkg/
├── tests/
├── migrations/
├── infra/
└── docker-compose.yml
```

### Template B: Go + Microservices

```text
project-root/
├── services/
│   ├── service-a/
│   │   ├── cmd/
│   │   └── internal/
│   └── service-b/
│       ├── cmd/
│       └── internal/
├── pkg/
├── tests/
├── migrations/
├── infra/
└── docker-compose.yml
```

---

## Article XVI: Security Policies 🔄 🟡 IMPORTANT

> **📋 Applies to**: ALL project types

### Section 16.1: Network Security

Decision class: **❓ User must choose**

| Component                | Configuration                     |
| ------------------------ | --------------------------------- |
| Virtual Network          | [ ] Azure VNet [ ] None           |
| Private Endpoints        | [ ] Enabled [ ] Disabled          |
| Web Application Firewall | [ ] Azure Front Door WAF [ ] None |

### Section 16.2: Data Protection

Decision class: **✅ Recommended (editable)**

| Policy                | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Encryption at Rest    | [x] Azure-managed keys [ ] Customer-managed keys      |
| Encryption in Transit | TLS 1.2+ (mandatory)                                  |
| PII Handling          | [ ] Anonymization [x] Pseudonymization [ ] Encryption |

### Section 16.3: Compliance Requirements

Decision class: **❓ User must choose**

| Standard | Required       |
| -------- | -------------- |
| GDPR     | [ ] Yes [ ] No |
| HIPAA    | [ ] Yes [ ] No |
| SOC 2    | [ ] Yes [ ] No |
| PCI-DSS  | [ ] Yes [ ] No |

---

## Article XVII: Legacy & Migration 🟡 IMPORTANT

> **📋 Applies to**: Application Development, Full Stack (if migrating)

### Section 17.1: Migration Context

Decision class: **❓ User must choose**

Select ONE:

- [ ] **Greenfield**
- [ ] **Brownfield**
- [ ] **Legacy Migration**
- [ ] **Strangler Fig**

### Section 17.2: Migration Strategy (if applicable)

Decision class: **❓ User must choose**

Select ONE:

- [ ] **Big Bang**
- [ ] **Strangler Fig**
- [ ] **Branch by Abstraction**

---

## Article XVIII: API Management

> **📋 Applies to**: Application Development, Full Stack

### Section 18.1: API Gateway

Decision class: **❓ User must choose**

Select ONE:

- [ ] **None**
- [ ] **Azure API Management (APIM)**
- [ ] **Azure Front Door**
- [ ] **YARP**

### Section 18.2: API Features

Decision class: **❓ User must choose**

| Feature        | Enabled        | Configuration                |
| -------------- | -------------- | ---------------------------- |
| Rate Limiting  | [ ] Yes [ ] No | ___ requests/minute          |
| API Versioning | [ ] Yes [ ] No | Strategy: [ ] URL [ ] Header |

### Section 18.3: API Documentation

Decision class: **✅ Recommended (editable)**

| Type         | Tool              | Enabled        |
| ------------ | ----------------- | -------------- |
| REST API     | OpenAPI / Swagger | [x] Yes        |
| Async Events | AsyncAPI          | [ ] Yes [x] No |

---

## Article XIX: Governance 🔄

> **📋 Applies to**: ALL project types

### Section 19.1: Constitution Amendments

Decision class: **❓ User must choose**

1. Proposal process.
2. Review process.
3. Approval policy.
4. Implementation and communication.
5. Versioning policy.

### Section 19.2: AI Agent Compliance

Decision class: **🔒 Mandatory (fixed)**

All AI agents operating in this project MUST:

1. Read this constitution before any operation.
2. Validate all decisions against constitution principles.
3. Fail operations that violate constitution.
4. Request amendment for justified exceptions.
5. Log constitution checks for audit.

---

## Quick Start Checklist

- [ ] Apply template to backend constitution before refinement.
- [ ] Keep all **🔒 Mandatory** decisions fixed.
- [ ] Review and confirm **✅ Recommended** defaults.
- [ ] Resolve all **❓ User must choose** decisions.
- [ ] Run constitution setup and complete refinement.

## Notes

- This template is intentionally structure-compatible with backend constitution (same article/section IDs).
- Use this template to prefill defaults; do not renumber or delete articles.

