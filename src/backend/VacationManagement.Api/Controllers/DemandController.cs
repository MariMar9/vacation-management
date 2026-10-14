using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Access;
using VacationManagement.Application.Demand;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("api")]
public sealed class DemandController(IDemandService demand, IAccessPolicyService accessPolicy) : ControllerBase
{
    [HttpGet("demand/summary")]
    [ProducesResponseType(typeof(DemandSummary), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult<DemandSummary> GetSummary(
        [FromQuery] string scopeType,
        [FromQuery] string scopeId,
        [FromQuery] DateOnly fromDate,
        [FromQuery] DateOnly toDate)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }

        var result = demand.GetSummary(actorId, scopeType, scopeId, fromDate, toDate);
        if (result.Succeeded)
        {
            return Ok(result.Value);
        }

        return result.ErrorCode switch
        {
            "Invalid" => BadRequest(new { error = "Scope or inclusive date range is invalid." }),
            "Forbidden" => Forbid(),
            "NoSnapshot" => Conflict(new { error = "No valid organization snapshot exists." }),
            _ => NotFound()
        };
    }

    [HttpGet("capacity-limits")]
    [ProducesResponseType(typeof(IReadOnlyList<CapacityLimit>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<IReadOnlyList<CapacityLimit>> ListCapacityLimits(
        [FromQuery] string scopeType = "Department",
        [FromQuery] string scopeId = "DEPT-TEST-001")
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("ManageCapacity", scopeType, scopeId)).Allowed)
        {
            return Forbid();
        }

        return Ok(demand.ListLimits(scopeType, scopeId));
    }

    [HttpPut("capacity-limits")]
    [ProducesResponseType(typeof(CapacityLimit), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<CapacityLimit> SetCapacityLimit(CapacityLimitInput input)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }

        var result = demand.SetLimit(actorId, input);
        if (result.Succeeded)
        {
            return Ok(result.Value);
        }

        return result.ErrorCode == "Forbidden"
            ? Forbid()
            : BadRequest(new { error = "Only a positive department limit with a valid inclusive period is supported." });
    }

    private string? GetSubjectId() =>
        User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
}