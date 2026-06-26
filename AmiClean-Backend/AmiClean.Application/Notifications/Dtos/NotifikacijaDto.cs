namespace AmiClean.Application.Notifications.Dtos;

public class NotifikacijaDto
{
    public int Id { get; set; }
    public int? NarudzbaId { get; set; }
    public string Naslov { get; set; } = null!;
    public string Poruka { get; set; } = null!;
    public DateTime DatumSlanja { get; set; }
    public bool Procitano { get; set; }
}

public class BrojNeprocitanihDto
{
    public int Broj { get; set; }
}
