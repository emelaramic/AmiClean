namespace AmiClean.Application.Catalog.Dtos;

public class CjenovnikStavkaDto
{
    public int Id { get; set; }
    public int ArtikalId { get; set; }
    public string ArtikalNaziv { get; set; } = null!;
    public string ArtikalKategorija { get; set; } = null!;
    public int UslugaId { get; set; }
    public string UslugaNaziv { get; set; } = null!;
    public decimal Cijena { get; set; }
    public decimal? CijenaMax { get; set; }
    public DateOnly VaziOd { get; set; }
    public DateOnly? VaziDo { get; set; }
}
