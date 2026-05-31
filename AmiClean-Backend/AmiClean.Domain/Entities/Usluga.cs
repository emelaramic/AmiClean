namespace AmiClean.Domain.Entities;

public class Usluga
{
    public int ID_Usluge { get; set; }
    public string Naziv { get; set; } = null!;
    public string? Opis { get; set; }
    public bool Aktivan { get; set; } = true;

    public virtual ICollection<Cjenovnik> Cjenovnici { get; set; } = new List<Cjenovnik>();
    public virtual ICollection<StavkaUsluga> StavkeUsluge { get; set; } = new List<StavkaUsluga>();
}
