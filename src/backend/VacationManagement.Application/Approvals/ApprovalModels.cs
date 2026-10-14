using VacationManagement.Application.Requests;

namespace VacationManagement.Application.Approvals;

public sealed record DecisionCommand(string Outcome, string? Reason, int? ExpectedRequestVersion);

public sealed record DepartmentApprovalCommand(string Outcome, int ExpectedRequestVersion, string? Reason = null);

public sealed record ReviewRequest(
    Guid RequestId,
    string ProjectId,
    string RequesterId,
    DateOnly StartDate,
    DateOnly EndDate,
    string RequestStatus,
    string ApprovalLevel,
    int Version);

public sealed record ApprovalDecision(
    Guid Id,
    Guid RequestId,
    string Level,
    string Outcome,
    string ActorId,
    Guid? DelegationId,
    string? Reason,
    DateTimeOffset DecidedAt,
    int RequestVersion);

public sealed record DelegationCommand(string DelegateId, int DurationDays);

public sealed record ProjectDelegation(
    Guid Id,
    string ProjectId,
    string DelegatorId,
    string DelegateId,
    DateTimeOffset StartsAt,
    DateTimeOffset ExpiresAt,
    DateTimeOffset? RevokedAt)
{
    public string Status(DateTimeOffset now) => RevokedAt is not null
        ? "Revoked"
        : ExpiresAt <= now ? "Expired" : "Active";
}

public interface IProjectDelegationStore
{
    IReadOnlyList<ProjectDelegation> ListDelegations();

    bool TryAddDelegation(ProjectDelegation delegation);

    bool TryRevokeDelegation(Guid delegationId, string delegatorId, DateTimeOffset revokedAt, out ProjectDelegation? delegation);
}

public interface IApprovalRepository
{
    IReadOnlyList<ApprovalDecision> ListDecisions();

    void AddDecision(ApprovalDecision decision);
}

public interface IApprovalService
{
    IReadOnlyList<ApprovalDecision> ListDecisions();

    IReadOnlyList<ProjectDelegation> ListDelegations(string actorId, string projectId);

    IReadOnlyList<ReviewRequest> ListProjectRequests(string actorId, string projectId, string? status);

    IReadOnlyList<ReviewRequest> ListDepartmentRequests(string actorId);

    RequestCommandResult<ApprovalDecision> DecideProject(string actorId, Guid requestId, DecisionCommand command);

    RequestCommandResult<ApprovalDecision> DecideDepartment(string actorId, Guid requestId, DepartmentApprovalCommand command);

    RequestCommandResult<ProjectDelegation> GrantDelegation(string actorId, string projectId, DelegationCommand command);

    RequestCommandResult<ProjectDelegation> RevokeDelegation(string actorId, Guid delegationId);
}