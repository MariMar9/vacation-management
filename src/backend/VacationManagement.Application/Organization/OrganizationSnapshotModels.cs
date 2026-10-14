namespace VacationManagement.Application.Organization;

public sealed record DepartmentSnapshot(string DepartmentId, string Name);

public sealed record EmployeeSnapshot(string EmployeeId, bool Active);

public sealed record ProjectSnapshot(string ProjectId, string DepartmentId);

public sealed record MembershipSnapshot(string EmployeeId, string ProjectId);

public sealed record ApproverAssignmentSnapshot(
    string ScopeType,
    string ScopeId,
    string ApproverId,
    string Role);

public sealed record OrganizationSnapshot(
    string SnapshotVersion,
    DateTimeOffset GeneratedAt,
    DepartmentSnapshot Department,
    IReadOnlyList<EmployeeSnapshot> Employees,
    IReadOnlyList<ProjectSnapshot> Projects,
    IReadOnlyList<MembershipSnapshot> Memberships,
    IReadOnlyList<ApproverAssignmentSnapshot> ApproverAssignments);

public sealed record SnapshotImportResult(bool Accepted, IReadOnlyList<string> Errors);

public interface IOrganizationSnapshotStore
{
    OrganizationSnapshot? Current { get; }

    IReadOnlyList<string> LastValidationErrors { get; }

    bool IsStale(DateTimeOffset now);

    SnapshotImportResult Import(OrganizationSnapshot snapshot);
}