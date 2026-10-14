# UC-006: Resolve Approver Responsibility

## Scenario

backend+frontend

## Scope

F-002 Approval and Delegation. This system-supported use case covers identifying project approvers and establishing the responsibility used by review and decision flows. The implementation stack is not decided.

## Level

Subfunction

## Primary Actor

System

## Secondary Actors

- Project/data owner
- Project approver
- Department approver
- Employee/requester

## Trigger

The system needs to establish the project approver for a request or project review.

## Preconditions

- The request or project can be associated with an agreed project identifier.
- An approved source and mapping rule for project approver identity are available.
- The applicable role, scope, and authorization rules have been approved.

## Main Success Scenario

1. The system obtains the request's project association.
2. The system consults the approved source and mapping rule for that project.
3. The system resolves the designated project approver or approvers under the approved cardinality rule.
4. The system makes the request available only to those authorized approvers within their approved scope.
5. The system makes the resolved responsibility available to the approval workflow without inferring approval sequence or finality.

## Alternative Flows

- 3a. The approved rule permits multiple project approvers: the system resolves the applicable set and applies the stakeholder-defined assignment/decision rules.
- 3b. Stakeholders approve the approximately-50-person department coverage rule: the system applies the approved department-size measure and approver-coverage rule.
- 3c. The project is not associated with a department-level approval: the system follows the approved rule for that case; no department decision requirement is inferred here.

## Error Flows

- 2a. The source is unavailable or stale: the system cannot verify the mapping and follows the approved fallback/freshness policy; that policy is currently undefined.
- 3d. No project approver is found: the system reports unresolved responsibility and does not invent an approver; routing, blocking, and escalation behavior require stakeholder definition.
- 3e. Multiple or conflicting mappings violate the approved rule: the system reports an assignment conflict and does not select an arbitrary approver.
- 4a. A resolved person lacks approved access for the relevant scope: the system does not grant access solely because the person appears in source data.

## Postconditions

- Success: the approved project responsibility is resolved and available for scoped review; no approval decision is made.
- Failure: responsibility remains unresolved, and the system does not disclose requests or grant authority based on an unverified mapping.

## Business Rules

- The system identifies the project approver using an approved source (FR-028; INT-003).
- Interpretation of project membership and relationships to approvers depends on INT-004 and is not yet settled.
- FR-031's approximately-50-person coverage statement is not treated as a rule until confirmed and made measurable.
- The identity of "responsible approver" in FR-010 and FR-032 remains unresolved.

## Security and Authorization Rules

- A source mapping is not, by itself, proof of authorization; apply the approved role/action and project-scope policy.
- Do not expose project requests or permit decisions while the actor's scope cannot be established.
- The access matrix, role assignment/revocation, and privacy/audit requirements remain open under SEC-001 to SEC-003.

## Requirements Covered

- F-002 US-005, AC-005.1 and AC-005.2
- FR-010, FR-028, FR-031, FR-032
- INT-003, INT-004
- SEC-001 to SEC-003 (draft/unresolved)

## Open Questions

- Who owns and maintains project and department approver assignments, and what source is authoritative?
- May a project or department have zero, one, or multiple approvers? How are conflicting mappings resolved?
- Who is the "responsible" approver in FR-010 and FR-032, and what actions and scope does that role have?
- Is FR-031 a committed requirement or an example, and how are department size and approver coverage measured?
- How do role assignment, multiple roles, delegation, and source-data freshness affect authorization?
- What fallback, escalation, and recovery behavior applies when mappings are missing, stale, or inconsistent?
