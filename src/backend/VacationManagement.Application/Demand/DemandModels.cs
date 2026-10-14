using VacationManagement.Application.Requests;

namespace VacationManagement.Application.Demand;

public sealed record DemandSummary(
    string ScopeType,
    string ScopeId,
    DateOnly FromDate,
    DateOnly ToDate,
    int ActiveMemberCount,
    int PeopleOnApprovedVacation,
    double? DemandPercentage,
    bool ThresholdExceeded,
    bool CapacityExceeded,
    DateTimeOffset DataAsOf,
    bool Stale);

public sealed record CapacityLimitInput(
    string ScopeType,
    string ScopeId,
    DateOnly PeriodStart,
    DateOnly PeriodEnd,
    int MaxConcurrentPeople);

public sealed record CapacityLimit(
    Guid Id,
    string ScopeType,
    string ScopeId,
    DateOnly PeriodStart,
    DateOnly PeriodEnd,
    int MaxConcurrentPeople,
    string UpdatedBy,
    DateTimeOffset UpdatedAt);

public interface ICapacityLimitStore
{
    IReadOnlyList<CapacityLimit> List();

    CapacityLimit Upsert(CapacityLimit limit);
}

public interface IDemandService
{
    RequestCommandResult<DemandSummary> GetSummary(
        string actorId,
        string scopeType,
        string scopeId,
        DateOnly fromDate,
        DateOnly toDate);

    IReadOnlyList<CapacityLimit> ListLimits(string scopeType, string scopeId);

    RequestCommandResult<CapacityLimit> SetLimit(string actorId, CapacityLimitInput input);
}