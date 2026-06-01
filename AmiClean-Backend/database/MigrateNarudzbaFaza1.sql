-- Faza 1 narudžbe: status Kreirana, Nacin_Predaje
USE AmiCleanDb;
GO

IF COL_LENGTH('Narudzba', 'Nacin_Predaje') IS NULL
BEGIN
    ALTER TABLE Narudzba
        ADD Nacin_Predaje NVARCHAR(50) NOT NULL
            CONSTRAINT DF_Narudzba_Nacin_Predaje DEFAULT N'DonosUCistionicu';
END
GO

IF NOT EXISTS (SELECT 1 FROM StatusNarudzbe WHERE Naziv = N'Kreirana')
BEGIN
    INSERT INTO StatusNarudzbe (Naziv, Redoslijed) VALUES (N'Kreirana', 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM StatusStavke WHERE Naziv = N'Kreirana')
BEGIN
    INSERT INTO StatusStavke (Naziv) VALUES (N'Kreirana');
END
GO

PRINT N'MigrateNarudzbaFaza1 zavrsen.';
GO
