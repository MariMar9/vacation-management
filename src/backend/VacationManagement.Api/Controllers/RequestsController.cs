using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Application.Requests;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("api/requests")]
public sealed class RequestsController : ControllerBase
{
    private readonly IRequestReadService requestReadService;
    private readonly IRequestCommandService requestCommandService;
    private readonly TimeProvider timeProvider;

    public RequestsController(IRequestReadService requestReadService, TimeProvider timeProvider)
        : this(requestReadService, new UnavailableRequestCommandService(), timeProvider)
    {
    }

    public RequestsController(
        IRequestReadService requestReadService,
        IRequestCommandService requestCommandService,
        TimeProvider timeProvider)
    {
        this.requestReadService = requestReadService;
        this.requestCommandService = requestCommandService;
        this.timeProvider = timeProvider;
    }

    [HttpPost]
    [ProducesResponseType(typeof(VacationRequestReadModel), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult<VacationRequestReadModel> SubmitVacationRequest(
        SubmitVacationRequest command)
    {
        var requesterId = GetRequesterId();
        if (requesterId is null)
        {
            return Unauthorized();
        }
        if (requestCommandService is UnavailableRequestCommandService)
        {
            return Problem(statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        var todayInMadrid = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(
            timeProvider.GetUtcNow(), GetMadridTimeZone()).DateTime);
        var result = requestCommandService.Submit(requesterId, command, todayInMadrid);
        if (!result.Succeeded)
        {
            return result.ErrorCode switch
            {
                "Invalid" => BadRequest(new { error = "Request fields or dates are invalid." }),
                "Forbidden" => Forbid(),
                "Overlap" => Conflict(new { error = "An active request overlaps this period." }),
                "StaleSnapshot" or "ApproverConfiguration" => Conflict(new { error = "Organization or approver configuration is unavailable." }),
                _ => Conflict()
            };
        }

        return CreatedAtAction(nameof(GetMyVacationRequest), new { requestId = result.Value!.Id }, result.Value);
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyList<VacationRequestReadModel>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<IReadOnlyList<VacationRequestReadModel>>> ListMyVacationRequests(
        [FromQuery] string? status,
        CancellationToken cancellationToken)
    {
        var requesterId = GetRequesterId();
        if (requesterId is null)
        {
            return Unauthorized();
        }

        RequestStatus? parsedStatus = null;
        if (status is not null)
        {
            if (!Enum.TryParse(status, ignoreCase: false, out RequestStatus value) || !Enum.IsDefined(value))
            {
                return BadRequest(new { error = "Unknown request status." });
            }

            parsedStatus = value;
        }

        return Ok(await requestReadService.ListAsync(requesterId, parsedStatus, cancellationToken));
    }

    [HttpGet("mine/history")]
    [ProducesResponseType(typeof(IReadOnlyList<VacationRequestHistoryItem>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<IReadOnlyList<VacationRequestHistoryItem>>> GetMyVacationHistory(
        CancellationToken cancellationToken)
    {
        var requesterId = GetRequesterId();
        if (requesterId is null)
        {
            return Unauthorized();
        }

        var todayInMadrid = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(
            timeProvider.GetUtcNow(), GetMadridTimeZone()).DateTime);
        return Ok(await requestReadService.GetHistoryAsync(requesterId, todayInMadrid, cancellationToken));
    }

    [HttpGet("{requestId:guid}")]
    [ProducesResponseType(typeof(VacationRequestReadModel), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<VacationRequestReadModel>> GetMyVacationRequest(
        Guid requestId,
        CancellationToken cancellationToken)
    {
        var requesterId = GetRequesterId();
        if (requesterId is null)
        {
            return Unauthorized();
        }

        var request = await requestReadService.GetByIdAsync(requesterId, requestId, cancellationToken);
        return request is null ? NotFound() : Ok(request);
    }

    [HttpPost("{requestId:guid}/cancel")]
    [ProducesResponseType(typeof(VacationRequestReadModel), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status409Conflict)]
    public ActionResult<VacationRequestReadModel> CancelMyVacationRequest(Guid requestId)
    {
        var requesterId = GetRequesterId();
        if (requesterId is null)
        {
            return Unauthorized();
        }
        if (requestCommandService is UnavailableRequestCommandService)
        {
            return Problem(statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        var result = requestCommandService.Cancel(requesterId, requestId, timeProvider.GetUtcNow());
        if (result.Succeeded)
        {
            return Ok(result.Value);
        }

        return result.ErrorCode switch
        {
            "NotFound" => NotFound(),
            _ => Conflict(new { error = "Only an owned request awaiting project approval can be cancelled." })
        };
    }

    private string? GetRequesterId()
    {
        var requesterId = User.FindFirstValue("sub") ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        return string.IsNullOrWhiteSpace(requesterId) ? null : requesterId;
    }

    private static TimeZoneInfo GetMadridTimeZone()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById("Europe/Madrid");
        }
        catch (TimeZoneNotFoundException)
        {
            return TimeZoneInfo.FindSystemTimeZoneById("Romance Standard Time");
        }
    }

    private sealed class UnavailableRequestCommandService : IRequestCommandService
    {
        public RequestCommandResult<VacationRequestReadModel> Submit(
            string requesterId,
            SubmitVacationRequest command,
            DateOnly todayInMadrid) => RequestCommandResult<VacationRequestReadModel>.Failure("Unavailable");

        public RequestCommandResult<VacationRequestReadModel> Cancel(
            string requesterId,
            Guid requestId,
            DateTimeOffset now) => RequestCommandResult<VacationRequestReadModel>.Failure("Unavailable");
    }
}