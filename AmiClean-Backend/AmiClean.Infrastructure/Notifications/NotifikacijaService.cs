using AmiClean.Application.Notifications.Constants;
using AmiClean.Application.Notifications.Dtos;
using AmiClean.Application.Notifications.Interfaces;
using AmiClean.Application.Orders.Constants;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Notifications;

public class NotifikacijaService : INotifikacijaService
{
    private readonly AmiCleanContext _context;

    public NotifikacijaService(AmiCleanContext context)
    {
        _context = context;
    }

    public void PlanirajStatusObavijest(
        int korisnikId,
        int narudzbaId,
        string statusNaziv,
        DateTime? rokZavrsetka = null)
    {
        if (korisnikId <= 0 || narudzbaId <= 0)
            return;

        if (!NotifikacijaTekstovi.TrebaObavijest(statusNaziv))
            return;

        var (naslov, poruka) = NotifikacijaTekstovi.Izgradi(narudzbaId, statusNaziv, rokZavrsetka);

        _context.Notifikacije.Add(new Notifikacija
        {
            FK_Korisnik = korisnikId,
            FK_Narudzba = narudzbaId,
            Kanal = NotifikacijaKanali.InApp,
            Naslov = naslov,
            Poruka = poruka,
            Datum_Slanja = DateTime.Now,
            Status_Slanja = NotifikacijaStatusiSlanja.Poslano,
            Procitano = false,
        });
    }

    public async Task<IReadOnlyList<NotifikacijaDto>> GetZaKorisnikaAsync(
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return [];

        return await _context.Notifikacije
            .AsNoTracking()
            .Where(n => n.FK_Korisnik == korisnikId && n.Kanal == NotifikacijaKanali.InApp)
            .OrderByDescending(n => n.Datum_Slanja)
            .Select(n => new NotifikacijaDto
            {
                Id = n.ID_Notifikacije,
                NarudzbaId = n.FK_Narudzba,
                Naslov = n.Naslov,
                Poruka = n.Poruka,
                DatumSlanja = n.Datum_Slanja,
                Procitano = n.Procitano,
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<int> GetBrojNeprocitanihAsync(
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return 0;

        return await _context.Notifikacije
            .AsNoTracking()
            .CountAsync(
                n => n.FK_Korisnik == korisnikId &&
                     n.Kanal == NotifikacijaKanali.InApp &&
                     !n.Procitano,
                cancellationToken);
    }

    public async Task OznaciProcitanomAsync(
        int notifikacijaId,
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        var notifikacija = await _context.Notifikacije
            .FirstOrDefaultAsync(
                n => n.ID_Notifikacije == notifikacijaId && n.FK_Korisnik == korisnikId,
                cancellationToken);

        if (notifikacija == null)
            throw new NotifikacijaValidationException("Obavijest nije pronađena.");

        notifikacija.Procitano = true;
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task OznaciSveProcitanimAsync(
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            throw new NotifikacijaValidationException("KorisnikId nije ispravan.");

        var neprocitane = await _context.Notifikacije
            .Where(n =>
                n.FK_Korisnik == korisnikId &&
                n.Kanal == NotifikacijaKanali.InApp &&
                !n.Procitano)
            .ToListAsync(cancellationToken);

        foreach (var notifikacija in neprocitane)
            notifikacija.Procitano = true;

        if (neprocitane.Count > 0)
            await _context.SaveChangesAsync(cancellationToken);
    }
}

internal static class NotifikacijaTekstovi
{
    public static bool TrebaObavijest(string statusNaziv) => statusNaziv switch
    {
        NarudzbaStatusi.Primljena => true,
        NarudzbaStatusi.UObradi => true,
        NarudzbaStatusi.Gotova => true,
        NarudzbaStatusi.Preuzeta => true,
        NarudzbaStatusi.Otkazana => true,
        _ => false,
    };

    public static (string Naslov, string Poruka) Izgradi(
        int narudzbaId,
        string statusNaziv,
        DateTime? rokZavrsetka)
    {
        var broj = $"#{narudzbaId}";

        return statusNaziv switch
        {
            NarudzbaStatusi.Primljena => (
                "Narudžba primljena",
                rokZavrsetka.HasValue
                    ? $"Narudžba {broj} je primljena u čistionici. Rok završetka: {rokZavrsetka.Value:dd.MM.yyyy}."
                    : $"Narudžba {broj} je primljena u čistionici."),
            NarudzbaStatusi.UObradi => (
                "Narudžba u obradi",
                $"Narudžba {broj} je u obradi. Obavijestit ćemo vas kad bude spremna."),
            NarudzbaStatusi.Gotova => (
                "Narudžba spremna",
                $"Narudžba {broj} je gotova i spremna za preuzimanje ili dostavu."),
            NarudzbaStatusi.Preuzeta => (
                "Narudžba preuzeta",
                $"Narudžba {broj} je označena kao preuzeta. Hvala vam na povjerenju!"),
            NarudzbaStatusi.Otkazana => (
                "Narudžba otkazana",
                $"Narudžba {broj} je otkazana. Za detalje nas možete kontaktirati."),
            _ => (
                "Ažuriranje narudžbe",
                $"Status narudžbe {broj} je promijenjen u '{statusNaziv}'."),
        };
    }
}

public class NotifikacijaValidationException : Exception
{
    public NotifikacijaValidationException(string message) : base(message) { }
}
