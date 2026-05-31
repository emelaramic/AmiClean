namespace AmiClean.Application.Catalog.Constants;

public static class ArtikalKategorije
{
    public const string Odjeća = "Odjeća";
    public const string Posteljina = "Posteljina";
    public const string Namještaj = "Namještaj";
    public const string Tepisi = "Tepisi";

    public static readonly IReadOnlyList<string> Sve =
    [
        Odjeća,
        Posteljina,
        Namještaj,
        Tepisi,
    ];
}
