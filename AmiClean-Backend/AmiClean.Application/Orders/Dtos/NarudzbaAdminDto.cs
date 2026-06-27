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
    public IReadOnlyList<NarudzbaAdminAkcijaDto> DozvoljeneAkcije { get; set; } = [];
}

public class NarudzbaAdminAkcijaDto
{
    public string Tip { get; set; } = null!;
    public string Label { get; set; } = null!;
    public string? SljedeciStatusNaziv { get; set; }
    public bool ZahtijevaRokZavrsetka { get; set; }
}

public class PrimijeniNarudzbuRequest
{
    public int NarudzbaId { get; set; }
    public int ZaposlenikId { get; set; }
}

public class PromijeniStatusNarudzbeRequest
{
    public int NarudzbaId { get; set; }
    public int ZaposlenikId { get; set; }
    public string NoviStatusNaziv { get; set; } = null!;
    public DateTime? RokZavrsetka { get; set; }
}

public class PromijeniRokZavrsetkaRequest
{
    public int NarudzbaId { get; set; }
    public int ZaposlenikId { get; set; }
    public DateTime RokZavrsetka { get; set; }
}

public class OtkaziNarudzbuRequest
{
    public int NarudzbaId { get; set; }
    public int? KorisnikId { get; set; }
    public int? ZaposlenikId { get; set; }
}

public class NarudzbaStatusPromjenaDto
{
    public int Id { get; set; }
    public string StatusNaziv { get; set; } = null!;
    public DateTime? RokZavrsetka { get; set; }
    public string Poruka { get; set; } = null!;
}

public class StatusBrojDto
{
    public string StatusNaziv { get; set; } = null!;
    public int Broj { get; set; }
}

public class BrojNarudzbiPoStatusuDto
{
    public int Ukupno { get; set; }
    public int Aktivne { get; set; }
    public IReadOnlyList<StatusBrojDto> PoStatusu { get; set; } = [];
}
