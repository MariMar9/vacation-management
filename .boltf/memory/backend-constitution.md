<!-- ================================================================ -->
<!-- SCOPE: backend -->
<!-- Generated: 2026-10-07 13:34:00 -->
<!-- Source: .boltf/scopes/backend/memory/constitution.md -->
<!-- ================================================================ -->

# BOLT Framework Project Constitution — Scope: Backend

> **Extracted from**: `.boltf/memory/constitution.md`
> **Scope**: `backend` — Backend language, runtime, architecture, data, caching, identity, containers, testing, and code standards.
> Articles marked with 🔄 are **common to all scopes** and always present.

---

## Preamble 🔄

This Constitution establishes the governing principles, technology decisions, and standards for the **[PROJECT_NAME]** project. All AI agents, developers, and automated systems MUST adhere to this document.

**This document is the SINGLE SOURCE OF TRUTH.**

**Cloud Provider**: Microsoft Azure (mandatory for all deployments)

---

## Article II: Application Configuration

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 2.1: Backend Language & Runtime 🔴 CRITICAL

> **🔴 CRITICAL**: Language choice affects entire codebase - extremely difficult to change later

Select ONE:

- [x] **C# / .NET**
    - Version: [x] .NET 8 (LTS) **(LOCKED for dotnet-8 template)** [ ] .NET 10 *(only if user explicitly overrides template)*
  - API Style: [ ] Minimal APIs [ ] Controllers (MVC) [ ] Azure Functions 🟡 IMPORTANT

- [ ] **Node.js / TypeScript** (N/A for this stack)
  - Version: [ ] Node.js 20 LTS [ ] Node.js 22
  - Framework: [ ] Express [ ] Fastify [ ] NestJS [ ] Azure Functions

- [ ] **Python**
  - Version: [ ] Python 3.12 [ ] Python 3.13 🟢 LOW-PRIO
  - Framework: [ ] FastAPI [ ] Flask [ ] Django [ ] Azure Functions 🟡 IMPORTANT

- [ ] **Go**
  - Version: [ ] Go 1.22 [ ] Go 1.23 🟢 LOW-PRIO
  - Framework: [ ] net/http (stdlib, no external framework) [ ] net/http + chi [ ] Gin [ ] Fiber [ ] Echo [ ] Azure Functions 🟡 IMPORTANT

---

## Article III: Application Architecture

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 3.1: Backend Architecture Style 🔴 CRITICAL

> **🔴 CRITICAL**: Architecture style affects service boundaries, deployment strategy, and team organization

Select ONE:

- [ ] **Microservices**
- [ ] **Modular Monolith** (recommended for this stack)
- [ ] **Traditional Monolith**
- [ ] **Serverless**
- [ ] **Event-Driven / CQRS+ES**

### Section 3.3: CQRS Configuration 🟡 IMPORTANT

> **🟡 IMPORTANT**: CQRS pattern affects code structure but can be added/removed with moderate effort

CQRS Enabled: [ ] Yes [ ] No

If Yes, select pattern:

- [ ] **Full CQRS**
- [ ] **CQRS + Event Sourcing**
- [ ] **Simple CQRS** (recommended for this stack)

#### For C#/.NET: Native CQRS Interfaces (NO MediatR)

> **⚠️ IMPORTANT**: NO usar MediatR. Implementar CQRS con interfaces nativas de .NET.

```csharp
// Commands
public interface ICommand { }
public interface ICommandHandler<in TCommand> where TCommand : ICommand
{
    Task HandleAsync(TCommand command, CancellationToken ct = default);
}
public interface ICommandHandler<in TCommand, TResult> where TCommand : ICommand
{
    Task<TResult> HandleAsync(TCommand command, CancellationToken ct = default);
}

// Queries
public interface IQuery<TResult> { }
public interface IQueryHandler<in TQuery, TResult> where TQuery : IQuery<TResult>
{
    Task<TResult> HandleAsync(TQuery query, CancellationToken ct = default);
}

// Dispatchers (DI-based, no reflection magic)
public interface ICommandDispatcher
{
    Task DispatchAsync<TCommand>(TCommand command, CancellationToken ct = default)
        where TCommand : ICommand;
}
public interface IQueryDispatcher
{
    Task<TResult> DispatchAsync<TQuery, TResult>(TQuery query, CancellationToken ct = default)
        where TQuery : IQuery<TResult>;
}

// Domain Events
public interface IDomainEvent
{
    Guid EventId { get; }
    DateTime OccurredOn { get; }
}
public interface IDomainEventHandler<in TEvent> where TEvent : IDomainEvent
{
    Task HandleAsync(TEvent domainEvent, CancellationToken ct = default);
}
```

