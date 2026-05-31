namespace AmiClean.Domain.Entities;

public class Kupon
{
    public int ID_Kupona { get; set; }
    public string Kod { get; set; } = null!;
    public decimal Postotak_Popusta { get; set; }
    public DateOnly Datum_Isteka { get; set; }
    public decimal? Min_Iznos_Narudzbe { get; set; }
    public int? Max_Broj_Koristenja { get; set; }
    public bool Aktivan { get; set; } = true;

    public virtual ICollection<Narudzba> Narudzbe { get; set; } = new List<Narudzba>();
}
