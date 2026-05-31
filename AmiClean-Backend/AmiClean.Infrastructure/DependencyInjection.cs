using AmiClean.Application.Auth.Interfaces;
using AmiClean.Application.Catalog.Interfaces;
using AmiClean.Infrastructure.Auth;
using AmiClean.Infrastructure.Catalog;
using AmiClean.Infrastructure.Persistence;
using AmiClean.Infrastructure.Security;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AmiClean.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<AmiCleanContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<IPasswordHasher, Sha256PasswordHasher>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ICatalogService, CatalogService>();

        return services;
    }
}