#### For Node.js/TypeScript: Native CQRS Pattern

```typescript
// Commands
interface ICommand {}
interface ICommandHandler<TCommand extends ICommand, TResult = void> {
  handle(command: TCommand): Promise<TResult>;
}

// Queries
interface IQuery<TResult> {}
interface IQueryHandler<TQuery extends IQuery<TResult>, TResult> {
  handle(query: TQuery): Promise<TResult>;
}

// Bus (simple DI-based)
interface ICommandBus {
  dispatch<TCommand extends ICommand>(command: TCommand): Promise<void>;
}
interface IQueryBus {
  dispatch<TQuery extends IQuery<TResult>, TResult>(query: TQuery): Promise<TResult>;
}

// Domain Events
interface IDomainEvent {
  eventId: string;
  occurredOn: Date;
}
interface IDomainEventHandler<TEvent extends IDomainEvent> {
  handle(event: TEvent): Promise<void>;
}
```

### Section 3.4: Event Sourcing Configuration 🔴 CRITICAL

> **🔴 CRITICAL**: Once committed to Event Sourcing, very difficult to migrate away from

Event Sourcing Enabled: [ ] Yes [ ] No

If Yes, select Event Store:

- [ ] **EventStoreDB**
- [ ] **Azure Cosmos DB** - Change Feed for events
- [ ] **SQL Server / PostgreSQL**

---

## Article IV: Communication

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 4.1: Communication Style 🔴 CRITICAL

> **🔴 CRITICAL**: Sync vs Async vs Hybrid defines entire integration approach

Select ONE:

- [ ] **Synchronous only**
- [ ] **Asynchronous only**
- [ ] **Hybrid** (recommended for this stack)

### Section 4.2: Synchronous Communication 🟡 IMPORTANT

- [ ] **REST API** (recommended for this stack)
- [ ] **gRPC**
- [ ] **GraphQL**

### Section 4.3: Asynchronous Communication

Message Broker - Select ONE: 🔴 CRITICAL (if async)

- [ ] **None**
- [ ] **Azure Service Bus** - Cloud-native, enterprise
- [ ] **Azure Event Hubs** - High-throughput streaming
- [ ] **RabbitMQ**
- [ ] **Azure Storage Queues** - Simple, cost-effective

Background Processing - Select ONE or more: 🟡 IMPORTANT

- [ ] **None**
- [ ] **.NET BackgroundService** / **Node.js Worker Threads** / **Python Celery or RQ** / **Go Goroutines + Worker Pools**
- [ ] **Azure Functions**
- [ ] **Hangfire** (.NET) / **BullMQ** (Node.js) / **Celery Beat** (Python) / **Asynq** (Go) - Persistent jobs

---

## Article V: Data Storage

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 5.1: Primary Database 🔴 CRITICAL

> **🔴 CRITICAL**: SQL vs NoSQL migration is extremely expensive - choose carefully

Select ONE:

- [ ] **Azure SQL Database**
- [ ] **SQL Server**
- [ ] **PostgreSQL** (recommended for this stack)
- [ ] **Azure Cosmos DB** - NoSQL, globally distributed
- [ ] **MongoDB**

### Section 5.2: Data Access Pattern 🟡 IMPORTANT

#### For C#/.NET

- [ ] **Entity Framework Core**
- [ ] **Dapper**
- [ ] **EF Core + Dapper** (recommended for this stack)

#### For Node.js/TypeScript

- [ ] **Prisma**
- [ ] **TypeORM**
- [ ] **Drizzle**
- [ ] **Knex.js**

#### For Python

- [ ] **SQLAlchemy** - Full ORM / SQL toolkit
- [ ] **SQLModel** - Type-friendly ORM built on SQLAlchemy
- [ ] **Django ORM** - Batteries-included ORM
- [ ] **psycopg + SQL query layer** - Lightweight SQL-first access

#### For Go

- [ ] **sqlc + pgx** - SQL-first, generated typed queries
- [ ] **GORM** - Full ORM
- [ ] **Ent** - Schema-first ORM/codegen
- [ ] **sqlx** - Lightweight extension over database/sql

