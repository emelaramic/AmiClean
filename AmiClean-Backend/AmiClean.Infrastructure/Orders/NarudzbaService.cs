using AmiClean.Application.Coupons.Interfaces;
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
    private readonly IKuponService _kuponService;

    public NarudzbaService(
        AmiCleanContext context,
        INotifikacijaService notifikacijaService,
        IKuponService kuponService)
    {
        _context = context;
        _notifikacijaService = notifikacijaService;
        _kuponService = kuponService;
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

        decimal popustIznos = 0;
        Kupon? primijenjeniKupon = null;

        if (!string.IsNullOrWhiteSpace(request.KuponKod))
        {
            try
            {
                var kuponRezultat = await _kuponService.RijesiZaNarudzbuAsync(
                    request.KuponKod,
                    ukupnaCijena,
                    cancellationToken);
                primijenjeniKupon = kuponRezultat.Kupon;
                popustIznos = kuponRezultat.PopustIznos;
            }
            catch (Application.Coupons.KuponValidationException ex)
            {
                throw new NarudzbaValidationException(ex.Message);
            }
        }

        var ukupnoZaPlatiti = ukupnaCijena - popustIznos;

        var nacinZavrsetka = request.NacinPredaje == NacinPredajeVrijednosti.PreuzimanjeIDostava
            ? NacinZavrsetkaVrijednosti.Dostava
            : NacinZavrsetkaVrijednosti.PreuzimanjeURadnji;

        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

        var narudzba = new Narudzba
        {
            FK_Korisnik = korisnik.ID_Korisnika,
            FK_Kupon = primijenjeniKupon?.ID_Kupona,
            FK_Status = statusNarudzbe.ID_Statusa,
            Kanal = NarudzbaKanali.Aplikacija,
            Nacin_Predaje = request.NacinPredaje,
            Nacin_Zavrsetka = nacinZavrsetka,
            Datum_Prijema = DateTime.Now,
            Ukupna_Cijena = ukupnaCijena,
            Popust_Iznos = popustIznos,
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

        if (popustIznos > 0)
        {
            poruka += $" Primijenjen popust: {popustIznos:0.00} KM.";
        }

        return new NarudzbaKreiranaDto
        {
            Id = narudzba.ID_Narudzbe,
            StatusNaziv = statusNarudzbe.Naziv,
            NacinPredaje = request.NacinPredaje,
            UkupnaCijena = ukupnaCijena,
            PopustIznos = popustIznos,
            UkupnoZaPlatiti = ukupnoZaPlatiti,
            KuponKod = primijenjeniKupon?.Kod,
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
                PopustIznos = n.Popust_Iznos,
                UkupnoZaPlatiti = n.Ukupna_Cijena - n.Popust_Iznos,
                KuponKod = n.Kupon != null ? n.Kupon.Kod : null,
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
            .Include(n => n.Kupon)
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
            PopustIznos = detalj.PopustIznos,
            UkupnoZaPlatiti = detalj.UkupnoZaPlatiti,
            KuponKod = detalj.KuponKod,
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

        var redniBrojStavke = 1;
        foreach (var stavka in narudzba.Stavke.OrderBy(s => s.ID_Stavke))
        {
            stavka.FK_Status = statusStavkePrimljena.ID_Statusa;

            if (string.IsNullOrWhiteSpace(stavka.Broj_Oznake))
            {
                stavka.Broj_Oznake = BrojOznakeGenerator.Generisi(
                    narudzba.ID_Narudzbe,
                    redniBrojStavke);
            }

            redniBrojStavke++;
        }

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

    public async Task<StavkaOznakaInfoDto> GetInfoPoOznaciAsync(
        string unos,
        int? korisnikId = null,
        CancellationToken cancellationToken = default)
    {
        var brojOznake = ParsirajBrojOznake(unos);
        var stavka = await UcitajStavkuPoOznaciAsync(brojOznake, cancellationToken)
            ?? throw new NarudzbaValidationException("Oznaka nije pronađena.");

        if (korisnikId is > 0 && stavka.Narudzba.FK_Korisnik != korisnikId)
        {
            throw new NarudzbaValidationException("Ova oznaka ne pripada vašoj narudžbi.");
        }

        return MapStavkaOznakaInfo(stavka, korisnikId);
    }

    public async Task<RadnikOznakaRezultatDto> RadnikPokreniDostavuAsync(
        RadnikOznakaRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.ZaposlenikId <= 0)
            throw new NarudzbaValidationException("ZaposlenikId nije ispravan.");

        var brojOznake = ParsirajBrojOznake(request.Unos);

        var zaposlenik = await _context.Zaposlenici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                z => z.ID_Zaposlenika == request.ZaposlenikId && z.Aktivan,
                cancellationToken)
            ?? throw new NarudzbaValidationException("Zaposlenik nije pronađen.");

        var stavka = await UcitajStavkuPoOznaciAsync(brojOznake, cancellationToken, zaIzmjenu: true)
            ?? throw new NarudzbaValidationException("Oznaka nije pronađena.");

        var narudzba = stavka.Narudzba;
        var statusNarudzbe = narudzba.Status.Naziv;

        if (statusNarudzbe != NarudzbaStatusi.Gotova)
        {
            throw new NarudzbaValidationException(
                $"Narudžba mora biti u statusu '{NarudzbaStatusi.Gotova}'. Trenutni status: '{statusNarudzbe}'.");
        }

        if (narudzba.Nacin_Predaje == NacinPredajeVrijednosti.PreuzimanjeIDostava)
        {
            var logistika = narudzba.Logistike
                .FirstOrDefault(l => l.Tip == LogistikaTipovi.Preuzimanje)
                ?? throw new NarudzbaValidationException("Logistika dostave nije pronađena.");

            var logistikaStatus = logistika.Status.Naziv;

            if (logistikaStatus == LogistikaStatusi.Zavrseno)
            {
                throw new NarudzbaValidationException("Dostava za ovu narudžbu je već završena.");
            }

            if (logistikaStatus == LogistikaStatusi.Otkazano)
            {
                throw new NarudzbaValidationException("Dostava za ovu narudžbu je otkazana.");
            }

            var dostavaPokrenuta = false;
            string poruka;

            if (logistikaStatus == LogistikaStatusi.Zakazano)
            {
                var statusUToku = await _context.StatusiLogistike
                    .AsNoTracking()
                    .FirstOrDefaultAsync(s => s.Naziv == LogistikaStatusi.UToku, cancellationToken)
                    ?? throw new NarudzbaValidationException(
                        $"Status logistike '{LogistikaStatusi.UToku}' nije definisan u bazi.");

                logistika.FK_Status = statusUToku.ID_Statusa;
                logistika.FK_Vozac = zaposlenik.ID_Zaposlenika;
                logistika.Stvarno_Vrijeme = DateTime.Now;

                _notifikacijaService.PlanirajDostavuPokrenutu(
                    narudzba.FK_Korisnik,
                    narudzba.ID_Narudzbe);

                await _context.SaveChangesAsync(cancellationToken);

                dostavaPokrenuta = true;
                poruka =
                    $"Dostava narudžbe #{narudzba.ID_Narudzbe} je pokrenuta. Adresa: {logistika.Adresa}.";
            }
            else
            {
                poruka = logistikaStatus == LogistikaStatusi.UToku
                    ? $"Dostava narudžbe #{narudzba.ID_Narudzbe} je već u toku."
                    : $"Logistika narudžbe #{narudzba.ID_Narudzbe} je u statusu '{logistikaStatus}'.";
            }

            return new RadnikOznakaRezultatDto
            {
                NarudzbaId = narudzba.ID_Narudzbe,
                StatusNarudzbe = statusNarudzbe,
                LogistikaStatusNaziv = dostavaPokrenuta
                    ? LogistikaStatusi.UToku
                    : logistika.Status.Naziv,
                DostavaPokrenuta = dostavaPokrenuta,
                Poruka = poruka,
            };
        }

        return new RadnikOznakaRezultatDto
        {
            NarudzbaId = narudzba.ID_Narudzbe,
            StatusNarudzbe = statusNarudzbe,
            LogistikaStatusNaziv = null,
            DostavaPokrenuta = false,
            Poruka =
                $"Stavka '{stavka.Artikal.Naziv}' potvrđena. Narudžba #{narudzba.ID_Narudzbe} čeka preuzimanje korisnika u radnji.",
        };
    }

    public async Task<KorisnikOznakaRezultatDto> KorisnikPotvrdiPreuzimanjeAsync(
        KorisnikOznakaRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.KorisnikId <= 0)
            throw new NarudzbaValidationException("KorisnikId nije ispravan.");

        var brojOznake = ParsirajBrojOznake(request.Unos);

        var korisnik = await _context.Korisnici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                k => k.ID_Korisnika == request.KorisnikId && k.Aktivan,
                cancellationToken)
            ?? throw new NarudzbaValidationException("Korisnik nije pronađen.");

        var stavka = await UcitajStavkuPoOznaciAsync(brojOznake, cancellationToken, zaIzmjenu: true)
            ?? throw new NarudzbaValidationException("Oznaka nije pronađena.");

        var narudzba = stavka.Narudzba;

        if (narudzba.FK_Korisnik != korisnik.ID_Korisnika)
        {
            throw new NarudzbaValidationException("Ova oznaka ne pripada vašoj narudžbi.");
        }

        var statusNarudzbe = narudzba.Status.Naziv;

        if (statusNarudzbe == NarudzbaStatusi.Preuzeta)
        {
            throw new NarudzbaValidationException("Narudžba je već preuzeta.");
        }

        if (statusNarudzbe != NarudzbaStatusi.Gotova)
        {
            throw new NarudzbaValidationException(
                $"Narudžba nije spremna za preuzimanje. Trenutni status: '{statusNarudzbe}'.");
        }

        var logistika = narudzba.Logistike
            .FirstOrDefault(l => l.Tip == LogistikaTipovi.Preuzimanje);

        if (logistika != null)
        {
            var logistikaStatus = logistika.Status.Naziv;

            if (logistikaStatus == LogistikaStatusi.Zavrseno)
            {
                throw new NarudzbaValidationException("Preuzimanje za ovu narudžbu je već potvrđeno.");
            }

            if (logistikaStatus == LogistikaStatusi.Otkazano)
            {
                throw new NarudzbaValidationException("Dostava za ovu narudžbu je otkazana.");
            }
        }

        var statusPreuzeta = await _context.StatusiNarudzbe
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == NarudzbaStatusi.Preuzeta, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status narudžbe '{NarudzbaStatusi.Preuzeta}' nije definisan u bazi.");

        var statusStavkeIsporucena = await _context.StatusiStavke
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Naziv == StavkaStatusi.Isporucena, cancellationToken)
            ?? throw new NarudzbaValidationException(
                $"Status stavke '{StavkaStatusi.Isporucena}' nije definisan u bazi.");

        narudzba.FK_Status = statusPreuzeta.ID_Statusa;

        foreach (var stavkaNarudzbe in narudzba.Stavke)
            stavkaNarudzbe.FK_Status = statusStavkeIsporucena.ID_Statusa;

        string? logistikaStatusNaziv = null;

        if (logistika != null)
        {
            var statusZavrseno = await _context.StatusiLogistike
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.Naziv == LogistikaStatusi.Zavrseno, cancellationToken)
                ?? throw new NarudzbaValidationException(
                    $"Status logistike '{LogistikaStatusi.Zavrseno}' nije definisan u bazi.");

            logistika.FK_Status = statusZavrseno.ID_Statusa;
            logistika.Stvarno_Vrijeme ??= DateTime.Now;
            logistikaStatusNaziv = LogistikaStatusi.Zavrseno;
        }

        _notifikacijaService.PlanirajStatusObavijest(
            narudzba.FK_Korisnik,
            narudzba.ID_Narudzbe,
            NarudzbaStatusi.Preuzeta);

        await _context.SaveChangesAsync(cancellationToken);

        var poruka = logistika != null
            ? $"Preuzimanje narudžbe #{narudzba.ID_Narudzbe} je potvrđeno. Hvala vam!"
            : $"Preuzimanje u radnji za narudžbu #{narudzba.ID_Narudzbe} je potvrđeno. Hvala vam!";

        return new KorisnikOznakaRezultatDto
        {
            NarudzbaId = narudzba.ID_Narudzbe,
            StatusNarudzbe = NarudzbaStatusi.Preuzeta,
            LogistikaStatusNaziv = logistikaStatusNaziv,
            PreuzimanjePotvrdeno = true,
            Poruka = poruka,
        };
    }

    public async Task<RadnikDostaveListaDto> GetDostaveZaRadnikaAsync(
        int zaposlenikId,
        CancellationToken cancellationToken = default)
    {
        if (zaposlenikId <= 0)
            throw new NarudzbaValidationException("ZaposlenikId nije ispravan.");

        var zaposlenikPostoji = await _context.Zaposlenici
            .AsNoTracking()
            .AnyAsync(
                z => z.ID_Zaposlenika == zaposlenikId && z.Aktivan,
                cancellationToken);

        if (!zaposlenikPostoji)
            throw new NarudzbaValidationException("Zaposlenik nije pronađen.");

        var logistike = await _context.Logistike
            .AsNoTracking()
            .Include(l => l.Status)
            .Include(l => l.Vozac)
            .Include(l => l.Narudzba).ThenInclude(n => n.Korisnik)
            .Include(l => l.Narudzba).ThenInclude(n => n.Status)
            .Include(l => l.Narudzba).ThenInclude(n => n.Stavke)
            .Where(l =>
                l.Tip == LogistikaTipovi.Preuzimanje &&
                (l.Status.Naziv == LogistikaStatusi.Zakazano ||
                 l.Status.Naziv == LogistikaStatusi.UToku) &&
                l.Narudzba.Nacin_Predaje == NacinPredajeVrijednosti.PreuzimanjeIDostava &&
                l.Narudzba.Status.Naziv == NarudzbaStatusi.Gotova)
            .OrderByDescending(l => l.Narudzba.Datum_Prijema)
            .ToListAsync(cancellationToken);

        var spremne = new List<RadnikDostavaPregledDto>();
        var uToku = new List<RadnikDostavaPregledDto>();

        foreach (var logistika in logistike)
        {
            var dto = MapRadnikDostava(logistika, zaposlenikId);
            if (dto.LogistikaStatusNaziv == LogistikaStatusi.Zakazano)
                spremne.Add(dto);
            else
                uToku.Add(dto);
        }

        return new RadnikDostaveListaDto
        {
            Spremne = spremne,
            UToku = uToku,
        };
    }

    public async Task<RadnikDostavaDetaljDto> GetDetaljDostaveZaRadnikaAsync(
        int narudzbaId,
        int zaposlenikId,
        CancellationToken cancellationToken = default)
    {
        if (narudzbaId <= 0 || zaposlenikId <= 0)
            throw new NarudzbaValidationException("Identifikatori nisu ispravni.");

        var logistika = await UcitajAktivnuDostavuZaRadnikaAsync(
            narudzbaId,
            zaposlenikId,
            cancellationToken);

        var pregled = MapRadnikDostava(logistika, zaposlenikId);
        var narudzba = logistika.Narudzba;

        return new RadnikDostavaDetaljDto
        {
            NarudzbaId = pregled.NarudzbaId,
            KorisnikPunoIme = pregled.KorisnikPunoIme,
            KorisnikTelefon = pregled.KorisnikTelefon,
            AdresaDostave = pregled.AdresaDostave,
            LogistikaStatusNaziv = pregled.LogistikaStatusNaziv,
            BrojStavki = pregled.BrojStavki,
            DatumPrijema = pregled.DatumPrijema,
            RokZavrsetka = pregled.RokZavrsetka,
            VozacPunoIme = pregled.VozacPunoIme,
            JeMojaDostava = pregled.JeMojaDostava,
            MozePokrenuti = pregled.MozePokrenuti,
            Napomena = narudzba.Napomena,
            Stavke = narudzba.Stavke
                .OrderBy(s => s.ID_Stavke)
                .Select(s => new RadnikDostavaStavkaDto
                {
                    StavkaId = s.ID_Stavke,
                    ArtikalNaziv = s.Artikal.Naziv,
                    BrojOznake = s.Broj_Oznake,
                    Kolicina = s.Kolicina,
                })
                .ToList(),
        };
    }

    private async Task<Logistika> UcitajAktivnuDostavuZaRadnikaAsync(
        int narudzbaId,
        int zaposlenikId,
        CancellationToken cancellationToken)
    {
        if (zaposlenikId <= 0)
            throw new NarudzbaValidationException("ZaposlenikId nije ispravan.");

        var zaposlenikPostoji = await _context.Zaposlenici
            .AsNoTracking()
            .AnyAsync(
                z => z.ID_Zaposlenika == zaposlenikId && z.Aktivan,
                cancellationToken);

        if (!zaposlenikPostoji)
            throw new NarudzbaValidationException("Zaposlenik nije pronađen.");

        var logistika = await _context.Logistike
            .AsNoTracking()
            .Include(l => l.Status)
            .Include(l => l.Vozac)
            .Include(l => l.Narudzba).ThenInclude(n => n.Korisnik)
            .Include(l => l.Narudzba).ThenInclude(n => n.Status)
            .Include(l => l.Narudzba).ThenInclude(n => n.Stavke).ThenInclude(s => s.Artikal)
            .FirstOrDefaultAsync(
                l =>
                    l.FK_Narudzba == narudzbaId &&
                    l.Tip == LogistikaTipovi.Preuzimanje &&
                    (l.Status.Naziv == LogistikaStatusi.Zakazano ||
                     l.Status.Naziv == LogistikaStatusi.UToku) &&
                    l.Narudzba.Nacin_Predaje == NacinPredajeVrijednosti.PreuzimanjeIDostava &&
                    l.Narudzba.Status.Naziv == NarudzbaStatusi.Gotova,
                cancellationToken);

        if (logistika == null)
        {
            throw new NarudzbaValidationException(
                "Dostava nije pronađena ili narudžba nije spremna za dostavu.");
        }

        return logistika;
    }

    private static RadnikDostavaPregledDto MapRadnikDostava(Logistika logistika, int zaposlenikId)
    {
        var narudzba = logistika.Narudzba;
        var logistikaStatus = logistika.Status.Naziv;
        var jeMoja = logistika.FK_Vozac == zaposlenikId;

        return new RadnikDostavaPregledDto
        {
            NarudzbaId = narudzba.ID_Narudzbe,
            KorisnikPunoIme = $"{narudzba.Korisnik.Ime} {narudzba.Korisnik.Prezime}".Trim(),
            KorisnikTelefon = narudzba.Korisnik.Broj_Telefona,
            AdresaDostave = logistika.Adresa,
            LogistikaStatusNaziv = logistikaStatus,
            BrojStavki = narudzba.Stavke.Count,
            DatumPrijema = narudzba.Datum_Prijema,
            RokZavrsetka = narudzba.Rok_Zavrsetka,
            VozacPunoIme = logistika.Vozac == null
                ? null
                : $"{logistika.Vozac.Ime} {logistika.Vozac.Prezime}".Trim(),
            JeMojaDostava = jeMoja,
            MozePokrenuti = logistikaStatus == LogistikaStatusi.Zakazano,
        };
    }

    private static string ParsirajBrojOznake(string unos)
    {
        try
        {
            return BrojOznakeGenerator.ParsirajUnos(unos);
        }
        catch (ArgumentException ex)
        {
            throw new NarudzbaValidationException(ex.Message);
        }
    }

    private async Task<StavkaNarudzbe?> UcitajStavkuPoOznaciAsync(
        string brojOznake,
        CancellationToken cancellationToken,
        bool zaIzmjenu = false)
    {
        var query = _context.StavkeNarudzbe
            .Include(s => s.Artikal)
            .Include(s => s.Narudzba).ThenInclude(n => n.Status)
            .Include(s => s.Narudzba).ThenInclude(n => n.Korisnik)
            .Include(s => s.Narudzba).ThenInclude(n => n.Logistike).ThenInclude(l => l.Status)
            .Where(s => s.Broj_Oznake == brojOznake);

        if (!zaIzmjenu)
            query = query.AsNoTracking();

        return await query.FirstOrDefaultAsync(cancellationToken);
    }

    private static StavkaOznakaInfoDto MapStavkaOznakaInfo(
        StavkaNarudzbe stavka,
        int? korisnikId = null)
    {
        var narudzba = stavka.Narudzba;
        var logistika = narudzba.Logistike
            .FirstOrDefault(l => l.Tip == LogistikaTipovi.Preuzimanje);
        var statusNarudzbe = narudzba.Status.Naziv;
        var logistikaStatus = logistika?.Status.Naziv;
        var mozePokrenuti = statusNarudzbe == NarudzbaStatusi.Gotova &&
            (narudzba.Nacin_Predaje != NacinPredajeVrijednosti.PreuzimanjeIDostava ||
             logistikaStatus is LogistikaStatusi.Zakazano or LogistikaStatusi.UToku);
        var mozePotvrditi = IzracunajMozePotvrditiPreuzimanje(stavka, korisnikId);

        var poruka = statusNarudzbe switch
        {
            NarudzbaStatusi.Gotova when korisnikId is > 0 && mozePotvrditi
                && narudzba.Nacin_Predaje == NacinPredajeVrijednosti.PreuzimanjeIDostava =>
                "Potvrdite preuzimanje nakon što vam radnik dostavi narudžbu.",
            NarudzbaStatusi.Gotova when korisnikId is > 0 && mozePotvrditi =>
                "Potvrdite preuzimanje u radnji skeniranjem ili unosom broja oznake.",
            NarudzbaStatusi.Gotova when narudzba.Nacin_Predaje == NacinPredajeVrijednosti.PreuzimanjeIDostava
                && logistikaStatus == LogistikaStatusi.UToku =>
                "Dostava je već u toku. Možete nastaviti s predajom korisniku.",
            NarudzbaStatusi.Gotova when narudzba.Nacin_Predaje == NacinPredajeVrijednosti.PreuzimanjeIDostava =>
                "Narudžba je spremna — potvrdite da krećete u dostavu.",
            NarudzbaStatusi.Gotova =>
                "Narudžba je spremna za preuzimanje korisnika u radnji.",
            NarudzbaStatusi.Preuzeta when korisnikId is > 0 =>
                "Narudžba je već preuzeta.",
            _ => korisnikId is > 0
                ? $"Narudžba još nije spremna za preuzimanje (status: {statusNarudzbe})."
                : $"Narudžba nije spremna za ovu radnju (status: {statusNarudzbe}).",
        };

        return new StavkaOznakaInfoDto
        {
            BrojOznake = stavka.Broj_Oznake!,
            StavkaId = stavka.ID_Stavke,
            ArtikalNaziv = stavka.Artikal.Naziv,
            NarudzbaId = narudzba.ID_Narudzbe,
            StatusNarudzbe = statusNarudzbe,
            NacinPredaje = narudzba.Nacin_Predaje,
            NacinPredajeNaziv = NacinPredajeNazivi.ZaPrikaz(narudzba.Nacin_Predaje),
            AdresaDostave = logistika?.Adresa,
            KorisnikPunoIme = $"{narudzba.Korisnik.Ime} {narudzba.Korisnik.Prezime}",
            LogistikaStatusNaziv = logistikaStatus,
            MozePokrenutiDostavu = mozePokrenuti,
            MozePotvrditiPreuzimanje = mozePotvrditi,
            Poruka = poruka,
        };
    }

    private static bool IzracunajMozePotvrditiPreuzimanje(
        StavkaNarudzbe stavka,
        int? korisnikId)
    {
        if (korisnikId is null or <= 0)
            return false;

        var narudzba = stavka.Narudzba;

        if (narudzba.FK_Korisnik != korisnikId)
            return false;

        if (narudzba.Status.Naziv != NarudzbaStatusi.Gotova)
            return false;

        var logistika = narudzba.Logistike
            .FirstOrDefault(l => l.Tip == LogistikaTipovi.Preuzimanje);

        if (logistika == null)
            return true;

        return logistika.Status.Naziv is LogistikaStatusi.Zakazano or LogistikaStatusi.UToku;
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
            .Include(n => n.Kupon)
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
            PopustIznos = narudzba.Popust_Iznos,
            UkupnoZaPlatiti = narudzba.Ukupna_Cijena - narudzba.Popust_Iznos,
            KuponKod = narudzba.Kupon?.Kod,
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
                    BrojOznake = s.Broj_Oznake,
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
