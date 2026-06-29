namespace AmiClean.Application.Orders;

public static class BrojOznakeGenerator
{
    public const string QrScheme = "amiclean://stavka/";

    public static string Generisi(int narudzbaId, int redniBrojStavke)
    {
        if (narudzbaId <= 0 || redniBrojStavke <= 0)
            throw new ArgumentOutOfRangeException(nameof(redniBrojStavke));

        return $"AC-{DateTime.Now.Year}-{narudzbaId:D4}-{redniBrojStavke:D2}";
    }

    public static string ZaQr(string brojOznake) => $"{QrScheme}{brojOznake}";

    /// <summary>Iz QR sadržaja ili ručnog unosa izvlači broj oznake (npr. AC-2026-0001-01).</summary>
    public static string ParsirajUnos(string unos)
    {
        if (string.IsNullOrWhiteSpace(unos))
            throw new ArgumentException("Unesite broj oznake ili skenirajte QR kod.", nameof(unos));

        var trimmed = unos.Trim();

        if (trimmed.StartsWith(QrScheme, StringComparison.OrdinalIgnoreCase))
            return trimmed[QrScheme.Length..].Trim();

        return trimmed;
    }
}
