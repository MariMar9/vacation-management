using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Access;
using VacationManagement.Application.Notifications;
using VacationManagement.Application.Organization;
using VacationManagement.Application.Requests;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("test-simulator/notifications")]
public sealed class NotificationSimulatorController(
    INotificationOutbox notifications,
    IRequestLifecycleStore requests,
    IOrganizationSnapshotStore organizations,
    IAccessPolicyService accessPolicy,
    TimeProvider timeProvider) : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<NotificationRecord>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public ActionResult<IReadOnlyList<NotificationRecord>> List(
        [FromQuery] Guid? requestId,
        [FromQuery] string? recipientId)
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (recipientId is not null && recipientId != actorId)
        {
            return Forbid();
        }

        return Ok(notifications.ListForRecipient(actorId, requestId));
    }

    [HttpPost("evaluate-escalations")]
    [ProducesResponseType(StatusCodes.Status202Accepted)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public IActionResult EvaluateEscalations()
    {
        var actorId = GetSubjectId();
        if (actorId is null)
        {
            return Unauthorized();
        }
        if (!accessPolicy.Authorize(actorId,
            new CapabilityRequest("ManageCapacity", "Department", "DEPT-TEST-001")).Allowed)
        {
            return Forbid();
        }

        var snapshot = organizations.Current;
        if (snapshot is not null)
        {
            var queuedCount = notifications.EvaluateEscalations(requests.ListAll(), snapshot, timeProvider.GetUtcNow());
            return Accepted(new { queuedCount });
        }

        return Accepted(new { queuedCount = 0 });
    }

    private string? GetSubjectId() =>
        User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
}