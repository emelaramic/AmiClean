using AmiClean.Application.Auth.Constants;
using AmiClean.Application.Auth.Dtos;
using AmiClean.Application.Auth.Interfaces;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Auth;

public class AuthService : IAuthService
{
    private readonly AmiCleanContext _context;
    private readonly IPasswordHasher _passwordHasher;

    public AuthService(AmiCleanContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public async Task<PrijavaResponse?> PrijavaKorisnikaAsync(
        PrijavaKorisnikaRequest request,
        CancellationToken cancellationToken = default)
    {
        var normalizedEmail = request.Email.Trim().ToLowerInvariant();

        var korisnik = await _context.Korisnici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                k => k.Email != null && k.Email.ToLower() == normalizedEmail,
                cancellationToken);

        if (korisnik is null || !korisnik.Aktivan)
            return null;

        if (!_passwordHasher.Verify(request.Lozinka, korisnik.Lozinka_Hash))
            return null;

        return new PrijavaResponse
        {
            Id = korisnik.ID_Korisnika,
            Ime = korisnik.Ime,
            Prezime = korisnik.Prezime,
            Uloga = AuthUloge.Korisnik,
            Email = korisnik.Email,
        };
    }

    public async Task<PrijavaResponse?> PrijavaZaposlenikaAsync(
        PrijavaZaposlenikaRequest request,
        CancellationToken cancellationToken = default)
    {
        var normalizedUsername = request.Korisnicko_Ime.Trim().ToLowerInvariant();

        var zaposlenik = await _context.Zaposlenici
            .AsNoTracking()
            .FirstOrDefaultAsync(
                z => z.Korisnicko_Ime.ToLower() == normalizedUsername,
                cancellationToken);

        if (zaposlenik is null || !zaposlenik.Aktivan)
            return null;

        if (!_passwordHasher.Verify(request.Lozinka, zaposlenik.Lozinka_Hash))
            return null;

        return new PrijavaResponse
        {
            Id = zaposlenik.ID_Zaposlenika,
            Ime = zaposlenik.Ime,
            Prezime = zaposlenik.Prezime,
            Uloga = AuthUloge.Admin,
            Korisnicko_Ime = zaposlenik.Korisnicko_Ime,
            Uloga_Zaposlenika = zaposlenik.Uloga,
        };
    }
}
