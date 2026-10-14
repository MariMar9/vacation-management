namespace VacationManagement.Application.Requests;

public sealed class RequestReadService(IRequestReadRepository repository) : IRequestReadService
{
    public async Task<IReadOnlyList<VacationRequestReadModel>> ListAsync(
        string requesterId,
        RequestStatus? status,
        CancellationToken cancellationToken)
    {
        var requests = await repository.ListByRequesterAsync(requesterId, cancellationToken);
        return status is null
            ? requests
            : requests.Where(request => request.Status == status).ToArray();
    }

    public async Task<VacationRequestReadModel?> GetByIdAsync(
        string requesterId,
        Guid requestId,
        CancellationToken cancellationToken)
    {
        var requests = await repository.ListByRequesterAsync(requesterId, cancellationToken);
        return requests.SingleOrDefault(request => request.Id == requestId);
    }

    public async Task<IReadOnlyList<VacationRequestHistoryItem>> GetHistoryAsync(
        string requesterId,
        DateOnly todayInMadrid,
        CancellationToken cancellationToken)
    {
        var requests = await repository.ListByRequesterAsync(requesterId, cancellationToken);
        return requests
            .Select(request => new VacationRequestHistoryItem(
                request.Id,
                request.RequesterId,
                request.DepartmentId,
                request.ProjectId,
                request.StartDate,
                request.EndDate,
                request.Reason,
                request.Status,
                request.CreatedAt,
                request.UpdatedAt,
                request.Version,
                request.Status == RequestStatus.Approved && request.EndDate < todayInMadrid))
            .ToArray();
    }
}