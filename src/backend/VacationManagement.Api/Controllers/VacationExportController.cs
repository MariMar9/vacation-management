using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Access;
using VacationManagement.Application.Exports;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("test-simulator/vacation-exports")]
public sealed class VacationExportController(
    IVacationExportOutbox exports,
    IAccessPolicyService accessPolicy,
    TimeProvider timeProvider) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<VacationExportRecord>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<IReadOnlyList<VacationExportRecord>> List()
    {
        var actorId = User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("ManageCapacity", "Department", "DEPT-TEST-001")).Allowed)
        {
            return Forbid();
        }

        return Ok(exports.List());
    }

    [HttpPost("evaluate")]
    [ProducesResponseType(StatusCodes.Status202Accepted)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public IActionResult EvaluatePending([FromBody] VacationExportEvaluation evaluation)
    {
        var actorId = User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("ManageCapacity", "Department", "DEPT-TEST-001")).Allowed)
        {
            return Forbid();
        }

        var processedCount = exports.EvaluatePending(timeProvider.GetUtcNow(), evaluation.SimulateFailure);
        return Accepted(new { processedCount, evaluation.SimulateFailure });
    }
}