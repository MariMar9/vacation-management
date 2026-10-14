# F-003 Mockups

**Status:** Draft wireframes for stakeholder review. F-003 requirements and baseline are not formally approved.

| Flow              | User story                                                      | States                         |
| ----------------- | --------------------------------------------------------------- | ------------------------------ |
| `demand-overview` | US-001 to US-003: inspect department/project demand and periods | default, empty, loading, error |

Open HTML files directly in a browser, or serve their folder with `python -m http.server` from the repository root.

## Decisions and Limits

- Scope, date period, and day/week controls are shown disabled because the organization hierarchy, period semantics, and date boundaries are unresolved (FR-015 to FR-018).
- Counts are placeholders; no values, numerator, denominator, included request states, or 70% threshold are invented (FR-011, FR-016, FR-020, FR-033).
- Capacity-limit management is omitted because owner, scope, and block/warn/display behavior are unresolved (FR-019).
- This read-only flow has no success state; no limit change or submission action is represented.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
