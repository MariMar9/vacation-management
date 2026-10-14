using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Access;
using VacationManagement.Application.Approvals;
using VacationManagement.Application.Requests;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("api")]
public sealed class ApprovalController(
    IApprovalService approvals,
    IAccessPolicyService accessPolicy,
    TimeProvider timeProvider) : ControllerBase
{
    [HttpGet("projects/{projectId}/delegations")]
    [ProducesResponseType(typeof(IReadOnlyList<ProjectDelegationView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<IReadOnlyList<ProjectDelegationView>> ListProjectDelegations(string projectId)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("DelegateProject", "Project", projectId)).Allowed)
        {
            return Forbid();
        }

        return Ok(approvals.ListDelegations(actorId, projectId).Select(ToView).ToArray());
    }

    [HttpGet("review/project-requests")]
    [ProducesResponseType(typeof(IReadOnlyList<ReviewRequest>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<IReadOnlyList<ReviewRequest>> ListProjectRequests(
        [FromQuery] string projectId,
        [FromQuery] string? status)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (status is not null && !Enum.TryParse<RequestStatus>(status, ignoreCase: false, out _))
        {
            return BadRequest(new { error = "Unknown request status." });
        }
        if (!accessPolicy.Authorize(actorId, new CapabilityRequest("ReviewProject", "Project", projectId)).Allowed &&
            !approvals.ListProjectRequests(actorId, projectId, null).Any())
        {
            return Forbid();
        }

        return Ok(approvals.ListProjectRequests(actorId, projectId, status));
    }

    [HttpGet("review/department-requests")]
    [ProducesResponseType(typeof(IReadOnlyList<ReviewRequest>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<IReadOnlyList<ReviewRequest>> ListDepartmentRequests()
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }

        var profile = accessPolicy.GetProfile(actorId);
        if (profile is null || !profile.Roles.Contains("DepartmentApprover", StringComparer.Ordinal))
        {
            return Forbid();
        }

        return Ok(approvals.ListDepartmentRequests(actorId));
    }

    [HttpPost("requests/{requestId:guid}/decisions/project")]
    [ProducesResponseType(typeof(ApprovalDecision), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult<ApprovalDecision> DecideProject(Guid requestId, DecisionCommand command) =>
        MapDecision(approvals.DecideProject(GetSubjectId() ?? string.Empty, requestId, command));

    [HttpPost("requests/{requestId:guid}/decisions/department")]
    [ProducesResponseType(typeof(ApprovalDecision), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult<ApprovalDecision> DecideDepartment(Guid requestId, DepartmentApprovalCommand command) =>
        MapDecision(approvals.DecideDepartment(GetSubjectId() ?? string.Empty, requestId, command));

    [HttpPost("projects/{projectId}/delegations")]
    [ProducesResponseType(typeof(ProjectDelegation), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult<ProjectDelegation> GrantDelegation(string projectId, DelegationCommand command)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }

        var result = approvals.GrantDelegation(actorId, projectId, command);
        if (!result.Succeeded)
        {
            return result.ErrorCode switch
            {
                "Invalid" or "InvalidDelegate" => BadRequest(new { error = "Delegation must target an active same-project member for 1 to 30 days." }),
                "Forbidden" => Forbid(),
                _ => Conflict(new { error = "A current delegation conflicts with this grant or the snapshot is stale." })
            };
        }

        return CreatedAtAction(nameof(GrantDelegation), new { projectId }, ToView(result.Value!));
    }

    [HttpDelete("delegations/{delegationId:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult RevokeDelegation(Guid delegationId)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }

        var result = approvals.RevokeDelegation(actorId, delegationId);
        return result.Succeeded ? NoContent() : result.ErrorCode switch
        {
            "Forbidden" => Forbid(),
            _ => NotFound()
        };
    }

    private ActionResult<ApprovalDecision> MapDecision(RequestCommandResult<ApprovalDecision> result)
    {
        if (GetSubjectId() is null)
        {
            return Unauthorized();
        }
        if (result.Succeeded)
        {
            return Ok(result.Value);
        }

        return result.ErrorCode switch
        {
            "Invalid" => BadRequest(new { error = "Decision outcome or rejection reason is invalid." }),
            "Forbidden" => Forbid(),
            "NotFound" => NotFound(),
            _ => Conflict(new { error = "The request is stale, ineligible, or cannot be self-approved." })
        };
    }

    private string? GetSubjectId() =>
        User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);

    private ProjectDelegationView ToView(ProjectDelegation delegation) => new(
        delegation.Id,
        delegation.ProjectId,
        delegation.DelegatorId,
        delegation.DelegateId,
        delegation.StartsAt,
        delegation.ExpiresAt,
        delegation.RevokedAt,
        delegation.Status(timeProvider.GetUtcNow()));
}

public sealed record ProjectDelegationView(
    Guid Id,
    string ProjectId,
    string DelegatorId,
    string DelegateId,
    DateTimeOffset StartsAt,
    DateTimeOffset ExpiresAt,
    DateTimeOffset? RevokedAt,
    string Status);