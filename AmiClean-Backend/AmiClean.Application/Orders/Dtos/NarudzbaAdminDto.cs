namespace AmiClean.Application.Orders.Dtos;

public class NarudzbaAdminPregledDto
{
    public int Id { get; set; }
    public DateTime DatumKreiranja { get; set; }
    public string StatusNaziv { get; set; } = null!;
    public string NacinPredaje { get; set; } = null!;
    public string NacinPredajeNaziv { get; set; } = null!;
    public decimal UkupnaCijena { get; set; }
    public int BrojStavki { get; set; }
    public string KorisnikPunoIme { get; set; } = null!;
    public string? KorisnikTelefon { get; set; }
}

public class NarudzbaAdminDetaljDto : NarudzbaDetaljDto
{
    public int KorisnikId { get; set; }
    public string KorisnikPunoIme { get; set; } = null!;
    public string? KorisnikEmail { get; set; }
    public string? KorisnikTelefon { get; set; }
    public string? KorisnikAdresaStanovanja { get; set; }
    public bool MozeSePrimijeti { get; set; }
}

public class PrimijeniNarudzbuRequest
{
    public int NarudzbaId { get; set; }
    public int ZaposlenikId { get; set; }
    public DateTime RokZavrsetka { get; set; }
}

public class NarudzbaStatusPromjenaDto
{
    public int Id { get; set; }
    public string StatusNaziv { get; set; } = null!;
    public DateTime? RokZavrsetka { get; set; }
    public string Poruka { get; set; } = null!;
}
