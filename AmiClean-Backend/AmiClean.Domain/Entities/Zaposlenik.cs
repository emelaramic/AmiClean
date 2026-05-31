namespace AmiClean.Domain.Entities;

public class Zaposlenik
{
    public int ID_Zaposlenika { get; set; }
    public string Ime { get; set; } = null!;
    public string Prezime { get; set; } = null!;
    public string Uloga { get; set; } = null!;
    public string Korisnicko_Ime { get; set; } = null!;
    public string Lozinka_Hash { get; set; } = null!;
    public bool Aktivan { get; set; } = true;

    public virtual ICollection<Narudzba> NarudzbePrimljene { get; set; } = new List<Narudzba>();
    public virtual ICollection<Logistika> Logistike { get; set; } = new List<Logistika>();
}
