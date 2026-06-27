# AmiClean

Aplikacija za hemijsku čistionicu — korisnici naručuju usluge preko mobilne/web aplikacije, administratori upravljaju narudžbama i cjenovnikom.

| Dio | Tehnologija |
|-----|-------------|
| Backend | ASP.NET Core Web API (.NET 10), Entity Framework Core |
| Baza | Microsoft SQL Server Express (`AmiCleanDb`) |
| Frontend | Flutter (Web, Windows, Android) |

Repozitorij: [github.com/emelaramic/AmiClean](https://github.com/emelaramic/AmiClean)

---

## Struktura projekta

```
AmiClean/
├── AmiClean-Backend/          # .NET API
│   ├── AmiClean.API/          # REST kontroleri, Swagger
│   ├── AmiClean.Application/  # DTO-ovi, interfejsi
│   ├── AmiClean.Infrastructure/
│   ├── AmiClean.Domain/
│   └── database/              # SQL skripte
├── AmiClean-App/              # Flutter klijent
└── README.md                  # ovaj dokument
```

---

## Preduvjeti

Instaliraj prije pokretanja:

1. **[.NET SDK 10](https://dotnet.microsoft.com/download)** — backend
2. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** — frontend (`flutter doctor`)
3. **SQL Server Express** — lokalna instanca (u projektu: `localhost\SQLEXPRESS`)
4. **SQL Server Management Studio (SSMS)** — pokretanje SQL skripti (preporučeno)
5. **Google Chrome** — za web demo (`flutter run -d chrome`)

---

## 1. Baza podataka

### Nova instalacija (preporučeno za prvo pokretanje)

U SSMS-u pokreni skripte **redom**:

| Red | Skripta | Opis |
|-----|---------|------|
| 1 | `AmiClean-Backend/database/AmiCleanDb.sql` | Kreira bazu, tabele i početne podatke (uključujući admin nalog) |
| 2 | `AmiClean-Backend/database/SeedKatalog.sql` | Artikli, usluge i cjenovnik |
| 3 | `AmiClean-Backend/database/SeedKupon.sql` | Test kuponi (npr. `AMICLEAN10` — 10% popusta, min. 20 KM) |

> **Napomena:** `AmiCleanDb.sql` briše postojeću bazu `AmiCleanDb` ako već postoji.

### Connection string

U `AmiClean-Backend/AmiClean.API/appsettings.json`:

```json
"DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=AmiCleanDb;Trusted_Connection=True;TrustServerCertificate=True;"
```

Ako koristiš drugu SQL instancu, promijeni `Server=` (npr. `Server=localhost;` ili `Server=.\MSSQLSERVER;`).

### Admin nalog (nakon `AmiCleanDb.sql`)

| Polje | Vrijednost |
|-------|------------|
| Korisničko ime | `admin` |
| Lozinka | `admin123` |

Korisnički nalog kreiraš kroz **Registracija** u aplikaciji.

---

## 2. Pokretanje backend-a

Otvori terminal u **rootu repozitorija** (`AmiClean/`):

```powershell
cd C:\projects\AmiClean
dotnet run --project AmiClean-Backend/AmiClean.API --launch-profile http
```

API radi na: **http://localhost:5230**

Swagger (Development): **http://localhost:5230/swagger**

Ostavi terminal otvoren dok radi aplikacija.

---

## 3. Pokretanje Flutter aplikacije

U **drugom** terminalu:

```powershell
cd C:\projects\AmiClean\AmiClean-App
flutter pub get
flutter run -d chrome
```

### Druge platforme

```powershell
flutter run -d windows    # Windows desktop
flutter run -d android    # Android emulator (API: 10.0.2.2:5230)
```

Flutter automatski koristi `http://localhost:5230` za Web/Windows i `http://10.0.2.2:5230` za Android emulator.

---

## 4. Prijava i uloge

| Uloga | Kako se prijavi | Šta vidi |
|-------|-----------------|----------|
| **Korisnik** | Registracija ili Prijava (korisnik) | Početna, katalog, narudžbe, notifikacije, recenzije |
| **Admin** | Prijava zaposlenika: `admin` / `admin123` | Dashboard, narudžbe, cjenovnik |

---

## 5. Demo scenarij (za pregled)

Preporučeno: **Chrome + Incognito** (korisnik u jednom, admin u drugom prozoru).

1. **Korisnik** — registruj se → kreiraj narudžbu (Odjeća / Usluge → Košarica → Potvrda).
2. **Admin** — dashboard → otvori narudžbu u statusu *Kreirana* → **Primijeni narudžbu**.
3. **Admin** → **Označi u obradi** i odaberi **rok završetka** u kalendaru.
4. **Admin** → *Gotova* → *Preuzeta*.
5. **Korisnik** — ikona zvona (notifikacije) → **Moje narudžbe** → ocijeni uslugu (recenzija).
6. **Admin** — u detalju iste narudžbe vidi recenziju korisnika.

---

## Implementirane funkcionalnosti

- Registracija i prijava (korisnik + zaposlenik/admin)
- Katalog artikala i usluga, cjenovnik
- Kreiranje narudžbe (košarica, način predaje)
- Statusi narudžbe: Kreirana → Primljena → U obradi → Gotova → Preuzeta
- Rok završetka (admin postavlja pri „U obradi“)
- In-app notifikacije (zvono u traci)
- Preporuke na Početnoj
- Recenzije nakon preuzete narudžbe
- Admin dashboard (statistika po statusu, najnovije narudžbe)
- Admin: pregled i upravljanje narudžbama, uređivanje cjenovnika

---

## Uobičajeni problemi

| Problem | Rješenje |
|---------|----------|
| Flutter ne može spojiti API | Provjeri da backend radi na portu 5230 |
| SQL greška pri startu | Provjeri da je SQL Server Express pokrenut i da postoji baza `AmiCleanDb` |
| Prazan katalog | Pokreni `SeedKatalog.sql` |
| `flutter` nije prepoznat | Dodaj Flutter u PATH ili koristi punu putanju do `flutter.bat` |
| CORS / mreža na Androidu | Koristi emulator; app već koristi `10.0.2.2` umjesto `localhost` |

---

## Razvoj

```powershell
# Backend build
dotnet build AmiClean-Backend/AmiClean.API/AmiClean.API.csproj

# Flutter analiza
cd AmiClean-App
flutter analyze
```

---

## Autor

Projekt: **AmiClean** — hemijska čistionica, informacioni sistem za narudžbe i administraciju.
