using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class UslugaController : ControllerBase
{
    private readonly AmiCleanContext _context;

    public UslugaController(AmiCleanContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Usluga>>> GetUsluge()
    {
        return await _context.Usluge
            .AsNoTracking()
            .Where(u => u.Aktivan)
            .OrderBy(u => u.Naziv)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Usluga>> GetUsluga(int id)
    {
        var usluga = await _context.Usluge
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.ID_Usluge == id);

        if (usluga == null)
            return NotFound();

        return usluga;
    }

    [HttpPost]
    public async Task<ActionResult<Usluga>> PostUsluga(Usluga usluga)
    {
        usluga.Aktivan = true;
        _context.Usluge.Add(usluga);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUsluga), new { id = usluga.ID_Usluge }, usluga);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutUsluga(int id, Usluga usluga)
    {
        if (id != usluga.ID_Usluge)
            return BadRequest();

        _context.Entry(usluga).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Usluge.AnyAsync(e => e.ID_Usluge == id))
                return NotFound();

            throw;
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUsluga(int id)
    {
        var usluga = await _context.Usluge.FindAsync(id);
        if (usluga == null)
            return NotFound();

        usluga.Aktivan = false;
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
