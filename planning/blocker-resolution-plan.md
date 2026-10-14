La convención test-only usa refs hermanos no conflictivos: `feature/<feature-name>` para el padre y `bolt/<feature-name>-bolt-<N>-<slug>` para cada Bolt. No se anidan refs Bolt bajo el nombre de la feature.
Los perfiles de decisión F-001–F-006, modelos, contratos y escenarios están cerrados para este proyecto de prueba; las preguntas de uso real permanecen Draft y no bloquean la implementación sintética.
Cada Bolt requiere una rama conforme a la convención, tests RED para comportamiento autorizado, GREEN mínimo, gates aplicables y evidencia documentada antes del siguiente Bolt. Coverage y mutation se miden únicamente cuando exista lógica de feature.

# Plan de Resolución de Bloqueos para F-001–F-006

**Estado:** T001/T002 y readiness documental F-001–F-006 completados para el proyecto de prueba únicamente; no constituye aprobación formal de requisitos, arquitectura de producción ni operación real.
**Fecha de auditoría:** 2026-10-09.
**Baseline de tareas:** [planning/tasks.md](tasks.md), 54 tareas; T001/T002 y los readiness Bolts están cerrados para este alcance de prueba. Ningún Bolt de lógica de negocio está implementado.

## Objetivo

Cerrar los bloqueos de gobernanza y readiness, producir contratos y escenarios aprobados para las seis features y habilitar la construcción de Bolts en orden de dependencia. Las decisiones que requieren sponsor, Product Owner, propietarios de sistemas o autoridades de seguridad no se considerarán resueltas por este plan ni por una selección almacenada en configuración.

## Estado verificado

- El RFP y el Requirements Baseline continúan en Draft como documentos fuente. El usuario los acepta solo como referencias de test/discovery; no hay aprobación formal externa ni sign-off de negocio/producción.
- [`.boltf/scopes.yaml`](../.boltf/scopes.yaml) registra los scopes `backend`, `frontend`, `cloud-platform` e `integration`; `.NET 8`, Angular 20, Podman, Terraform, GitHub Actions, OTel→Azure y GitHub Projects quedan ratificados solo para este proyecto de prueba. `data` no se activa porque la aplicación es transaccional, no una plataforma analítica.
- La [constitución](../.boltf/memory/constitution.md), el [digest](../.boltf/memory/constitution.digest.md), los cuatro refinamientos por scope y el [merge](../.boltf/memory/refinement-states/merged-refinement.yaml) registran las decisiones autorizadas para este test. La [evidencia T001/T002](../.boltf/memory/test-project-approval.md) identifica `MariMar9` solo como identidad de sesión/Git y no como identidad legal verificada.
- La [arquitectura de solución](../docs/design/architecture/solution-architecture.md) sigue siendo propuesta general; [ADR-002](../docs/docs/adr/ADR-002-test-project-architecture-and-controls.md) fija la dirección únicamente para el proyecto de prueba y no aprueba topología productiva.
- Se resolvieron para el test los conflictos de Azure (Azure solo como target test), auto-deploy de UAT/Prod (desactivado; aprobación manual requerida), tracker (GitHub Projects) y mutation score (70%). La convención de rama inválida `feature/<name>/bolt-*` se sustituyó por refs hermanos no conflictivos.
- Los documentos fuente RFP/Baseline y las secciones fuente de requisitos permanecen Draft para uso real. Los perfiles de aceptación test-only, seis modelos, seis planes, seis OpenAPI, contratos simulator/event y Gherkin están enlazados desde [planning/tasks.md](tasks.md) y [el registro de decisiones](../specs/test-project-feature-decisions.md).
- Existe scaffold .NET 8 (Domain/Application/Infrastructure/API/xUnit) y Angular 20. Pasan `dotnet build`, xUnit smoke, `ng build`, Angular unit tests (2), Playwright smoke (1), parser Gherkin, AC-tag coverage y Redocly para seis OpenAPI.
- NPM reportó catorce vulnerabilidades altas en dependencias de desarrollo; `npm audit --omit=dev` reporta cero. No se ejecutó `npm audit fix --force`.
- Las features pueden iniciar Bolts de código en el orden de dependencias definido abajo. Ningún Bolt de lógica está implementado ni se declara pasado un gate de cobertura/mutación antes de ejecutar ese Bolt.

## Plan por fases

### Fase 0: Gobierno y baseline

**T001 — Sponsor y autoridades. Estado: completado para el test solamente.** El usuario declara ser responsable de todos los roles y delega estas decisiones para el proyecto de prueba. El RFP/Baseline se acepta solo como referencia test/discovery, con fecha efectiva 2026-10-09. `MariMar9` (identidad de sesión/Git, no identidad legal verificada) figura como dueño único y A/R para Sponsor, Product Owner, Workflow Owner, Data/Integration Owner, Security/Privacy Authority, Architecture/Platform Authority, Release Authority y Service Owner. El RACI y las limitaciones están en [test-project-approval.md](../.boltf/memory/test-project-approval.md).

