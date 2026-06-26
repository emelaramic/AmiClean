using AmiClean.Application.Catalog.Constants;
using AmiClean.Application.Catalog.Dtos;
using AmiClean.Application.Catalog.Interfaces;
using AmiClean.Application.Orders.Constants;
using AmiClean.Application.Recommendations.Constants;
using AmiClean.Application.Recommendations.Dtos;
using AmiClean.Application.Recommendations.Interfaces;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Recommendations;

/// <summary>
/// Hibridni sustav preporuka: povijest narudžbi (content-based),
/// komplementarne kategorije (rule-based) i globalna popularnost.
/// </summary>
public class PreporukaService : IPreporukaService
{
    private const int MaxLimit = 6;
    private const int DefaultLimit = 3;

    private static readonly IReadOnlyDictionary<string, string[]> KomplementarneKategorije =
        new Dictionary<string, string[]>
        {
            [ArtikalKategorije.Tepisi] = [ArtikalKategorije.Posteljina, ArtikalKategorije.Namještaj],
            [ArtikalKategorije.Odjeća] = [ArtikalKategorije.Posteljina, ArtikalKategorije.Namještaj],
            [ArtikalKategorije.Posteljina] = [ArtikalKategorije.Tepisi, ArtikalKategorije.Odjeća],
            [ArtikalKategorije.Namještaj] = [ArtikalKategorije.Tepisi, ArtikalKategorije.Odjeća],
        };

    private readonly AmiCleanContext _context;
    private readonly ICatalogService _catalogService;

    public PreporukaService(AmiCleanContext context, ICatalogService catalogService)
    {
        _context = context;
        _catalogService = catalogService;
    }

    public async Task<IReadOnlyList<PreporukaDto>> GetZaKorisnikaAsync(
        int korisnikId,
        int limit = DefaultLimit,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return [];

        limit = Math.Clamp(limit, 1, MaxLimit);

        var katalog = await _catalogService.GetKatalogAsync(cancellationToken);
        if (katalog.Count == 0)
            return [];

        var korisnikPostoji = await _context.Korisnici
            .AsNoTracking()
            .AnyAsync(k => k.ID_Korisnika == korisnikId, cancellationToken);

        if (!korisnikPostoji)
            return [];

        var povijest = await UcitajPovijestKorisnikaAsync(korisnikId, cancellationToken);
        var popularnost = await UcitajPopularnostAsync(cancellationToken);

        var kandidati = new List<PreporukaKandidat>();

        if (povijest.ImaNarudzbi)
        {
            kandidati.AddRange(
                PreporukeNaTemeljuHistorije(katalog, povijest, popularnost));
            kandidati.AddRange(
                PreporukeKomplementarnihKategorija(katalog, povijest));
        }

        kandidati.AddRange(
            PreporukePopularnosti(katalog, povijest, popularnost, povijest.ImaNarudzbi));

        return kandidati
            .GroupBy(k => k.Artikal.Id)
            .Select(grupa => grupa.MaxBy(k => k.Score)!)
            .OrderByDescending(k => k.Score)
            .ThenBy(k => k.Artikal.Naziv)
            .Take(limit)
            .Select(MapToDto)
            .ToList();
    }

    private static IEnumerable<PreporukaKandidat> PreporukeNaTemeljuHistorije(
        IReadOnlyList<ArtikalKatalogDto> katalog,
        KorisnikPovijest povijest,
        IReadOnlyDictionary<int, int> popularnost)
    {
        foreach (var (kategorija, brojNarudzbi) in povijest.BrojPoKategoriji
                     .OrderByDescending(x => x.Value))
        {
            var artikli = katalog
                .Where(a =>
                    a.Kategorija == kategorija &&
                    !povijest.NaruceniArtikalIds.Contains(a.Id))
                .ToList();

            foreach (var artikal in artikli)
            {
                var popularnostBonus = popularnost.GetValueOrDefault(artikal.Id);
                yield return new PreporukaKandidat(
                    artikal,
                    Score: 300 + brojNarudzbi * 10 + popularnostBonus,
                    Tip: PreporukaTipovi.Historija,
                    Razlog: $"Često naručujete usluge iz kategorije {kategorija}.");
            }
        }
    }

