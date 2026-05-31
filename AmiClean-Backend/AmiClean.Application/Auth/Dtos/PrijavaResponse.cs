namespace AmiClean.Application.Auth.Dtos;

public class PrijavaResponse
{
    public int Id { get; set; }
    public string Ime { get; set; } = null!;
    public string Prezime { get; set; } = null!;
    public string Uloga { get; set; } = null!;
    public string? Email { get; set; }
    public string? Korisnicko_Ime { get; set; }
    public string? Uloga_Zaposlenika { get; set; }
}
