using AmiClean.Application.Recommendations.Dtos;
using AmiClean.Application.Recommendations.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class PreporukeController : ControllerBase
{
    private readonly IPreporukaService _preporukaService;

    public PreporukeController(IPreporukaService preporukaService)
    {
        _preporukaService = preporukaService;
    }

    /// <summary>
    /// Personalizirane preporuke usluga za korisnika (historija + popularnost).
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<PreporukaDto>>> GetZaKorisnika(
        int korisnikId,
        int limit = 3,
        CancellationToken cancellationToken = default)
    {
        if (korisnikId <= 0)
            return BadRequest(new { message = "korisnikId mora biti veći od 0." });

        var preporuke = await _preporukaService.GetZaKorisnikaAsync(
            korisnikId,
            limit,
            cancellationToken);

        return Ok(preporuke);
    }
}
