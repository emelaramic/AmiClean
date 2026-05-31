-- AmiClean katalog cijena (normalizirano: Artikal + Usluga + Cjenovnik)
-- Pokreni u SSMS (preporučeno) ili: sqlcmd -S localhost\SQLEXPRESS -E -C -f 65001 -i SeedKatalog.sql

USE AmiCleanDb;
GO

IF COL_LENGTH('Cjenovnik', 'Cijena_Max') IS NULL
BEGIN
    ALTER TABLE Cjenovnik ADD Cijena_Max DECIMAL(10,2) NULL;
END
GO

IF COL_LENGTH('Artikal', 'Kategorija') IS NULL
BEGIN
    ALTER TABLE Artikal ADD Kategorija NVARCHAR(50) NOT NULL DEFAULT N'Odjeća';
END
GO

-- Potpuni reset kataloga (sigurno dok nema stavki narudžbi)
DELETE FROM Cjenovnik;
DELETE FROM Artikal;
DELETE FROM Usluga;
GO

INSERT INTO Usluga (Naziv, Aktivan) VALUES
    (N'Hemijsko čišćenje', 1),
    (N'Pranje', 1),
    (N'Peglanje', 1),
    (N'Dubinsko čišćenje', 1);
GO

INSERT INTO Artikal (Naziv, Opis, Kategorija, Aktivan) VALUES
    (N'Odijelo', NULL, N'Odjeća', 1),
    (N'Sako', NULL, N'Odjeća', 1),
    (N'Hlače', NULL, N'Odjeća', 1),
    (N'Kaput', NULL, N'Odjeća', 1),
    (N'Haljina', NULL, N'Odjeća', 1),
    (N'Jakna (tanka)', NULL, N'Odjeća', 1),
    (N'Jakna (debela)', NULL, N'Odjeća', 1),
    (N'Košulja', NULL, N'Odjeća', 1),
    (N'Džemper', NULL, N'Odjeća', 1),
    (N'Vjenčanica', NULL, N'Odjeća', 1),
    (N'Deka (mala)', NULL, N'Posteljina', 1),
    (N'Deka (velika)', NULL, N'Posteljina', 1),
    (N'Jorgan (mali)', NULL, N'Posteljina', 1),
    (N'Jorgan (veliki)', NULL, N'Posteljina', 1),
    (N'Jorgan (vuna/perje)', NULL, N'Posteljina', 1),
    (N'Jastuk', NULL, N'Posteljina', 1),
    (N'Nadmadrac (mali)', NULL, N'Namještaj', 1),
    (N'Nadmadrac (veliki)', NULL, N'Namještaj', 1),
    (N'Madrac (mali)', NULL, N'Namještaj', 1),
    (N'Madrac (veliki)', NULL, N'Namještaj', 1),
    (N'Stolica', NULL, N'Namještaj', 1),
    (N'Fotelja', NULL, N'Namještaj', 1),
    (N'Dvosjed', NULL, N'Namještaj', 1),
    (N'Trosjed', NULL, N'Namještaj', 1),
    (N'Ugao', NULL, N'Namještaj', 1),
    (N'Auto sicevi', NULL, N'Namještaj', 1),
    (N'Tepih (etison) - 1m²', N'Cijena po m²', N'Tepisi', 1),
    (N'Tepih (sintetički - do 1 cm debljine) - 1m²', N'Cijena po m²', N'Tepisi', 1),
    (N'Tepih (sintetički - deblji od 1 cm) - 1m²', N'Cijena po m²', N'Tepisi', 1),
    (N'Tepih (vuna) - 1m²', N'Cijena po m²', N'Tepisi', 1);
GO

DECLARE @Danas DATE = CAST(GETDATE() AS DATE);

