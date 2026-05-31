using AmiClean.Application.Auth.Dtos;
using AmiClean.Application.Auth.Interfaces;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class KorisnikController : ControllerBase
{
    private readonly AmiCleanContext _context;
    private readonly IAuthService _authService;

    public KorisnikController(AmiCleanContext context, IAuthService authService)
    {
        _context = context;
        _authService = authService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Korisnik>>> GetKorisnici()
    {
        return await _context.Korisnici.ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Korisnik>> GetKorisnik(int id)
    {
        var korisnik = await _context.Korisnici.FindAsync(id);

        if (korisnik == null)
            return NotFound();

        return korisnik;
    }

    [HttpPost]
    public async Task<ActionResult<Korisnik>> PostKorisnik(Korisnik korisnik)
    {
        _context.Korisnici.Add(korisnik);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetKorisnik), new { id = korisnik.ID_Korisnika }, korisnik);
    }

    [HttpPost]
    public async Task<ActionResult<PrijavaResponse>> Prijava(PrijavaKorisnikaRequest request)
    {
        var result = await _authService.PrijavaKorisnikaAsync(request);

        if (result is null)
        {
            return Unauthorized(new
            {
                message = "Neispravni podaci za prijavu.",
            });
        }

        return Ok(result);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> PutKorisnik(int id, Korisnik korisnik)
    {
        if (id != korisnik.ID_Korisnika)
            return BadRequest();

        _context.Entry(korisnik).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.Korisnici.AnyAsync(e => e.ID_Korisnika == id))
                return NotFound();

            throw;
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteKorisnik(int id)
    {
        var korisnik = await _context.Korisnici.FindAsync(id);
        if (korisnik == null)
            return NotFound();

        _context.Korisnici.Remove(korisnik);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
