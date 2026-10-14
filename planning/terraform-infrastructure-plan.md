# Terraform Infrastructure Plan: Vacation Management

**Status:** Planning proposal only; not an approved infrastructure design.
**Execution:** No `.tf` modules generated, no `terraform init/validate/plan` run, and no infrastructure applied.
**Target environments:** Dev, UAT, Prod (recorded in `.boltf/scopes.yaml`; approval status requires confirmation).
**IaC tool:** Terraform is recorded in `.boltf/scopes.yaml`; provider and target services are not approved.

## Decision Gate

The request asks to provision infrastructure from an approved architecture, but the current [solution architecture](../docs/design/architecture/solution-architecture.md) explicitly says it is a proposal. The [requirements baseline](../origin/Requirements-Baseline.md) says Draft and does not approve the RFP's proposal. The project [constitution](../.boltf/memory/constitution.md) is an unratified template. In particular:

- The baseline names Azure and Amazon as cloud options and does not select a provider; the template says Azure mandatory but is not ratified.
- The logical architecture does not choose compute, database/storage, messaging, registry, network topology, resource regions, or identity provider.
- `.boltf/scopes.yaml` records Terraform, Azure-oriented observability/security values, and `auto-deploy` for Dev/UAT/Prod, but these are generated scope settings and conflict with the unapproved architecture. They must be ratified before use. Production auto-deployment must receive explicit release-authority review.
- Terraform is not installed in the current terminal, and the repository contains no Terraform configuration or lock file. Therefore there is no executable configuration to validate or plan.

**Plan result:** Resource-level Terraform and an executable Terraform plan are blocked. This document gives the proposed module shape and the approval/validation sequence only; it deliberately does not choose Azure resources or make a plan appear safe when the architecture is unresolved.

## Plan Objective

Provide a reusable Terraform module composition for Dev, UAT, and Prod covering networking, identity/RBAC, configuration/secrets, compute, database/storage, messaging, monitoring/alerts, container registry, state management, tagging/cost controls, and security scanning. Promote shared module versions consistently while keeping environment-specific state, configuration, access, and release controls isolated.

## Proposed Repository Layout

The names below are a candidate layout, not created directories or resource choices.

```text
infra/terraform/
  versions.tf
  providers.tf
  modules/
    networking/
    identity-rbac/
    configuration-secrets/
    compute/
    data-storage/
    messaging/
    monitoring-alerts/
    container-registry/
    tagging-cost/
  bootstrap-state/
  environments/
    dev/
      main.tf
      backend.hcl.example
      terraform.tfvars.example
    uat/
      main.tf
      backend.hcl.example
      terraform.tfvars.example
    prod/
      main.tf
      backend.hcl.example
      terraform.tfvars.example
  policies/
  security-scan/
```

Keep the state-backend bootstrap separate from the state it creates. Do not store credentials, production secrets, real resource identifiers, or sensitive values in checked-in tfvars. Do not commit `.tfstate`, plan files, credentials, or secret-bearing outputs.

## Module Plan

