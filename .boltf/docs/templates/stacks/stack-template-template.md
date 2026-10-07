# Scope Stack Template Template

This file is a meta-template to create new stack templates for any scope (backend, data, IA, and others) with consistent structure and decision rules.

Use this when adding a new file like:

- `{stack-name}-template.md`

---

## Goal

Every new stack template must classify decisions using only this logic:

- Mandatory (fixed): only decisions that are 100% implied by selecting the stack.
- Recommended (editable): best-practice defaults that fit the stack but can be changed.
- User must choose: no default recommendation, or organization/governance/context-dependent choices.

This avoids accidental lock-in and keeps refinement predictable.

---

## Classification Rules (Source of Truth)

### 1) Mandatory (fixed)

A decision is Mandatory only if ALL conditions are true:

- It is a direct technical consequence of the selected stack.
- Choosing a different value would contradict the selected stack.
- It does not depend on company policy, environment, cloud preference, or product context.

Typical examples:

- Primary language/runtime required by the selected stack.
- Core engine/model family/version when the template is version-specific.

Not valid as Mandatory (unless strictly implied by the stack):

- API style (for example Minimal APIs vs Controllers).
- Architecture style.
- CI/CD platform.
- Cloud provider choices.
- IAM provider.

### 2) Recommended (editable)

Use Recommended when:

- There is a clear best-practice default for the stack.
- It is not forced by the stack.
- User can change it safely.

Important:

- In Recommended sections, do not pre-check options.
- If guidance is needed, add it in text (for example, `(recommended for this stack)`).

### 3) User must choose

Use User must choose when:

- No single recommendation should be imposed.
- The decision depends on organization policy, compliance, scale, budget, cloud strategy, or team preference.
- The section is explicitly governance or process oriented.

Important:

- In User must choose sections, do not pre-check any option.
- If you want to provide guidance, do it as a note, not as a preselected checkbox.

---

## Authoring Checklist

- Keep article and section IDs exactly aligned with the canonical constitution for the selected scope.
- Do not add, remove, or renumber articles.
- Keep non-applicable options as N/A notes, do not delete them.
- Keep Mandatory minimal.
- Keep Recommended options unmarked and add guidance in option text when useful.
- Keep policy/context decisions in User must choose.
- Ensure each User must choose section has no preselected option.
- Add explicit resolution lock keys for all Mandatory stack-derived decisions.
- Ensure every preselected option (`[x]`) maps to an existing option label in the canonical constitution for that scope.

---

## Required Resolution Lock Block

Every stack template must include a lock block in the preamble.

Example:

```text
### Resolution lock for refinement

When `{scope}-stack-template: {stack-key}` is selected, these decisions are locked and must be
persisted as resolved-from-template before asking any scope question:

- `{decision-key-1} = {value}`
- `{decision-key-2} = {value}`

Do not ask these decisions again unless user explicitly requests an override.
```

---

## Skeleton

Copy this skeleton to create a new stack template and fill placeholders.

```markdown
# BOLT Framework Constitution Template - Scope: {SCOPE_DISPLAY_NAME} / Stack: {STACK_DISPLAY_NAME}

> Preconfigured template for {STACK_DESCRIPTION} in scope `{scope}`.
> This file intentionally preserves the same article and section structure as the canonical constitution in `.boltf/scopes/{scope}/memory/constitution.md`.

---

## Preamble 🔄

This template preselects scope decisions for a {STACK_DISPLAY_NAME} project while keeping article numbering and order stable.

**Cloud Provider**: not fixed by this template.

## Decision Model For Refinement

- **🔒 Mandatory (fixed)**: do not ask again.
- **✅ Recommended (editable)**: suggested default (left unmarked), user can change.
- **❓ User must choose**: always ask.

### Mandatory in this stack template

- Primary stack axis: **{PRIMARY_AXIS}**
- Version/runtime/model family: **{STACK_VERSION_OR_ENGINE}**

### Resolution lock for refinement

When `{scope}-stack-template: {stack-key}` is selected, these decisions are **locked** and must be
persisted as resolved-from-template before asking any scope question:

- `{decision-key-1} = {value}`
- `{decision-key-2} = {value}`

Do not ask locked decisions again unless the user explicitly requests an override.

### Recommended defaults in this stack template

- {Scope dimension A}: **{recommended}**
- {Scope dimension B}: **{recommended}**
- {Scope dimension C}: **{recommended}**
- {Delivery/ops baseline if applicable}: **{recommended}**

### User must choose in refinement

- Additional scopes and organization constraints.
- Governance/compliance requirements.
- Environment and deployment policy.
- Cloud-managed service choices.

---

## Article {N}: {Scope Configuration Title}

### Section {N.M}: {Primary Stack Decision} 🔴 CRITICAL

Decision class: **🔒 Mandatory (fixed)**

Select ONE:

- [x] **{PRIMARY_LOCKED_OPTION}**
  - Version/engine: [x] {LOCKED_VALUE} **(LOCKED for {stack-key} template)** [ ] {optional override if explicitly allowed}

- [ ] **{OTHER_OPTION}** (N/A for this stack)

### Section {N.M+1}: {Recommended Stack Choice} 🟡 IMPORTANT

Decision class: **✅ Recommended (editable)**

Select ONE:

- [ ] **{recommended}**
- [ ] **{alternative}**
- [ ] **{alternative}**

---

## Remaining Articles

Keep the full canonical structure unchanged for the selected scope.

For each section:

1. Classify using Mandatory/Recommended/User must choose rules.
2. If User must choose: no preselected option.
3. If Recommended: keep all options unmarked and annotate guidance in option text when needed.
4. If Mandatory: ensure the lock is defined in preamble.
```

---

## Quick QA Before Commit

- Search for "Decision class: **🔒 Mandatory (fixed)**" and verify each one is truly stack-implied.
- Search for "Decision class: **❓ User must choose**" and verify no [x] appears in that section.
- Search for `[x]` options and verify each option label exists in canonical as a selectable option (do not invent new labels).
- Validate article/section parity against canonical constitution for the selected scope.
- Run structure validation script (scope-specific when available).

PowerShell example:

```powershell
.\.boltf\scripts\powershell\Validate-{Scope}StackTemplateStructure.ps1 `
  -CanonicalPath ".boltf/scopes/{scope}/memory/constitution.md" `
  -TemplatePath ".boltf/docs/templates/stacks/{stack-name}-template.md"
```

---

## Notes

- This is a template of templates.
- If in doubt, downgrade to Recommended or User must choose.
- Mandatory must stay intentionally minimal.
- If a scope-specific validator does not exist yet, use manual parity checks until the validator is added.
