# F-003 Data Model: Demand Query

**Status:** Approved for the synthetic-data test profile only; see [feature decisions](../../test-project-feature-decisions.md).

## Query: DemandSummary

Inputs: `scopeType` (`Department` or `Project`), `scopeId`, inclusive `fromDate`, inclusive `toDate`, and display period (`Day` or ISO week). The selected scope must exist in the latest valid F-005 snapshot.

| Output                     | Type         | Definition                                                                           |
| -------------------------- | ------------ | ------------------------------------------------------------------------------------ |
| `scopeType` / `scopeId`    | enum/string  | Echo selected direct scope.                                                          |
| `fromDate` / `toDate`      | date         | Inclusive date range.                                                                |
| `activeMemberCount`        | integer      | Unique active synthetic members assigned directly to scope.                          |
| `peopleOnApprovedVacation` | integer      | Unique members with an Approved request overlapping the period.                      |
| `demandPercentage`         | decimal/null | `peopleOnApprovedVacation / activeMemberCount * 100`; null when denominator is zero. |
| `thresholdExceeded`        | boolean      | True when demand percentage >= 70; advisory only.                                    |
| `capacityExceeded`         | boolean      | True when an optional configured limit is exceeded; advisory only.                   |
| `dataAsOf`                 | date-time    | `generatedAt` of the F-005 snapshot used.                                            |
| `stale`                    | boolean      | Snapshot older than 36 hours.                                                        |

An overlapping request satisfies `startDate <= toDate` and `endDate >= fromDate`. Count each person once per period, regardless of overlapping request count. Only status `Approved` counts; pending/rejected/cancelled do not.

## Entity: CapacityLimit

| Field                       | Type             | Required | Constraints                                    |
| --------------------------- | ---------------- | -------- | ---------------------------------------------- |
| `id`                        | UUID             | Yes      | Server generated.                              |
| `scopeType` / `scopeId`     | enum/string      | Yes      | Department or direct project scope.            |
| `periodStart` / `periodEnd` | date             | Yes      | Inclusive; valid ordered range.                |
| `maxConcurrentPeople`       | integer          | Yes      | Positive integer; optional record, no default. |
| `updatedBy` / `updatedAt`   | string/date-time | Yes      | DepartmentApprover and UTC timestamp.          |

A limit affects only `capacityExceeded` advisory display. It never blocks request submission, approval, or export.
