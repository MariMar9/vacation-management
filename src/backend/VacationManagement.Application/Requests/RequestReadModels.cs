namespace VacationManagement.Application.Requests;

public enum RequestStatus
{
    PendingProjectApproval,
    PendingDepartmentApproval,
    Approved,
    Rejected,
    Cancelled
}

public sealed record VacationRequestReadModel(
    Guid Id,
    string RequesterId,
    string DepartmentId,
    string ProjectId,
    DateOnly StartDate,
    DateOnly EndDate,
    string? Reason,
    RequestStatus Status,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt,
    int Version);

public sealed record VacationRequestHistoryItem(
    Guid Id,
    string RequesterId,
    string DepartmentId,
    string ProjectId,
    DateOnly StartDate,
    DateOnly EndDate,
    string? Reason,
    RequestStatus Status,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt,
    int Version,
    bool Taken);

public interface IRequestReadRepository
{
    Task<IReadOnlyList<VacationRequestReadModel>> ListByRequesterAsync(
        string requesterId,
        CancellationToken cancellationToken);
}

    public interface IRequestLifecycleStore
    {
        IReadOnlyList<VacationRequestReadModel> ListAll();

        bool TryAdd(VacationRequestReadModel request);

        bool TryUpdate(
        Guid requestId,
        int expectedVersion,
        Func<VacationRequestReadModel, VacationRequestReadModel?> update,
        out VacationRequestReadModel? updatedRequest);
    }

public interface IRequestReadService
{
    Task<IReadOnlyList<VacationRequestReadModel>> ListAsync(
        string requesterId,
        RequestStatus? status,
        CancellationToken cancellationToken);

    Task<VacationRequestReadModel?> GetByIdAsync(
        string requesterId,
        Guid requestId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<VacationRequestHistoryItem>> GetHistoryAsync(
        string requesterId,
        DateOnly todayInMadrid,
        CancellationToken cancellationToken);
}