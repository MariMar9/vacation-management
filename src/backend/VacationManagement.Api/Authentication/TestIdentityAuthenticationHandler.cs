using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace VacationManagement.Api.Authentication;

public sealed class TestIdentityAuthenticationHandler(
    IOptionsMonitor<AuthenticationSchemeOptions> options,
    ILoggerFactory logger,
    UrlEncoder encoder)
    : AuthenticationHandler<AuthenticationSchemeOptions>(options, logger, encoder)
{
    public const string SchemeName = "SyntheticTestIdentity";

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        if (!Request.Headers.TryGetValue("Authorization", out var authorization) ||
            !authorization.ToString().StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult(AuthenticateResult.NoResult());
        }

        var subjectId = authorization.ToString()["Bearer ".Length..].Trim();
        if (!IsProvisionedSyntheticIdentity(subjectId))
        {
            return Task.FromResult(AuthenticateResult.Fail("Unknown synthetic test identity."));
        }

        var claims = new[]
        {
            new Claim("sub", subjectId),
            new Claim(ClaimTypes.NameIdentifier, subjectId)
        };
        var identity = new ClaimsIdentity(claims, SchemeName);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, SchemeName);
        return Task.FromResult(AuthenticateResult.Success(ticket));
    }

    private static bool IsProvisionedSyntheticIdentity(string subjectId) =>
        subjectId is "EMP-TEST-001" or "EMP-TEST-002" or "EMP-TEST-003" or "EMP-TEST-004" or
            "EMP-TEST-005" or "EMP-TEST-006" or "EMP-TEST-007" or "EMP-TEST-008" or
            "EMP-TEST-009" or "EMP-TEST-010";
}