| Module                                              | Responsibility                                                                                                            | Inputs requiring approval                                                                                                                                                           | Candidate dependency order                                                  |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `bootstrap-state`                                   | Create/provision a protected remote state backend, access policy, encryption, versioning/retention, and locking strategy. | Cloud/provider, state account/project, identity, recovery/retention policy, separation/approval model. Azure Blob backend is only a candidate if Azure is approved.                 | First, operated as a separately protected bootstrap root.                   |
| `tagging-cost`                                      | Enforce required metadata and cost allocation conventions; define budget/alert hooks without hard-coding amounts.         | Required tag keys/values, owners, cost center, budget authority, allowed missing values.                                                                                            | Called by all environment compositions.                                     |
| `networking`                                        | Define ingress/egress, address space, subnets, DNS, private connectivity, firewall/WAF boundaries.                        | Provider, region, CIDRs, public/private exposure, on-prem connectivity, threat model. `.boltf/scopes.yaml` records VNet/private endpoints but is unratified.                        | Before private compute/data/registry integrations.                          |
| `identity-rbac` (Identity and RBAC)                 | Create workload/deployment identities and least-privilege role assignments with separation of duties.                     | Identity provider, tenant/subscription/project scope, RBAC model, human/service roles, OIDC/managed identity choice.                                                                | Before secrets, data, compute and deployment permissions.                   |
| `configuration-secrets` (Configuration and secrets) | Provide non-secret configuration and a secret-store boundary; applications retrieve secret values at runtime.             | Approved secret manager, naming, rotation, access policy, environment isolation, secret references. Azure Key Vault is a candidate, not approved.                                   | Depends on identity; precedes compute configuration.                        |
| `data-storage`                                      | Provide the approved application database/storage and backup/retention foundations.                                       | Database engine, consistency/capacity, private access, backup/restore/RTO/RPO, data classification and retention. No engine is selected.                                            | Depends on network, identity, secret/config and tags.                       |
| `messaging`                                         | Provide broker/queue/topic resources only if approved asynchronous workflows require them.                                | Messaging requirement, service/provider, delivery semantics, ordering, retention, DLQ/retry and ownership. Architecture identifies no approved broker.                              | Conditional; depends on network, identity and monitoring.                   |
| `container-registry`                                | Store/sign/scan application images if container deployment is selected.                                                   | Container decision, registry provider, SKU/replication, retention, trust/signing and image access model. ACR is conditional on Azure and container approval.                        | Before container compute; depends on identity, network and tags.            |
| `compute`                                           | Host the web experience, application core and scheduled exchange according to approved deployment topology.               | App topology, runtime/container decision, region, sizing/autoscale, ingress, availability, secrets, health probes. App Service/Container Apps/AKS are alternatives, not selections. | After network, identity, config, and data/messaging interfaces are defined. |
| `monitoring-alerts`                                 | Set telemetry workspace/collection, diagnostics, dashboards, alerts, action routing and retention.                        | Telemetry provider, signals, data minimization, SLI/SLO, alert owner/routing, retention/cost. `otel-azure` is recorded in scopes but not architecture-approved.                     | Foundation alongside network/state; connect all deployed modules.           |
| `security-scan`                                     | Run static IaC checks, provider policy, dependency/image scans and report-only gates before enforcement.                  | Approved scanners, severity thresholds, exception process, policy source, CI platform. Terraform fmt/validate and plan review precede any deployment.                               | Pipeline gate before plan approval and any apply.                           |

The module boundaries may be combined or split after the architecture decision. Do not encode individual `azurerm_*` resources until provider, services, topology, and security decisions are approved.

## Environment Composition

Use the same versioned modules for all environments, with separate environment roots/state and reviewed variable sets. Isolation boundary (separate subscriptions/accounts vs. resource groups/projects) is a decision, not presumed.

| Environment | Candidate purpose/composition                                                                                                                                                     | Required safeguards and unresolved settings                                                                                                                                                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dev         | Lowest-cost approved networking, identities, configuration, application runtime, data services, messaging if selected, registry access, diagnostics and test-only integrations.   | No production data by default; approve developer access, secret isolation, network exposure, teardown/retention, and ephemeral resources. Exact sizing/region unresolved.                                                                                       |
| UAT         | Production-representative module versions and access boundaries, test data, external-system test endpoints, monitoring and release-candidate validation.                          | Data masking/consent, test identity controls, integration isolation, refresh schedule, test restore/retention. Exact topology and scale unresolved.                                                                                                             |
| Prod        | Approved production topology and runtime, protected data, least-privilege identities, restricted ingress/egress, backup/restore, monitoring/alerts, budgets and release controls. | No apply without security/compliance, performance/recovery, operations and business release approval. `.boltf/scopes.yaml` currently records auto-deploy for Prod, but that is unratified and must not be implemented without explicit release-policy approval. |

Environment configuration should vary only through reviewed values and deliberate policy, not copied divergent module code. Secrets are provisioned/referenced securely per environment, never embedded in tfvars or plan output.

## Dependency and Provisioning Order

1. **Approval and design baseline:** ratify cloud/provider, regions, services, network, identity, data, security, environments, tags/cost and release gates.
2. **Toolchain/bootstrap:** install a pinned Terraform CLI version and approved providers; establish the protected remote state backend in a separate bootstrap root and verify access/locking.
3. **Shared controls:** tagging/policy, security scanning, foundational monitoring and logging destinations.
4. **Network and identity:** provision approved network boundaries and workload/deployment identities/RBAC.
5. **Configuration and data:** provision approved secret/config service and data/storage, with private paths and backup controls.
6. **Conditional registry and messaging:** provision only if containerization/asynchronous messaging is approved.
7. **Compute:** deploy host topology and scheduled work with approved probes, scaling and secret references.
8. **Environment roots:** initialize/validate/plan Dev first, then UAT, then Prod. Review each plan separately; no apply is permitted under this request.

