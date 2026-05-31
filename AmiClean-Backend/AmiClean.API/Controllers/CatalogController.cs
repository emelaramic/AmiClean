using AmiClean.Application.Catalog.Constants;
using AmiClean.Application.Catalog.Dtos;
using AmiClean.Application.Catalog.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AmiClean.API.Controllers;

[Route("api/[controller]/[action]")]
[ApiController]
public class CatalogController : ControllerBase
{
    private readonly ICatalogService _catalogService;

    public CatalogController(ICatalogService catalogService)
    {
        _catalogService = catalogService;
    }

    [HttpGet]
    public ActionResult<IReadOnlyList<string>> GetKategorije()
    {
        return Ok(ArtikalKategorije.Sve);
    }

    /// <summary>
    /// Cjenovnik grupiran po artiklu — nova usluga ne zahtijeva promjenu API-ja.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<ArtikalKatalogDto>>> GetKatalog()
    {
        var katalog = await _catalogService.GetKatalogAsync();
        return Ok(katalog);
    }
}
