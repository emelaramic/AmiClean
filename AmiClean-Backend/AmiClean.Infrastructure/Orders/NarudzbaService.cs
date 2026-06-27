using AmiClean.Application.Notifications.Interfaces;
using AmiClean.Application.Orders;
using AmiClean.Application.Orders.Constants;
using AmiClean.Application.Orders.Dtos;
using AmiClean.Application.Orders.Interfaces;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using AmiClean.Infrastructure.Reviews;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Orders;

public class NarudzbaService : INarudzbaService
{
    private readonly AmiCleanContext _context;
    private readonly INotifikacijaService _notifikacijaService;

    public NarudzbaService(AmiCleanContext context, INotifikacijaService notifikacijaService)
    {
        _context = context;
        _notifikacijaService = notifikacijaService;
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
                MozeSeRecenzirati =
                    n.Status.Naziv == NarudzbaStatusi.Preuzeta && n.Recenzija == null,
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
            .Include(n => n.Recenzija)
            .Include(n => n.Stavke).ThenInclude(s => s.Artikal)
            .Include(n => n.Stavke).ThenInclude(s => s.Usluge).ThenInclude(u => u.Usluga)
            .Include(n => n.Logistike)
            .FirstOrDefaultAsync(
                n => n.ID_Narudzbe == narudzbaId && n.FK_Korisnik == korisnikId,
                cancellationToken);

        if (narudzba == null)
            throw new NarudzbaValidationException("Narudžba nije pronađena.");

        return MapDetaljDto(narudzba);
    }

    public async Task<IReadOnlyList<NarudzbaAdminPregledDto>> GetSveNarudzbeAsync(
        string? statusNaziv = null,
        int? limit = null,
        CancellationToken cancellationToken = default)
    {
        if (limit is <= 0)
            throw new NarudzbaValidationException("Limit mora biti veći od nule.");

        var upit = _context.Narudzbe.AsNoTracking();

        if (!string.IsNullOrWhiteSpace(statusNaziv))
        {
            var filter = statusNaziv.Trim();
            upit = upit.Where(n => n.Status.Naziv == filter);
        }

        upit = upit.OrderByDescending(n => n.Datum_Prijema);

        if (limit.HasValue)
            upit = upit.Take(limit.Value);

        var narudzbe = await upit
            .Select(n => new NarudzbaAdminPregledDto
            {
                Id = n.ID_Narudzbe,
                DatumKreiranja = n.Datum_Prijema,
                StatusNaziv = n.Status.Naziv,
                NacinPredaje = n.Nacin_Predaje,
                UkupnaCijena = n.Ukupna_Cijena,
                BrojStavki = n.Stavke.Count,
                KorisnikPunoIme = n.Korisnik.Ime + " " + n.Korisnik.Prezime,
                KorisnikTelefon = n.Korisnik.Broj_Telefona,
            })
            .ToListAsync(cancellationToken);

        foreach (var n in narudzbe)
            n.NacinPredajeNaziv = NacinPredajeNazivi.ZaPrikaz(n.NacinPredaje);

        return narudzbe;
    }

    public async Task<BrojNarudzbiPoStatusuDto> GetBrojNarudzbiPoStatusuAsync(
        CancellationToken cancellationToken = default)
    {
        var poStatusu = await _context.Narudzbe
            .AsNoTracking()
            .GroupBy(n => n.Status.Naziv)
            .Select(g => new StatusBrojDto
            {
                StatusNaziv = g.Key,
                Broj = g.Count(),
            })
            .OrderBy(s => s.StatusNaziv)
            .ToListAsync(cancellationToken);

        var ukupno = poStatusu.Sum(s => s.Broj);
        var aktivne = poStatusu
            .Where(s =>
                s.StatusNaziv != NarudzbaStatusi.Preuzeta &&
                s.StatusNaziv != NarudzbaStatusi.Otkazana)
            .Sum(s => s.Broj);

        return new BrojNarudzbiPoStatusuDto
        {
            Ukupno = ukupno,
            Aktivne = aktivne,
            PoStatusu = poStatusu,
        };
    }

