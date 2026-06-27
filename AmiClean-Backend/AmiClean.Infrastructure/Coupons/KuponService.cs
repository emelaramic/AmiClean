using AmiClean.Application.Coupons;
using AmiClean.Application.Coupons.Dtos;
using AmiClean.Application.Coupons.Interfaces;
using AmiClean.Application.Orders.Constants;
using AmiClean.Domain.Entities;
using AmiClean.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AmiClean.Infrastructure.Coupons;

public class KuponService : IKuponService
{
    private readonly AmiCleanContext _context;

    public KuponService(AmiCleanContext context)
    {
        _context = context;
    }

    public async Task<KuponProvjeraDto> ProvjeriAsync(
        string kod,
        decimal ukupnaCijena,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var rezultat = await RijesiInternoAsync(kod, ukupnaCijena, cancellationToken);
            return new KuponProvjeraDto
            {
                Vazeci = true,
                Kod = rezultat.Kupon.Kod,
                PostotakPopusta = rezultat.Kupon.Postotak_Popusta,
                PopustIznos = rezultat.PopustIznos,
                UkupnoNakonPopusta = ukupnaCijena - rezultat.PopustIznos,
                Poruka = $"Kupon primijenjen: -{rezultat.PopustIznos:0.00} KM ({rezultat.Kupon.Postotak_Popusta:0.#}%).",
            };
        }
        catch (KuponValidationException ex)
        {
            return new KuponProvjeraDto
            {
                Vazeci = false,
                Poruka = ex.Message,
            };
        }
    }

    public async Task<KuponPrimjenaRezultat> RijesiZaNarudzbuAsync(
        string kod,
        decimal ukupnaCijena,
        CancellationToken cancellationToken = default)
    {
        return await RijesiInternoAsync(kod, ukupnaCijena, cancellationToken);
    }

    private async Task<KuponPrimjenaRezultat> RijesiInternoAsync(
        string kod,
        decimal ukupnaCijena,
        CancellationToken cancellationToken)
    {
        if (ukupnaCijena <= 0)
            throw new KuponValidationException("Narudžba mora imati pozitivan iznos za primjenu kupona.");

        var normaliziranKod = NormalizirajKod(kod);
        if (normaliziranKod.Length == 0)
            throw new KuponValidationException("Unesite kod kupona.");

        var kupon = await _context.Kuponi
            .FirstOrDefaultAsync(k => k.Kod == normaliziranKod, cancellationToken)
            ?? throw new KuponValidationException("Kupon nije pronađen.");

        if (!kupon.Aktivan)
            throw new KuponValidationException("Kupon nije aktivan.");

        if (kupon.Datum_Isteka < DateOnly.FromDateTime(DateTime.Today))
            throw new KuponValidationException("Kupon je istekao.");

        if (kupon.Min_Iznos_Narudzbe.HasValue && ukupnaCijena < kupon.Min_Iznos_Narudzbe.Value)
        {
            throw new KuponValidationException(
                $"Minimalni iznos narudžbe za ovaj kupon je {kupon.Min_Iznos_Narudzbe.Value:0.00} KM.");
        }

        if (kupon.Max_Broj_Koristenja.HasValue)
        {
            var brojKoristenja = await _context.Narudzbe
                .AsNoTracking()
                .CountAsync(
                    n => n.FK_Kupon == kupon.ID_Kupona &&
                         n.Status.Naziv != NarudzbaStatusi.Otkazana,
                    cancellationToken);

            if (brojKoristenja >= kupon.Max_Broj_Koristenja.Value)
            {
                throw new KuponValidationException("Kupon je iskorišten maksimalan broj puta.");
            }
        }

        var popustIznos = IzracunajPopust(ukupnaCijena, kupon.Postotak_Popusta);

        return new KuponPrimjenaRezultat
        {
            Kupon = kupon,
            PopustIznos = popustIznos,
        };
    }

    internal static decimal IzracunajPopust(decimal ukupnaCijena, decimal postotakPopusta)
    {
        if (postotakPopusta <= 0)
            return 0;

        var popust = Math.Round(
            ukupnaCijena * postotakPopusta / 100m,
            2,
            MidpointRounding.AwayFromZero);

        return popust > ukupnaCijena ? ukupnaCijena : popust;
    }

    internal static string NormalizirajKod(string kod) =>
        kod.Trim().ToUpperInvariant();
}
