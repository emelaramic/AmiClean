namespace AmiClean.Domain.Entities;

public class StavkaNarudzbe
{
    public int ID_Stavke { get; set; }
    public int FK_Narudzba { get; set; }
    public int FK_Artikal { get; set; }
    public int FK_Status { get; set; }
    public decimal Kolicina { get; set; } = 1;
    public string? Broj_Oznake { get; set; }
    public string? Materijal { get; set; }
    public string? Boja { get; set; }
    public string? Napomena { get; set; }
    public decimal Cijena_Jedinicna { get; set; }

    public virtual Narudzba Narudzba { get; set; } = null!;
    public virtual Artikal Artikal { get; set; } = null!;
    public virtual StatusStavke Status { get; set; } = null!;
    public virtual ICollection<StavkaUsluga> Usluge { get; set; } = new List<StavkaUsluga>();
}
