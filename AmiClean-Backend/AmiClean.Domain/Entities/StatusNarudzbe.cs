namespace AmiClean.Domain.Entities;

public class StatusNarudzbe
{
    public int ID_Statusa { get; set; }
    public string Naziv { get; set; } = null!;
    public int Redoslijed { get; set; }

    public virtual ICollection<Narudzba> Narudzbe { get; set; } = new List<Narudzba>();
}
