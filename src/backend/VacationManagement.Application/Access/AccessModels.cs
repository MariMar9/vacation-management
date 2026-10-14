namespace VacationManagement.Application.Access;

public enum Capability
{
    CreateRequest,
    ReadOwnRequest,
    CancelOwnRequest,
    ReviewProject,
    DecideProject,
    DecideDepartment,
    DelegateProject,
    ReadDemand,
    ManageCapacity
}

public sealed record AccessProfile(
    string SubjectId,
    bool Active,
    string DepartmentId,
    IReadOnlyList<string> Roles,
    IReadOnlyList<string> ProjectIds,
    IReadOnlyList<string> MembershipProjectIds,
    IReadOnlyList<string> DelegatableProjectIds);

public sealed record CapabilityRequest(string Capability, string ScopeType, string ScopeId);

public sealed record CapabilityDecision(bool Allowed, string? Reason);

public interface IAccessPolicyService
{
    AccessProfile? GetProfile(string subjectId);

    CapabilityDecision Authorize(string subjectId, CapabilityRequest request);
}