    public async Task<NarudzbaAdminDetaljDto> GetDetaljNarudzbeAdminAsync(
        int narudzbaId,
        CancellationToken cancellationToken = default)
    {
        if (narudzbaId <= 0)
            throw new NarudzbaValidationException("NarudzbaId nije ispravan.");

        var narudzba = await UcitajNarudzbuZaDetaljAsync(narudzbaId, cancellationToken)
            ?? throw new NarudzbaValidationException("Narudžba nije pronađena.");

        var detalj = MapDetaljDto(narudzba);

        return new NarudzbaAdminDetaljDto
        {
            Id = detalj.Id,
            DatumKreiranja = detalj.DatumKreiranja,
            StatusNaziv = detalj.StatusNaziv,
            NacinPredaje = detalj.NacinPredaje,
            NacinPredajeNaziv = detalj.NacinPredajeNaziv,
            UkupnaCijena = detalj.UkupnaCijena,
            Napomena = detalj.Napomena,
            AdresaPreuzimanja = detalj.AdresaPreuzimanja,
            RokZavrsetka = detalj.RokZavrsetka,
            Stavke = detalj.Stavke,
            KorisnikId = narudzba.FK_Korisnik,
            KorisnikPunoIme = $"{narudzba.Korisnik.Ime} {narudzba.Korisnik.Prezime}",
            KorisnikEmail = narudzba.Korisnik.Email,
            KorisnikTelefon = narudzba.Korisnik.Broj_Telefona,
            KorisnikAdresaStanovanja = narudzba.Korisnik.Adresa_Stanovanja,
            MozeSePrimijeti = narudzba.Status.Naziv == NarudzbaStatusi.Kreirana,
            DozvoljeneAkcije = IzgradiDozvoljeneAkcije(narudzba.Status.Naziv),
        };
    }

    public async Task<NarudzbaStatusPromjenaDto> PrimijeniNarudzbuAsync(
        PrimijeniNarudzbuRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.NarudzbaId <= 0 || request.ZaposlenikId <= 0)
            throw new NarudzbaValidationException("Identifikatori nisu ispravni.");