Repository Pattern: [ ] Yes [ ] No 🟡 IMPORTANT
Unit of Work Pattern: [ ] Yes [ ] No 🟡 IMPORTANT

### Section 5.3: Database Migrations 🟢 LOW-PRIO

#### For C#/.NET

- [ ] **EF Core Migrations**
- [ ] **DbUp**
- [ ] **FluentMigrator**

#### For Node.js/TypeScript

- [ ] **Prisma Migrate**
- [ ] **TypeORM Migrations**
- [ ] **Knex Migrations**

#### For Python

- [ ] **Alembic** - SQLAlchemy migrations
- [ ] **Django Migrations** - Integrated with Django ORM
- [ ] **Raw SQL + migration runner** - SQL scripts

#### For Go

- [ ] **golang-migrate** - SQL-based migrations
- [ ] **goose** - SQL and Go migrations
- [ ] **Atlas** - Schema management and migrations

---

## Article VI: Caching Strategy

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 6.1: Cache Levels 🟡 IMPORTANT (Enabled) / 🟢 LOW-PRIO (TTL values)

| Level                | Technology                                 | Enabled        | TTL Default    |
| -------------------- | ------------------------------------------ | -------------- | -------------- |
| **L1 - In-Memory**   | IMemoryCache (.NET) / node-cache (Node.js) / cachetools (Python) / patrickmn/go-cache (Go) | [ ] Yes [ ] No | \_\_\_ minutes |
| **L2 - Distributed** | (see below)                                | [ ] Yes [ ] No | \_\_\_ minutes |
| **L3 - CDN**         | (see below)                                | [ ] Yes [ ] No | \_\_\_ hours   |

### Section 6.2: Distributed Cache (L2) 🟡 IMPORTANT

Select ONE:

- [ ] **None**
- [ ] **Azure Cache for Redis**
- [ ] **Redis**

### Section 6.3: CDN (L3) 🟡 IMPORTANT

Select ONE:

- [ ] **None**
- [ ] **Azure CDN**
- [ ] **Azure Front Door** - Global load balancing + CDN

### Section 6.4: Cache Patterns 🟢 LOW-PRIO

- [ ] **Cache-Aside** (recommended for this stack)
- [ ] **Read-Through**
- [ ] **Write-Through**
- [ ] **Write-Behind**

---

## Article VII: Identity & Access Management

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 7.1: Identity Provider (Production) 🔴 CRITICAL

> **🔴 CRITICAL**: Identity provider choice affects entire auth stack and user management

Select ONE:

- [ ] **Microsoft Entra ID (Azure AD)**
- [ ] **Azure AD B2C**
- [ ] **Duende IdentityServer**
- [ ] **Keycloak**
- [ ] **Auth0**

### Section 7.2: Identity Provider (Development/Testing) 🟢 LOW-PRIO

Select ONE:

- [ ] **Mock IDP**
- [ ] **Azure AD Test Tenant**
- [ ] **Local IdentityServer/Keycloak**

### Section 7.3: Authentication Flows

| Scenario           | Flow                      | Enabled        |
| ------------------ | ------------------------- | -------------- |
| SPA Frontend       | Authorization Code + PKCE | [ ] Yes [ ] No |
| Mobile App         | Authorization Code + PKCE | [ ] Yes [ ] No |
| Service-to-Service | Client Credentials        | [ ] Yes [ ] No |
| Backend API        | JWT Bearer Validation     | [ ] Yes [ ] No |

### Section 7.4: Authorization Model

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

- [ ] **Docker**
- [ ] **None** - PaaS only (Azure App Service)

### Section 8.2: Orchestration Platform

Select ONE:

- [ ] **Azure Kubernetes Service (AKS)**
- [ ] **Azure Container Apps**
- [ ] **Azure App Service**
- [ ] **On-premises Kubernetes**
- [ ] **Docker Compose**

### Section 8.3: Kubernetes Configuration (if AKS/K8s selected)

Package Manager:

- [ ] **Helm**
- [ ] **Kustomize**

Ingress Controller:

- [ ] **NGINX Ingress**
- [ ] **Azure Application Gateway Ingress (AGIC)**
- [ ] **Traefik**

### Section 8.4: Cloud-Native Extensions

#### KEDA (Kubernetes Event-Driven Autoscaling)

KEDA Enabled: [ ] Yes [ ] No

If Yes, select scalers:

- [ ] Azure Service Bus
- [ ] Azure Event Hubs
- [ ] Azure Storage Queue
- [ ] HTTP Request count