**Evidencia y límite:** autorización del usuario en esta conversación de Copilot, con referencia explícita en el registro versionado; no es firma criptográfica ni aprobación externa formal. No se nombran propietarios reales de sistemas externos. T001 no aprueba reglas de features ni readiness.

### Fase 1: Constitución, arquitectura y toolchain

**T002 — Constitución y arquitectura. Estado: completado para el test solamente.** Las decisiones delegadas están registradas en la [constitución](../.boltf/memory/constitution.md), refinamientos por scope, [digest](../.boltf/memory/constitution.digest.md) y [ADR-002](../docs/docs/adr/ADR-002-test-project-architecture-and-controls.md). No se presenta como ratificación formal ni como autorización de despliegue real.

Decisiones globales registradas:

1. Scopes activos: `backend`, `frontend`, `cloud-platform`, `integration`; no activar `data`.
2. Stack: ASP.NET Core .NET 8 Controllers, Angular 20, modular monolith, Azure SQL/EF Core, REST/OpenAPI, simple native CQRS sin MediatR, sin event sourcing y sin broker inicial.
3. Azure Container Apps/Azure SQL son target solo para test; Terraform, Podman, GitHub Actions y OTel→Azure; GitHub Projects.
4. Dev se despliega al merge; UAT/Prod no auto-deploy y requieren aprobación manual. No hay despliegue real autorizado.
5. Umbrales: lint errors 0, tests 100%, line coverage >=80%, branch >=75%, mutation >=70%, frontend Playwright smoke >=1.
6. Entra ID OIDC para usuarios; managed identity para servicios Azure; GitHub OIDC para CI; Key Vault en hosting y User Secrets local.
7. Solo datos sintéticos; cifrado en tránsito/reposo y mínimo privilegio; VNet/private endpoints como targets test; WAF off. Compliance no determinada/no aplicable a este test; no afirmar GDPR/HIPAA.
8. Usar `feature/<feature-name>` y `bolt/<feature-name>-bolt-<N>-<slug>` como refs hermanos.

**Ejecución y validación:** creados cuatro refinamientos y merge, constitución/digest, scope card y ADR-002. Existen scaffolds .NET/Angular y gates locales para build/unit/lint/E2E/contratos. Esto no sustituye aprobación formal ni habilita despliegues reales.

**Salida y límite:** constitución, scopes, ADR, digest, feature decisions, modelos, contratos, Gherkin, planes y scaffolds coherentes para el test project. No hay firma formal ni autorización de producción; no hay code Bolt de feature completado.

### Fase 2: Readiness de cada feature

Los perfiles sintéticos de las seis features están decididos en [el registro de decisiones](../specs/test-project-feature-decisions.md). La tabla resume qué tendría que reaprobarse para uso real; esos puntos no bloquean el test project.

| Feature y tareas     | Pendientes solo para uso real                                                                                                                                                                                                                                                                          | Readiness del test profile                                                                                                                                                                        |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **F-001, T003–T005** | Product Owner/Workflow Owner: campos y semántica de fechas; validaciones y duplicados; estados/transiciones; elegibilidad/efectos de cancelación; histórico y significado de “taken”; categorías de estado; alcance de periodos alternativos FR-024. Seguridad resuelve identidad/propiedad con F-006. | **Completo para test:** decisiones, requisitos, modelo, OpenAPI y Gherkin validados; AC 8/8, schema/model y links pasan. Refrescar labels del mockup requester-list antes de US-003.              |
| **F-002, T018–T020** | Workflow/Process Owner: orden y finality de aprobación, aprobadores requeridos, tratamiento de desacuerdo/rechazo, assess/close, atribución y límites de delegación. Security define matriz rol/scope; F-005 define fuentes de asignación.                                                             | **Completo para test:** modelo/lifecycle/access, OpenAPI, plan y seis escenarios reconciliados con AC; casos condicionales excluidos o decididos. B2 espera F-001 read; B3 espera F-005 snapshot. |
| **F-003, T029–T031** | Business/Department Owner y Data Owner: fuente, jerarquía/scope, periodo y zona horaria, estados contados, definición de “on vacation”, numerador/denominador, umbral 70%, frescura y si el límite bloquea/advierte/solo informa.                                                                      | **Completo para test:** reglas/cálculo, modelo/query contract, datasets de referencia, plan y Gherkin trazan AC. B2 usa fixtures sintéticos; límites son advisory-only.                           |
| **F-004, T037–T038** | Workflow Owner y Email/Communications Owner: eventos de aprobación/cancelación, trigger de finality, destinatarios, canal, contenido, timeout/repetición/supresión, errores/reintentos, delivery evidence y retención. Teams es opcional hasta decisión explícita.                                     | **Completo para test:** catálogo de eventos, simulator contract, política, plan y Gherkin trazan AC; delivery externo y Teams están excluidos.                                                    |
| **F-005, T044–T045** | Data/Integration Owners de ServiceNow y AD: sistemas/productos, autoridad por campo, IDs/mapeos/jerarquías, dirección, schedule/frescura, autenticación, paginación, acknowledgements, errores/reintentos/replay/reconciliación. Confirmar o excluir “my scaturing”.                                   | **Completo para test:** catálogo/mapeos sintéticos, contratos simulator, datasets, plan y Gherkin trazan AC; no se requieren credenciales. B2 importa snapshot local.                             |
| **F-006, T050–T051** | Security/Identity, Privacy y Business Owner: población, proveedor/protocolo, roles/acciones, límites departamento/proyecto, delegados, alta/baja, sesión/denegación, audit/retención, obligaciones de compliance y significado/entorno/población del trial.                                            | **Completo para test:** matriz de acceso, fake-identity contract, requisitos, plan y escenarios permitidos/denegados trazan AC; B2 usa identidades sintéticas locales.                            |

