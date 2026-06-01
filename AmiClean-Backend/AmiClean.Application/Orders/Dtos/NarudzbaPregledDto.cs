namespace AmiClean.Application.Orders.Dtos;

public class NarudzbaPregledDto
{
    public int Id { get; set; }
    public DateTime DatumKreiranja { get; set; }
    public string StatusNaziv { get; set; } = null!;
    public string NacinPredaje { get; set; } = null!;
    public string NacinPredajeNaziv { get; set; } = null!;
    public decimal UkupnaCijena { get; set; }
    public int BrojStavki { get; set; }
}

public class NarudzbaDetaljDto
{
    public int Id { get; set; }
    public DateTime DatumKreiranja { get; set; }
    public string StatusNaziv { get; set; } = null!;
    public string NacinPredaje { get; set; } = null!;
    public string NacinPredajeNaziv { get; set; } = null!;
    public decimal UkupnaCijena { get; set; }
    public string? Napomena { get; set; }
    public string? AdresaPreuzimanja { get; set; }
    public DateTime? RokZavrsetka { get; set; }
    public IReadOnlyList<StavkaPregledDto> Stavke { get; set; } = [];
}

public class StavkaPregledDto
{
    public int Id { get; set; }
    public string ArtikalNaziv { get; set; } = null!;
    public string Kategorija { get; set; } = null!;
    public decimal Kolicina { get; set; }
    public decimal CijenaJedinicna { get; set; }
    public decimal Ukupno { get; set; }
    public string? Napomena { get; set; }
    public IReadOnlyList<StavkaUslugaPregledDto> Usluge { get; set; } = [];
}

public class StavkaUslugaPregledDto
{
    public string UslugaNaziv { get; set; } = null!;
    public decimal Cijena { get; set; }
}
