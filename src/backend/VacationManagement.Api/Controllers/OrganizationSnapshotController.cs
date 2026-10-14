using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Access;
using VacationManagement.Application.Organization;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("test-simulator/organization/snapshots")]
public sealed class OrganizationSnapshotController(
    IOrganizationSnapshotStore snapshots,
    IAccessPolicyService accessPolicy,
    TimeProvider timeProvider) : ControllerBase
{
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status202Accepted)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult SubmitSyntheticSnapshot(OrganizationSnapshot snapshot)
    {
        if (!IsDepartmentApprover())
        {
            return User.Identity?.IsAuthenticated == true ? Forbid() : Unauthorized();
        }

        var result = snapshots.Import(snapshot);
        if (result.Accepted)
        {
            return Accepted();
        }

        var conflict = result.Errors.Any(error => error.StartsWith("Snapshot version", StringComparison.Ordinal));
        return conflict
            ? Conflict(new { validationErrors = result.Errors })
            : BadRequest(new { validationErrors = result.Errors });
    }

    [HttpGet("current")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public ActionResult GetCurrentSnapshot()
    {
        if (!IsDepartmentApprover())
        {
            return User.Identity?.IsAuthenticated == true ? Forbid() : Unauthorized();
        }

        var snapshot = snapshots.Current;
        if (snapshot is null)
        {
            return NotFound();
        }

        return Ok(new
        {
            snapshot.SnapshotVersion,
            snapshot.GeneratedAt,
            stale = snapshots.IsStale(timeProvider.GetUtcNow()),
            validationErrors = snapshots.LastValidationErrors
        });
    }

    private bool IsDepartmentApprover()
    {
        var subjectId = User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        return subjectId is not null && accessPolicy.Authorize(subjectId,
            new CapabilityRequest("ManageCapacity", "Department", "DEPT-TEST-001")).Allowed;
    }
}