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
    public async Task<ActionResult<IEnumerable<Cjenovnik>>> GetCjenovnik()
    {
        return await _context.Cjenovnici
            .AsNoTracking()
            .Include(c => c.Artikal)
            .Include(c => c.Usluga)
            .OrderBy(c => c.Artikal.Naziv)
            .ThenBy(c => c.Usluga.Naziv)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Cjenovnik>> GetCjenovnikStavka(int id)
    {
        var stavka = await _context.Cjenovnici
            .AsNoTracking()
            .Include(c => c.Artikal)
            .Include(c => c.Usluga)
            .FirstOrDefaultAsync(c => c.ID_Cjenovnika == id);

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
    public async Task<IActionResult> PutCjenovnik(int id, Cjenovnik cjenovnik)
    {
        if (id != cjenovnik.ID_Cjenovnika)
            return BadRequest();

        var duplicate = await _context.Cjenovnici.AnyAsync(c =>
            c.ID_Cjenovnika != id &&
            c.FK_Artikal == cjenovnik.FK_Artikal &&
            c.FK_Usluga == cjenovnik.FK_Usluga);

        if (duplicate)
        {
            return Conflict(new
            {
                message = "Cijena za ovu kombinaciju artikla i usluge već postoji.",
            });
        }

        _context.Entry(cjenovnik).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Cjenovnici.AnyAsync(e => e.ID_Cjenovnika == id))
                return NotFound();

            throw;
        }

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
