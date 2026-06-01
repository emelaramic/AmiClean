using AmiClean.Application.Orders;
using AmiClean.Application.Orders.Constants;
using AmiClean.Application.Orders.Dtos;
using AmiClean.Application.Orders.Interfaces;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Orders;

public class NarudzbaService : INarudzbaService
{
    private readonly AmiCleanContext _context;

    public NarudzbaService(AmiCleanContext context)
    {
        _context = context;
    }

    public async Task<NarudzbaKreiranaDto> KreirajNarudzbuAsync(
        KreirajNarudzbuRequest request,
        CancellationToken cancellationToken = default)
    {
        ValidirajZahtjev(request);

        var korisnik = await _context.Korisnici
            .AsNoTracking()
            .FirstOrDefaultAsync(k => k.ID_Korisnika == request.KorisnikId && k.Aktivan, cancellationToken)
            ?? throw new NarudzbaValidationException("Korisnik nije pronađen ili nije aktivan.");

        var statusNarudzbe = await _context.StatusiNarudzbe
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == NarudzbaStatusi.Kreirana, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status narudžbe '{NarudzbaStatusi.Kreirana}' nije definisan u bazi.");

        var statusStavke = await _context.StatusiStavke
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == StavkaStatusi.Kreirana, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status stavke '{StavkaStatusi.Kreirana}' nije definisan u bazi.");

        var pripremeneStavke = await PripremiStavkeAsync(request.Stavke, cancellationToken);
        var ukupnaCijena = pripremeneStavke.Sum(s => s.Ukupno);

        var nacinZavrsetka = request.NacinPredaje == NacinPredajeVrijednosti.PreuzimanjeIDostava
            ? NacinZavrsetkaVrijednosti.Dostava
            : NacinZavrsetkaVrijednosti.PreuzimanjeURadnji;

        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

        var narudzba = new Narudzba
        {
            FK_Korisnik = korisnik.ID_Korisnika,
            FK_Status = statusNarudzbe.ID_Statusa,
            Kanal = NarudzbaKanali.Aplikacija,
            Nacin_Predaje = request.NacinPredaje,
            Nacin_Zavrsetka = nacinZavrsetka,
            Datum_Prijema = DateTime.Now,
            Ukupna_Cijena = ukupnaCijena,
            Popust_Iznos = 0,
            Napomena = string.IsNullOrWhiteSpace(request.Napomena) ? null : request.Napomena.Trim(),
        };

        _context.Narudzbe.Add(narudzba);
        await _context.SaveChangesAsync(cancellationToken);

        foreach (var stavka in pripremeneStavke)
        {
            var entitet = new StavkaNarudzbe
            {
                FK_Narudzba = narudzba.ID_Narudzbe,
                FK_Artikal = stavka.ArtikalId,
                FK_Status = statusStavke.ID_Statusa,
                Kolicina = stavka.Kolicina,
                Napomena = stavka.Napomena,
                Cijena_Jedinicna = stavka.CijenaJedinicna,
                Usluge = stavka.Usluge.Select(u => new StavkaUsluga
                {
                    FK_Usluga = u.UslugaId,
                    Cijena_Usluge = u.Cijena,
                }).ToList(),
            };

            _context.StavkeNarudzbe.Add(entitet);
        }

        if (request.NacinPredaje == NacinPredajeVrijednosti.PreuzimanjeIDostava)
        {
            var statusLogistike = await _context.StatusiLogistike
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.Naziv == LogistikaStatusi.Zakazano, cancellationToken)
                ?? throw new NarudzbaValidationException(
                    $"Status logistike '{LogistikaStatusi.Zakazano}' nije definisan u bazi.");

            _context.Logistike.Add(new Logistika
            {
                FK_Narudzba = narudzba.ID_Narudzbe,
                FK_Status = statusLogistike.ID_Statusa,
                Tip = LogistikaTipovi.Preuzimanje,
                Adresa = request.Adresa!.Trim(),
            });
        }

        await _context.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        var poruka = request.NacinPredaje == NacinPredajeVrijednosti.DonosUCistionicu
            ? "Narudžba je kreirana. Donijet ćete stvari u čistionicu — rok završetka bit će potvrđen nakon prijema."
            : "Narudžba je kreirana. Kontaktirat ćemo vas za preuzimanje — rok završetka bit će potvrđen nakon prijema stvari.";

