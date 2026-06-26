using AmiClean.Application.Notifications.Dtos;

namespace AmiClean.Application.Notifications.Interfaces;

public interface INotifikacijaService
{
    /// <summary>Dodaje in-app obavijest u trenutni DbContext (bez SaveChanges).</summary>
    void PlanirajStatusObavijest(
        int korisnikId,
        int narudzbaId,
        string statusNaziv,
        DateTime? rokZavrsetka = null);

    Task<IReadOnlyList<NotifikacijaDto>> GetZaKorisnikaAsync(
        int korisnikId,
        CancellationToken cancellationToken = default);

    Task<int> GetBrojNeprocitanihAsync(
        int korisnikId,
        CancellationToken cancellationToken = default);

    Task OznaciProcitanomAsync(
        int notifikacijaId,
        int korisnikId,
        CancellationToken cancellationToken = default);

    Task OznaciSveProcitanimAsync(
        int korisnikId,
        CancellationToken cancellationToken = default);
}
