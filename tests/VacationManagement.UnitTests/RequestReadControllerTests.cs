using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using VacationManagement.Api.Controllers;
using VacationManagement.Application.Requests;

namespace VacationManagement.UnitTests;

public class RequestReadControllerTests
{
    [Fact]
    public async Task GetMyVacationRequest_hides_requests_owned_by_another_requester()
    {
        var requestId = Guid.NewGuid();
        var controller = CreateController(
            new VacationRequestReadModel(
                requestId, "EMP-TEST-002", "DEPT-TEST-001", "PRJ-TEST-ALPHA",
                new(2026, 9, 1), new(2026, 9, 5), null, RequestStatus.Approved,
                DateTimeOffset.UnixEpoch, DateTimeOffset.UnixEpoch, 1),
            "EMP-TEST-001");

        var result = await controller.GetMyVacationRequest(requestId, CancellationToken.None);

        Assert.IsType<NotFoundResult>(result.Result);
    }

    [Fact]
    public async Task GetMyVacationRequest_returns_the_authenticated_requesters_record()
    {
        var requestId = Guid.NewGuid();
        var controller = CreateController(
            new VacationRequestReadModel(
                requestId, "EMP-TEST-001", "DEPT-TEST-001", "PRJ-TEST-ALPHA",
                new(2026, 9, 1), new(2026, 9, 5), null, RequestStatus.Approved,
                DateTimeOffset.UnixEpoch, DateTimeOffset.UnixEpoch, 1),
            "EMP-TEST-001");

        var result = await controller.GetMyVacationRequest(requestId, CancellationToken.None);

        var response = Assert.IsType<OkObjectResult>(result.Result);
        Assert.Equal(requestId, Assert.IsType<VacationRequestReadModel>(response.Value).Id);
    }

    private static RequestsController CreateController(VacationRequestReadModel request, string subject)
    {
        var repository = new SingleRequestRepository(request);
        return new RequestsController(new RequestReadService(repository), TimeProvider.System)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("sub", subject)], "test"))
                }
            }
        };
    }

    private sealed class SingleRequestRepository(VacationRequestReadModel request) : IRequestReadRepository
    {
        public Task<IReadOnlyList<VacationRequestReadModel>> ListByRequesterAsync(
            string requesterId,
            CancellationToken cancellationToken)
        {
            IReadOnlyList<VacationRequestReadModel> requests = request.RequesterId == requesterId
                ? [request]
                : [];
            return Task.FromResult(requests);
        }
    }
}