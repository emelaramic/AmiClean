namespace AmiClean.Domain.Entities;

public class StatusStavke
{
    public int ID_Statusa { get; set; }
    public string Naziv { get; set; } = null!;

    public virtual ICollection<StavkaNarudzbe> Stavke { get; set; } = new List<StavkaNarudzbe>();
}
