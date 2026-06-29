namespace AmiClean.Application.Orders.Constants;

public static class NacinPredajeVrijednosti
{
    public const string DonosUCistionicu = "DonosUCistionicu";
    public const string PreuzimanjeIDostava = "PreuzimanjeIDostava";

    public static readonly IReadOnlySet<string> Sve = new HashSet<string>
    {
        DonosUCistionicu,
        PreuzimanjeIDostava,
    };
}

public static class NarudzbaKanali
{
    public const string Aplikacija = "Aplikacija";
}

public static class NarudzbaStatusi
{
    public const string Kreirana = "Kreirana";
    public const string Primljena = "Primljena";
    public const string UObradi = "U obradi";
    public const string DjelomicnoGotova = "Djelomicno gotova";
    public const string Gotova = "Gotova";
    public const string Preuzeta = "Preuzeta";
    public const string Otkazana = "Otkazana";
}

public static class StavkaStatusi
{
    public const string Kreirana = "Kreirana";
    public const string Primljena = "Primljena";
    public const string UObradi = "U obradi";
    public const string Gotova = "Gotova";
    public const string Isporucena = "Isporucena";
}

public static class NarudzbaAdminAkcije
{
    public const string Primijeni = "Primijeni";
    public const string PromijeniStatus = "PromijeniStatus";
    public const string PromijeniRok = "PromijeniRok";
    public const string Otkazi = "Otkazi";
}

public static class NarudzbaStatusPrijelazi
{
    private static readonly IReadOnlyDictionary<string, string> Sljedeci = new Dictionary<string, string>
    {
        [NarudzbaStatusi.Primljena] = NarudzbaStatusi.UObradi,
        [NarudzbaStatusi.UObradi] = NarudzbaStatusi.Gotova,
        [NarudzbaStatusi.Gotova] = NarudzbaStatusi.Preuzeta,
    };

    private static readonly IReadOnlyDictionary<string, string> StavkaZaNarudzbu = new Dictionary<string, string>
    {
        [NarudzbaStatusi.Primljena] = StavkaStatusi.Primljena,
        [NarudzbaStatusi.UObradi] = StavkaStatusi.UObradi,
        [NarudzbaStatusi.Gotova] = StavkaStatusi.Gotova,
        [NarudzbaStatusi.Preuzeta] = StavkaStatusi.Isporucena,
    };

    public static string? GetSljedeci(string trenutniStatus) =>
        Sljedeci.TryGetValue(trenutniStatus, out var sljedeci) ? sljedeci : null;

    public static bool JeDozvoljenPrijelaz(string trenutniStatus, string noviStatus) =>
        GetSljedeci(trenutniStatus) == noviStatus;

    public static bool MozeSeOtkazati(string trenutniStatus) =>
        trenutniStatus == NarudzbaStatusi.Kreirana;

    public static string? GetStavkaStatusZaNarudzbu(string statusNarudzbe) =>
        StavkaZaNarudzbu.TryGetValue(statusNarudzbe, out var status) ? status : null;

    public static string GetPorukaPromjene(string noviStatus) => noviStatus switch
    {
        NarudzbaStatusi.Primljena => "Narudžba je primljena u čistionici.",
        NarudzbaStatusi.UObradi => "Narudžba je označena kao u obradi.",
        NarudzbaStatusi.Gotova => "Narudžba je gotova za preuzimanje ili dostavu.",
        NarudzbaStatusi.Preuzeta => "Narudžba je označena kao preuzeta.",
        NarudzbaStatusi.Otkazana => "Narudžba je otkazana.",
        _ => $"Status narudžbe je promijenjen u '{noviStatus}'.",
    };

    public static string GetLabelAkcije(string sljedeciStatus) => sljedeciStatus switch
    {
        NarudzbaStatusi.UObradi => "Označi u obradi",
        NarudzbaStatusi.Gotova => "Označi gotovom",
        NarudzbaStatusi.Preuzeta => "Označi preuzetom",
        _ => $"Promijeni u '{sljedeciStatus}'",
    };
}

public static class LogistikaTipovi
{
    public const string Preuzimanje = "Preuzimanje";
}

public static class LogistikaStatusi
{
    public const string Zakazano = "Zakazano";
    public const string UToku = "U toku";
    public const string Zavrseno = "Zavrseno";
    public const string Otkazano = "Otkazano";
}

public static class NacinZavrsetkaVrijednosti
{
    public const string PreuzimanjeURadnji = "PreuzimanjeURadnji";
    public const string Dostava = "Dostava";
}

public static class NacinPredajeNazivi
{
    public static string ZaPrikaz(string nacinPredaje) => nacinPredaje switch
    {
        NacinPredajeVrijednosti.DonosUCistionicu => "Donijet ću u čistionicu",
        NacinPredajeVrijednosti.PreuzimanjeIDostava => "Preuzimanje i dostava",
        _ => nacinPredaje,
    };
}
