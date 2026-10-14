using VacationManagement.Application.Exports;
using VacationManagement.Application.Requests;

namespace VacationManagement.Infrastructure.Exports;

public sealed class InMemoryVacationExportOutbox : IVacationExportOutbox
{
    private readonly object sync = new();
    private readonly Dictionary<string, VacationExportRecord> records = new(StringComparer.Ordinal);

    public VacationExportRecord QueueApproved(VacationRequestReadModel request, DateTimeOffset createdAt)
    {
        if (request.Status != RequestStatus.Approved)
        {
            throw new InvalidOperationException("Only final Approved requests can be exported.");
        }

        var key = $"{request.Id}:{request.Version}";
        lock (sync)
        {
            if (!records.TryGetValue(key, out var record))
            {
                record = new VacationExportRecord(request.Id, request.Version, key, "Pending", 0, createdAt, null);
                records.Add(key, record);
            }

            return record;
        }
    }

    public IReadOnlyList<VacationExportRecord> List()
    {
        lock (sync)
        {
            return records.Values.OrderByDescending(record => record.CreatedAt).ToArray();
        }
    }

    public int EvaluatePending(DateTimeOffset attemptedAt, bool simulateFailure)
    {
        lock (sync)
        {
            var pending = records
                .Where(item => item.Value.Status == "Pending")
                .Select(item => item.Key)
                .ToArray();
            foreach (var key in pending)
            {
                var current = records[key];
                var attemptCount = current.AttemptCount + 1;
                var status = simulateFailure
                    ? attemptCount >= 3 ? "NeedsReconciliation" : "Pending"
                    : "Delivered";
                records[key] = current with
                {
                    Status = status,
                    AttemptCount = attemptCount,
                    LastAttemptAt = attemptedAt,
                };
            }

            return pending.Length;
        }
    }
}