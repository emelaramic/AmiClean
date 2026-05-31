namespace AmiClean.Application.Catalog.Dtos;

public class ArtikalKatalogDto
{
    public int Id { get; set; }
    public string Naziv { get; set; } = null!;
    public string Kategorija { get; set; } = null!;
    public string? Opis { get; set; }
    public IReadOnlyList<UslugaCijenaDto> Usluge { get; set; } = [];
}

public class UslugaCijenaDto
{
    public int UslugaId { get; set; }
    public string UslugaNaziv { get; set; } = null!;
    public int CjenovnikId { get; set; }
    public decimal Cijena { get; set; }
    public decimal? CijenaMax { get; set; }
    public string? CijenaOpis { get; set; }
}
