using AmiClean.Application.Notifications.Dtos;
using AmiClean.Application.Notifications.Interfaces;
using AmiClean.Infrastructure.Notifications;
using Microsoft.AspNetCore.Mvc;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class NotifikacijaController : ControllerBase
{
    private readonly INotifikacijaService _notifikacijaService;

    public NotifikacijaController(INotifikacijaService notifikacijaService)
    {
        _notifikacijaService = notifikacijaService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<NotifikacijaDto>>> GetZaKorisnika(
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return BadRequest(new { message = "korisnikId mora biti veći od 0." });

        try
        {
            return Ok(await _notifikacijaService.GetZaKorisnikaAsync(korisnikId, cancellationToken));
        }
        catch (NotifikacijaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<BrojNeprocitanihDto>> GetBrojNeprocitanih(
        int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return BadRequest(new { message = "korisnikId mora biti veći od 0." });

        var broj = await _notifikacijaService.GetBrojNeprocitanihAsync(korisnikId, cancellationToken);
        return Ok(new BrojNeprocitanihDto { Broj = broj });
    }

    [HttpPost]
    public async Task<IActionResult> OznaciProcitanom(
        [FromQuery] int notifikacijaId,
        [FromQuery] int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (notifikacijaId <= 0 || korisnikId <= 0)
            return BadRequest(new { message = "Identifikatori nisu ispravni." });

        try
        {
            await _notifikacijaService.OznaciProcitanomAsync(
                notifikacijaId,
                korisnikId,
                cancellationToken);
            return NoContent();
        }
        catch (NotifikacijaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> OznaciSveProcitanim(
        [FromQuery] int korisnikId,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return BadRequest(new { message = "korisnikId mora biti veći od 0." });

        try
        {
            await _notifikacijaService.OznaciSveProcitanimAsync(korisnikId, cancellationToken);
            return NoContent();
        }
        catch (NotifikacijaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