**Gate por paquete:** T005, T020, T031, T038, T045 y T051 están completos para el test profile: decisiones, modelo/contrato/Gherkin y AC traceability validados. Cobertura/mutación son N/A en readiness, no aprobados ni pasados.

### Fase 3: Corregir dependencias y arrancar construcción

Los contratos ya publican límites de proveedor/consumidor antes de implementación; los Bolts pueden probarse con adapters y fixtures locales mientras se construyen.

- **F-001/F-002:** Read/outcome contracts are published. Implement F-001 Bolt 2 before F-002 Bolt 2; then F-002 consumes the F-001 read/eligibility implementation.
- **F-005:** The synthetic snapshot schema is published. Implement F-005 Bolt 2 importer before F-002 Bolt 3 and before demand integration tests; consumers can begin against deterministic fixtures.
- **F-006:** Fake identity/access contract is published. Implement local auth and server-side scope checks; T053 completes cross-feature denial E2E after F-001–F-003 routes exist.

Orden de construcción recomendado, sujeto a reestimación y aprobación del equipo:

1. Iniciar en paralelo F-001 Bolt 2 requester read, F-005 Bolt 2 synthetic snapshot importer y F-006 Bolt 2 local fake-auth shell.
2. Completar F-001 Bolt 3 submit y Bolt 4 cancel después del read shell; usar solo el outbox F-004 simulado.
3. Implementar F-002 Bolt 2 tras F-001 Bolt 2 y F-005 Bolt 2; luego F-002 Bolt 3 delegation con snapshot membership.
4. Implementar F-003 Bolt 2 con requests/snapshot locales; Bolt 3 solo advisory limits.
5. Implementar F-004 Bolt 2 cuando F-001/F-002 emitan eventos; verificar Teams fuera de scope en Bolt 3.
6. Implementar F-005 Bolt 3 como local export outbox después de F-001/F-002 decision handlers; no llamar ServiceNow real.
7. Cerrar F-006 T053 con matriz E2E server-side cuando existan rutas F-001–F-003.

Cada Bolt requiere branch/issue conforme a la convención ya corregida, tests RED por comportamiento aprobado, GREEN mínimo, suite y gates ratificados, refactor sin cambio de comportamiento y evidencia documentada antes del siguiente Bolt.

## Trabajo ejecutado en esta solicitud

- Registrados T001/T002 y Q001–Q027 para el test scope únicamente; se mantienen límites de origen/producción y no se afirma aprobación externa.
- Actualizados los seis requisitos con aceptación test-only; creados seis data models, seis planes, seis OpenAPI y los contratos de eventos/simulator; AC tags de Gherkin trazan todos los IDs.
- Añadidos mockups submit/cancel F-001. F-002 conserva seis escenarios reconciliados; reglas de assess/close y Teams quedan excluidas.
- Scaffold .NET 8 (Domain/Application/Infrastructure/API/xUnit) y Angular 20 generado; endpoint `/health` tiene TDD RED→GREEN. `dotnet build/test`, `ng build/test` (2), Playwright `@smoke` (1), parser Gherkin, AC coverage y Redocly (6/6) pasan.
- Se generó `.gherkin-lintrc` y `stryker-config.json`. NPM audit reporta 14 high en dependencias dev (Karma/Angular ESLint ranges); `npm audit fix` no las resuelve sin `--force`/downgrade mayor; `npm audit --omit=dev` reporta 0. No se forzó actualización.
- No se implementaron reglas de negocio de features, integración real, credenciales ni despliegues. No se creó rama de implementación; el primer Bolt está listo para iniciar con la convención `bolt/...`.

## Criterio global para empezar código

Los readiness profiles y scaffolds de test están listos. Puede iniciarse el primer Bolt de código creando una rama `bolt/<feature-name>-bolt-<N>-<slug>` desde la rama feature. Cada Bolt debe ejecutar RED/GREEN, tests pertinentes y su gate antes de abrir el siguiente. Stryker está configurado; coverage/mutation de feature se medirán sobre lógica real y no se consideran pasados por el scaffold.

## Evidencia de origen

- [Cross-feature tasks](tasks.md)
- [Scopes wizard configuration](../.boltf/scopes.yaml)
- [Test-project constitution](../.boltf/memory/constitution.md)
- [Constitution initial metadata](../.boltf/memory/constitution-init.md)
- [Source requirements baseline](../origin/Requirements-Baseline.md)
- [Source RFP](../origin/RFP-Vacation-Management.md)
- [Architecture proposal](../docs/design/architecture/solution-architecture.md)