#### Dapr (Distributed Application Runtime)

Dapr Enabled: [ ] Yes [ ] No

If Yes, select building blocks:

| Building Block     | Enabled        | Azure Component                      |
| ------------------ | -------------- | ------------------------------------ |
| Service Invocation | [ ] Yes [ ] No | -                                    |
| State Management   | [ ] Yes [ ] No | [ ] Azure Cosmos DB [ ] Redis        |
| Pub/Sub            | [ ] Yes [ ] No | [ ] Azure Service Bus [ ] Event Hubs |
| Secrets            | [ ] Yes [ ] No | [ ] Azure Key Vault                  |

---

## Article X: Environments & Configuration 🔄

> **📋 Applies to**: ALL project types

### Section 10.1: Environment Strategy

| Environment | Purpose                      | Enabled | Auto-Deploy              |
| ----------- | ---------------------------- | ------- | ------------------------ |
| **dev**     | Development, rapid iteration | [ ] Yes [ ] No | [ ] On commit to develop |
| **uat**     | User Acceptance Testing      | [ ] Yes [ ] No | [ ] On PR merge          |
| **pre**     | Pre-production, staging      | [ ] Yes [ ] No | [ ] Manual trigger       |
| **prod**    | Production                   | [ ] Yes [ ] No | [ ] Manual approval      |

### Section 10.2: Configuration Management

Select strategy:

- [ ] **Azure App Configuration** - Centralized, feature flags (recommended)
- [ ] **Environment Variables**
- [ ] **appsettings.{Environment}.json** (.NET) / **.env files** (Node.js, Python) / **config.{env}.yaml|json + env vars** (Go)
- [ ] **Combination**

### Section 10.3: Secrets Management

| Secret Type        | Storage         |
| ------------------ | --------------- |
| Connection Strings | Azure Key Vault |
| API Keys           | Azure Key Vault |
| Certificates       | Azure Key Vault |

Local Development Secrets:

- [ ] **User Secrets** (.NET)
- [ ] **.env files** (Node.js)
- [ ] **Env vars + local config files** (Go) - gitignored
- [ ] **Local Key Vault**

### Section 10.4: Feature Flags

Feature Flag Provider:

- [ ] **None**
- [ ] **Azure App Configuration** - Native integration
- [ ] **LaunchDarkly**
- [ ] **Unleash**

---

## Article XI: CI/CD Pipeline 🔄

> **📋 Applies to**: ALL project types

### Section 11.1: CI/CD Platform

Select ONE:

- [ ] **GitHub Actions** (recommended for this stack)
- [ ] **Azure DevOps Pipelines**

### Section 11.2: Pipeline Stages

#### For Application Development

| Stage                  | Enabled | Threshold                          |
| ---------------------- | ------- | ---------------------------------- |
| **Build**              | [x] Yes | Warnings as errors: [x] Yes [ ] No |
| **Lint/Format**        | [ ] Yes | -                                  |
| **Unit Tests**         | [ ] Yes | Coverage >= \_\_%                  |
| **Integration Tests**  | [ ] Yes | -                                  |
| **Architecture Tests** | [ ] Yes | -                                  |
| **Mutation Tests**     | [ ] Yes | Score >= \_\_%                     |
| **Security Scan**      | [ ] Yes | 0 Critical                         |
| **Container Build**    | [ ] Yes | -                                  |
| **Container Scan**     | [ ] Yes | 0 Critical                         |

#### Deployment Stages

| Stage           | Enabled | Trigger            |
| --------------- | ------- | ------------------ |
| **Deploy Dev**  | [x] Yes | Auto on develop    |
| **Deploy UAT**  | [ ] Yes | Auto on release/\* |
| **Deploy Pre**  | [x] Yes | Manual trigger     |
| **Deploy Prod** | [x] Yes | Manual approval    |

### Section 11.3: Deployment Strategy

Select ONE:

- [ ] **Rolling Update**
- [ ] **Blue-Green**
- [ ] **Canary**
- [ ] **Feature Flags**

### Section 11.4: Branch Strategy

Select ONE:

- [ ] **GitFlow**
- [ ] **GitHub Flow**
- [ ] **Trunk-Based**

---

## Article XII: Observability 🔄

> **📋 Applies to**: ALL project types

### Section 12.1: Observability Strategy

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
> **⏭️ Skip if**: Infrastructure Only (see IaC testing below)

