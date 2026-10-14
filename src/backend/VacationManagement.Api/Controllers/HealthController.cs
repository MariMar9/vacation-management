using Microsoft.AspNetCore.Mvc;

namespace VacationManagement.Api.Controllers;

[ApiController]
[Route("health")]
public sealed class HealthController : ControllerBase
{
    [HttpGet]
    public ActionResult<string> Get() => Ok("Healthy");
}