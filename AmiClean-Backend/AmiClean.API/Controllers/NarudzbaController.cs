using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class NarudzbaController : ControllerBase
{
    private readonly AmiCleanContext _context;

    public NarudzbaController(AmiCleanContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Narudzba>>> GetNarudzbe()
    {
        return await _context.Narudzbe
            .AsNoTracking()
            .Include(n => n.Korisnik)
            .Include(n => n.Status)
            .OrderByDescending(n => n.Datum_Prijema)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Narudzba>> GetNarudzba(int id)
    {
        var narudzba = await _context.Narudzbe
            .AsNoTracking()
            .Include(n => n.Korisnik)
            .Include(n => n.Status)
            .Include(n => n.Stavke)
            .FirstOrDefaultAsync(n => n.ID_Narudzbe == id);

        if (narudzba == null)
            return NotFound();

        return narudzba;
    }

    [HttpGet("korisnik/{korisnikId}")]
    public async Task<ActionResult<IEnumerable<Narudzba>>> GetNarudzbeKorisnika(int korisnikId)
    {
        return await _context.Narudzbe
            .AsNoTracking()
            .Include(n => n.Status)
            .Where(n => n.FK_Korisnik == korisnikId)
            .OrderByDescending(n => n.Datum_Prijema)
            .ToListAsync();
    }

    [HttpPost]
    public async Task<ActionResult<Narudzba>> PostNarudzba(Narudzba narudzba)
    {
        if (narudzba.Datum_Prijema == default)
            narudzba.Datum_Prijema = DateTime.Now;

        _context.Narudzbe.Add(narudzba);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetNarudzba), new { id = narudzba.ID_Narudzbe }, narudzba);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutNarudzba(int id, Narudzba narudzba)
    {
        if (id != narudzba.ID_Narudzbe)
            return BadRequest();

        _context.Entry(narudzba).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Narudzbe.AnyAsync(e => e.ID_Narudzbe == id))
                return NotFound();

            throw;
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteNarudzba(int id)
    {
        var narudzba = await _context.Narudzbe.FindAsync(id);
        if (narudzba == null)
            return NotFound();

        _context.Narudzbe.Remove(narudzba);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
