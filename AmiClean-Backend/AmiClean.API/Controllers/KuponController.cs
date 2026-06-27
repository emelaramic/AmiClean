using AmiClean.Application.Coupons;
using AmiClean.Application.Coupons.Dtos;
using AmiClean.Application.Coupons.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class KuponController : ControllerBase
{
    private readonly IKuponService _kuponService;

    public KuponController(IKuponService kuponService)
    {
        _kuponService = kuponService;
    }

    [HttpGet]
    public async Task<ActionResult<KuponProvjeraDto>> Provjeri(
        [FromQuery] string kod,
        [FromQuery] decimal ukupnaCijena,
        CancellationToken cancellationToken = default)
    {
        if (ukupnaCijena < 0)
            return BadRequest(new { message = "Ukupna cijena nije ispravna." });

        return Ok(await _kuponService.ProvjeriAsync(kod, ukupnaCijena, cancellationToken));
    }
}
