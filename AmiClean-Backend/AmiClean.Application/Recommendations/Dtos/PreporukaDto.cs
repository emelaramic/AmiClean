namespace AmiClean.Application.Recommendations.Dtos;

public class PreporukaDto
{
    public int ArtikalId { get; set; }
    public string Naziv { get; set; } = null!;
    public string Kategorija { get; set; } = null!;
    public string? Opis { get; set; }
    public string Tip { get; set; } = null!;
    public string Razlog { get; set; } = null!;
    public decimal? OdCijena { get; set; }
    public string? CijenaOpis { get; set; }
}
