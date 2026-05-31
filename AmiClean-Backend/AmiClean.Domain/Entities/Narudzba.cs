namespace AmiClean.Domain.Entities;

public class Narudzba
{
    public int ID_Narudzbe { get; set; }
    public int FK_Korisnik { get; set; }
    public int? FK_Kupon { get; set; }
    public int? FK_Primio_Zaposlenik { get; set; }
    public int FK_Status { get; set; }
    public string Kanal { get; set; } = null!;
    public string Nacin_Zavrsetka { get; set; } = null!;
    public DateTime Datum_Prijema { get; set; }
    public DateTime? Rok_Zavrsetka { get; set; }
    public DateTime? Datum_Zavrsetka { get; set; }
    public DateTime? Datum_Preuzimanja { get; set; }
    public decimal Ukupna_Cijena { get; set; }
    public decimal Popust_Iznos { get; set; }
    public string? Napomena { get; set; }

    public virtual Korisnik Korisnik { get; set; } = null!;
    public virtual Kupon? Kupon { get; set; }
    public virtual Zaposlenik? PrimioZaposlenik { get; set; }
    public virtual StatusNarudzbe Status { get; set; } = null!;
    public virtual ICollection<StavkaNarudzbe> Stavke { get; set; } = new List<StavkaNarudzbe>();
    public virtual ICollection<Placanje> Placanja { get; set; } = new List<Placanje>();
    public virtual ICollection<Logistika> Logistike { get; set; } = new List<Logistika>();
    public virtual ICollection<Notifikacija> Notifikacije { get; set; } = new List<Notifikacija>();
    public virtual Recenzija? Recenzija { get; set; }
}
