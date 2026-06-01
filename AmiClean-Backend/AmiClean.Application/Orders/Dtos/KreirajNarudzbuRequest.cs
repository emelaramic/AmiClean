namespace AmiClean.Application.Orders.Dtos;

public class KreirajNarudzbuRequest
{
    public int KorisnikId { get; set; }
    public string NacinPredaje { get; set; } = null!;
    public string? Adresa { get; set; }
    public string? Napomena { get; set; }
    public List<KreirajStavkuRequest> Stavke { get; set; } = [];
}

public class KreirajStavkuRequest
{
    public int ArtikalId { get; set; }
    public decimal Kolicina { get; set; }
    public List<int> UslugaIds { get; set; } = [];
    public string? Napomena { get; set; }
}

public class NarudzbaKreiranaDto
{
    public int Id { get; set; }
    public string StatusNaziv { get; set; } = null!;
    public string NacinPredaje { get; set; } = null!;
    public decimal UkupnaCijena { get; set; }
    public DateTime DatumKreiranja { get; set; }
    public string Poruka { get; set; } = null!;
}