        var zaposlenik = await _context.Zaposlenici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                z => z.ID_Zaposlenika == request.ZaposlenikId && z.Aktivan,
                cancellationToken)
            ?? throw new NarudzbaValidationException("Zaposlenik nije pronađen.");

        var narudzba = await _context.Narudzbe
            .Include(n => n.Status)
            .Include(n => n.Stavke)
            .FirstOrDefaultAsync(n => n.ID_Narudzbe == request.NarudzbaId, cancellationToken)
            ?? throw new NarudzbaValidationException("Narudžba nije pronađena.");

        if (narudzba.Status.Naziv != NarudzbaStatusi.Kreirana)
        {
            throw new NarudzbaValidationException(
                $"Narudžba se može primiti samo iz statusa '{NarudzbaStatusi.Kreirana}'.");
        }

        var statusPrimljena = await _context.StatusiNarudzbe
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == NarudzbaStatusi.Primljena, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status narudžbe '{NarudzbaStatusi.Primljena}' nije definisan u bazi.");

        var statusStavkePrimljena = await _context.StatusiStavke
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == StavkaStatusi.Primljena, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status stavke '{StavkaStatusi.Primljena}' nije definisan u bazi.");

        narudzba.FK_Status = statusPrimljena.ID_Statusa;
        narudzba.FK_Primio_Zaposlenik = zaposlenik.ID_Zaposlenika;

        foreach (var stavka in narudzba.Stavke)
            stavka.FK_Status = statusStavkePrimljena.ID_Statusa;

        _notifikacijaService.PlanirajStatusObavijest(
            narudzba.FK_Korisnik,
            narudzba.ID_Narudzbe,
            NarudzbaStatusi.Primljena);

        await _context.SaveChangesAsync(cancellationToken);

        return new NarudzbaStatusPromjenaDto
        {
            Id = narudzba.ID_Narudzbe,
            StatusNaziv = NarudzbaStatusi.Primljena,
            RokZavrsetka = null,
            Poruka = "Narudžba je primljena u čistionici. Rok završetka bit će potvrđen nakon pregleda.",
        };
    }

    public async Task<NarudzbaStatusPromjenaDto> PromijeniStatusNarudzbeAsync(
        PromijeniStatusNarudzbeRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.NarudzbaId <= 0 || request.ZaposlenikId <= 0)
            throw new NarudzbaValidationException("Identifikatori nisu ispravni.");

        if (string.IsNullOrWhiteSpace(request.NoviStatusNaziv))
            throw new NarudzbaValidationException("Novi status nije ispravan.");

        var noviStatusNaziv = request.NoviStatusNaziv.Trim();

        var zaposlenik = await _context.Zaposlenici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                z => z.ID_Zaposlenika == request.ZaposlenikId && z.Aktivan,
                cancellationToken)
            ?? throw new NarudzbaValidationException("Zaposlenik nije pronađen.");

        var narudzba = await _context.Narudzbe
            .Include(n => n.Status)
            .Include(n => n.Stavke)
            .FirstOrDefaultAsync(n => n.ID_Narudzbe == request.NarudzbaId, cancellationToken)
            ?? throw new NarudzbaValidationException("Narudžba nije pronađena.");

        var trenutniStatus = narudzba.Status.Naziv;

        if (!NarudzbaStatusPrijelazi.JeDozvoljenPrijelaz(trenutniStatus, noviStatusNaziv))
        {
            throw new NarudzbaValidationException(
                $"Status se ne može promijeniti iz '{trenutniStatus}' u '{noviStatusNaziv}'.");
        }

        var noviStatus = await _context.StatusiNarudzbe
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == noviStatusNaziv, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status narudžbe '{noviStatusNaziv}' nije definisan u bazi.");

        var stavkaStatusNaziv = NarudzbaStatusPrijelazi.GetStavkaStatusZaNarudzbu(noviStatusNaziv)
            ?? throw new NarudzbaValidationException(
                $"Status stavke za '{noviStatusNaziv}' nije definisan.");

        var noviStavkaStatus = await _context.StatusiStavke
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == stavkaStatusNaziv, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status stavke '{stavkaStatusNaziv}' nije definisan u bazi.");

        if (noviStatusNaziv == NarudzbaStatusi.UObradi)
        {
            if (!request.RokZavrsetka.HasValue)
            {
                throw new NarudzbaValidationException(
                    "Rok završetka je obavezan pri označavanju narudžbe u obradi.");
            }

            ValidirajRokZavrsetka(request.RokZavrsetka.Value);
            narudzba.Rok_Zavrsetka = request.RokZavrsetka.Value;
        }

        narudzba.FK_Status = noviStatus.ID_Statusa;

        if (noviStatusNaziv == NarudzbaStatusi.UObradi && narudzba.FK_Primio_Zaposlenik == null)
            narudzba.FK_Primio_Zaposlenik = zaposlenik.ID_Zaposlenika;

        foreach (var stavka in narudzba.Stavke)
            stavka.FK_Status = noviStavkaStatus.ID_Statusa;

        _notifikacijaService.PlanirajStatusObavijest(
            narudzba.FK_Korisnik,
            narudzba.ID_Narudzbe,
            noviStatusNaziv,
            narudzba.Rok_Zavrsetka);

        await _context.SaveChangesAsync(cancellationToken);

        return new NarudzbaStatusPromjenaDto
        {
            Id = narudzba.ID_Narudzbe,
            StatusNaziv = noviStatusNaziv,
            RokZavrsetka = narudzba.Rok_Zavrsetka,
            Poruka = noviStatusNaziv == NarudzbaStatusi.UObradi && narudzba.Rok_Zavrsetka.HasValue
                ? $"Narudžba je u obradi. Rok završetka: {narudzba.Rok_Zavrsetka:dd.MM.yyyy}."
                : NarudzbaStatusPrijelazi.GetPorukaPromjene(noviStatusNaziv),
        };
    }

    public async Task<NarudzbaStatusPromjenaDto> PromijeniRokZavrsetkaAsync(
        PromijeniRokZavrsetkaRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.NarudzbaId <= 0 || request.ZaposlenikId <= 0)
            throw new NarudzbaValidationException("Identifikatori nisu ispravni.");

        ValidirajRokZavrsetka(request.RokZavrsetka);

        var zaposlenik = await _context.Zaposlenici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                z => z.ID_Zaposlenika == request.ZaposlenikId && z.Aktivan,
                cancellationToken)
            ?? throw new NarudzbaValidationException("Zaposlenik nije pronađen.");

        var narudzba = await _context.Narudzbe
            .Include(n => n.Status)
            .FirstOrDefaultAsync(n => n.ID_Narudzbe == request.NarudzbaId, cancellationToken)
            ?? throw new NarudzbaValidationException("Narudžba nije pronađena.");

        var status = narudzba.Status.Naziv;
        if (status != NarudzbaStatusi.UObradi && status != NarudzbaStatusi.Gotova)
        {
            throw new NarudzbaValidationException(
                "Rok završetka se može promijeniti samo dok je narudžba u obradi ili gotova.");
        }

        narudzba.Rok_Zavrsetka = request.RokZavrsetka;

        _notifikacijaService.PlanirajRokAzuriran(
            narudzba.FK_Korisnik,
            narudzba.ID_Narudzbe,
            request.RokZavrsetka);

        await _context.SaveChangesAsync(cancellationToken);

        return new NarudzbaStatusPromjenaDto
        {
            Id = narudzba.ID_Narudzbe,
            StatusNaziv = status,
            RokZavrsetka = narudzba.Rok_Zavrsetka,
            Poruka = $"Rok završetka ažuriran: {request.RokZavrsetka:dd.MM.yyyy}.",
        };
    }

    public async Task<NarudzbaStatusPromjenaDto> OtkaziNarudzbuAsync(
        OtkaziNarudzbuRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.NarudzbaId <= 0)
            throw new NarudzbaValidationException("NarudzbaId nije ispravan.");

        var korisnikId = request.KorisnikId;
        var zaposlenikId = request.ZaposlenikId;
        var korisnikOtkazuje = korisnikId is > 0;
        var adminOtkazuje = zaposlenikId is > 0;

        if (korisnikOtkazuje == adminOtkazuje)
        {
            throw new NarudzbaValidationException(
                "Navedite ili korisnika ili zaposlenika koji otkazuje narudžbu.");
        }

        if (korisnikOtkazuje)
        {
            var postoji = await _context.Korisnici
                .AsNoTracking()
                .AnyAsync(k => k.ID_Korisnika == korisnikId && k.Aktivan, cancellationToken);

            if (!postoji)
                throw new NarudzbaValidationException("Korisnik nije pronađen.");
        }
        else
        {
            var postoji = await _context.Zaposlenici
                .AsNoTracking()
                .AnyAsync(z => z.ID_Zaposlenika == zaposlenikId && z.Aktivan, cancellationToken);

            if (!postoji)
                throw new NarudzbaValidationException("Zaposlenik nije pronađen.");
        }

        var narudzba = await _context.Narudzbe
            .Include(n => n.Status)
            .Include(n => n.Logistike)
            .FirstOrDefaultAsync(n => n.ID_Narudzbe == request.NarudzbaId, cancellationToken)
            ?? throw new NarudzbaValidationException("Narudžba nije pronađena.");

        if (!NarudzbaStatusPrijelazi.MozeSeOtkazati(narudzba.Status.Naziv))
        {
            throw new NarudzbaValidationException(
                $"Narudžba se može otkazati samo dok je u statusu '{NarudzbaStatusi.Kreirana}'.");
        }

        if (korisnikOtkazuje && narudzba.FK_Korisnik != korisnikId)
        {
            throw new NarudzbaValidationException("Narudžba ne pripada ovom korisniku.");
        }

        var statusOtkazana = await _context.StatusiNarudzbe
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == NarudzbaStatusi.Otkazana, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status narudžbe '{NarudzbaStatusi.Otkazana}' nije definisan u bazi.");

        narudzba.FK_Status = statusOtkazana.ID_Statusa;

        if (narudzba.Logistike.Count > 0)
        {
            var statusLogistikeOtkazano = await _context.StatusiLogistike
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.Naziv == LogistikaStatusi.Otkazano, cancellationToken)
                ?? throw new NarudzbaValidationException(
                    $"Status logistike '{LogistikaStatusi.Otkazano}' nije definisan u bazi.");

            foreach (var logistika in narudzba.Logistike)
                logistika.FK_Status = statusLogistikeOtkazano.ID_Statusa;
        }

        if (adminOtkazuje)
        {
            _notifikacijaService.PlanirajStatusObavijest(
                narudzba.FK_Korisnik,
                narudzba.ID_Narudzbe,
                NarudzbaStatusi.Otkazana);
        }

        await _context.SaveChangesAsync(cancellationToken);

        return new NarudzbaStatusPromjenaDto
        {
            Id = narudzba.ID_Narudzbe,
            StatusNaziv = NarudzbaStatusi.Otkazana,
            RokZavrsetka = narudzba.Rok_Zavrsetka,
            Poruka = NarudzbaStatusPrijelazi.GetPorukaPromjene(NarudzbaStatusi.Otkazana),
        };
    }

    private static IReadOnlyList<NarudzbaAdminAkcijaDto> IzgradiDozvoljeneAkcije(string statusNaziv)
    {
        if (statusNaziv == NarudzbaStatusi.Kreirana)
        {
            return
            [
                new NarudzbaAdminAkcijaDto
                {
                    Tip = NarudzbaAdminAkcije.Primijeni,
                    Label = "Primijeni narudžbu",
                    ZahtijevaRokZavrsetka = false,
                },
                new NarudzbaAdminAkcijaDto
                {
                    Tip = NarudzbaAdminAkcije.Otkazi,
                    Label = "Otkaži narudžbu",
                    SljedeciStatusNaziv = NarudzbaStatusi.Otkazana,
                },
            ];
        }

        var akcije = new List<NarudzbaAdminAkcijaDto>();

        var sljedeci = NarudzbaStatusPrijelazi.GetSljedeci(statusNaziv);
        if (sljedeci != null)
        {
            akcije.Add(new NarudzbaAdminAkcijaDto
            {
                Tip = NarudzbaAdminAkcije.PromijeniStatus,
                Label = NarudzbaStatusPrijelazi.GetLabelAkcije(sljedeci),
                SljedeciStatusNaziv = sljedeci,
                ZahtijevaRokZavrsetka = sljedeci == NarudzbaStatusi.UObradi,
            });
        }

        if (statusNaziv == NarudzbaStatusi.UObradi || statusNaziv == NarudzbaStatusi.Gotova)
        {
            akcije.Add(new NarudzbaAdminAkcijaDto
            {
                Tip = NarudzbaAdminAkcije.PromijeniRok,
                Label = "Promijeni rok završetka",
                ZahtijevaRokZavrsetka = true,
            });
        }

        return akcije;
    }

    private static void ValidirajRokZavrsetka(DateTime rok)
    {
        if (rok.Date < DateTime.Today)
            throw new NarudzbaValidationException("Rok završetka ne može biti u prošlosti.");
    }

    private async Task<Narudzba?> UcitajNarudzbuZaDetaljAsync(
        int narudzbaId,
        CancellationToken cancellationToken)
    {
        return await _context.Narudzbe
            .AsNoTracking()
            .Include(n => n.Korisnik)
            .Include(n => n.Status)
            .Include(n => n.Recenzija)
            .Include(n => n.Stavke).ThenInclude(s => s.Artikal)
            .Include(n => n.Stavke).ThenInclude(s => s.Usluge).ThenInclude(u => u.Usluga)
            .Include(n => n.Logistike)
            .FirstOrDefaultAsync(n => n.ID_Narudzbe == narudzbaId, cancellationToken);
    }

    private static NarudzbaDetaljDto MapDetaljDto(Narudzba narudzba)
    {
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
            MozeSeOtkazati = NarudzbaStatusPrijelazi.MozeSeOtkazati(narudzba.Status.Naziv),
            MozeSeRecenzirati =
                narudzba.Status.Naziv == NarudzbaStatusi.Preuzeta && narudzba.Recenzija == null,
            Recenzija = RecenzijaService.MapDto(narudzba.Recenzija),
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
