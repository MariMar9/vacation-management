using VacationManagement.Application.Access;
using VacationManagement.Application.Organization;
using VacationManagement.Application.Requests;
using VacationManagement.Application.Notifications;
using VacationManagement.Application.Exports;

namespace VacationManagement.Application.Approvals;

public sealed class ApprovalService(
    IRequestLifecycleStore requests,
    IOrganizationSnapshotStore organizations,
    IProjectDelegationStore delegations,
    IApprovalRepository approvalRepository,
    IAccessPolicyService accessPolicy,
    INotificationOutbox notifications,
    IVacationExportOutbox exports,
    TimeProvider timeProvider) : IApprovalService
{
    public IReadOnlyList<ApprovalDecision> ListDecisions() => approvalRepository.ListDecisions();

    public IReadOnlyList<ProjectDelegation> ListDelegations(string actorId, string projectId)
    {
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("DelegateProject", "Project", projectId)).Allowed)
        {
            return [];
        }

        return delegations.ListDelegations()
            .Where(delegation => delegation.ProjectId == projectId)
            .OrderByDescending(delegation => delegation.StartsAt)
            .ToArray();
    }

    public IReadOnlyList<ReviewRequest> ListProjectRequests(string actorId, string projectId, string? status)
    {
        var snapshot = organizations.Current;
        if (snapshot is null || !IsProjectApprover(actorId, projectId, timeProvider.GetUtcNow()))
        {
            return [];
        }

        return requests.ListAll()
            .Where(request => request.ProjectId == projectId && (status is null || request.Status.ToString() == status))
            .OrderBy(request => request.StartDate)
            .Select(request => new ReviewRequest(
                request.Id, request.ProjectId, request.RequesterId, request.StartDate, request.EndDate,
                request.Status.ToString(), request.Status == RequestStatus.PendingDepartmentApproval ? "Department" : "Project",
                request.Version))
            .ToArray();
    }

    public IReadOnlyList<ReviewRequest> ListDepartmentRequests(string actorId)
    {
        var departmentId = organizations.Current?.Department.DepartmentId;
        if (departmentId is null || !accessPolicy.Authorize(actorId,
            new CapabilityRequest("DecideDepartment", "Department", departmentId)).Allowed)
        {
            return [];
        }

        return requests.ListAll()
            .Where(request => request.DepartmentId == departmentId && request.Status == RequestStatus.PendingDepartmentApproval)
            .OrderBy(request => request.StartDate)
            .Select(request => new ReviewRequest(
                request.Id, request.ProjectId, request.RequesterId, request.StartDate, request.EndDate,
                request.Status.ToString(), "Department", request.Version))
            .ToArray();
    }

    public RequestCommandResult<ApprovalDecision> DecideProject(
        string actorId,
        Guid requestId,
        DecisionCommand command)
    {
        if (command.Outcome is not ("Approved" or "Rejected") || command.Reason?.Length > 500 ||
            command.Outcome == "Rejected" && string.IsNullOrWhiteSpace(command.Reason))
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Invalid");
        }

        var snapshot = organizations.Current;
        var request = requests.ListAll().SingleOrDefault(item => item.Id == requestId);
        if (snapshot is null || organizations.IsStale(timeProvider.GetUtcNow()))
        {
            return RequestCommandResult<ApprovalDecision>.Failure("StaleSnapshot");
        }
        if (request is null)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("NotFound");
        }
        if (request.RequesterId == actorId)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("SelfApproval");
        }
        if (!IsProjectApprover(actorId, request.ProjectId, timeProvider.GetUtcNow()))
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Forbidden");
        }
        if (request.Status != RequestStatus.PendingProjectApproval ||
            command.ExpectedRequestVersion is not null && command.ExpectedRequestVersion != request.Version)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Conflict");
        }

        var now = timeProvider.GetUtcNow();
        var nextStatus = command.Outcome == "Approved" ? RequestStatus.PendingDepartmentApproval : RequestStatus.Rejected;
        var updated = requests.TryUpdate(request.Id, request.Version,
            current => current.Status == RequestStatus.PendingProjectApproval
                ? current with { Status = nextStatus, UpdatedAt = now, Version = current.Version + 1 }
                : null,
            out var updatedRequest);
        if (!updated || updatedRequest is null)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Conflict");
        }

        var delegationId = GetActiveDelegation(actorId, request.ProjectId, now)?.Id;
        var decision = new ApprovalDecision(
            Guid.NewGuid(), request.Id, "Project", command.Outcome, actorId, delegationId,
            command.Reason, now, updatedRequest.Version);
        approvalRepository.AddDecision(decision);
        if (command.Outcome == "Approved")
        {
            var departmentApprover = snapshot.ApproverAssignments.Single(assignment =>
                assignment.ScopeType == "Department" && assignment.ScopeId == request.DepartmentId &&
                assignment.Role == "DepartmentApprover");
            notifications.Enqueue(updatedRequest, "ProjectApproved", departmentApprover.ApproverId, now);
        }
        else
        {
            notifications.Enqueue(updatedRequest, "RequestRejected", request.RequesterId, now);
        }
        return RequestCommandResult<ApprovalDecision>.Success(decision);
    }

    public RequestCommandResult<ApprovalDecision> DecideDepartment(
        string actorId,
        Guid requestId,
        DepartmentApprovalCommand command)
    {
        if (command.Outcome is not ("Approved" or "Rejected") || command.Reason?.Length > 500 ||
            command.Outcome == "Rejected" && string.IsNullOrWhiteSpace(command.Reason))
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Invalid");
        }

        var snapshot = organizations.Current;
        var request = requests.ListAll().SingleOrDefault(item => item.Id == requestId);
        if (snapshot is null || organizations.IsStale(timeProvider.GetUtcNow()))
        {
            return RequestCommandResult<ApprovalDecision>.Failure("StaleSnapshot");
        }
        if (request is null)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("NotFound");
        }
        if (request.RequesterId == actorId)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("SelfApproval");
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("DecideDepartment", "Department", request.DepartmentId)).Allowed)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Forbidden");
        }
        if (request.Status != RequestStatus.PendingDepartmentApproval || request.Version != command.ExpectedRequestVersion)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Conflict");
        }

        var now = timeProvider.GetUtcNow();
        var nextStatus = command.Outcome == "Approved" ? RequestStatus.Approved : RequestStatus.Rejected;
        var updated = requests.TryUpdate(request.Id, request.Version,
            current => current.Status == RequestStatus.PendingDepartmentApproval
                ? current with { Status = nextStatus, UpdatedAt = now, Version = current.Version + 1 }
                : null,
            out var updatedRequest);
        if (!updated || updatedRequest is null)
        {
            return RequestCommandResult<ApprovalDecision>.Failure("Conflict");
        }

        var decision = new ApprovalDecision(
            Guid.NewGuid(), request.Id, "Department", command.Outcome, actorId, null, command.Reason, now, updatedRequest.Version);
        approvalRepository.AddDecision(decision);
        if (command.Outcome == "Approved")
        {
            notifications.Enqueue(updatedRequest, "RequestFinallyApproved", request.RequesterId, now);
            exports.QueueApproved(updatedRequest, now);
        }
        else
        {
            notifications.Enqueue(updatedRequest, "RequestRejected", request.RequesterId, now);
        }
        return RequestCommandResult<ApprovalDecision>.Success(decision);
    }

    public RequestCommandResult<ProjectDelegation> GrantDelegation(
        string actorId,
        string projectId,
        DelegationCommand command)
    {
        if (command.DurationDays is < 1 or > 30 || string.IsNullOrWhiteSpace(command.DelegateId))
        {
            return RequestCommandResult<ProjectDelegation>.Failure("Invalid");
        }

        var snapshot = organizations.Current;
        var now = timeProvider.GetUtcNow();
        if (snapshot is null || organizations.IsStale(now))
        {
            return RequestCommandResult<ProjectDelegation>.Failure("StaleSnapshot");
        }
        if (!accessPolicy.Authorize(actorId, new CapabilityRequest("DelegateProject", "Project", projectId)).Allowed)
        {
            return RequestCommandResult<ProjectDelegation>.Failure("Forbidden");
        }
        if (actorId == command.DelegateId || !snapshot.Employees.Any(employee =>
                employee.EmployeeId == command.DelegateId && employee.Active) ||
            !snapshot.Memberships.Any(membership =>
                membership.EmployeeId == command.DelegateId && membership.ProjectId == projectId))
        {
            return RequestCommandResult<ProjectDelegation>.Failure("InvalidDelegate");
        }

        var delegation = new ProjectDelegation(
            Guid.NewGuid(), projectId, actorId, command.DelegateId, now, now.AddDays(command.DurationDays), null);
        return delegations.TryAddDelegation(delegation)
            ? RequestCommandResult<ProjectDelegation>.Success(delegation)
            : RequestCommandResult<ProjectDelegation>.Failure("Conflict");
    }

    public RequestCommandResult<ProjectDelegation> RevokeDelegation(string actorId, Guid delegationId)
    {
        var existing = delegations.ListDelegations().SingleOrDefault(item => item.Id == delegationId);
        if (existing is null)
        {
            return RequestCommandResult<ProjectDelegation>.Failure("NotFound");
        }
        if (existing.DelegatorId != actorId)
        {
            return RequestCommandResult<ProjectDelegation>.Failure("Forbidden");
        }

        return delegations.TryRevokeDelegation(delegationId, actorId, timeProvider.GetUtcNow(), out var delegation) && delegation is not null
            ? RequestCommandResult<ProjectDelegation>.Success(delegation)
            : RequestCommandResult<ProjectDelegation>.Failure("Conflict");
    }

    private bool IsProjectApprover(string actorId, string projectId, DateTimeOffset now)
    {
        var direct = accessPolicy.Authorize(actorId,
            new CapabilityRequest("ReviewProject", "Project", projectId)).Allowed;
        return direct || GetActiveDelegation(actorId, projectId, now) is not null;
    }

    private ProjectDelegation? GetActiveDelegation(string actorId, string projectId, DateTimeOffset now) =>
        delegations.ListDelegations().SingleOrDefault(delegation =>
            delegation.DelegateId == actorId && delegation.ProjectId == projectId &&
            delegation.RevokedAt is null && delegation.StartsAt <= now && delegation.ExpiresAt > now);
}