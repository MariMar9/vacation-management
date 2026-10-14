namespace VacationManagement.Application.Requests;

public sealed record SubmitVacationRequest(string ProjectId, DateOnly StartDate, DateOnly EndDate, string? Reason);

public sealed record RequestCommandResult<T>(T? Value, string? ErrorCode)
{
    public bool Succeeded => ErrorCode is null;

    public static RequestCommandResult<T> Success(T value) => new(value, null);

    public static RequestCommandResult<T> Failure(string errorCode) => new(default, errorCode);
}

public interface IRequestCommandService
{
    RequestCommandResult<VacationRequestReadModel> Submit(
        string requesterId,
        SubmitVacationRequest command,
        DateOnly todayInMadrid);

    RequestCommandResult<VacationRequestReadModel> Cancel(
        string requesterId,
        Guid requestId,
        DateTimeOffset now);
}