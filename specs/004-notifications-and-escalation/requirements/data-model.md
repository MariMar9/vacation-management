# F-004 Data Model: Notification Outbox

**Status:** Approved for the synthetic-data test profile only; delivery uses a local simulator. See [feature decisions](../../test-project-feature-decisions.md).

## Entity: NotificationOutbox

| Field            | Type      | Required | Constraints                                                                                                                                    |
| ---------------- | --------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`             | UUID      | Yes      | Server generated.                                                                                                                              |
| `eventKey`       | string    | Yes      | Unique idempotency key from source event and recipient.                                                                                        |
| `requestId`      | UUID      | Yes      | References F-001 request.                                                                                                                      |
| `eventType`      | enum      | Yes      | `RequestSubmitted`, `ProjectApproved`, `RequestFinallyApproved`, `RequestRejected`, `RequestCancelled`, `RequestReminder`, `RequestEscalated`. |
| `recipientId`    | string    | Yes      | Synthetic test user ID.                                                                                                                        |
| `occurredAt`     | date-time | Yes      | UTC event time.                                                                                                                                |
| `payload`        | object    | Yes      | Request ID, event, recipient, status/decision and app link only; no reason or unnecessary personal data.                                       |
| `deliveryStatus` | enum      | Yes      | `Pending`, `Delivered`, `Failed`.                                                                                                              |
| `attemptCount`   | integer   | Yes      | 0–3; simulator is deterministic.                                                                                                               |
| `createdAt`      | date-time | Yes      | UTC.                                                                                                                                           |

## Escalation Evaluation

- Reminder once at 3 calendar days and escalation once at 5 calendar days from the current approval-level start.
- Suppress pending notifications after `Approved`, `Rejected`, or `Cancelled`.
- No repeated escalation. The simulator records delivery; it does not send SMTP/Teams messages.
- Outbox fixture records expire after 90 days. This is a test-data cleanup rule, not a legal retention policy.

## Ownership

F-001/F-002 produce source events. F-004 owns event-to-recipient mapping and the local outbox simulator. External transport contracts remain out of scope.
