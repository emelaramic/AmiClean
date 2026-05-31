-- Novi ER model (hemijska čistionica) — pokreni u SSMS (Execute)

IF DB_ID(N'AmiCleanDb') IS NOT NULL
BEGIN
    ALTER DATABASE AmiCleanDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AmiCleanDb;
END
GO

CREATE DATABASE AmiCleanDb;
GO

USE AmiCleanDb;
GO

CREATE TABLE StatusNarudzbe (
    ID_Statusa INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL,
    Redoslijed INT NOT NULL
);

CREATE TABLE StatusStavke (
    ID_Statusa INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL
);

CREATE TABLE StatusPlacanja (
    ID_Statusa INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL
);

CREATE TABLE StatusLogistike (
    ID_Statusa INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL
);

CREATE TABLE Korisnik (
    ID_Korisnika INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ime NVARCHAR(100) NOT NULL,
    Prezime NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NULL,
    Lozinka_Hash NVARCHAR(255) NOT NULL,
    Broj_Telefona NVARCHAR(50) NULL,
    Adresa_Stanovanja NVARCHAR(500) NULL,
    Aktivan BIT NOT NULL DEFAULT 1
);

CREATE TABLE Zaposlenik (
    ID_Zaposlenika INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ime NVARCHAR(100) NOT NULL,
    Prezime NVARCHAR(100) NOT NULL,
    Uloga NVARCHAR(50) NOT NULL,
    Korisnicko_Ime NVARCHAR(100) NOT NULL,
    Lozinka_Hash NVARCHAR(255) NOT NULL,
    Aktivan BIT NOT NULL DEFAULT 1
);

CREATE TABLE Kupon (
    ID_Kupona INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Kod NVARCHAR(50) NOT NULL,
    Postotak_Popusta DECIMAL(5,2) NOT NULL,
    Datum_Isteka DATE NOT NULL,
    Min_Iznos_Narudzbe DECIMAL(10,2) NULL,
    Max_Broj_Koristenja INT NULL,
    Aktivan BIT NOT NULL DEFAULT 1
);

CREATE TABLE Artikal (
    ID_Artikla INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naziv NVARCHAR(200) NOT NULL,
    Opis NVARCHAR(500) NULL,
    Kategorija NVARCHAR(50) NOT NULL DEFAULT N'Odjeća',
    Aktivan BIT NOT NULL DEFAULT 1
);

CREATE TABLE Usluga (
    ID_Usluge INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naziv NVARCHAR(200) NOT NULL,
    Opis NVARCHAR(500) NULL,
    Aktivan BIT NOT NULL DEFAULT 1
);

CREATE TABLE Cjenovnik (
    ID_Cjenika INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Artikal INT NOT NULL,
    FK_Usluga INT NOT NULL,
    Cijena DECIMAL(10,2) NOT NULL,
    Cijena_Max DECIMAL(10,2) NULL,
    Vazi_Od DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Vazi_Do DATE NULL,
    CONSTRAINT FK_Cjenovnik_Artikal FOREIGN KEY (FK_Artikal) REFERENCES Artikal(ID_Artikla),
    CONSTRAINT FK_Cjenovnik_Usluga FOREIGN KEY (FK_Usluga) REFERENCES Usluga(ID_Usluge),
    CONSTRAINT UQ_Cjenovnik_Artikal_Usluga UNIQUE (FK_Artikal, FK_Usluga)
);

CREATE TABLE Narudzba (
    ID_Narudzbe INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Korisnik INT NOT NULL,
    FK_Kupon INT NULL,
    FK_Primio_Zaposlenik INT NULL,
    FK_Status INT NOT NULL,
    Kanal NVARCHAR(50) NOT NULL,
    Nacin_Zavrsetka NVARCHAR(50) NOT NULL,
    Datum_Prijema DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Rok_Zavrsetka DATETIME2 NULL,
    Datum_Zavrsetka DATETIME2 NULL,
    Datum_Preuzimanja DATETIME2 NULL,
    Ukupna_Cijena DECIMAL(10,2) NOT NULL DEFAULT 0,
    Popust_Iznos DECIMAL(10,2) NOT NULL DEFAULT 0,
    Napomena NVARCHAR(1000) NULL,
    CONSTRAINT FK_Narudzba_Korisnik FOREIGN KEY (FK_Korisnik) REFERENCES Korisnik(ID_Korisnika),
    CONSTRAINT FK_Narudzba_Kupon FOREIGN KEY (FK_Kupon) REFERENCES Kupon(ID_Kupona),
    CONSTRAINT FK_Narudzba_Primio FOREIGN KEY (FK_Primio_Zaposlenik) REFERENCES Zaposlenik(ID_Zaposlenika),
    CONSTRAINT FK_Narudzba_Status FOREIGN KEY (FK_Status) REFERENCES StatusNarudzbe(ID_Statusa)
);

