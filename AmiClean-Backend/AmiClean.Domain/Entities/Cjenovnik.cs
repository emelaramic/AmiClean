using System.ComponentModel.DataAnnotations.Schema;

namespace AmiClean.Domain.Entities;

public class Cjenovnik
{
    [Column("ID_Cjenika")]
    public int ID_Cjenovnika { get; set; }

    public int FK_Artikal { get; set; }
    public int FK_Usluga { get; set; }
    public decimal Cijena { get; set; }
    public decimal? Cijena_Max { get; set; }
    public DateOnly Vazi_Od { get; set; }
    public DateOnly? Vazi_Do { get; set; }

    public virtual Artikal Artikal { get; set; } = null!;
    public virtual Usluga Usluga { get; set; } = null!;
}