        return new NarudzbaKreiranaDto
        {
            Id = narudzba.ID_Narudzbe,
            StatusNaziv = statusNarudzbe.Naziv,
            NacinPredaje = request.NacinPredaje,
            UkupnaCijena = ukupnaCijena,
            DatumKreiranja = narudzba.Datum_Prijema,
            Poruka = poruka,
        };
    }

    private static void ValidirajZahtjev(KreirajNarudzbuRequest request)
    {
        if (request.KorisnikId <= 0)
            throw new NarudzbaValidationException("KorisnikId nije ispravan.");

        if (!NacinPredajeVrijednosti.Sve.Contains(request.NacinPredaje))
            throw new NarudzbaValidationException("Način predaje nije ispravan.");

        if (request.NacinPredaje == NacinPredajeVrijednosti.PreuzimanjeIDostava
            && string.IsNullOrWhiteSpace(request.Adresa))
        {
            throw new NarudzbaValidationException(
                "Adresa je obavezna za opciju preuzimanja i dostave.");
        }

        if (request.Stavke.Count == 0)
            throw new NarudzbaValidationException("Narudžba mora imati barem jednu stavku.");
    }

    private async Task<List<PripremenaStavka>> PripremiStavkeAsync(
        List<KreirajStavkuRequest> stavke,
        CancellationToken cancellationToken)
    {
        var artikalIds = stavke.Select(s => s.ArtikalId).Distinct().ToList();
        var today = DateOnly.FromDateTime(DateTime.Today);

        var artikli = await _context.Artikli
            .AsNoTracking()
            .Where(a => artikalIds.Contains(a.ID_Artikla) && a.Aktivan)
            .ToDictionaryAsync(a => a.ID_Artikla, cancellationToken);

        if (artikli.Count != artikalIds.Count)
            throw new NarudzbaValidationException("Jedan ili više artikala nije dostupan.");

        var cjenovnik = await _context.Cjenovnici
            .AsNoTracking()
            .Where(c =>
                artikalIds.Contains(c.FK_Artikal) &&
                c.Vazi_Od <= today &&
                (c.Vazi_Do == null || c.Vazi_Do >= today))
            .Select(c => new
            {
                c.FK_Artikal,
                c.FK_Usluga,
                c.Cijena,
            })
            .ToListAsync(cancellationToken);

        var cijenePoParu = cjenovnik.ToDictionary(
            c => (c.FK_Artikal, c.FK_Usluga),
            c => c.Cijena);

        var rezultat = new List<PripremenaStavka>();

        foreach (var stavka in stavke)
        {
            if (stavka.Kolicina <= 0)
            {
                throw new NarudzbaValidationException(
                    $"Količina mora biti veća od nule (artikal ID {stavka.ArtikalId}).");
            }

            if (stavka.UslugaIds.Count == 0)
            {
                throw new NarudzbaValidationException(
                    $"Odaberite barem jednu uslugu za artikal ID {stavka.ArtikalId}.");
            }

            var jedinstveneUsluge = stavka.UslugaIds.Distinct().ToList();
            decimal cijenaJedinicna = 0;
            var usluge = new List<PripremenaUsluga>();

            foreach (var uslugaId in jedinstveneUsluge)
            {
                if (!cijenePoParu.TryGetValue((stavka.ArtikalId, uslugaId), out var cijena))
                {
                    var naziv = artikli[stavka.ArtikalId].Naziv;
                    throw new NarudzbaValidationException(
                        $"Usluga nije dostupna u cjenovniku za artikal '{naziv}'.");
                }

                cijenaJedinicna += cijena;
                usluge.Add(new PripremenaUsluga(uslugaId, cijena));
            }

            rezultat.Add(new PripremenaStavka
            {
                ArtikalId = stavka.ArtikalId,
                Kolicina = stavka.Kolicina,
                Napomena = string.IsNullOrWhiteSpace(stavka.Napomena) ? null : stavka.Napomena.Trim(),
                CijenaJedinicna = cijenaJedinicna,
                Usluge = usluge,
            });
        }

        return rezultat;
    }

    public async Task<IReadOnlyList<NarudzbaPregledDto>> GetNarudzbeKorisnikaAsync(
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            throw new NarudzbaValidationException("KorisnikId nije ispravan.");

        var postoji = await _context.Korisnici
            .AsNoTracking()
            .AnyAsync(k => k.ID_Korisnika == korisnikId && k.Aktivan, cancellationToken);

        if (!postoji)
            throw new NarudzbaValidationException("Korisnik nije pronađen.");

        var narudzbe = await _context.Narudzbe
            .AsNoTracking()
            .Where(n => n.FK_Korisnik == korisnikId)
            .OrderByDescending(n => n.Datum_Prijema)
            .Select(n => new NarudzbaPregledDto
            {
                Id = n.ID_Narudzbe,
                DatumKreiranja = n.Datum_Prijema,
                StatusNaziv = n.Status.Naziv,
                NacinPredaje = n.Nacin_Predaje,
                UkupnaCijena = n.Ukupna_Cijena,
                BrojStavki = n.Stavke.Count,
            })
            .ToListAsync(cancellationToken);

        foreach (var n in narudzbe)
            n.NacinPredajeNaziv = NacinPredajeNazivi.ZaPrikaz(n.NacinPredaje);

        return narudzbe;
    }

    public async Task<NarudzbaDetaljDto> GetDetaljNarudzbeAsync(
        int narudzbaId,
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (narudzbaId <= 0 || korisnikId <= 0)
            throw new NarudzbaValidationException("Identifikatori nisu ispravni.");

        var narudzba = await _context.Narudzbe
            .AsNoTracking()
            .Include(n => n.Status)
            .Include(n => n.Stavke).ThenInclude(s => s.Artikal)
            .Include(n => n.Stavke).ThenInclude(s => s.Usluge).ThenInclude(u => u.Usluga)
            .Include(n => n.Logistike)
            .FirstOrDefaultAsync(
                n => n.ID_Narudzbe == narudzbaId && n.FK_Korisnik == korisnikId,
                cancellationToken);

        if (narudzba == null)
            throw new NarudzbaValidationException("Narudžba nije pronađena.");

        var adresa = narudzba.Logistike
            .FirstOrDefault(l => l.Tip == LogistikaTipovi.Preuzimanje)
            ?.Adresa;

        return new NarudzbaDetaljDto
        {
            Id = narudzba.ID_Narudzbe,
            DatumKreiranja = narudzba.Datum_Prijema,
            StatusNaziv = narudzba.Status.Naziv,
            NacinPredaje = narudzba.Nacin_Predaje,
            NacinPredajeNaziv = NacinPredajeNazivi.ZaPrikaz(narudzba.Nacin_Predaje),
            UkupnaCijena = narudzba.Ukupna_Cijena,
            Napomena = narudzba.Napomena,
            AdresaPreuzimanja = adresa,
            RokZavrsetka = narudzba.Rok_Zavrsetka,
            Stavke = narudzba.Stavke
                .OrderBy(s => s.ID_Stavke)
                .Select(s => new StavkaPregledDto
                {
                    Id = s.ID_Stavke,
                    ArtikalNaziv = s.Artikal.Naziv,
                    Kategorija = s.Artikal.Kategorija,
                    Kolicina = s.Kolicina,
                    CijenaJedinicna = s.Cijena_Jedinicna,
                    Ukupno = s.Kolicina * s.Cijena_Jedinicna,
                    Napomena = s.Napomena,
                    Usluge = s.Usluge
                        .OrderBy(u => u.Usluga.Naziv)
                        .Select(u => new StavkaUslugaPregledDto
                        {
                            UslugaNaziv = u.Usluga.Naziv,
                            Cijena = u.Cijena_Usluge,
                        })
                        .ToList(),
                })
                .ToList(),
        };
    }

    private sealed class PripremenaStavka
    {
        public int ArtikalId { get; init; }
        public decimal Kolicina { get; init; }
        public string? Napomena { get; init; }
        public decimal CijenaJedinicna { get; init; }
        public List<PripremenaUsluga> Usluge { get; init; } = [];
        public decimal Ukupno => Kolicina * CijenaJedinicna;
    }

    private sealed record PripremenaUsluga(int UslugaId, decimal Cijena);
}
