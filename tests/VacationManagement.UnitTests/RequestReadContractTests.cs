using Microsoft.AspNetCore.Mvc;

namespace VacationManagement.UnitTests;

public class RequestReadContractTests
{
    [Theory]
    [InlineData("ListMyVacationRequests", "")]
    [InlineData("GetMyVacationHistory", "mine/history")]
    [InlineData("GetMyVacationRequest", "{requestId:guid}")]
    public void Request_read_actions_match_the_openapi_routes(string actionName, string expectedRoute)
    {
        var controllerType = typeof(Program).Assembly.GetTypes()
            .SingleOrDefault(type => type.Name == "RequestsController");

        Assert.NotNull(controllerType);

        var controllerRoute = controllerType!.GetCustomAttributes(typeof(RouteAttribute), true)
            .Cast<RouteAttribute>()
            .Single();
        Assert.Equal("api/requests", controllerRoute.Template);
        var action = controllerType.GetMethods()
            .SingleOrDefault(method => method.Name == actionName);
        Assert.NotNull(action);

        var getRoute = action!.GetCustomAttributes(typeof(HttpGetAttribute), true)
            .Cast<HttpGetAttribute>()
            .Single();

        Assert.Equal(expectedRoute, getRoute.Template ?? string.Empty);
    }
}