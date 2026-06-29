-- Test radnik za prijavu (pokreni jednom u SSMS na AmiCleanDb)
-- Korisničko ime: radnik
-- Lozinka: admin123

USE AmiCleanDb;
GO

IF NOT EXISTS (SELECT 1 FROM Zaposlenik WHERE Korisnicko_Ime = N'radnik')
BEGIN
    INSERT INTO Zaposlenik (Ime, Prezime, Uloga, Korisnicko_Ime, Lozinka_Hash, Aktivan)
    VALUES (
        N'Nedime',
        N'',
        N'Radnik',
        N'radnik',
        N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
        1
    );
END
ELSE
BEGIN
    UPDATE Zaposlenik
    SET Ime = N'Nedime', Prezime = N''
    WHERE Korisnicko_Ime = N'radnik';
END
GO
