using AmiClean.Application.Reviews;
using AmiClean.Application.Reviews.Dtos;
using AmiClean.Application.Reviews.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class RecenzijaController : ControllerBase
{
    private readonly IRecenzijaService _recenzijaService;

    public RecenzijaController(IRecenzijaService recenzijaService)
    {
        _recenzijaService = recenzijaService;
    }

    [HttpPost]
    public async Task<ActionResult<RecenzijaDto>> KreirajRecenziju(
        [FromBody] KreirajRecenzijuRequest request,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var recenzija = await _recenzijaService.KreirajRecenzijuAsync(
                request,
                cancellationToken);
            return Ok(recenzija);
        }
        catch (RecenzijaValidationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
