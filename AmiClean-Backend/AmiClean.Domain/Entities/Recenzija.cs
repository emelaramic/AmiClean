namespace AmiClean.Domain.Entities;

public class Recenzija
{
    public int ID_Recenzije { get; set; }
    public int FK_Korisnik { get; set; }
    public int FK_Narudzba { get; set; }
    public int Ocjena { get; set; }
    public string? Komentar { get; set; }
    public DateTime Datum_Objave { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;
    public virtual Narudzba Narudzba { get; set; } = null!;
}
