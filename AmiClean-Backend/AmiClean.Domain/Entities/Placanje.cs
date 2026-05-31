namespace AmiClean.Domain.Entities;

public class Placanje
{
    public int ID_Placanja { get; set; }
    public int FK_Narudzba { get; set; }
    public int FK_Status { get; set; }
    public string Metoda { get; set; } = null!;
    public decimal Iznos { get; set; }
    public DateTime Datum_Uplate { get; set; }

    public virtual Narudzba Narudzba { get; set; } = null!;
    public virtual StatusPlacanja Status { get; set; } = null!;
}