INSERT INTO Cjenovnik (FK_Artikal, FK_Usluga, Cijena, Cijena_Max, Vazi_Od)
SELECT a.ID_Artikla, u.ID_Usluge, s.Cijena, s.CijenaMax, @Danas
FROM (VALUES
    -- Odjeća
    (N'Odijelo', N'Hemijsko čišćenje', 23.00, NULL),
    (N'Odijelo', N'Peglanje', 10.00, NULL),
    (N'Sako', N'Hemijsko čišćenje', 12.00, NULL),
    (N'Sako', N'Peglanje', 5.00, NULL),
    (N'Hlače', N'Hemijsko čišćenje', 9.00, NULL),
    (N'Hlače', N'Pranje', 6.00, NULL),
    (N'Hlače', N'Peglanje', 4.00, NULL),
    (N'Kaput', N'Hemijsko čišćenje', 20.00, NULL),
    (N'Kaput', N'Peglanje', 10.00, NULL),
    (N'Haljina', N'Hemijsko čišćenje', 16.00, NULL),
    (N'Haljina', N'Pranje', 10.00, NULL),
    (N'Haljina', N'Peglanje', 5.00, NULL),
    (N'Jakna (tanka)', N'Hemijsko čišćenje', 16.00, NULL),
    (N'Jakna (tanka)', N'Pranje', 10.00, NULL),
    (N'Jakna (tanka)', N'Peglanje', 5.00, NULL),
    (N'Jakna (debela)', N'Hemijsko čišćenje', 20.00, NULL),
    (N'Jakna (debela)', N'Pranje', 13.00, NULL),
    (N'Košulja', N'Hemijsko čišćenje', 7.00, NULL),
    (N'Košulja', N'Pranje', 5.00, NULL),
    (N'Košulja', N'Peglanje', 2.00, NULL),
    (N'Džemper', N'Hemijsko čišćenje', 5.00, NULL),
    (N'Džemper', N'Pranje', 3.00, NULL),
    (N'Džemper', N'Peglanje', 2.00, NULL),
    (N'Vjenčanica', N'Hemijsko čišćenje', 35.00, NULL),
    (N'Vjenčanica', N'Pranje', 25.00, NULL),
    (N'Vjenčanica', N'Peglanje', 15.00, NULL),
    -- Posteljina
    (N'Deka (mala)', N'Pranje', 10.00, NULL),
    (N'Deka (velika)', N'Pranje', 15.00, NULL),
    (N'Jorgan (mali)', N'Pranje', 12.00, NULL),
    (N'Jorgan (veliki)', N'Pranje', 18.00, NULL),
    (N'Jorgan (vuna/perje)', N'Pranje', 20.00, NULL),
    (N'Jastuk', N'Pranje', 5.00, NULL),
    -- Dubinsko — namještaj i madraci
    (N'Nadmadrac (mali)', N'Dubinsko čišćenje', 16.00, NULL),
    (N'Nadmadrac (veliki)', N'Dubinsko čišćenje', 24.00, NULL),
    (N'Madrac (mali)', N'Dubinsko čišćenje', 20.00, NULL),
    (N'Madrac (veliki)', N'Dubinsko čišćenje', 30.00, NULL),
    (N'Stolica', N'Dubinsko čišćenje', 5.00, NULL),
    (N'Fotelja', N'Dubinsko čišćenje', 15.00, NULL),
    (N'Dvosjed', N'Dubinsko čišćenje', 25.00, NULL),
    (N'Trosjed', N'Dubinsko čišćenje', 35.00, NULL),
    (N'Ugao', N'Dubinsko čišćenje', 60.00, 90.00),
    (N'Auto sicevi', N'Dubinsko čišćenje', 30.00, NULL),
    -- Tepisi (cijena po m²)
    (N'Tepih (etison) - 1m²', N'Pranje', 2.70, NULL),
    (N'Tepih (sintetički - do 1 cm debljine) - 1m²', N'Pranje', 3.20, NULL),
    (N'Tepih (sintetički - deblji od 1 cm) - 1m²', N'Pranje', 3.60, NULL),
    (N'Tepih (vuna) - 1m²', N'Pranje', 3.90, NULL)
) AS s(Artikal, Usluga, Cijena, CijenaMax)
INNER JOIN Artikal a ON a.Naziv = s.Artikal
INNER JOIN Usluga u ON u.Naziv = s.Usluga;
GO

SELECT
    (SELECT COUNT(*) FROM Artikal WHERE Aktivan = 1) AS BrojArtikala,
    (SELECT COUNT(*) FROM Usluga WHERE Aktivan = 1) AS BrojUsluga,
    (SELECT COUNT(*) FROM Cjenovnik) AS BrojCijena;
GO
