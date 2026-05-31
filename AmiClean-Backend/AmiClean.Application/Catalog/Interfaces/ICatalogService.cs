using AmiClean.Application.Catalog.Dtos;

namespace AmiClean.Application.Catalog.Interfaces;

public interface ICatalogService
{
    Task<IReadOnlyList<ArtikalKatalogDto>> GetKatalogAsync(CancellationToken cancellationToken = default);
}
