namespace AmiClean.Domain.Entities;

public class StavkaUsluga
{
    public int ID { get; set; }
    public int FK_Stavka { get; set; }
    public int FK_Usluga { get; set; }
    public decimal Cijena_Usluge { get; set; }

    public virtual StavkaNarudzbe Stavka { get; set; } = null!;
    public virtual Usluga Usluga { get; set; } = null!;
}
