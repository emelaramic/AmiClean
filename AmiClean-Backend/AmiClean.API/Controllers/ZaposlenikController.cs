using AmiClean.Application.Auth.Dtos;
using AmiClean.Application.Auth.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class ZaposlenikController : ControllerBase
{
    private readonly IAuthService _authService;

    public ZaposlenikController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost]
    public async Task<ActionResult<PrijavaResponse>> Prijava(PrijavaZaposlenikaRequest request)
    {
        var result = await _authService.PrijavaZaposlenikaAsync(request);

        if (result is null)
        {
            return Unauthorized(new
            {
                message = "Neispravni podaci za prijavu.",
            });
        }

        return Ok(result);
    }
}
