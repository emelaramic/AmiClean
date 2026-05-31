using System.ComponentModel.DataAnnotations;

namespace AmiClean.Application.Auth.Dtos;

public class PrijavaKorisnikaRequest
{
    [Required(ErrorMessage = "Email je obavezan.")]
    [EmailAddress(ErrorMessage = "Email nije ispravan.")]
    public string Email { get; set; } = null!;

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [MinLength(6, ErrorMessage = "Lozinka mora imati najmanje 6 znakova.")]
    public string Lozinka { get; set; } = null!;
}
