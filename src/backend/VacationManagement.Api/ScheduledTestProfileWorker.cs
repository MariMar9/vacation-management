using VacationManagement.Application.Exports;
using VacationManagement.Application.Notifications;
using VacationManagement.Application.Organization;
using VacationManagement.Application.Requests;

namespace VacationManagement.Api;

public sealed class ScheduledTestProfileWorker(
    IOrganizationSnapshotStore snapshots,
    IRequestLifecycleStore requests,
    IVacationExportOutbox exports,
    INotificationOutbox notifications,
    TimeProvider timeProvider,
    ILogger<ScheduledTestProfileWorker> logger) : BackgroundService
{
    private DateOnly? lastSnapshotRefresh;
    private DateOnly? lastDailyEvaluation;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        await RunDueJobs(stoppingToken);
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1), timeProvider);
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            await RunDueJobs(stoppingToken);
        }
    }

    private Task RunDueJobs(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var now = timeProvider.GetUtcNow();
        var madrid = ToMadrid(now);
        var today = DateOnly.FromDateTime(madrid.DateTime);

        if (madrid.TimeOfDay >= new TimeSpan(2, 0, 0) && lastSnapshotRefresh != today)
        {
            RefreshSnapshot(now, today);
        }

        if (madrid.TimeOfDay >= new TimeSpan(3, 0, 0) && lastDailyEvaluation != today)
        {
            EvaluateDailyOutboxes(now, today);
        }

        return Task.CompletedTask;
    }

    private void RefreshSnapshot(DateTimeOffset now, DateOnly today)
    {
        var current = snapshots.Current;
        if (current is null)
        {
            logger.LogWarning("Synthetic organization snapshot refresh skipped because no valid snapshot exists.");
            return;
        }

        var refreshed = current with
        {
            SnapshotVersion = $"{current.SnapshotVersion}-refresh-{now.ToUnixTimeMilliseconds()}",
            GeneratedAt = now,
        };
        var result = snapshots.Import(refreshed);
        if (!result.Accepted)
        {
            logger.LogWarning("Synthetic snapshot refresh was rejected: {ValidationErrors}", string.Join(" ", result.Errors));
            return;
        }

        lastSnapshotRefresh = today;
        logger.LogInformation("Synthetic organization snapshot refreshed as {SnapshotVersion}.", refreshed.SnapshotVersion);
    }

    private void EvaluateDailyOutboxes(DateTimeOffset now, DateOnly today)
    {
        var snapshot = snapshots.Current;
        if (snapshot is null || snapshots.IsStale(now))
        {
            logger.LogWarning("Daily simulator evaluation skipped because the organization snapshot is missing or stale.");
            return;
        }

        var allRequests = requests.ListAll();
        foreach (var request in allRequests.Where(item => item.Status == RequestStatus.Approved))
        {
            exports.QueueApproved(request, now);
        }

        var exported = exports.EvaluatePending(now, simulateFailure: false);
        var notificationsQueued = notifications.EvaluateEscalations(allRequests, snapshot, now);
        lastDailyEvaluation = today;
        logger.LogInformation(
            "Daily synthetic evaluation processed {ExportCount} export(s) and queued {NotificationCount} reminder/escalation event(s).",
            exported,
            notificationsQueued);
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