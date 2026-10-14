using Microsoft.AspNetCore.Mvc;
using VacationManagement.Api.Controllers;

namespace VacationManagement.UnitTests;

public class HealthControllerTests
{
    [Fact]
    public void Get_ReturnsHealthyStatus()
    {
        var controller = new HealthController();

        var result = controller.Get();

        var response = Assert.IsType<OkObjectResult>(result.Result);
        Assert.Equal("Healthy", response.Value);
    }
}