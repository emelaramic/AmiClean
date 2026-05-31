namespace AmiClean.Domain.Entities;

public class StatusPlacanja
{
    public int ID_Statusa { get; set; }
    public string Naziv { get; set; } = null!;

    public virtual ICollection<Placanje> Placanja { get; set; } = new List<Placanje>();
}
