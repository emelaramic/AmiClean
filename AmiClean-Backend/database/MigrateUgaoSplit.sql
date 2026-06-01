-- Ugao: jedan artikal s rasponom -> Ugao (manji) 60 KM, Ugao (veliki) 80 KM
USE AmiCleanDb;
GO

DECLARE @Danas DATE = CAST(GETDATE() AS DATE);
DECLARE @UslugaId INT = (SELECT ID_Usluge FROM Usluga WHERE Naziv = N'Dubinsko čišćenje');

IF @UslugaId IS NULL
BEGIN
    RAISERROR(N'Usluga Dubinsko čišćenje nije pronađena.', 16, 1);
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM Artikal WHERE Naziv = N'Ugao (manji)')
BEGIN
    INSERT INTO Artikal (Naziv, Opis, Kategorija, Aktivan)
    VALUES (N'Ugao (manji)', NULL, N'Namještaj', 1);
END

IF NOT EXISTS (SELECT 1 FROM Artikal WHERE Naziv = N'Ugao (veliki)')
BEGIN
    INSERT INTO Artikal (Naziv, Opis, Kategorija, Aktivan)
    VALUES (N'Ugao (veliki)', NULL, N'Namještaj', 1);
END
GO

DECLARE @Danas DATE = CAST(GETDATE() AS DATE);
DECLARE @UslugaId INT = (SELECT ID_Usluge FROM Usluga WHERE Naziv = N'Dubinsko čišćenje');
DECLARE @ManjiId INT = (SELECT ID_Artikla FROM Artikal WHERE Naziv = N'Ugao (manji)');
DECLARE @VelikiId INT = (SELECT ID_Artikla FROM Artikal WHERE Naziv = N'Ugao (veliki)');

IF NOT EXISTS (SELECT 1 FROM Cjenovnik WHERE FK_Artikal = @ManjiId AND FK_Usluga = @UslugaId)
BEGIN
    INSERT INTO Cjenovnik (FK_Artikal, FK_Usluga, Cijena, Cijena_Max, Vazi_Od)
    VALUES (@ManjiId, @UslugaId, 60.00, NULL, @Danas);
END
ELSE
BEGIN
    UPDATE Cjenovnik
    SET Cijena = 60.00, Cijena_Max = NULL
    WHERE FK_Artikal = @ManjiId AND FK_Usluga = @UslugaId;
END

IF NOT EXISTS (SELECT 1 FROM Cjenovnik WHERE FK_Artikal = @VelikiId AND FK_Usluga = @UslugaId)
BEGIN
    INSERT INTO Cjenovnik (FK_Artikal, FK_Usluga, Cijena, Cijena_Max, Vazi_Od)
    VALUES (@VelikiId, @UslugaId, 80.00, NULL, @Danas);
END
ELSE
BEGIN
    UPDATE Cjenovnik
    SET Cijena = 80.00, Cijena_Max = NULL
    WHERE FK_Artikal = @VelikiId AND FK_Usluga = @UslugaId;
END
GO

-- Ukloni stari Ugao ako nema stavki narudžbi
IF EXISTS (SELECT 1 FROM Artikal WHERE Naziv = N'Ugao')
BEGIN
    DECLARE @StariUgaoId INT = (SELECT ID_Artikla FROM Artikal WHERE Naziv = N'Ugao');

    IF NOT EXISTS (SELECT 1 FROM Stavka_Narudzbe WHERE FK_Artikal = @StariUgaoId)
    BEGIN
        DELETE FROM Cjenovnik WHERE FK_Artikal = @StariUgaoId;
        DELETE FROM Artikal WHERE ID_Artikla = @StariUgaoId;
        PRINT N'Stari artikal Ugao uklonjen.';
    END
    ELSE
    BEGIN
        UPDATE Artikal SET Aktivan = 0 WHERE ID_Artikla = @StariUgaoId;
        PRINT N'Stari Ugao deaktiviran (postoje stavke narudžbi).';
    END
END
GO

PRINT N'MigrateUgaoSplit zavrsen.';
GO
