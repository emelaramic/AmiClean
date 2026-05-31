-- Test admin za prijavu (pokreni jednom u SSMS na AmiCleanDb)
-- Korisničko ime: admin
-- Lozinka: admin123

USE AmiCleanDb;
GO

IF NOT EXISTS (SELECT 1 FROM Zaposlenik WHERE Korisnicko_Ime = N'admin')
BEGIN
    INSERT INTO Zaposlenik (Ime, Prezime, Uloga, Korisnicko_Ime, Lozinka_Hash, Aktivan)
    VALUES (
        N'Admin',
        N'AmiClean',
        N'Administrator',
        N'admin',
        N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
        1
    );
END
GO
