using VacationManagement.Application.Requests;
using VacationManagement.Infrastructure.Requests;
using VacationManagement.Application.Organization;
using VacationManagement.Infrastructure.Organization;
using VacationManagement.Application.Access;
using VacationManagement.Infrastructure.Access;
using VacationManagement.Application.Approvals;
using VacationManagement.Infrastructure.Approvals;
using VacationManagement.Application.Demand;
using VacationManagement.Infrastructure.Demand;
using VacationManagement.Application.Notifications;
using VacationManagement.Infrastructure.Notifications;
using VacationManagement.Application.Exports;
using VacationManagement.Infrastructure.Exports;
using System.Text.Json.Serialization;
using VacationManagement.Api.Authentication;
using Microsoft.AspNetCore.Authentication;
using VacationManagement.Api;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddJsonOptions(options =>
    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.AddSingleton<TimeProvider>(TimeProvider.System);
builder.Services.AddSingleton<InMemoryRequestReadRepository>();
builder.Services.AddSingleton<IRequestReadRepository>(services => services.GetRequiredService<InMemoryRequestReadRepository>());
builder.Services.AddSingleton<IRequestLifecycleStore>(services => services.GetRequiredService<InMemoryRequestReadRepository>());
builder.Services.AddScoped<IRequestReadService, RequestReadService>();
builder.Services.AddSingleton<IOrganizationSnapshotStore, InMemoryOrganizationSnapshotStore>();
builder.Services.AddSingleton<InMemoryApprovalRepository>();
builder.Services.AddSingleton<IProjectDelegationStore>(services => services.GetRequiredService<InMemoryApprovalRepository>());
builder.Services.AddSingleton<IApprovalRepository>(services => services.GetRequiredService<InMemoryApprovalRepository>());
builder.Services.AddSingleton<IAccessPolicyService, SnapshotAccessPolicyService>();
builder.Services.AddScoped<IApprovalService, ApprovalService>();
builder.Services.AddSingleton<ICapacityLimitStore, InMemoryCapacityLimitStore>();
builder.Services.AddScoped<IDemandService, DemandService>();
builder.Services.AddSingleton<INotificationOutbox, InMemoryNotificationOutbox>();
builder.Services.AddSingleton<IVacationExportOutbox, InMemoryVacationExportOutbox>();
builder.Services.AddScoped<IRequestCommandService, RequestCommandService>();
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddHostedService<ScheduledTestProfileWorker>();
    builder.Services
        .AddAuthentication(TestIdentityAuthenticationHandler.SchemeName)
        .AddScheme<AuthenticationSchemeOptions, TestIdentityAuthenticationHandler>(
            TestIdentityAuthenticationHandler.SchemeName,
            _ => { });
}
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

public partial class Program { }
