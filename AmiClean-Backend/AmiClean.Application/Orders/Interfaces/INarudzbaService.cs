using AmiClean.Application.Orders.Dtos;

namespace AmiClean.Application.Orders.Interfaces;

public interface INarudzbaService
{
    Task<NarudzbaKreiranaDto> KreirajNarudzbuAsync(
        KreirajNarudzbuRequest request,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<NarudzbaPregledDto>> GetNarudzbeKorisnikaAsync(
        int korisnikId,
        CancellationToken cancellationToken = default);

    Task<NarudzbaDetaljDto> GetDetaljNarudzbeAsync(
        int narudzbaId,
        int korisnikId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<NarudzbaAdminPregledDto>> GetSveNarudzbeAsync(
        string? statusNaziv = null,
        CancellationToken cancellationToken = default);

    Task<NarudzbaAdminDetaljDto> GetDetaljNarudzbeAdminAsync(
        int narudzbaId,
        CancellationToken cancellationToken = default);

    Task<NarudzbaStatusPromjenaDto> PrimijeniNarudzbuAsync(
        PrimijeniNarudzbuRequest request,
        CancellationToken cancellationToken = default);

    Task<NarudzbaStatusPromjenaDto> PromijeniStatusNarudzbeAsync(
        PromijeniStatusNarudzbeRequest request,
        CancellationToken cancellationToken = default);
}
