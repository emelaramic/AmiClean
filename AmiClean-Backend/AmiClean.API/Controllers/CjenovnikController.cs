using AmiClean.Application.Catalog.Dtos;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class CjenovnikController : ControllerBase
{
    private readonly AmiCleanContext _context;

    public CjenovnikController(AmiCleanContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<CjenovnikStavkaDto>>> GetCjenovnik()
    {
        var stavke = await _context.Cjenovnici
            .AsNoTracking()
            .Include(c => c.Artikal)
            .Include(c => c.Usluga)
            .OrderBy(c => c.Artikal.Naziv)
            .ThenBy(c => c.Usluga.Naziv)
            .Select(c => new CjenovnikStavkaDto
            {
                Id = c.ID_Cjenovnika,
                ArtikalId = c.FK_Artikal,
                ArtikalNaziv = c.Artikal.Naziv,
                ArtikalKategorija = c.Artikal.Kategorija,
                UslugaId = c.FK_Usluga,
                UslugaNaziv = c.Usluga.Naziv,
                Cijena = c.Cijena,
                CijenaMax = c.Cijena_Max,
                VaziOd = c.Vazi_Od,
                VaziDo = c.Vazi_Do,
            })
            .ToListAsync();

        return stavke;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<CjenovnikStavkaDto>> GetCjenovnikStavka(int id)
    {
        var stavka = await _context.Cjenovnici
            .AsNoTracking()
            .Include(c => c.Artikal)
            .Include(c => c.Usluga)
            .Where(c => c.ID_Cjenovnika == id)
            .Select(c => new CjenovnikStavkaDto
            {
                Id = c.ID_Cjenovnika,
                ArtikalId = c.FK_Artikal,
                ArtikalNaziv = c.Artikal.Naziv,
                ArtikalKategorija = c.Artikal.Kategorija,
                UslugaId = c.FK_Usluga,
                UslugaNaziv = c.Usluga.Naziv,
                Cijena = c.Cijena,
                CijenaMax = c.Cijena_Max,
                VaziOd = c.Vazi_Od,
                VaziDo = c.Vazi_Do,
            })
            .FirstOrDefaultAsync();

        if (stavka == null)
            return NotFound();

        return stavka;
    }

    [HttpPost]
    public async Task<ActionResult<Cjenovnik>> PostCjenovnik(Cjenovnik cjenovnik)
    {
        var exists = await _context.Cjenovnici.AnyAsync(c =>
            c.FK_Artikal == cjenovnik.FK_Artikal && c.FK_Usluga == cjenovnik.FK_Usluga);

        if (exists)
        {
            return Conflict(new
            {
                message = "Cijena za ovu kombinaciju artikla i usluge već postoji.",
            });
        }

        if (cjenovnik.Vazi_Od == default)
            cjenovnik.Vazi_Od = DateOnly.FromDateTime(DateTime.Today);

        _context.Cjenovnici.Add(cjenovnik);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(GetCjenovnikStavka),
            new { id = cjenovnik.ID_Cjenovnika },
            cjenovnik);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutCjenovnik(int id, AzurirajCijenuRequest request)
    {
        if (request.Cijena <= 0)
        {
            return BadRequest(new { message = "Cijena mora biti veća od 0." });
        }

        var postojeca = await _context.Cjenovnici.FindAsync(id);
        if (postojeca == null)
            return NotFound();

        postojeca.Cijena = request.Cijena;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCjenovnik(int id)
    {
        var stavka = await _context.Cjenovnici.FindAsync(id);
        if (stavka == null)
            return NotFound();

        _context.Cjenovnici.Remove(stavka);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
