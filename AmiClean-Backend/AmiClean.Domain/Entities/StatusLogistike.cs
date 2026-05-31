namespace AmiClean.Domain.Entities;

public class StatusLogistike
{
    public int ID_Statusa { get; set; }
    public string Naziv { get; set; } = null!;

    public virtual ICollection<Logistika> Logistike { get; set; } = new List<Logistika>();
}