## State Management and Security

- Use a remote state backend with encryption, locking/concurrency control, versioning/recovery, narrow RBAC and audit; choose its service only after provider approval.
- Bootstrap state separately; never keep production state in the source repository or use a shared state key for Dev/UAT/Prod.
- Use workload identity/managed identity or federated pipeline identity where supported; prohibit committed client secrets and shared administrator credentials.
- Restrict state and plan artifact access because both can expose sensitive infrastructure metadata or values.
- Keep provider/module versions constrained and commit the dependency lock file after the provider choice is approved.
- Run format, validate, IaC security/policy scanning, dependency checks, and a reviewed `terraform plan` per environment. Keep scan findings/approved exceptions as artifacts.
- Do not use `terraform apply`, `apply -auto-approve`, resource create/update tools, or deployment pipelines in this task.

## Tagging and Cost Controls

Propose a tag schema for approval, not policy: `application`, `environment`, `owner`, `costCenter`, `managedBy`, `dataClassification`, `service`, and `expiry` for ephemeral resources. Required keys, allowed values, data classification, and exception behavior need owner approval. Set budgets/alerts and cost estimates only after finance/platform owners provide amounts and cost-center mapping; current BR-007/NFR-006 specify cost sensitivity but no budget or ceiling.

## Security Scanning and Plan Validation

### Preflight

- Terraform CLI: not detected in the current shell. Azure Terraform guidance gives `winget install Hashicorp.Terraform` as the Windows install command; do not install without project/user approval.
- No Terraform configuration, variable files, provider lock file, or backend configuration currently exists under `infra/`.
- No cloud subscription/account, tenant/provider credentials, or environment target was selected or supplied in the approved architecture.

### Validation sequence (after decisions and code are approved)

1. `terraform fmt -check -recursive` for deterministic formatting.
2. Initialize the selected backend/provider in a non-production plan context; do not migrate state without an approved migration plan.
3. `terraform validate` before planning, as required by the Azure Terraform guidance.
4. Run the approved static IaC/security policy scanners and provider/module/dependency checks; review every finding and exception.
5. Generate a saved plan per environment (`terraform plan -out=<environment>.tfplan -var-file=<environment>.tfvars`) only after backend, provider and variables are available.
6. Review the plan for unintended replacements/deletions, public exposure, privilege escalation, secret leakage, data loss, cost and environment drift; obtain the required reviewer signatures.
7. Stop. No `terraform apply` or deployment occurs under this request.

**Current validation result:** No executable Terraform validate/plan can run because Terraform is absent and there are no `.tf` roots/provider/backend/variables. The plan document itself can be structurally checked, but this does not validate Azure resource configuration.

## Approval Decisions Required Before Terraform Modules

1. Formally approve the architecture and select Azure vs. AWS/other provider; reconcile the unratified constitution Azure statement.
2. Confirm subscription/account and tenancy/environment isolation, regions, naming, network CIDRs, DNS and ingress/egress boundaries.
3. Select compute service/topology for web, application core and scheduled exchange; decide whether containers are used.
4. Select data store/storage, backup/restore, retention, encryption/key ownership and recovery objectives.
5. Decide whether a broker is required and define its delivery/retention contract.
6. Select identity/RBAC model, deployment identity, secret/config service and environment-specific permissions.
7. Approve registry, observability provider/retention/alerts, tags, budgets and cost-review ownership.
8. Approve Terraform backend/state separation, CI validation/security scanners, production approval and apply authority.

## Proposed Plan Acceptance Checklist

- [ ] Architecture and cloud/provider approved.
- [ ] Module service selections, environment boundaries, state and identity decisions approved.
- [ ] Module dependency order and environment composition reviewed by platform/security/data/operations owners.
- [ ] Dev/UAT/Prod variable schemas defined with secret-safe handling.
- [ ] Validation/scanning tools and thresholds approved.
- [ ] Terraform executable plan generated and reviewed for each environment; no apply performed.

## References

- [Solution architecture (proposal)](../docs/design/architecture/solution-architecture.md)
- [Requirements baseline (Draft)](../origin/Requirements-Baseline.md)
- [Project constitution template](../.boltf/memory/constitution.md)
- [Scope configuration](../.boltf/scopes.yaml)
- [Azure Terraform best practices](https://developer.hashicorp.com/terraform/language/style)
- [AzureRM provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
