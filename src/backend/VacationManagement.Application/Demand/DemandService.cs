using VacationManagement.Application.Access;
using VacationManagement.Application.Organization;
using VacationManagement.Application.Requests;

namespace VacationManagement.Application.Demand;

public sealed class DemandService(
    IRequestLifecycleStore requests,
    IOrganizationSnapshotStore organizations,
    ICapacityLimitStore capacityLimits,
    IAccessPolicyService accessPolicy,
    TimeProvider timeProvider) : IDemandService
{
    public RequestCommandResult<DemandSummary> GetSummary(
        string actorId,
        string scopeType,
        string scopeId,
        DateOnly fromDate,
        DateOnly toDate)
    {
        if (fromDate > toDate || scopeType is not ("Department" or "Project"))
        {
            return RequestCommandResult<DemandSummary>.Failure("Invalid");
        }

        var snapshot = organizations.Current;
        if (snapshot is null)
        {
            return RequestCommandResult<DemandSummary>.Failure("NoSnapshot");
        }
        if (!accessPolicy.Authorize(actorId, new CapabilityRequest("ReadDemand", scopeType, scopeId)).Allowed)
        {
            return RequestCommandResult<DemandSummary>.Failure("Forbidden");
        }

        var activeEmployees = snapshot.Employees.Where(employee => employee.Active).Select(employee => employee.EmployeeId);
        var members = scopeType == "Department"
            ? activeEmployees.ToHashSet(StringComparer.Ordinal)
            : snapshot.Memberships
                .Where(membership => membership.ProjectId == scopeId && activeEmployees.Contains(membership.EmployeeId))
                .Select(membership => membership.EmployeeId)
                .ToHashSet(StringComparer.Ordinal);

        var peopleOnVacation = requests.ListAll()
            .Where(request => request.Status == RequestStatus.Approved && members.Contains(request.RequesterId) &&
                request.StartDate <= toDate && request.EndDate >= fromDate &&
                (scopeType == "Department" || request.ProjectId == scopeId))
            .Select(request => request.RequesterId)
            .Distinct(StringComparer.Ordinal)
            .Count();
        var memberCount = members.Count;
        double? percentage = memberCount == 0 ? null : peopleOnVacation * 100d / memberCount;
        var matchingLimit = capacityLimits.List().SingleOrDefault(limit =>
            limit.ScopeType == scopeType && limit.ScopeId == scopeId &&
            limit.PeriodStart <= fromDate && limit.PeriodEnd >= toDate);
        var now = timeProvider.GetUtcNow();
        var summary = new DemandSummary(
            scopeType, scopeId, fromDate, toDate, memberCount, peopleOnVacation, percentage,
            percentage is >= 70, matchingLimit is not null && peopleOnVacation > matchingLimit.MaxConcurrentPeople,
            snapshot.GeneratedAt, organizations.IsStale(now));
        return RequestCommandResult<DemandSummary>.Success(summary);
    }

    public IReadOnlyList<CapacityLimit> ListLimits(string scopeType, string scopeId) =>
        capacityLimits.List()
            .Where(limit => limit.ScopeType == scopeType && limit.ScopeId == scopeId)
            .OrderBy(limit => limit.PeriodStart)
            .ToArray();

    public RequestCommandResult<CapacityLimit> SetLimit(string actorId, CapacityLimitInput input)
    {
        var snapshot = organizations.Current;
        if (input.ScopeType != "Department" || input.PeriodStart > input.PeriodEnd || input.MaxConcurrentPeople < 1 ||
            snapshot is null || input.ScopeId != snapshot.Department.DepartmentId)
        {
            return RequestCommandResult<CapacityLimit>.Failure("Invalid");
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("ManageCapacity", "Department", input.ScopeId)).Allowed)
        {
            return RequestCommandResult<CapacityLimit>.Failure("Forbidden");
        }

        var current = capacityLimits.List().SingleOrDefault(limit =>
            limit.ScopeType == input.ScopeType && limit.ScopeId == input.ScopeId &&
            limit.PeriodStart == input.PeriodStart && limit.PeriodEnd == input.PeriodEnd);
        var limit = new CapacityLimit(
            current?.Id ?? Guid.NewGuid(), input.ScopeType, input.ScopeId, input.PeriodStart, input.PeriodEnd,
            input.MaxConcurrentPeople, actorId, timeProvider.GetUtcNow());
        return RequestCommandResult<CapacityLimit>.Success(capacityLimits.Upsert(limit));
    }
}