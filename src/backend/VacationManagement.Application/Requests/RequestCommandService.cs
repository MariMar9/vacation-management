using VacationManagement.Application.Organization;
using VacationManagement.Application.Approvals;
using VacationManagement.Application.Notifications;

namespace VacationManagement.Application.Requests;

public sealed class RequestCommandService(
    IRequestLifecycleStore requests,
    IOrganizationSnapshotStore organizations,
    IProjectDelegationStore delegations,
    INotificationOutbox notifications,
    TimeProvider timeProvider) : IRequestCommandService
{
    private const string DepartmentId = "DEPT-TEST-001";

    public RequestCommandResult<VacationRequestReadModel> Submit(
        string requesterId,
        SubmitVacationRequest command,
        DateOnly todayInMadrid)
    {
        if (command.StartDate < todayInMadrid || command.EndDate < command.StartDate ||
            command.Reason?.Length > 500 || string.IsNullOrWhiteSpace(command.ProjectId))
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("Invalid");
        }

        var snapshot = organizations.Current;
        if (snapshot is null || organizations.IsStale(timeProvider.GetUtcNow()))
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("StaleSnapshot");
        }

        var activeEmployee = snapshot.Employees.Any(employee => employee.EmployeeId == requesterId && employee.Active);
        var isMember = snapshot.Memberships.Any(membership =>
            membership.EmployeeId == requesterId && membership.ProjectId == command.ProjectId);
        var projectExists = snapshot.Projects.Any(project => project.ProjectId == command.ProjectId);
        var projectApprovers = snapshot.ApproverAssignments.Count(assignment =>
            assignment.ScopeType == "Project" && assignment.ScopeId == command.ProjectId &&
            assignment.Role == "ProjectApprover" && snapshot.Employees.Any(employee =>
                employee.EmployeeId == assignment.ApproverId && employee.Active));
        var departmentApprovers = snapshot.ApproverAssignments.Count(assignment =>
            assignment.ScopeType == "Department" && assignment.ScopeId == DepartmentId &&
            assignment.Role == "DepartmentApprover" && snapshot.Employees.Any(employee =>
                employee.EmployeeId == assignment.ApproverId && employee.Active));
        if (!activeEmployee || !isMember || !projectExists)
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("Forbidden");
        }

        if (projectApprovers != 1 || departmentApprovers != 1)
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("ApproverConfiguration");
        }

        var overlaps = requests.ListAll().Any(existing =>
            existing.RequesterId == requesterId && existing.ProjectId == command.ProjectId &&
            existing.Status is RequestStatus.PendingProjectApproval or RequestStatus.PendingDepartmentApproval or RequestStatus.Approved &&
            command.StartDate <= existing.EndDate && command.EndDate >= existing.StartDate);
        if (overlaps)
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("Overlap");
        }

        var now = timeProvider.GetUtcNow();
        var request = new VacationRequestReadModel(
            Guid.NewGuid(), requesterId, DepartmentId, command.ProjectId, command.StartDate, command.EndDate,
            command.Reason, RequestStatus.PendingProjectApproval, now, now, 1);
        if (!requests.TryAdd(request))
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("Conflict");
        }

        var projectApprover = snapshot.ApproverAssignments.Single(assignment =>
            assignment.ScopeType == "Project" && assignment.ScopeId == request.ProjectId && assignment.Role == "ProjectApprover");
        notifications.Enqueue(request, "RequestSubmitted", projectApprover.ApproverId, now);
        return RequestCommandResult<VacationRequestReadModel>.Success(request);
    }

    public RequestCommandResult<VacationRequestReadModel> Cancel(
        string requesterId,
        Guid requestId,
        DateTimeOffset now)
    {
        var request = requests.ListAll().SingleOrDefault(item => item.Id == requestId);
        if (request is null || request.RequesterId != requesterId)
        {
            return RequestCommandResult<VacationRequestReadModel>.Failure("NotFound");
        }

        var cancelled = requests.TryUpdate(requestId, request.Version, current =>
            current.RequesterId == requesterId && current.Status == RequestStatus.PendingProjectApproval
                ? current with { Status = RequestStatus.Cancelled, UpdatedAt = now, Version = current.Version + 1 }
                : null,
            out var updated);
        if (cancelled && updated is not null)
        {
            var snapshot = organizations.Current;
            var assignedApprover = snapshot?.ApproverAssignments.SingleOrDefault(assignment =>
                assignment.ScopeType == "Project" && assignment.ScopeId == updated.ProjectId && assignment.Role == "ProjectApprover");
            var activeDelegate = delegations.ListDelegations().SingleOrDefault(delegation =>
                delegation.ProjectId == updated.ProjectId && delegation.DelegatorId == assignedApprover?.ApproverId &&
                delegation.RevokedAt is null && delegation.StartsAt <= now && delegation.ExpiresAt > now);
            notifications.Enqueue(updated, "RequestCancelled", requesterId, now);
            if (activeDelegate is null)
            {
                if (assignedApprover is not null)
                {
                    notifications.Enqueue(updated, "RequestCancelled", assignedApprover.ApproverId, now);
                }
            }
            else
            {
                notifications.Enqueue(updated, "RequestCancelled", activeDelegate.DelegateId, now);
            }
            return RequestCommandResult<VacationRequestReadModel>.Success(updated);
        }

        var latest = requests.ListAll().SingleOrDefault(item => item.Id == requestId);
        return latest?.RequesterId != requesterId
            ? RequestCommandResult<VacationRequestReadModel>.Failure("NotFound")
            : RequestCommandResult<VacationRequestReadModel>.Failure("Conflict");
    }
}