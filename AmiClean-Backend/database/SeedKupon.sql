-- AmiClean test kuponi
-- Pokreni nakon AmiCleanDb.sql (i po želji SeedKatalog.sql)

USE AmiCleanDb;
GO

IF NOT EXISTS (SELECT 1 FROM Kupon WHERE Kod = N'AMICLEAN10')
BEGIN
    INSERT INTO Kupon (Kod, Postotak_Popusta, Datum_Isteka, Min_Iznos_Narudzbe, Max_Broj_Koristenja, Aktivan)
    VALUES (N'AMICLEAN10', 10.00, '2027-12-31', 20.00, NULL, 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM Kupon WHERE Kod = N'WELCOME5')
BEGIN
    INSERT INTO Kupon (Kod, Postotak_Popusta, Datum_Isteka, Min_Iznos_Narudzbe, Max_Broj_Koristenja, Aktivan)
    VALUES (N'WELCOME5', 5.00, '2027-12-31', NULL, 100, 1);
END
GO
