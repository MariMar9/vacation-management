using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Access;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("api/session")]
public sealed class SessionController(IAccessPolicyService accessPolicy) : ControllerBase
{
    [HttpGet("access")]
    [ProducesResponseType(typeof(AccessProfile), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<AccessProfile> GetCurrentAccessProfile()
    {
        var subjectId = GetSubjectId();
        if (subjectId is null)
        {
            return Unauthorized();
        }

        var profile = accessPolicy.GetProfile(subjectId);
        return profile is null || !profile.Active ? Forbid() : Ok(profile);
    }

    [HttpPost("authorize")]
    [ProducesResponseType(typeof(CapabilityDecision), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<CapabilityDecision> CheckCapability(CapabilityRequest request)
    {
        var subjectId = GetSubjectId();
        if (subjectId is null)
        {
            return Unauthorized();
        }

        var profile = accessPolicy.GetProfile(subjectId);
        if (profile is null || !profile.Active)
        {
            return Forbid();
        }

        if (string.IsNullOrWhiteSpace(request.ScopeId) ||
            request.ScopeType is not ("Self" or "Project" or "Department"))
        {
            return BadRequest(new { error = "A valid scope type and ID are required." });
        }

        if (!CanInspectScope(profile, request))
        {
            return Forbid();
        }

        return Ok(accessPolicy.Authorize(subjectId, request));
    }

    private bool CanInspectScope(AccessProfile profile, CapabilityRequest request) => request.ScopeType switch
    {
        "Self" => request.ScopeId == profile.SubjectId,
        "Department" => request.ScopeId == profile.DepartmentId &&
            profile.Roles.Contains("DepartmentApprover", StringComparer.Ordinal),
        "Project" => profile.ProjectIds.Contains(request.ScopeId, StringComparer.Ordinal) ||
            profile.Roles.Contains("ProjectApprover", StringComparer.Ordinal) &&
            accessPolicy.Authorize(profile.SubjectId, new CapabilityRequest("ReviewProject", "Project", request.ScopeId)).Allowed,
        _ => false
    };

    private string? GetSubjectId() =>
        User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
}