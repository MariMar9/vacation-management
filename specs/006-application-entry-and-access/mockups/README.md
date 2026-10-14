# F-006 Mockups

**Status:** Draft wireframes for stakeholder review. The F-006 access requirements and baseline are not formally approved.

| Flow                | User story                                                                          | States         |
| ------------------- | ----------------------------------------------------------------------------------- | -------------- |
| `application-entry` | US-001 / FR-025: reach the application entry point from a stakeholder-approved link | default, error |

Open the HTML files directly in a browser, or serve the folder with `python -m http.server` from the repository root.

## Decisions and Limits

- No identity provider, sign-in form, authentication challenge, role picker, or access matrix is shown because SEC-001/SEC-002 are draft proposals.
- The link-based trial is omitted because “try,” audience, environment, duration, data, and permitted actions are unresolved (US-002, FR-026).
- Empty and success states do not apply to the entry-only capability as currently specified. A loading state is omitted because no loading behavior is defined.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