CREATE TABLE Stavka_Narudzbe (
    ID_Stavke INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Narudzba INT NOT NULL,
    FK_Artikal INT NOT NULL,
    FK_Status INT NOT NULL,
    Kolicina DECIMAL(10,2) NOT NULL DEFAULT 1,
    Broj_Oznake NVARCHAR(50) NULL,
    Materijal NVARCHAR(100) NULL,
    Boja NVARCHAR(50) NULL,
    Napomena NVARCHAR(500) NULL,
    Cijena_Jedinicna DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Stavka_Narudzba FOREIGN KEY (FK_Narudzba) REFERENCES Narudzba(ID_Narudzbe),
    CONSTRAINT FK_Stavka_Artikal FOREIGN KEY (FK_Artikal) REFERENCES Artikal(ID_Artikla),
    CONSTRAINT FK_Stavka_Status FOREIGN KEY (FK_Status) REFERENCES StatusStavke(ID_Statusa)
);

CREATE TABLE Stavka_Usluga (
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Stavka INT NOT NULL,
    FK_Usluga INT NOT NULL,
    Cijena_Usluge DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_StavkaUsluga_Stavka FOREIGN KEY (FK_Stavka) REFERENCES Stavka_Narudzbe(ID_Stavke),
    CONSTRAINT FK_StavkaUsluga_Usluga FOREIGN KEY (FK_Usluga) REFERENCES Usluga(ID_Usluge)
);

CREATE TABLE Placanje (
    ID_Placanja INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Narudzba INT NOT NULL,
    FK_Status INT NOT NULL,
    Metoda NVARCHAR(50) NOT NULL,
    Iznos DECIMAL(10,2) NOT NULL,
    Datum_Uplate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Placanje_Narudzba FOREIGN KEY (FK_Narudzba) REFERENCES Narudzba(ID_Narudzbe),
    CONSTRAINT FK_Placanje_Status FOREIGN KEY (FK_Status) REFERENCES StatusPlacanja(ID_Statusa)
);

CREATE TABLE Logistika (
    ID_Logistike INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Narudzba INT NOT NULL,
    FK_Vozac INT NULL,
    FK_Status INT NOT NULL,
    Tip NVARCHAR(50) NOT NULL,
    Adresa NVARCHAR(500) NOT NULL,
    Planirano_Vrijeme DATETIME2 NULL,
    Stvarno_Vrijeme DATETIME2 NULL,
    CONSTRAINT FK_Logistika_Narudzba FOREIGN KEY (FK_Narudzba) REFERENCES Narudzba(ID_Narudzbe),
    CONSTRAINT FK_Logistika_Vozac FOREIGN KEY (FK_Vozac) REFERENCES Zaposlenik(ID_Zaposlenika),
    CONSTRAINT FK_Logistika_Status FOREIGN KEY (FK_Status) REFERENCES StatusLogistike(ID_Statusa)
);

CREATE TABLE Notifikacija (
    ID_Notifikacije INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Korisnik INT NOT NULL,
    FK_Narudzba INT NULL,
    Kanal NVARCHAR(20) NOT NULL,
    Naslov NVARCHAR(200) NOT NULL,
    Poruka NVARCHAR(1000) NOT NULL,
    Datum_Slanja DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Status_Slanja NVARCHAR(30) NOT NULL DEFAULT N'Na_cekanju',
    Procitano BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Notifikacija_Korisnik FOREIGN KEY (FK_Korisnik) REFERENCES Korisnik(ID_Korisnika),
    CONSTRAINT FK_Notifikacija_Narudzba FOREIGN KEY (FK_Narudzba) REFERENCES Narudzba(ID_Narudzbe)
);

CREATE TABLE Recenzija (
    ID_Recenzije INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FK_Korisnik INT NOT NULL,
    FK_Narudzba INT NOT NULL,
    Ocjena INT NOT NULL,
    Komentar NVARCHAR(1000) NULL,
    Datum_Objave DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Recenzija_Korisnik FOREIGN KEY (FK_Korisnik) REFERENCES Korisnik(ID_Korisnika),
    CONSTRAINT FK_Recenzija_Narudzba FOREIGN KEY (FK_Narudzba) REFERENCES Narudzba(ID_Narudzbe),
    CONSTRAINT UQ_Recenzija_Narudzba UNIQUE (FK_Narudzba),
    CONSTRAINT CK_Recenzija_Ocjena CHECK (Ocjena BETWEEN 1 AND 5)
);
GO

-- Početni podaci (šifrarnici)
INSERT INTO StatusNarudzbe (Naziv, Redoslijed) VALUES
(N'Primljena', 1), (N'U obradi', 2), (N'Djelomicno gotova', 3), (N'Gotova', 4), (N'Preuzeta', 5), (N'Otkazana', 6);

INSERT INTO StatusStavke (Naziv) VALUES
(N'Primljena'), (N'U obradi'), (N'Gotova'), (N'Isporucena');

INSERT INTO StatusPlacanja (Naziv) VALUES
(N'Na cekanju'), (N'Djelomicno placeno'), (N'Placeno'), (N'Stornirano');

INSERT INTO StatusLogistike (Naziv) VALUES
(N'Zakazano'), (N'U toku'), (N'Zavrseno'), (N'Otkazano');

INSERT INTO Zaposlenik (Ime, Prezime, Uloga, Korisnicko_Ime, Lozinka_Hash, Aktivan)
VALUES (
    N'Admin',
    N'AmiClean',
    N'Administrator',
    N'admin',
    N'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
    1
);
GO