### Section 13.1: Testing Philosophy 🟢 LOW-PRIO (thresholds are configurable)

> **🟢 LOW-PRIO**: Coverage thresholds are runtime CI/CD configs - easily adjustable

> **Coverage-First approach validated by Mutation Testing**

| Metric          | Minimum | Recommended | Tool                                 |
| --------------- | ------- | ----------- | ------------------------------------ |
| Line Coverage   | >= 80%  | >= 90%      | coverlet (.NET) / istanbul (Node.js) / pytest-cov (Python) / go test -cover (Go) |
| Branch Coverage | >= 75%  | >= 85%      | coverlet (.NET) / istanbul (Node.js) / coverage.py (Python) / go tool cover (Go) |
| Mutation Score  | >= 70%  | >= 80%      | Stryker.NET / Stryker Mutator / mutmut or cosmic-ray (Python) / go-mutesting (Go) |

### Section 13.2: Testing Frameworks 🟡 IMPORTANT

> **🟡 IMPORTANT**: Framework choice affects project structure and test patterns

#### For C#/.NET

| Type               | Framework              |
| ------------------ | ---------------------- |
| Unit Tests         | xUnit                  |
| Integration Tests  | xUnit + Testcontainers |
| Architecture Tests | NetArchTest            |
| BDD/Gherkin        | SpecFlow / Reqnroll    |
| E2E Tests          | Playwright             |
| Performance Tests  | NBomber / k6           |

#### For Node.js/TypeScript

| Type               | Framework             |
| ------------------ | --------------------- |
| Unit Tests         | Jest / Vitest         |
| Integration Tests  | Jest + Testcontainers |
| Architecture Tests | dependency-cruiser    |
| BDD/Gherkin        | Cucumber.js           |
| E2E Tests          | Playwright / Cypress  |
| Performance Tests  | k6 / Artillery        |

#### For Python

| Type               | Framework                              |
| ------------------ | -------------------------------------- |
| Unit Tests         | pytest                                 |
| Integration Tests  | pytest + Testcontainers                |
| Architecture Tests | import-linter / pytest-archon          |
| BDD/Gherkin        | Behave / pytest-bdd                    |
| E2E Tests          | Playwright                             |
| Performance Tests  | k6 / Locust                            |

#### For Go

| Type               | Framework                              |
| ------------------ | -------------------------------------- |
| Unit Tests         | testing (stdlib) + testify             |
| Integration Tests  | testing + Testcontainers               |
| Architecture Tests | depguard / custom package boundary tests |
| BDD/Gherkin        | godog                                  |
| E2E Tests          | Playwright                             |
| Performance Tests  | k6 / vegeta                            |

### Section 13.3: Test Project Structure

#### For C#/.NET

```text
tests/
├── {Module}.UnitTests/
├── {Module}.IntegrationTests/
├── Architecture.Tests/
├── E2E.Tests/
└── Common.Tests/
    ├── Fixtures/
    ├── Fakes/
    └── Builders/
```

#### For Node.js/TypeScript

```text
src/
├── modules/
│   └── {module}/
│       ├── __tests__/
│       │   ├── unit/
│       │   └── integration/
│       └── ...
tests/
├── e2e/
├── architecture/
└── fixtures/
```

#### For Python

```text
src/
├── app/
│   ├── domain/
│   ├── application/
│   ├── infrastructure/
│   └── api/
tests/
├── unit/
├── integration/
├── e2e/
└── fixtures/
```

#### For Go

```text
cmd/
├── api/
internal/
├── domain/
├── application/
├── infrastructure/
└── transport/
tests/
├── unit/
├── integration/
└── e2e/
```

---

## Article XIV: Code Standards 🟢 LOW-PRIO

> **🟢 LOW-PRIO**: Code formatting and naming conventions are enforced by linter - easy to change
> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 14.1: Naming Conventions

#### For C#/.NET

| Element        | Convention     | Example                      |
| -------------- | -------------- | ---------------------------- |
| Namespaces     | PascalCase     | `MyCompany.MyProject.Domain` |
| Classes        | PascalCase     | `OrderService`               |
| Interfaces     | I + PascalCase | `IOrderService`              |
| Methods        | PascalCase     | `GetOrderByIdAsync`          |
| Properties     | PascalCase     | `OrderId`                    |
| Private fields | \_camelCase    | `_orderRepository`           |
| Async methods  | Suffix Async   | `GetOrderByIdAsync`          |

