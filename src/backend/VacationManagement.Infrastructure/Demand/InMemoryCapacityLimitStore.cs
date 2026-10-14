using VacationManagement.Application.Demand;

namespace VacationManagement.Infrastructure.Demand;

public sealed class InMemoryCapacityLimitStore : ICapacityLimitStore
{
    private readonly object sync = new();
    private readonly List<CapacityLimit> limits = [];

    public IReadOnlyList<CapacityLimit> List()
    {
        lock (sync)
        {
            return limits.ToArray();
        }
    }

    public CapacityLimit Upsert(CapacityLimit limit)
    {
        lock (sync)
        {
            var index = limits.FindIndex(existing => existing.ScopeType == limit.ScopeType &&
                existing.ScopeId == limit.ScopeId && existing.PeriodStart == limit.PeriodStart &&
                existing.PeriodEnd == limit.PeriodEnd);
            if (index < 0)
            {
                limits.Add(limit);
            }
            else
            {
                limits[index] = limit;
            }

            return limit;
        }
    }
}