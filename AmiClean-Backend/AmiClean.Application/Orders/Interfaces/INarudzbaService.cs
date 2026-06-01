using AmiClean.Application.Orders.Dtos;

namespace AmiClean.Application.Orders.Interfaces;

public interface INarudzbaService
{
    Task<NarudzbaKreiranaDto> KreirajNarudzbuAsync(
        KreirajNarudzbuRequest request,
        CancellationToken cancellationToken = default);
}
