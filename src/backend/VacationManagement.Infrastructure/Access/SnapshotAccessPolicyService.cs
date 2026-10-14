using VacationManagement.Application.Access;
using VacationManagement.Application.Approvals;
using VacationManagement.Application.Organization;

namespace VacationManagement.Infrastructure.Access;

public sealed class SnapshotAccessPolicyService(
    IOrganizationSnapshotStore organizations,
    IProjectDelegationStore delegations,
    TimeProvider timeProvider) : IAccessPolicyService
{
    public AccessProfile? GetProfile(string subjectId)
    {
        var snapshot = organizations.Current;
        var employee = snapshot?.Employees.SingleOrDefault(item => item.EmployeeId == subjectId);
        if (snapshot is null || employee is null)
        {
            return null;
        }

        var roles = new HashSet<string>(StringComparer.Ordinal) { "Requester" };
        var membershipProjects = snapshot.Memberships
            .Where(membership => membership.EmployeeId == subjectId)
            .Select(membership => membership.ProjectId)
            .Distinct(StringComparer.Ordinal)
            .ToArray();
        var delegatableProjects = snapshot.ApproverAssignments
            .Where(assignment => assignment.ScopeType == "Project" && assignment.ApproverId == subjectId &&
                assignment.Role == "ProjectApprover")
            .Select(assignment => assignment.ScopeId)
            .Distinct(StringComparer.Ordinal)
            .ToArray();
        var delegatedProjects = delegations.ListDelegations()
            .Where(delegation => delegation.DelegateId == subjectId && delegation.RevokedAt is null &&
                delegation.StartsAt <= timeProvider.GetUtcNow() && delegation.ExpiresAt > timeProvider.GetUtcNow())
            .Select(delegation => delegation.ProjectId)
            .ToArray();
        var projects = delegatableProjects
            .Concat(delegatedProjects)
            .Concat(membershipProjects)
            .Distinct(StringComparer.Ordinal)
            .ToArray();

        foreach (var assignment in snapshot.ApproverAssignments.Where(item => item.ApproverId == subjectId))
        {
            roles.Add(assignment.Role);
        }
        if (delegations.ListDelegations().Any(delegation => delegation.DelegateId == subjectId &&
            delegation.RevokedAt is null && delegation.StartsAt <= timeProvider.GetUtcNow() &&
            delegation.ExpiresAt > timeProvider.GetUtcNow()))
        {
            roles.Add("ProjectApprover");
        }

        return new AccessProfile(
            subjectId, employee.Active, snapshot.Department.DepartmentId,
            roles.Order(StringComparer.Ordinal).ToArray(), projects, membershipProjects, delegatableProjects);
    }

    public CapabilityDecision Authorize(string subjectId, CapabilityRequest request)
    {
        if (!Enum.TryParse(request.Capability, ignoreCase: false, out Capability capability) || !Enum.IsDefined(capability))
        {
            return new CapabilityDecision(false, "Unknown capability.");
        }

        var profile = GetProfile(subjectId);
        if (profile is null || !profile.Active)
        {
            return new CapabilityDecision(false, "Identity is not active in the current snapshot.");
        }

        var snapshot = organizations.Current!;
        var allowed = capability switch
        {
            Capability.CreateRequest => request.ScopeType == "Project" && profile.ProjectIds.Contains(request.ScopeId, StringComparer.Ordinal),
            Capability.ReadOwnRequest or Capability.CancelOwnRequest =>
                request.ScopeType == "Self" && request.ScopeId == subjectId,
            Capability.ReviewProject or Capability.DecideProject =>
                request.ScopeType == "Project" && IsProjectApprover(snapshot, subjectId, request.ScopeId),
            Capability.DelegateProject =>
                request.ScopeType == "Project" && snapshot.ApproverAssignments.Any(assignment =>
                    assignment.ScopeType == "Project" && assignment.ScopeId == request.ScopeId &&
                    assignment.ApproverId == subjectId && assignment.Role == "ProjectApprover"),
            Capability.DecideDepartment or Capability.ManageCapacity =>
                request.ScopeType == "Department" && request.ScopeId == snapshot.Department.DepartmentId &&
                snapshot.ApproverAssignments.Any(assignment =>
                    assignment.ScopeType == "Department" && assignment.ScopeId == request.ScopeId &&
                    assignment.ApproverId == subjectId && assignment.Role == "DepartmentApprover"),
            Capability.ReadDemand => CanReadDemand(snapshot, profile, request),
            _ => false
        };

        return new CapabilityDecision(allowed, allowed ? null : "Capability is outside the assigned direct scope.");
    }

    private bool IsProjectApprover(OrganizationSnapshot snapshot, string subjectId, string projectId)
    {
        return snapshot.ApproverAssignments.Any(assignment =>
                assignment.ScopeType == "Project" && assignment.ScopeId == projectId &&
                assignment.ApproverId == subjectId && assignment.Role == "ProjectApprover") ||
            delegations.ListDelegations().Any(delegation => delegation.ProjectId == projectId &&
                delegation.DelegateId == subjectId && delegation.RevokedAt is null &&
                delegation.StartsAt <= timeProvider.GetUtcNow() && delegation.ExpiresAt > timeProvider.GetUtcNow());
    }

    private bool CanReadDemand(
        OrganizationSnapshot snapshot,
        AccessProfile profile,
        CapabilityRequest request)
    {
        if (request.ScopeType == "Department")
        {
            return request.ScopeId == snapshot.Department.DepartmentId &&
                snapshot.ApproverAssignments.Any(assignment =>
                    assignment.ScopeType == "Department" && assignment.ScopeId == request.ScopeId &&
                    assignment.ApproverId == profile.SubjectId && assignment.Role == "DepartmentApprover");
        }

        return request.ScopeType == "Project" && profile.ProjectIds.Contains(request.ScopeId, StringComparer.Ordinal) &&
            snapshot.ApproverAssignments.Any(assignment =>
                assignment.ScopeType == "Project" && assignment.ScopeId == request.ScopeId &&
                assignment.ApproverId == profile.SubjectId && assignment.Role == "ProjectApprover") ||
            request.ScopeType == "Project" && IsProjectApprover(snapshot, profile.SubjectId, request.ScopeId);
    }
}