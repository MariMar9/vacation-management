using VacationManagement.Application.Requests;

namespace VacationManagement.Application.Exports;

public sealed record VacationExportRecord(
    Guid RequestId,
    int RequestVersion,
    string IdempotencyKey,
    string Status,
    int AttemptCount,
    DateTimeOffset CreatedAt,
    DateTimeOffset? LastAttemptAt);

public sealed record VacationExportEvaluation(bool SimulateFailure);

public interface IVacationExportOutbox
{
    VacationExportRecord QueueApproved(VacationRequestReadModel request, DateTimeOffset createdAt);

    IReadOnlyList<VacationExportRecord> List();

    int EvaluatePending(DateTimeOffset attemptedAt, bool simulateFailure);
}