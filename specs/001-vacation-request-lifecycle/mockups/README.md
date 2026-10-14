# F-001 Mockups

**Status:** Original requester-list wireframes remain draft source references. Additional flow mockups below are approved only for the synthetic test project; see [test decisions](../../test-project-feature-decisions.md).

| Flow             | User story                                                                                          | States                                                                                                                                                     |
| ---------------- | --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `my-requests`    | US-003; own request history with pending/approved/non-approved groups and derived taken label       | default, empty, loading, error (original draft references; update before feature UI implementation)                                                        |
| `request-submit` | US-001; select project, inclusive start/end date, optional reason, validation and submission result | [default](request-submit-default.html), [loading](request-submit-loading.html), [error](request-submit-error.html), [success](request-submit-success.html) |
| `request-cancel` | US-002/US-004; cancel only before project decision; approved requests have no cancel action         | [default](request-cancel-default.html), [error](request-cancel-error.html), [success](request-cancel-success.html)                                         |

Open the HTML files directly in a browser, or serve this folder with `python -m http.server` from the repository root and navigate to this directory.

## Decisions and Limits

- All names, request rows, and dates are synthetic. No real user data is shown.
- The original `my-requests` HTMLs predate the test-profile decisions and are visual references only; update their role/status labels before implementing that view.
- Use `request-submit-*` and `request-cancel-*` as the current test-profile flow references. They do not authorize production behavior.
- The shared rule set is in [test-project-feature-decisions.md](../../test-project-feature-decisions.md); source RFP/requirements remain Draft for real-world use.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
