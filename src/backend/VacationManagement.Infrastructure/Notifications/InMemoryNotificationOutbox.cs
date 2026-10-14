using VacationManagement.Application.Notifications;
using VacationManagement.Application.Organization;
using VacationManagement.Application.Requests;

namespace VacationManagement.Infrastructure.Notifications;

public sealed class InMemoryNotificationOutbox : INotificationOutbox
{
    private readonly object sync = new();
    private readonly Dictionary<string, NotificationRecord> records = new(StringComparer.Ordinal);

    public void Enqueue(
        VacationRequestReadModel request,
        string eventType,
        string recipientId,
        DateTimeOffset occurredAt)
    {
        var eventKey = $"{request.Id}:{request.Version}:{eventType}:{recipientId}";
        var payload = new NotificationPayload(
            request.Id, eventType, recipientId, request.Status.ToString(), $"/requests/{request.Id}");
        lock (sync)
        {
            records.TryAdd(eventKey, new NotificationRecord(
                Guid.NewGuid(), eventKey, request.Id, eventType, recipientId, occurredAt,
                payload, "Pending", 0, occurredAt));
        }
    }

    public IReadOnlyList<NotificationRecord> ListForRecipient(string recipientId, Guid? requestId)
    {
        lock (sync)
        {
            return records.Values
                .Where(record => record.RecipientId == recipientId && (requestId is null || record.RequestId == requestId))
                .OrderByDescending(record => record.CreatedAt)
                .ToArray();
        }
    }

    public int EvaluateEscalations(
        IReadOnlyList<VacationRequestReadModel> requests,
        OrganizationSnapshot snapshot,
        DateTimeOffset now)
    {
        var departmentApprover = snapshot.ApproverAssignments.SingleOrDefault(assignment =>
            assignment.ScopeType == "Department" && assignment.ScopeId == snapshot.Department.DepartmentId &&
            assignment.Role == "DepartmentApprover" && snapshot.Employees.Any(employee =>
                employee.EmployeeId == assignment.ApproverId && employee.Active));
        if (departmentApprover is null)
        {
            return 0;
        }

        var created = 0;
        var localNow = ToMadrid(now);
        foreach (var request in requests.Where(item =>
            item.Status is RequestStatus.PendingProjectApproval or RequestStatus.PendingDepartmentApproval))
        {
            var pendingSince = ToMadrid(request.UpdatedAt);
            if (localNow >= pendingSince.AddDays(3))
            {
                created += EnqueueIfNew(request, "RequestReminder", departmentApprover.ApproverId, now);
            }
            if (localNow >= pendingSince.AddDays(5))
            {
                created += EnqueueIfNew(request, "RequestEscalated", departmentApprover.ApproverId, now);
            }
        }

        return created;
    }

    private int EnqueueIfNew(
        VacationRequestReadModel request,
        string eventType,
        string recipientId,
        DateTimeOffset now)
    {
        var eventKey = $"{request.Id}:{request.Version}:{eventType}:{recipientId}";
        var payload = new NotificationPayload(
            request.Id, eventType, recipientId, request.Status.ToString(), $"/requests/{request.Id}");
        lock (sync)
        {
            return records.TryAdd(eventKey, new NotificationRecord(
                Guid.NewGuid(), eventKey, request.Id, eventType, recipientId, now,
                payload, "Pending", 0, now)) ? 1 : 0;
        }
    }

    private static DateTimeOffset ToMadrid(DateTimeOffset value)
    {
        try
        {
            return TimeZoneInfo.ConvertTime(value, TimeZoneInfo.FindSystemTimeZoneById("Europe/Madrid"));
        }
        catch (TimeZoneNotFoundException)
        {
            return TimeZoneInfo.ConvertTime(value, TimeZoneInfo.FindSystemTimeZoneById("Romance Standard Time"));
        }
    }
}