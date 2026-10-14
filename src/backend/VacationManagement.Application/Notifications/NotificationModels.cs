using VacationManagement.Application.Organization;
using VacationManagement.Application.Requests;

namespace VacationManagement.Application.Notifications;

public sealed record NotificationPayload(
    Guid RequestId,
    string EventType,
    string RecipientId,
    string Status,
    string Link);

public sealed record NotificationRecord(
    Guid Id,
    string EventKey,
    Guid RequestId,
    string EventType,
    string RecipientId,
    DateTimeOffset OccurredAt,
    NotificationPayload Payload,
    string DeliveryStatus,
    int AttemptCount,
    DateTimeOffset CreatedAt);

public interface INotificationOutbox
{
    void Enqueue(VacationRequestReadModel request, string eventType, string recipientId, DateTimeOffset occurredAt);

    IReadOnlyList<NotificationRecord> ListForRecipient(string recipientId, Guid? requestId);

    int EvaluateEscalations(
        IReadOnlyList<VacationRequestReadModel> requests,
        OrganizationSnapshot snapshot,
        DateTimeOffset now);
}