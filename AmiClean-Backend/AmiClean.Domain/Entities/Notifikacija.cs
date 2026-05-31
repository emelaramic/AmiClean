namespace AmiClean.Domain.Entities;

public class Notifikacija
{
    public int ID_Notifikacije { get; set; }
    public int FK_Korisnik { get; set; }
    public int? FK_Narudzba { get; set; }
    public string Kanal { get; set; } = null!;
    public string Naslov { get; set; } = null!;
    public string Poruka { get; set; } = null!;
    public DateTime Datum_Slanja { get; set; }
    public string Status_Slanja { get; set; } = "Na_cekanju";
    public bool Procitano { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;
    public virtual Narudzba? Narudzba { get; set; }
}
