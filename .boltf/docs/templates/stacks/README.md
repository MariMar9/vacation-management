# Backend Stack Templates

This folder contains backend stack templates used as a pre-refinement overlay in Bolt Constitution phase 2.

## Current Template

- `dotnet-8-template.md` (reference example)
- `go-template.md` (Go preconfigured defaults)
- `nodejs-nestjs-template.md` (Node.js/TypeScript + NestJS preconfigured defaults)
- `python-fastapi-template.md` (Python + FastAPI preconfigured defaults)
- `stack-template-template.md` (meta-template for creating new stack templates across scopes: backend, data, IA, etc.)

## Purpose

Each stack template must:

- Keep the same article and section IDs as the canonical backend constitution.
- Only prefill decisions and classify them as:
	- **Mandatory**: fixed by stack and not asked again.
	- **Recommended**: suggested for the stack but left unmarked (`[ ]`) and editable during refinement.
	- **User must choose**: always asked during refinement.

This rule avoids drift in article numbering and keeps refinement prompts stable.

Note:

- Current automated overlay/validation scripts in this folder are backend-oriented.
- The meta-template is scope-agnostic and can be used for other scopes (data, IA, etc.).
- For non-backend scopes, apply the same classification rules and canonical parity checks, and use scope-specific scripts when available.

## Usage (Option 2)

1. Run `Init.ps1`.
2. Copy the selected template to the generated backend constitution file.
3. Run Bolt Constitution phase 2 as usual.

### Example (PowerShell)

```powershell
Copy-Item `
	".boltf/docs/templates/stacks/dotnet-8-template.md" `
	"<project-path>/.boltf/memory/backend-constitution.md" `
	-Force
```

Node.js/NestJS example:

```powershell
Copy-Item `
	".boltf/docs/templates/stacks/nodejs-nestjs-template.md" `
	"<project-path>/.boltf/memory/backend-constitution.md" `
	-Force
```

Python/FastAPI example:

```powershell
Copy-Item `
	".boltf/docs/templates/stacks/python-fastapi-template.md" `
	"<project-path>/.boltf/memory/backend-constitution.md" `
	-Force
```

Go example:

```powershell
Copy-Item `
	".boltf/docs/templates/stacks/go-template.md" `
	"<project-path>/.boltf/memory/backend-constitution.md" `
	-Force
```

## Integrated Wizard Flow (Init.ps1)

`Init.ps1` now supports backend template selection when `backend` scope is active:

- Choose from discovered templates in `.boltf/docs/templates/stacks/*-template.md`.
- Or choose `custom` to keep the normal backend constitution flow (no overlay).
- The choice is stored in `.boltf/scopes.yaml` as `project.backend-stack-template`.
- If a template is selected, overlay is applied automatically to `.boltf/memory/backend-constitution.md`.

## Automated Validation and Overlay

Use these scripts to keep numbering/order stable while applying stack defaults.

### Overlay behavior (important)

In overlay mode, `Apply-BackendStackOverlay.ps1` applies only checkbox-driven option lines from the
template to `backend-constitution.md`.

Practical implications:

- **Mandatory** decisions should be marked (`[x]`) when they must be pre-applied by the template.
- **Recommended** decisions may stay unmarked (`[ ]`) as guidance only.
- **User must choose** decisions should stay unmarked (`[ ]`) and be resolved during refinement.

This is intentional for teams that prefer keeping recommendations visible but not preselected.

### 1) Validate structure consistency

```powershell
.\.boltf\scripts\powershell\Validate-BackendStackTemplateStructure.ps1 `
	-CanonicalPath ".boltf/scopes/backend/memory/constitution.md" `
	-TemplatePath ".boltf/docs/templates/stacks/dotnet-8-template.md"
```

### 2) Apply template as overlay (without replacing base file)

```powershell
.\.boltf\scripts\powershell\Apply-BackendStackOverlay.ps1 `
	-CanonicalPath ".boltf/scopes/backend/memory/constitution.md" `
	-TargetPath ".boltf/memory/backend-constitution.md" `
	-TemplatePath ".boltf/docs/templates/stacks/dotnet-8-template.md"
```

Optional dry-run:

```powershell
.\.boltf\scripts\powershell\Apply-BackendStackOverlay.ps1 `
	-CanonicalPath ".boltf/scopes/backend/memory/constitution.md" `
	-TargetPath ".boltf/memory/backend-constitution.md" `
	-TemplatePath ".boltf/docs/templates/stacks/dotnet-8-template.md" `
	-DryRun
```

## Consistency Guardrails

- Do not add, remove, or renumber backend articles.
- Keep original section names (for example `Section 3.3`, `Section 10.2`).
- If a section is auto-resolved by stack, mark it as **Mandatory** but keep the section in place.
- Use `N/A for this stack` notes instead of deleting non-applicable options.
- Every marked option (`[x]`) must match a selectable option label (`[ ]`) in the canonical backend constitution (`.boltf/scopes/backend/memory/constitution.md`), or an explicitly allowed alias handled by the validator. This is validated automatically by `Validate-BackendStackTemplateStructure.ps1`.

### Option Parity Check (marked options)

Before committing template changes, run the validator (it checks both structure and marked-option parity):

```powershell
.\.boltf\scripts\powershell\Validate-BackendStackTemplateStructure.ps1 `
	-CanonicalPath ".boltf/scopes/backend/memory/constitution.md" `
	-TemplatePath ".boltf/docs/templates/stacks/dotnet-8-template.md"
```

Optional manual inspection:

Checked options in templates:

```powershell
Select-String -Path ".boltf/docs/templates/stacks/*-template.md" -Pattern "\[x\]"
```

Selectable options in canonical:

```powershell
Select-String -Path ".boltf/scopes/backend/memory/constitution.md" -Pattern "^- \[ \]"
```

## Authoring Rules

- Keep **Mandatory** minimal (typically language/runtime and direct technical consequences).
- Keep **Recommended** options unmarked (`[ ]`) and add guidance in option text when useful
	(for example, `(recommended for this stack)`).
- Keep organization-specific and governance decisions in **User must choose**.
- Avoid hardcoding a cloud provider unless the stack is explicitly cloud-locked.
