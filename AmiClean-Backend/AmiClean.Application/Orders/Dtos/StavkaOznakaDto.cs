namespace AmiClean.Application.Orders.Dtos;

public class StavkaOznakaInfoDto
{
    public string BrojOznake { get; set; } = null!;
    public int StavkaId { get; set; }
    public string ArtikalNaziv { get; set; } = null!;
    public int NarudzbaId { get; set; }
    public string StatusNarudzbe { get; set; } = null!;
    public string NacinPredaje { get; set; } = null!;
    public string NacinPredajeNaziv { get; set; } = null!;
    public string? AdresaDostave { get; set; }
    public string KorisnikPunoIme { get; set; } = null!;
    public string? LogistikaStatusNaziv { get; set; }
    public bool MozePokrenutiDostavu { get; set; }
    public bool MozePotvrditiPreuzimanje { get; set; }
    public string Poruka { get; set; } = null!;
}

public class RadnikOznakaRequest
{
    public string Unos { get; set; } = null!;
    public int ZaposlenikId { get; set; }
}

public class RadnikOznakaRezultatDto
{
    public int NarudzbaId { get; set; }
    public string StatusNarudzbe { get; set; } = null!;
    public string? LogistikaStatusNaziv { get; set; }
    public bool DostavaPokrenuta { get; set; }
    public string Poruka { get; set; } = null!;
}

public class KorisnikOznakaRequest
{
    public string Unos { get; set; } = null!;
    public int KorisnikId { get; set; }
}

public class KorisnikOznakaRezultatDto
{
    public int NarudzbaId { get; set; }
    public string StatusNarudzbe { get; set; } = null!;
    public string? LogistikaStatusNaziv { get; set; }
    public bool PreuzimanjePotvrdeno { get; set; }
    public string Poruka { get; set; } = null!;
}

public class RadnikDostavaPregledDto
{
    public int NarudzbaId { get; set; }
    public string KorisnikPunoIme { get; set; } = null!;
    public string? KorisnikTelefon { get; set; }
    public string AdresaDostave { get; set; } = null!;
    public string LogistikaStatusNaziv { get; set; } = null!;
    public int BrojStavki { get; set; }
    public DateTime DatumPrijema { get; set; }
    public DateTime? RokZavrsetka { get; set; }
    public string? VozacPunoIme { get; set; }
    public bool JeMojaDostava { get; set; }
    public bool MozePokrenuti { get; set; }
}

public class RadnikDostaveListaDto
{
    public IReadOnlyList<RadnikDostavaPregledDto> Spremne { get; set; } = [];
    public IReadOnlyList<RadnikDostavaPregledDto> UToku { get; set; } = [];
}