#### For Node.js/TypeScript

| Element    | Convention       | Example            |
| ---------- | ---------------- | ------------------ |
| Files      | kebab-case       | `order-service.ts` |
| Classes    | PascalCase       | `OrderService`     |
| Interfaces | I + PascalCase   | `IOrderService`    |
| Functions  | camelCase        | `getOrderById`     |
| Variables  | camelCase        | `orderId`          |
| Constants  | UPPER_SNAKE_CASE | `MAX_RETRIES`      |

#### For Python

| Element     | Convention     | Example            |
| ----------- | -------------- | ------------------ |
| Modules     | snake_case     | `order_service.py` |
| Classes     | PascalCase     | `OrderService`     |
| Functions   | snake_case     | `get_order_by_id`  |
| Variables   | snake_case     | `order_id`         |
| Constants   | UPPER_SNAKE_CASE | `MAX_RETRIES`    |

#### For Go

| Element     | Convention     | Example            |
| ----------- | -------------- | ------------------ |
| Packages    | lower-case     | `orders`           |
| Files       | snake_case     | `order_service.go` |
| Exported    | PascalCase     | `OrderService`     |
| Unexported  | camelCase      | `orderService`     |
| Constants   | PascalCase / UPPER_SNAKE_CASE | `MaxRetries` |

### Section 14.2: Code Formatting

#### For C#/.NET

| Setting                  | Value                                  |
| ------------------------ | -------------------------------------- |
| Indentation              | 4 spaces                               |
| Line Length              | 120 characters                         |
| File-scoped namespaces   | [ ] Yes [ ] No                         |
| Nullable reference types | [ ] Enabled (recommended) 🟡 IMPORTANT |
| Tooling                  | .editorconfig + dotnet format          |

#### For Node.js/TypeScript

| Setting     | Value                 |
| ----------- | --------------------- |
| Indentation | 2 spaces              |
| Line Length | 100 characters        |
| Semicolons  | [ ] Yes [ ] No        |
| Quotes      | [ ] Single [ ] Double |
| Tooling     | ESLint + Prettier     |

#### For Python

| Setting     | Value                 |
| ----------- | --------------------- |
| Indentation | 4 spaces              |
| Line Length | 88-100 characters     |
| Type Hints  | [ ] Required [ ] Optional |
| Tooling     | Ruff + Black + isort  |

#### For Go

| Setting     | Value                 |
| ----------- | --------------------- |
| Indentation | tabs (gofmt)          |
| Line Length | gofmt default         |
| Error Style | explicit errors       |
| Tooling     | gofmt + golangci-lint |

---

## Article XV: Project Structure Templates

> **📋 Applies to**: Application Development, Full Stack
> **Auto-generated based on selections above.**
> Run `/bolt.scaffold` to generate the project structure.

### Template A: C# + Modular Monolith

```text
project-root/
├── src/
│   ├── Modules/
│   │   ├── Orders/
│   │   │   ├── Orders.Domain/
│   │   │   ├── Orders.Application/
│   │   │   ├── Orders.Infrastructure/
│   │   │   └── Orders.Api/
│   │   └── Users/
│   ├── Shared/
│   │   ├── SharedKernel/
│   │   │   └── CQRS/           # Native interfaces
│   │   └── Contracts/
│   └── Api.Host/
├── tests/
│   ├── Orders.UnitTests/
│   ├── Orders.IntegrationTests/
│   └── Architecture.Tests/
├── infra/
│   └── bicep/
├── Directory.Build.props
└── Directory.Packages.props
```

### Template B: C# + Microservices

```text
project-root/
├── src/
│   ├── Services/
│   │   ├── Orders/
│   │   │   ├── Orders.Api/
│   │   │   ├── Orders.Domain/
│   │   │   ├── Orders.Application/
│   │   │   └── Orders.Infrastructure/
│   │   └── Users/
│   ├── BuildingBlocks/
│   │   ├── SharedKernel/
│   │   ├── EventBus/
│   │   └── ServiceDiscovery/
│   └── ApiGateway/
├── tests/
│   └── ...
├── infra/
│   ├── bicep/
│   └── k8s/
└── docker-compose.yml
```

### Template C: Node.js + Modular Monolith

