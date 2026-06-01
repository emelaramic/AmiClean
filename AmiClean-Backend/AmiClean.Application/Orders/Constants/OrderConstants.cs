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
}

public static class StavkaStatusi
{
    public const string Kreirana = "Kreirana";
}

public static class LogistikaTipovi
{
    public const string Preuzimanje = "Preuzimanje";
}

public static class LogistikaStatusi
{
    public const string Zakazano = "Zakazano";
}

public static class NacinZavrsetkaVrijednosti
{
    public const string PreuzimanjeURadnji = "PreuzimanjeURadnji";
    public const string Dostava = "Dostava";
}
