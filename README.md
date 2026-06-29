# AmiClean

Aplikacija za hemijsku čistionicu — korisnici naručuju usluge preko mobilne/web aplikacije, administratori upravljaju narudžbama i cjenovnikom, radnici prate dostave i skeniraju QR oznake na artiklima.

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
6. **Android emulator** (opcionalno) — za ulogu radnika s kamerom za QR

---

## 1. Baza podataka

### Nova instalacija (preporučeno za prvo pokretanje)

U SSMS-u pokreni skripte **redom**:

| Red | Skripta | Opis |
|-----|---------|------|
| 1 | `AmiClean-Backend/database/AmiCleanDb.sql` | Kreira bazu, tabele i početne podatke (uključujući admin nalog) |
| 2 | `AmiClean-Backend/database/SeedKatalog.sql` | Artikli, usluge i cjenovnik |
| 3 | `AmiClean-Backend/database/SeedKupon.sql` | Test kuponi (npr. `AMICLEAN10` — 10% popusta, min. 20 KM) |
| 4 | `AmiClean-Backend/database/SeedRadnik.sql` | Test radnik za dostavu (korisničko ime `radnik`) |

> **Napomena:** `AmiCleanDb.sql` briše postojeću bazu `AmiCleanDb` ako već postoji.

### Connection string

U `AmiClean-Backend/AmiClean.API/appsettings.json`:

```json
"DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=AmiCleanDb;Trusted_Connection=True;TrustServerCertificate=True;"
```

Ako koristiš drugu SQL instancu, promijeni `Server=` (npr. `Server=localhost;` ili `Server=.\MSSQLSERVER;`).

### Test nalozi (nakon SQL skripti)

| Uloga | Prijava | Lozinka |
|-------|---------|---------|
| **Admin** | Korisničko ime: `admin` | `admin123` |
| **Radnik** | Korisničko ime: `radnik` | `admin123` |
| **Korisnik** | Email + lozinka | Registracija u aplikaciji |

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

Ako dobiješ grešku da je fajl zaključan, zaustavi stari proces:

```powershell
Get-Process -Name "AmiClean.API" -ErrorAction SilentlyContinue | Stop-Process -Force
```

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

### Preporuka za demo (tri uloge odjednom)

| Uloga | Gdje pokrenuti |
|-------|----------------|
| **Korisnik** | Chrome **Incognito** |
| **Admin** | Chrome (običan prozor) |
| **Radnik** | Android emulator (`flutter run -d emulator-5554`) |

---

## 4. Prijava i uloge

| Uloga | Kako se prijavi | Šta vidi |
|-------|-----------------|----------|
| **Korisnik** | Tab *Korisnik* — registracija ili prijava emailom | Početna, katalog, narudžbe, kuponi, notifikacije, QR preuzimanje, recenzije |
| **Admin** | Tab *Zaposlenik* — `admin` / `admin123` | Dashboard, narudžbe, cjenovnik, QR oznake u detalju |
| **Radnik** | Tab *Zaposlenik* — `radnik` / `admin123` | Lista dostava, skeniranje / ručni unos QR oznaka |

---

## 5. Demo scenarij (za odbranu)

Preporučeno: **Chrome + Incognito + Android emulator** (vidi tablicu iznad).

1. **Korisnik** — registruj se → kreiraj narudžbu s opcijom **Preuzimanje i dostava** (unesi adresu). Opcionalno primijeni kupon `AMICLEAN10` pri potvrdi.
2. **Admin** — dashboard → narudžba *Kreirana* → **Primijeni narudžbu** (generišu se QR oznake po stavci).
3. **Admin** → **Označi u obradi** i odaberi **rok završetka**.
4. **Admin** → **Označi gotovom**.
5. **Radnik** (emulator) — na početnom ekranu vidi narudžbu u listi **Spremne za dostavu** → **Skeniraj oznaku** (kamera ili ručni unos broja, npr. `AC-2026-0004-01`) → **Kreni u dostavu**.
6. **Korisnik** — u detalju narudžbe **Skeniraj QR** ili ručni unos → **Potvrdi preuzimanje** (status *Preuzeta*).
7. **Korisnik** — ocijeni uslugu (recenzija).
8. **Admin** — u detalju narudžbe vidi recenziju i QR oznake.

> Za narudžbe **bez dostave** (donos u čistionicu), korisnik potvrđuje preuzimanje QR-om u radnji; radnik lista dostava ostaje prazna.

### Demo checklist

- [ ] Backend radi na portu 5230
- [ ] Baza + seed skripte pokrenute
- [ ] Korisnik: narudžba s dostavom kreirana
- [ ] Admin: Primijeni → U obradi → Gotova
- [ ] Radnik: dostava u listi → skeniranje → U toku
- [ ] Korisnik: QR potvrda → Preuzeta → recenzija

---

## Implementirane funkcionalnosti

- Registracija i prijava (korisnik + admin + radnik)
- Katalog artikala i usluga, cjenovnik
- Kreiranje narudžbe (košarica, način predaje, adresa za dostavu)
- Kuponi — provjera i primjena popusta pri narudžbi
- Statusi narudžbe: Kreirana → Primljena → U obradi → Gotova → Preuzeta
- Rok završetka (admin postavlja pri „U obradi“)
- QR oznake po stavci (generisanje pri Primijeni, prikaz u adminu i korisniku)
- Radnik: lista dostava (spremne / u toku), skeniranje i ručni unos
- Korisnik: potvrda preuzimanja QR-om
- Logistika dostave (Zakazano → U toku → Završeno)
- In-app notifikacije (zvono u traci)
- Preporuke na Početnoj
- Recenzije nakon preuzete narudžbe
- Otkazivanje narudžbe (korisnik dok je Kreirana, admin)
- Admin dashboard (statistika po statusu, najnovije narudžbe)
- Admin: pregled i upravljanje narudžbama, uređivanje cjenovnika

---

## Uobičajeni problemi

| Problem | Rješenje |
|---------|----------|
| Flutter ne može spojiti API | Provjeri da backend radi na portu 5230 |
| SQL greška pri startu | Provjeri da je SQL Server Express pokrenut i da postoji baza `AmiCleanDb` |
| Prazan katalog | Pokreni `SeedKatalog.sql` |
| Radnik se ne može prijaviti | Pokreni `SeedRadnik.sql` |
| Lista dostava prazna | Narudžba mora biti *Gotova* i imati način *Preuzimanje i dostava* |
| `flutter` nije prepoznat | Dodaj Flutter u PATH ili koristi punu putanju do `flutter.bat` |
| CORS / mreža na Androidu | Koristi emulator; app već koristi `10.0.2.2` umjesto `localhost` |
| Email se ne može ukucati na emulatoru | Koristi korisnika u Chrome Incognito; emulator samo za radnika |
| MSB3027 / file locked pri buildu | `Stop-Process` na `AmiClean.API` pa ponovo `dotnet run` |

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
