namespace AmiClean.Domain.Entities;

public class Logistika
{
    public int ID_Logistike { get; set; }
    public int FK_Narudzba { get; set; }
    public int? FK_Vozac { get; set; }
    public int FK_Status { get; set; }
    public string Tip { get; set; } = null!;
    public string Adresa { get; set; } = null!;
    public DateTime? Planirano_Vrijeme { get; set; }
    public DateTime? Stvarno_Vrijeme { get; set; }

    public virtual Narudzba Narudzba { get; set; } = null!;
    public virtual Zaposlenik? Vozac { get; set; }
    public virtual StatusLogistike Status { get; set; } = null!;
}
