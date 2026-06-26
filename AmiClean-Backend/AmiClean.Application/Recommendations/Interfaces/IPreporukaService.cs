using AmiClean.Application.Recommendations.Dtos;

namespace AmiClean.Application.Recommendations.Interfaces;

public interface IPreporukaService
{
    Task<IReadOnlyList<PreporukaDto>> GetZaKorisnikaAsync(
        int korisnikId,
        int limit = 3,
        CancellationToken cancellationToken = default);
}
