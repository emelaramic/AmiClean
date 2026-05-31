namespace AmiClean.Domain.Entities;

public class Korisnik
{
    public int ID_Korisnika { get; set; }
    public string Ime { get; set; } = null!;
    public string Prezime { get; set; } = null!;
    public string? Email { get; set; }
    public string Lozinka_Hash { get; set; } = null!;
    public string? Broj_Telefona { get; set; }
    public string? Adresa_Stanovanja { get; set; }
    public bool Aktivan { get; set; } = true;

    public virtual ICollection<Narudzba> Narudzbe { get; set; } = new List<Narudzba>();
    public virtual ICollection<Notifikacija> Notifikacije { get; set; } = new List<Notifikacija>();
    public virtual ICollection<Recenzija> Recenzije { get; set; } = new List<Recenzija>();
}
