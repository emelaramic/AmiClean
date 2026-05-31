using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class ArtikalController : ControllerBase
{
    private readonly AmiCleanContext _context;

    public ArtikalController(AmiCleanContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Artikal>>> GetArtikli()
    {
        return await _context.Artikli
            .AsNoTracking()
            .Where(a => a.Aktivan)
            .OrderBy(a => a.Naziv)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Artikal>> GetArtikal(int id)
    {
        var artikal = await _context.Artikli
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.ID_Artikla == id);

        if (artikal == null)
            return NotFound();

        return artikal;
    }

    [HttpPost]
    public async Task<ActionResult<Artikal>> PostArtikal(Artikal artikal)
    {
        artikal.Aktivan = true;
        _context.Artikli.Add(artikal);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetArtikal), new { id = artikal.ID_Artikla }, artikal);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutArtikal(int id, Artikal artikal)
    {
        if (id != artikal.ID_Artikla)
            return BadRequest();

        _context.Entry(artikal).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Artikli.AnyAsync(e => e.ID_Artikla == id))
                return NotFound();

            throw;
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteArtikal(int id)
    {
        var artikal = await _context.Artikli.FindAsync(id);
        if (artikal == null)
            return NotFound();

        artikal.Aktivan = false;
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
