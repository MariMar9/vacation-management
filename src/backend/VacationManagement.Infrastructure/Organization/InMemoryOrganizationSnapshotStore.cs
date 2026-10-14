using VacationManagement.Application.Organization;

namespace VacationManagement.Infrastructure.Organization;

public sealed class InMemoryOrganizationSnapshotStore(TimeProvider timeProvider) : IOrganizationSnapshotStore
{
    private readonly object sync = new();
    private OrganizationSnapshot? current = CreateSeedSnapshot(timeProvider.GetUtcNow());
    private IReadOnlyList<string> lastValidationErrors = [];

    public OrganizationSnapshot? Current
    {
        get
        {
            lock (sync)
            {
                return current;
            }
        }
    }

    public IReadOnlyList<string> LastValidationErrors
    {
        get
        {
            lock (sync)
            {
                return lastValidationErrors.ToArray();
            }
        }
    }

    public bool IsStale(DateTimeOffset now)
    {
        lock (sync)
        {
            return current is null || now - current.GeneratedAt > TimeSpan.FromHours(36);
        }
    }

    public SnapshotImportResult Import(OrganizationSnapshot snapshot)
    {
        ArgumentNullException.ThrowIfNull(snapshot);
        lock (sync)
        {
            var errors = Validate(snapshot);
            if (current is not null && string.CompareOrdinal(snapshot.SnapshotVersion, current.SnapshotVersion) <= 0)
            {
                errors.Add("Snapshot version must be newer than the current version.");
            }

            if (errors.Count > 0)
            {
                lastValidationErrors = errors;
                return new SnapshotImportResult(false, errors);
            }

            current = snapshot;
            lastValidationErrors = [];
            return new SnapshotImportResult(true, []);
        }
    }

    private static List<string> Validate(OrganizationSnapshot snapshot)
    {
        var errors = new List<string>();
        if (string.IsNullOrWhiteSpace(snapshot.SnapshotVersion) || snapshot.GeneratedAt == default)
        {
            errors.Add("Snapshot version and generatedAt are required.");
        }

        if (snapshot.Department is null || snapshot.Department.DepartmentId != "DEPT-TEST-001")
        {
            errors.Add("The synthetic department DEPT-TEST-001 is required.");
            return errors;
        }

        var employeeIds = UniqueIds(snapshot.Employees.Select(employee => employee.EmployeeId), "employee", errors);
        var projectIds = UniqueIds(snapshot.Projects.Select(project => project.ProjectId), "project", errors);
        UniqueIds(snapshot.Memberships.Select(membership => $"{membership.EmployeeId}:{membership.ProjectId}"), "membership", errors);
        UniqueIds(snapshot.ApproverAssignments.Select(assignment => $"{assignment.ScopeType}:{assignment.ScopeId}:{assignment.Role}"), "approver assignment", errors);

        foreach (var employee in snapshot.Employees)
        {
            if (!employee.EmployeeId.StartsWith("EMP-TEST-", StringComparison.Ordinal))
            {
                errors.Add($"Employee ID '{employee.EmployeeId}' is outside the synthetic namespace.");
            }
        }

        foreach (var project in snapshot.Projects)
        {
            if (!project.ProjectId.StartsWith("PRJ-TEST-", StringComparison.Ordinal) ||
                project.DepartmentId != snapshot.Department.DepartmentId)
            {
                errors.Add($"Project '{project.ProjectId}' has an invalid ID or department reference.");
            }
        }

        foreach (var membership in snapshot.Memberships)
        {
            if (!employeeIds.Contains(membership.EmployeeId) || !projectIds.Contains(membership.ProjectId))
            {
                errors.Add($"Membership '{membership.EmployeeId}:{membership.ProjectId}' has an invalid reference.");
            }
        }

        foreach (var assignment in snapshot.ApproverAssignments)
        {
            var validScope = assignment.ScopeType switch
            {
                "Project" => projectIds.Contains(assignment.ScopeId),
                "Department" => assignment.ScopeId == snapshot.Department.DepartmentId,
                _ => false
            };
            var expectedRole = assignment.ScopeType == "Project" ? "ProjectApprover" : "DepartmentApprover";
            var activeEmployee = snapshot.Employees.Any(employee => employee.EmployeeId == assignment.ApproverId && employee.Active);
            if (!validScope || assignment.Role != expectedRole || !activeEmployee)
            {
                errors.Add($"Approver assignment for '{assignment.ScopeId}' is invalid.");
            }
        }

        foreach (var projectId in projectIds)
        {
            var approverCount = snapshot.ApproverAssignments.Count(assignment =>
                assignment.ScopeType == "Project" && assignment.ScopeId == projectId &&
                assignment.Role == "ProjectApprover" && snapshot.Employees.Any(employee =>
                    employee.EmployeeId == assignment.ApproverId && employee.Active));
            if (approverCount != 1)
            {
                errors.Add($"Project '{projectId}' must have exactly one active project approver.");
            }
        }

        var departmentApproverCount = snapshot.ApproverAssignments.Count(assignment =>
            assignment.ScopeType == "Department" && assignment.ScopeId == snapshot.Department.DepartmentId &&
            assignment.Role == "DepartmentApprover" && snapshot.Employees.Any(employee =>
                employee.EmployeeId == assignment.ApproverId && employee.Active));
        if (departmentApproverCount != 1)
        {
            errors.Add("The department must have exactly one active department approver.");
        }

        return errors;
    }

    private static HashSet<string> UniqueIds(IEnumerable<string> ids, string label, ICollection<string> errors)
    {
        var values = ids.ToArray();
        var unique = values.ToHashSet(StringComparer.Ordinal);
        if (values.Length != unique.Count)
        {
            errors.Add($"Snapshot contains duplicate {label} IDs.");
        }

        return unique;
    }

    private static OrganizationSnapshot CreateSeedSnapshot(DateTimeOffset generatedAt)
    {
        var employees = Enumerable.Range(1, 10)
            .Select(index => new EmployeeSnapshot($"EMP-TEST-{index:000}", true))
            .ToArray();
        var projects = new[]
        {
            new ProjectSnapshot("PRJ-TEST-ALPHA", "DEPT-TEST-001"),
            new ProjectSnapshot("PRJ-TEST-BETA", "DEPT-TEST-001")
        };
        var memberships = Enumerable.Range(1, 10)
            .Select(index => new MembershipSnapshot(
                $"EMP-TEST-{index:000}", index <= 6 ? "PRJ-TEST-ALPHA" : "PRJ-TEST-BETA"))
            .ToArray();
        var assignments = new[]
        {
            new ApproverAssignmentSnapshot("Project", "PRJ-TEST-ALPHA", "EMP-TEST-009", "ProjectApprover"),
            new ApproverAssignmentSnapshot("Project", "PRJ-TEST-BETA", "EMP-TEST-010", "ProjectApprover"),
            new ApproverAssignmentSnapshot("Department", "DEPT-TEST-001", "EMP-TEST-008", "DepartmentApprover")
        };
        return new OrganizationSnapshot(
            "test-v1", generatedAt, new DepartmentSnapshot("DEPT-TEST-001", "Synthetic Department"),
            employees, projects, memberships, assignments);
    }
}