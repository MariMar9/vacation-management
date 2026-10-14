using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Api.Controllers;
using VacationManagement.Application.Requests;

namespace VacationManagement.UnitTests;

public class RequestReadServiceTests
{
    private static readonly DateOnly Today = new(2026, 10, 9);
    private static readonly DateTimeOffset Timestamp = new(2026, 10, 9, 8, 0, 0, TimeSpan.Zero);

    [Fact]
    public async Task ListAsync_returns_only_the_requesters_matching_status()
    {
        var repository = new TestRequestReadRepository(
            Request("EMP-TEST-001", RequestStatus.Approved, new(2026, 9, 1), new(2026, 9, 5)),
            Request("EMP-TEST-001", RequestStatus.Rejected, new(2026, 11, 1), new(2026, 11, 3)),
            Request("EMP-TEST-002", RequestStatus.Approved, new(2026, 9, 1), new(2026, 9, 5)));
        var service = new RequestReadService(repository);

        var result = await service.ListAsync("EMP-TEST-001", RequestStatus.Approved, CancellationToken.None);

        var request = Assert.Single(result);
        Assert.Equal("EMP-TEST-001", request.RequesterId);
        Assert.Equal(RequestStatus.Approved, request.Status);
    }

    [Fact]
    public async Task GetHistoryAsync_returns_all_own_states_and_derives_taken_strictly_before_today()
    {
        var repository = new TestRequestReadRepository(
            Request("EMP-TEST-001", RequestStatus.Approved, new(2026, 10, 1), new(2026, 10, 8)),
            Request("EMP-TEST-001", RequestStatus.Approved, new(2026, 10, 8), Today),
            Request("EMP-TEST-001", RequestStatus.Rejected, new(2026, 8, 1), new(2026, 8, 5)),
            Request("EMP-TEST-001", RequestStatus.Cancelled, new(2026, 8, 1), new(2026, 8, 5)),
            Request("EMP-TEST-001", RequestStatus.PendingProjectApproval, new(2026, 12, 1), new(2026, 12, 5)),
            Request("EMP-TEST-002", RequestStatus.Approved, new(2026, 8, 1), new(2026, 8, 5)));
        var service = new RequestReadService(repository);

        var result = await service.GetHistoryAsync("EMP-TEST-001", Today, CancellationToken.None);

        Assert.Equal(5, result.Count);
        Assert.Single(result.Where(item => item.Taken));
        Assert.Equal(RequestStatus.Approved, result.Single(item => item.Taken).Status);
        Assert.Contains(result, item => item.Status == RequestStatus.Rejected && !item.Taken);
        Assert.Contains(result, item => item.Status == RequestStatus.Cancelled && !item.Taken);
        Assert.Contains(result, item => item.Status == RequestStatus.PendingProjectApproval && !item.Taken);
        Assert.Contains(result, item => item.Status == RequestStatus.Approved && item.EndDate == Today && !item.Taken);
    }

    [Fact]
    public async Task History_endpoint_returns_unauthorized_without_requester_identity()
    {
        var controller = new RequestsController(
            new RequestReadService(new TestRequestReadRepository()),
            TimeProvider.System)
        {
            ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() }
        };

        var result = await controller.GetMyVacationHistory(CancellationToken.None);

        Assert.IsType<UnauthorizedResult>(result.Result);
    }

    [Fact]
    public async Task History_endpoint_uses_only_the_authenticated_subject()
    {
        var repository = new TestRequestReadRepository(
            Request("EMP-TEST-001", RequestStatus.Approved, new(2026, 8, 1), new(2026, 8, 5)),
            Request("EMP-TEST-002", RequestStatus.Approved, new(2026, 8, 1), new(2026, 8, 5)));
        var controller = new RequestsController(new RequestReadService(repository), TimeProvider.System)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("sub", "EMP-TEST-001")], "test"))
                }
            }
        };

        var action = await controller.GetMyVacationHistory(CancellationToken.None);
        var response = Assert.IsType<OkObjectResult>(action.Result);
        var result = Assert.IsAssignableFrom<IReadOnlyList<VacationRequestHistoryItem>>(response.Value);

        Assert.Equal("EMP-TEST-001", Assert.Single(result).RequesterId);
    }

    private static VacationRequestReadModel Request(
        string requesterId,
        RequestStatus status,
        DateOnly startDate,
        DateOnly endDate) => new(
            Guid.NewGuid(), requesterId, "DEPT-TEST-001", "PRJ-TEST-ALPHA",
            startDate, endDate, null, status, Timestamp, Timestamp, 1);

    private sealed class TestRequestReadRepository(params VacationRequestReadModel[] requests)
        : IRequestReadRepository
    {
        public Task<IReadOnlyList<VacationRequestReadModel>> ListByRequesterAsync(
            string requesterId,
            CancellationToken cancellationToken)
        {
            IReadOnlyList<VacationRequestReadModel> results = requests
                .Where(request => request.RequesterId == requesterId)
                .ToArray();
            return Task.FromResult(results);
        }
    }
}