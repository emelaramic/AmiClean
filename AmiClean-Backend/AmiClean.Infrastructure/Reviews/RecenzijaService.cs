using AmiClean.Application.Orders.Constants;
using AmiClean.Application.Reviews;
using AmiClean.Application.Reviews.Dtos;
using AmiClean.Application.Reviews.Interfaces;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Reviews;

public class RecenzijaService : IRecenzijaService
{
    private const int MinOcjena = 1;
    private const int MaxOcjena = 5;
    private const int MaxKomentarDuzina = 1000;

    private readonly AmiCleanContext _context;

    public RecenzijaService(AmiCleanContext context)
    {
        _context = context;
    }

    public async Task<RecenzijaDto> KreirajRecenzijuAsync(
        KreirajRecenzijuRequest request,
        CancellationToken cancellationToken = default)
    {
        ValidirajZahtjev(request);

        var narudzba = await _context.Narudzbe
            .Include(n => n.Status)
            .Include(n => n.Recenzija)
            .FirstOrDefaultAsync(
                n => n.ID_Narudzbe == request.NarudzbaId && n.FK_Korisnik == request.KorisnikId,
                cancellationToken)
            ?? throw new RecenzijaValidationException("Narudžba nije pronađena.");

        if (narudzba.Status.Naziv != NarudzbaStatusi.Preuzeta)
        {
            throw new RecenzijaValidationException(
                "Recenziju možete ostaviti tek nakon što je narudžba preuzeta.");
        }

        if (narudzba.Recenzija != null)
        {
            throw new RecenzijaValidationException(
                "Za ovu narudžbu je recenzija već ostavljena.");
        }

        var komentar = string.IsNullOrWhiteSpace(request.Komentar)
            ? null
            : request.Komentar.Trim();

        var recenzija = new Recenzija
        {
            FK_Korisnik = request.KorisnikId,
            FK_Narudzba = request.NarudzbaId,
            Ocjena = request.Ocjena,
            Komentar = komentar,
            Datum_Objave = DateTime.Now,
        };

        _context.Recenzije.Add(recenzija);
        await _context.SaveChangesAsync(cancellationToken);

        return ToDto(recenzija);
    }

    internal static RecenzijaDto? MapDto(Recenzija? recenzija) =>
        recenzija == null ? null : ToDto(recenzija);

    private static RecenzijaDto ToDto(Recenzija recenzija) => new()
    {
        Id = recenzija.ID_Recenzije,
        NarudzbaId = recenzija.FK_Narudzba,
        Ocjena = recenzija.Ocjena,
        Komentar = recenzija.Komentar,
        DatumObjave = recenzija.Datum_Objave,
    };

    private static void ValidirajZahtjev(KreirajRecenzijuRequest request)
    {
        if (request.KorisnikId <= 0 || request.NarudzbaId <= 0)
            throw new RecenzijaValidationException("Identifikatori nisu ispravni.");

        if (request.Ocjena < MinOcjena || request.Ocjena > MaxOcjena)
        {
            throw new RecenzijaValidationException(
                $"Ocjena mora biti između {MinOcjena} i {MaxOcjena}.");
        }

        if (request.Komentar != null && request.Komentar.Trim().Length > MaxKomentarDuzina)
        {
            throw new RecenzijaValidationException(
                $"Komentar ne smije biti duži od {MaxKomentarDuzina} znakova.");
        }
    }
}
