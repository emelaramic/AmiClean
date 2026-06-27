namespace AmiClean.Application.Coupons.Dtos;

public class KuponProvjeraDto
{
    public bool Vazeci { get; set; }
    public string? Poruka { get; set; }
    public string? Kod { get; set; }
    public decimal PostotakPopusta { get; set; }
    public decimal PopustIznos { get; set; }
    public decimal UkupnoNakonPopusta { get; set; }
}
