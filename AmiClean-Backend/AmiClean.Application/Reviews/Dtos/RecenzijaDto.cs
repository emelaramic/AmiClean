namespace AmiClean.Application.Reviews.Dtos;

public class RecenzijaDto
{
    public int Id { get; set; }
    public int NarudzbaId { get; set; }
    public int Ocjena { get; set; }
    public string? Komentar { get; set; }
    public DateTime DatumObjave { get; set; }
}

public class KreirajRecenzijuRequest
{
    public int KorisnikId { get; set; }
    public int NarudzbaId { get; set; }
    public int Ocjena { get; set; }
    public string? Komentar { get; set; }
}
