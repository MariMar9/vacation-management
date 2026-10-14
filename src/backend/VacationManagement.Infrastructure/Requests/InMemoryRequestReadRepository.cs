using VacationManagement.Application.Requests;

namespace VacationManagement.Infrastructure.Requests;

public sealed class InMemoryRequestReadRepository : IRequestReadRepository, IRequestLifecycleStore
{
    private static readonly DateTimeOffset SeededAt = new(2026, 10, 9, 8, 0, 0, TimeSpan.Zero);
    private readonly object sync = new();

    private readonly List<VacationRequestReadModel> requests =
    [
        Create("EMP-TEST-001", "PRJ-TEST-ALPHA", RequestStatus.Approved, new(2026, 9, 1), new(2026, 9, 5)),
        Create("EMP-TEST-001", "PRJ-TEST-ALPHA", RequestStatus.Approved, new(2026, 10, 8), new(2026, 10, 12)),
        Create("EMP-TEST-001", "PRJ-TEST-ALPHA", RequestStatus.Rejected, new(2026, 11, 2), new(2026, 11, 6)),
        Create("EMP-TEST-001", "PRJ-TEST-ALPHA", RequestStatus.Cancelled, new(2026, 12, 1), new(2026, 12, 3)),
        Create("EMP-TEST-001", "PRJ-TEST-ALPHA", RequestStatus.PendingProjectApproval, new(2026, 12, 21), new(2026, 12, 30)),
        Create("EMP-TEST-002", "PRJ-TEST-ALPHA", RequestStatus.Approved, new(2026, 9, 1), new(2026, 9, 5))
    ];

    public Task<IReadOnlyList<VacationRequestReadModel>> ListByRequesterAsync(
        string requesterId,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        IReadOnlyList<VacationRequestReadModel> results;
        lock (sync)
        {
            results = requests
                .Where(request => request.RequesterId == requesterId)
                .OrderByDescending(request => request.CreatedAt)
                .ToArray();
        }
        return Task.FromResult(results);
    }

    public IReadOnlyList<VacationRequestReadModel> ListAll()
    {
        lock (sync)
        {
            return requests.ToArray();
        }
    }

    public bool TryAdd(VacationRequestReadModel request)
    {
        lock (sync)
        {
            if (requests.Any(existing => existing.Id == request.Id))
            {
                return false;
            }

            requests.Add(request);
            return true;
        }
    }

    public bool TryUpdate(
        Guid requestId,
        int expectedVersion,
        Func<VacationRequestReadModel, VacationRequestReadModel?> update,
        out VacationRequestReadModel? updatedRequest)
    {
        lock (sync)
        {
            var index = requests.FindIndex(request => request.Id == requestId);
            if (index < 0 || requests[index].Version != expectedVersion)
            {
                updatedRequest = null;
                return false;
            }

            updatedRequest = update(requests[index]);
            if (updatedRequest is null)
            {
                return false;
            }

            requests[index] = updatedRequest;
            return true;
        }
    }

    private static VacationRequestReadModel Create(
        string requesterId,
        string projectId,
        RequestStatus status,
        DateOnly startDate,
        DateOnly endDate)
    {
        return new VacationRequestReadModel(
            Guid.NewGuid(), requesterId, "DEPT-TEST-001", projectId,
            startDate, endDate, null, status, SeededAt, SeededAt, 1);
    }
}