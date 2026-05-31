using AmiClean.Application.Catalog.Dtos;
using AmiClean.Application.Catalog.Interfaces;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Catalog;

public class CatalogService : ICatalogService
{
    private readonly AmiCleanContext _context;

    public CatalogService(AmiCleanContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<ArtikalKatalogDto>> GetKatalogAsync(
        CancellationToken cancellationToken = default)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);

        var artikli = await _context.Artikli
            .AsNoTracking()
            .Where(a => a.Aktivan)
            .OrderBy(a => a.Naziv)
            .Select(a => new
            {
                a.ID_Artikla,
                a.Naziv,
                a.Opis,
                a.Kategorija,
                Usluge = a.Cjenovnici
                    .Where(c =>
                        c.Vazi_Od <= today &&
                        (c.Vazi_Do == null || c.Vazi_Do >= today) &&
                        c.Usluga.Aktivan)
                    .OrderBy(c => c.Usluga.Naziv)
                    .Select(c => new UslugaCijenaDto
                    {
                        UslugaId = c.FK_Usluga,
                        UslugaNaziv = c.Usluga.Naziv,
                        CjenovnikId = c.ID_Cjenovnika,
                        Cijena = c.Cijena,
                        CijenaMax = c.Cijena_Max,
                        CijenaOpis = c.Cijena_Max != null
                            ? $"{c.Cijena:0.00} – {c.Cijena_Max:0.00} KM"
                            : null,
                    })
                    .ToList(),
            })
            .ToListAsync(cancellationToken);

        return artikli
            .Where(a => a.Usluge.Count > 0)
            .Select(a => new ArtikalKatalogDto
            {
                Id = a.ID_Artikla,
                Naziv = a.Naziv,
                Opis = a.Opis,
                Kategorija = a.Kategorija,
                Usluge = a.Usluge,
            })
            .ToList();
    }
}
