namespace AmiClean.Domain.Entities;

public class Artikal
{
    public int ID_Artikla { get; set; }
    public string Naziv { get; set; } = null!;
    public string? Opis { get; set; }
    public string Kategorija { get; set; } = null!;
    public bool Aktivan { get; set; } = true;

    public virtual ICollection<Cjenovnik> Cjenovnici { get; set; } = new List<Cjenovnik>();
    public virtual ICollection<StavkaNarudzbe> Stavke { get; set; } = new List<StavkaNarudzbe>();
}
