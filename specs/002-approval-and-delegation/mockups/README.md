# F-002 Mockups

**Status:** Draft wireframes for stakeholder review. F-002 is not formally approved; these do not establish access policy or decision finality.

| Flow                  | User story / use case    | States                         |
| --------------------- | ------------------------ | ------------------------------ |
| `project-review`      | US-001 / UC-001          | default, empty, loading, error |
| `project-decision`    | US-002 / UC-002 / UC-003 | default, error, success        |
| `department-decision` | US-002 / UC-002          | default, error, success        |
| `delegation`          | US-004 / UC-005          | default, error, success        |

Open an HTML file directly in a browser, or serve its folder with `python -m http.server` from the repository root.

## Decisions and Limits

- Reviewer navigation is a placeholder; role visibility depends on an approved access matrix.
- Project and department decision screens are separate. Project rejection is not shown as a department action.
- No approval ordering, overall finality, rejection reason, reassignment, notification, or export behavior is invented.
- Delegation UI is conditional; same-project eligibility is shown, while scope, duration, acceptance, and active policy remain unresolved.
- `UC-003` assess/close is omitted because its meaning and outcome are undefined. `UC-006` approver resolution has no defined human-facing screen. `US-005 AC-005.2` remains pending clarification.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
