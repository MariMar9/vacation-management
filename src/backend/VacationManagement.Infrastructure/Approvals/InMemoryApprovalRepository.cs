using VacationManagement.Application.Approvals;

namespace VacationManagement.Infrastructure.Approvals;

public sealed class InMemoryApprovalRepository : IProjectDelegationStore, IApprovalRepository
{
    private readonly object sync = new();
    private readonly List<ApprovalDecision> decisions = [];
    private readonly List<ProjectDelegation> delegations = [];

    public IReadOnlyList<ApprovalDecision> ListDecisions()
    {
        lock (sync)
        {
            return decisions.ToArray();
        }
    }

    public IReadOnlyList<ProjectDelegation> ListDelegations()
    {
        lock (sync)
        {
            return delegations.ToArray();
        }
    }

    public void AddDecision(ApprovalDecision decision)
    {
        lock (sync)
        {
            decisions.Add(decision);
        }
    }

    public bool TryAddDelegation(ProjectDelegation delegation)
    {
        lock (sync)
        {
            if (delegations.Any(existing => existing.Id == delegation.Id ||
                existing.ProjectId == delegation.ProjectId && existing.DelegatorId == delegation.DelegatorId &&
                existing.RevokedAt is null && existing.ExpiresAt > delegation.StartsAt))
            {
                return false;
            }

            delegations.Add(delegation);
            return true;
        }
    }

    public bool TryRevokeDelegation(
        Guid delegationId,
        string delegatorId,
        DateTimeOffset revokedAt,
        out ProjectDelegation? delegation)
    {
        lock (sync)
        {
            var index = delegations.FindIndex(item => item.Id == delegationId && item.DelegatorId == delegatorId);
            if (index < 0 || delegations[index].RevokedAt is not null)
            {
                delegation = null;
                return false;
            }

            delegation = delegations[index] with { RevokedAt = revokedAt };
            delegations[index] = delegation;
            return true;
        }
    }
}