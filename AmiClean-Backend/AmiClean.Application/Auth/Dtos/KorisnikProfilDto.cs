namespace AmiClean.Application.Auth.Dtos;

public class KorisnikProfilDto
{
    public int Id { get; set; }
    public string Ime { get; set; } = null!;
    public string Prezime { get; set; } = null!;
    public string? Email { get; set; }
    public string? BrojTelefona { get; set; }
    public string? AdresaStanovanja { get; set; }
}
