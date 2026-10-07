# Azure DevOps Skills

Skills especializados para integración con Azure DevOps.

## Skills Disponibles

### azdo-sync

#### Sincronización bidireccional BOLT ↔ Azure DevOps

- Exporta features BOLT a Azure DevOps (Epic/Features/PBIs/Tasks)
- Importa work items existentes de Azure DevOps
- Sincroniza estados y actualizaciones
- Asigna work items a sprints
- Gestiona jerarquías parent-child

**Cuándo usar**: Proyectos que usan Azure DevOps Boards para gestión de trabajo.

📁 **Contenido**: Scripts PowerShell/Bash, mappings JSON, templates.

[Ver documentación completa](azdo-sync/README.md)

---

### azdo-wiki

#### Publicación automática en Azure DevOps Wiki

- Sincroniza documentación Markdown a Wiki
- Convierte diagramas Mermaid a SVG
- Gestiona attachments y assets
- Mantiene estructura de carpetas

**Cuándo usar**: Proyectos que documentan en Azure DevOps Wiki.

📁 **Contenido**: Scripts PowerShell, conversores Mermaid, templates.

[Ver documentación completa](azdo-wiki/README.md)

---

## Activación

- `azdo-sync`: **solo** desde `.boltf/scopes/work-management/scope.yaml` (owner único — ver
  `docs/bolt-plugin-distribution-proposal.md`). No se vendoriza también desde `integration` porque
  tener el mismo skill (`name: azdo-sync`) activo en dos plugins simultáneamente rompe la carga
  de skills en Copilot (`Failed to load 1 skill`).
- `azdo-wiki`: desde `.boltf/scopes/integration/scope.yaml`.

Para activar `azdo-sync`, editar `scopes/work-management/scope.yaml` y cambiar `enabled: true`:

```yaml
- id: work-management-azure-devops-sync-skill
  kind: skills
  enabled: true # Cambiar aquí
  tags: ['azure-devops', 'sync']
  source:
    type: local_folder
    path: available-skills/azdo/azdo-sync
  destination:
    folder: .claude/skills
    name: azdo-sync
```

## Requisitos

- Azure DevOps Personal Access Token (PAT)
- Azure CLI con extensión azure-devops
- PowerShell 7+ o Bash

## Referencias

- [Azure DevOps REST API](https://learn.microsoft.com/rest/api/azure/devops)
- [Azure DevOps CLI](https://learn.microsoft.com/azure/devops/cli/)