```text
project-root/
├── src/
│   ├── modules/
│   │   ├── orders/
│   │   │   ├── domain/
│   │   │   ├── application/
│   │   │   ├── infrastructure/
│   │   │   └── api/
│   │   └── users/
│   ├── shared/
│   │   ├── kernel/
│   │   │   └── cqrs/
│   │   └── contracts/
│   └── main.ts
├── tests/
│   ├── e2e/
│   └── architecture/
├── infra/
│   └── bicep/
├── package.json
└── tsconfig.json
```

### Template D: Node.js + Microservices

```text
project-root/
├── services/
│   ├── orders/
│   │   ├── src/
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   └── package.json
│   └── users/
├── packages/
│   ├── shared-kernel/
│   ├── event-bus/
│   └── service-discovery/
├── infra/
│   ├── bicep/
│   └── k8s/
├── docker-compose.yml
└── package.json (workspaces)
```

### Template E: Python/FastAPI + Modular Monolith

```text
project-root/
├── src/
│   └── app/
│       ├── domain/
│       ├── application/
│       ├── infrastructure/
│       ├── api/
│       └── main.py
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── infra/
│   └── bicep/
├── pyproject.toml
└── alembic/
```

### Template F: Go + Microservices

```text
project-root/
├── services/
│   ├── orders/
│   │   ├── cmd/api/
│   │   ├── internal/
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   └── go.mod
│   └── users/
├── pkg/
│   ├── shared-kernel/
│   ├── event-bus/
│   └── service-discovery/
├── infra/
│   ├── bicep/
│   └── k8s/
└── docker-compose.yml
```

---

## Article XVI: Security Policies 🔄 🟡 IMPORTANT

> **🟡 IMPORTANT**: Security configuration affects compliance and data protection
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
| Encryption at Rest    | [x] Azure-managed keys [ ] Customer-managed keys      |
| Encryption in Transit | TLS 1.2+ (mandatory)                                  |
| PII Handling          | [ ] Anonymization [x] Pseudonymization [ ] Encryption |

### Section 16.3: Compliance Requirements

| Standard | Required       |
| -------- | -------------- |
| GDPR     | [ ] Yes [ ] No |
| HIPAA    | [ ] Yes [ ] No |
| SOC 2    | [ ] Yes [ ] No |
| PCI-DSS  | [ ] Yes [ ] No |

---

## Article XVII: Legacy & Migration 🟡 IMPORTANT

> **🟡 IMPORTANT**: Migration strategy affects implementation approach and timeline
> **📋 Applies to**: Application Development, Full Stack (if migrating)
> **⏭️ Skip if**: Greenfield Infrastructure Only

### Section 17.1: Migration Context

Select ONE:

- [ ] **Greenfield**
- [ ] **Brownfield**
- [ ] **Legacy Migration**
- [ ] **Strangler Fig** - Incremental replacement

### Section 17.2: Migration Strategy (if applicable)

Select ONE:

- [ ] **Big Bang**
- [ ] **Strangler Fig** - Incremental replacement
- [ ] **Branch by Abstraction**

---

## Article XVIII: API Management

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 18.1: API Gateway

Select ONE:

- [ ] **None** - Direct service access
- [ ] **Azure API Management (APIM)**
- [ ] **Azure Front Door** - Global routing + WAF
- [ ] **YARP**

### Section 18.2: API Features

| Feature        | Enabled        | Configuration                |
| -------------- | -------------- | ---------------------------- |
| Rate Limiting  | [ ] Yes [ ] No | \_\_\_ requests/minute       |
| API Versioning | [ ] Yes [ ] No | Strategy: [ ] URL [ ] Header |

### Section 18.3: API Documentation

| Type         | Tool              | Enabled        |
| ------------ | ----------------- | -------------- |
| REST API     | OpenAPI / Swagger | [ ] Yes        |
| Async Events | AsyncAPI          | [ ] Yes [ ] No |

---

## Article XIX: Governance 🔄

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
| 2.2.0   | [DATE] | [AUTHOR] | Expanded backend stack support to include Python/FastAPI and Go across configuration, tooling, testing, and templates |
| 2.1.0   | [DATE] | [AUTHOR] | Added Project Scope (App/Infra/Full Stack), Landing Zone templates, Infrastructure testing |
| 2.0.0   | [DATE] | [AUTHOR] | Complete rewrite with C#/Node.js options                                                   |
| 1.0.0   | [DATE] | [AUTHOR] | Initial constitution                                                                       |


---

**Scope Constitution for backend** | Generated by Bolt Framework Init.ps1 on 2026-10-07 13:34:00
