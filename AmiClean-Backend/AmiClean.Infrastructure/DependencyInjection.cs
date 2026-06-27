using AmiClean.Application.Auth.Interfaces;
using AmiClean.Application.Catalog.Interfaces;
using AmiClean.Application.Coupons.Interfaces;
using AmiClean.Application.Notifications.Interfaces;
using AmiClean.Application.Orders.Interfaces;
using AmiClean.Application.Recommendations.Interfaces;
using AmiClean.Application.Reviews.Interfaces;
using AmiClean.Infrastructure.Auth;
using AmiClean.Infrastructure.Catalog;
using AmiClean.Infrastructure.Coupons;
using AmiClean.Infrastructure.Notifications;
using AmiClean.Infrastructure.Orders;
using AmiClean.Infrastructure.Persistence;
using AmiClean.Infrastructure.Recommendations;
using AmiClean.Infrastructure.Reviews;
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
        services.AddScoped<IKuponService, KuponService>();
        services.AddScoped<INarudzbaService, NarudzbaService>();
        services.AddScoped<IPreporukaService, PreporukaService>();
        services.AddScoped<INotifikacijaService, NotifikacijaService>();
        services.AddScoped<IRecenzijaService, RecenzijaService>();

        return services;
    }
}
