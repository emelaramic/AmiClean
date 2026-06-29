using AmiClean.Application.Orders.Dtos;
using AmiClean.Application.Orders.Interfaces;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmiClean.Application.Orders;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class NarudzbaController : ControllerBase
{
    private readonly AmiCleanContext _context;
    private readonly INarudzbaService _narudzbaService;

    public NarudzbaController(AmiCleanContext context, INarudzbaService narudzbaService)
    {
        _context = context;
        _narudzbaService = narudzbaService;
    }

    /// <summary>
    /// Kreira narudžbu iz aplikacije (košarica, način predaje, stavke + usluge).
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<NarudzbaKreiranaDto>> KreirajNarudzbu(KreirajNarudzbuRequest request)
    {
        try
        {
            var rezultat = await _narudzbaService.KreirajNarudzbuAsync(request);
            return Ok(rezultat);
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<NarudzbaPregledDto>>> GetMojeNarudzbe(
        [FromQuery] int korisnikId)
    {
        try
        {
            return Ok(await _narudzbaService.GetNarudzbeKorisnikaAsync(korisnikId));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<NarudzbaDetaljDto>> GetDetaljNarudzbe(
        [FromQuery] int narudzbaId,
        [FromQuery] int korisnikId)
    {
        try
        {
            return Ok(await _narudzbaService.GetDetaljNarudzbeAsync(narudzbaId, korisnikId));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<NarudzbaAdminPregledDto>>> GetSveNarudzbe(
        [FromQuery] string? statusNaziv = null,
        [FromQuery] int? limit = null)
    {
        try
        {
            return Ok(await _narudzbaService.GetSveNarudzbeAsync(statusNaziv, limit));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<BrojNarudzbiPoStatusuDto>> GetBrojNarudzbiPoStatusu()
    {
        return Ok(await _narudzbaService.GetBrojNarudzbiPoStatusuAsync());
    }

    [HttpGet]
    public async Task<ActionResult<NarudzbaAdminDetaljDto>> GetDetaljNarudzbeAdmin(
        [FromQuery] int narudzbaId)
    {
        try
        {
            return Ok(await _narudzbaService.GetDetaljNarudzbeAdminAsync(narudzbaId));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<NarudzbaStatusPromjenaDto>> PrimijeniNarudzbu(
        PrimijeniNarudzbuRequest request)
    {
        try
        {
            return Ok(await _narudzbaService.PrimijeniNarudzbuAsync(request));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<NarudzbaStatusPromjenaDto>> PromijeniStatusNarudzbe(
        PromijeniStatusNarudzbeRequest request)
    {
        try
        {
            return Ok(await _narudzbaService.PromijeniStatusNarudzbeAsync(request));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<NarudzbaStatusPromjenaDto>> PromijeniRokZavrsetka(
        PromijeniRokZavrsetkaRequest request)
    {
        try
        {
            return Ok(await _narudzbaService.PromijeniRokZavrsetkaAsync(request));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<NarudzbaStatusPromjenaDto>> OtkaziNarudzbu(
        OtkaziNarudzbuRequest request)
    {
        try
        {
            return Ok(await _narudzbaService.OtkaziNarudzbuAsync(request));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<StavkaOznakaInfoDto>> GetInfoPoOznaci(
        [FromQuery] string unos,
        [FromQuery] int? korisnikId = null)
    {
        try
        {
            return Ok(await _narudzbaService.GetInfoPoOznaciAsync(unos, korisnikId));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<RadnikOznakaRezultatDto>> RadnikPokreniDostavu(
        RadnikOznakaRequest request)
    {
        try
        {
            return Ok(await _narudzbaService.RadnikPokreniDostavuAsync(request));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<ActionResult<KorisnikOznakaRezultatDto>> KorisnikPotvrdiPreuzimanje(
        KorisnikOznakaRequest request)
    {
        try
        {
            return Ok(await _narudzbaService.KorisnikPotvrdiPreuzimanjeAsync(request));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<RadnikDostaveListaDto>> GetDostaveZaRadnika(
        [FromQuery] int zaposlenikId)
    {
        try
        {
            return Ok(await _narudzbaService.GetDostaveZaRadnikaAsync(zaposlenikId));
        }
        catch (NarudzbaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
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