    private static IEnumerable<PreporukaKandidat> PreporukeKomplementarnihKategorija(
        IReadOnlyList<ArtikalKatalogDto> katalog,
        KorisnikPovijest povijest)
    {
        foreach (var kategorija in povijest.BrojPoKategoriji.Keys)
        {
            if (!KomplementarneKategorije.TryGetValue(kategorija, out var komplementi))
                continue;

            foreach (var komplement in komplementi)
            {
                if (povijest.BrojPoKategoriji.ContainsKey(komplement))
                    continue;

                var artikli = katalog
                    .Where(a =>
                        a.Kategorija == komplement &&
                        !povijest.NaruceniArtikalIds.Contains(a.Id))
                    .Take(2);

                foreach (var artikal in artikli)
                {
                    yield return new PreporukaKandidat(
                        artikal,
                        Score: 200,
                        Tip: PreporukaTipovi.Komplementarno,
                        Razlog:
                            $"Korisnici koji koriste {kategorija} često naruče i {komplement}.");
                }
            }
        }
    }

    private static IEnumerable<PreporukaKandidat> PreporukePopularnosti(
        IReadOnlyList<ArtikalKatalogDto> katalog,
        KorisnikPovijest povijest,
        IReadOnlyDictionary<int, int> popularnost,
        bool korisnikImaPovijest)
    {
        foreach (var (artikalId, broj) in popularnost.OrderByDescending(x => x.Value))
        {
            var artikal = katalog.FirstOrDefault(a => a.Id == artikalId);
            if (artikal == null)
                continue;

            if (korisnikImaPovijest && povijest.NaruceniArtikalIds.Contains(artikalId))
                continue;

            var razlog = korisnikImaPovijest
                ? "Jedna od najpopularnijih usluga među našim korisnicima."
                : "Najpopularnija usluga za nove korisnike AmiClean-a.";

            yield return new PreporukaKandidat(
                artikal,
                Score: 100 + broj,
                Tip: PreporukaTipovi.Popularno,
                Razlog: razlog);
        }
    }

    private async Task<KorisnikPovijest> UcitajPovijestKorisnikaAsync(
        int korisnikId,
        CancellationToken cancellationToken)
    {
        var stavke = await _context.StavkeNarudzbe
            .AsNoTracking()
            .Where(s =>
                s.Narudzba.FK_Korisnik == korisnikId &&
                s.Narudzba.Status.Naziv != NarudzbaStatusi.Otkazana)
            .Select(s => new
            {
                s.FK_Artikal,
                s.Artikal.Kategorija,
            })
            .ToListAsync(cancellationToken);

        var brojPoKategoriji = stavke
            .GroupBy(s => s.Kategorija)
            .ToDictionary(g => g.Key, g => g.Count());

        var naruceniArtikalIds = stavke
            .Select(s => s.FK_Artikal)
            .ToHashSet();

        return new KorisnikPovijest(
            ImaNarudzbi: stavke.Count > 0,
            BrojPoKategoriji: brojPoKategoriji,
            NaruceniArtikalIds: naruceniArtikalIds);
    }

    private async Task<IReadOnlyDictionary<int, int>> UcitajPopularnostAsync(
        CancellationToken cancellationToken)
    {
        var counts = await _context.StavkeNarudzbe
            .AsNoTracking()
            .Where(s => s.Narudzba.Status.Naziv != NarudzbaStatusi.Otkazana)
            .GroupBy(s => s.FK_Artikal)
            .Select(g => new { ArtikalId = g.Key, Broj = g.Count() })
            .ToListAsync(cancellationToken);

        return counts.ToDictionary(x => x.ArtikalId, x => x.Broj);
    }

    private static PreporukaDto MapToDto(PreporukaKandidat kandidat)
    {
        var artikal = kandidat.Artikal;
        var minCijena = artikal.Usluge.Count > 0
            ? artikal.Usluge.Min(u => u.Cijena)
            : (decimal?)null;

        var cijenaOpis = minCijena.HasValue
            ? artikal.Kategorija == ArtikalKategorije.Tepisi
                ? $"od {minCijena.Value:0.00} KM/m²"
                : $"od {minCijena.Value:0.00} KM"
            : null;

        return new PreporukaDto
        {
            ArtikalId = artikal.Id,
            Naziv = artikal.Naziv,
            Kategorija = artikal.Kategorija,
            Opis = artikal.Opis,
            Tip = kandidat.Tip,
            Razlog = kandidat.Razlog,
            OdCijena = minCijena,
            CijenaOpis = cijenaOpis,
        };
    }

    private sealed record KorisnikPovijest(
        bool ImaNarudzbi,
        IReadOnlyDictionary<string, int> BrojPoKategoriji,
        HashSet<int> NaruceniArtikalIds);

    private sealed record PreporukaKandidat(
        ArtikalKatalogDto Artikal,
        int Score,
        string Tip,
        string Razlog);
}
