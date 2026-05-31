using System.ComponentModel.DataAnnotations;

namespace AmiClean.Application.Auth.Dtos;

public class PrijavaZaposlenikaRequest
{
    [Required(ErrorMessage = "Korisničko ime je obavezno.")]
    public string Korisnicko_Ime { get; set; } = null!;

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [MinLength(6, ErrorMessage = "Lozinka mora imati najmanje 6 znakova.")]
    public string Lozinka { get; set; } = null!;
}
