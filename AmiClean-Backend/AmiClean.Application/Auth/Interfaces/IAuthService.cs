using AmiClean.Application.Auth.Dtos;

namespace AmiClean.Application.Auth.Interfaces;

public interface IAuthService
{
    Task<PrijavaResponse?> PrijavaKorisnikaAsync(
        PrijavaKorisnikaRequest request,
        CancellationToken cancellationToken = default);

    Task<PrijavaResponse?> PrijavaZaposlenikaAsync(
        PrijavaZaposlenikaRequest request,
        CancellationToken cancellationToken = default);
}
