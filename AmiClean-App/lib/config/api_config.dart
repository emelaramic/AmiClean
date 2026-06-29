import 'package:flutter/foundation.dart';

/// Backend API adrese — port 5230 iz launchSettings.json.
class ApiConfig {
  static const int port = 5230;

  /// Android emulator: 10.0.2.2 mapira na localhost host računala.
  static const String androidEmulatorHost = 'http://10.0.2.2:$port';

  /// Web / Windows desktop: direktno na localhost.
  static const String localHost = 'http://localhost:$port';

  static String get baseUrl {
    if (kIsWeb) return localHost;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulatorHost;
      default:
        return localHost;
    }
  }

  static String get postKorisnikUri => '$baseUrl/api/Korisnik/PostKorisnik';
  static String get getKorisniciUri => '$baseUrl/api/Korisnik/GetKorisnici';
  static String getProfilUri(int korisnikId) =>
      '$baseUrl/api/Korisnik/GetProfil?korisnikId=$korisnikId';
  static String get azurirajProfilUri => '$baseUrl/api/Korisnik/AzurirajProfil';
  static String get prijavaKorisnikUri => '$baseUrl/api/Korisnik/Prijava';
  static String get prijavaZaposlenikUri => '$baseUrl/api/Zaposlenik/Prijava';
  static String get getKategorijeUri => '$baseUrl/api/Catalog/GetKategorije';
  static String get getKatalogUri => '$baseUrl/api/Catalog/GetKatalog';
  static String get kreirajNarudzbuUri => '$baseUrl/api/Narudzba/KreirajNarudzbu';

  static String provjeriKuponUri({
    required String kod,
    required double ukupnaCijena,
  }) =>
      '$baseUrl/api/Kupon/Provjeri?kod=${Uri.encodeComponent(kod.trim())}&ukupnaCijena=$ukupnaCijena';

  static String getMojeNarudzbeUri(int korisnikId) =>
      '$baseUrl/api/Narudzba/GetMojeNarudzbe?korisnikId=$korisnikId';

  static String getDetaljNarudzbeUri({
    required int narudzbaId,
    required int korisnikId,
  }) =>
      '$baseUrl/api/Narudzba/GetDetaljNarudzbe?narudzbaId=$narudzbaId&korisnikId=$korisnikId';

  static String get getSveNarudzbeUri => '$baseUrl/api/Narudzba/GetSveNarudzbe';

  static String getSveNarudzbeUriFiltered(String? statusNaziv, {int? limit}) {
    final params = <String>[];
    if (statusNaziv != null && statusNaziv.isNotEmpty) {
      params.add('statusNaziv=${Uri.encodeComponent(statusNaziv)}');
    }
    if (limit != null) {
      params.add('limit=$limit');
    }
    if (params.isEmpty) return getSveNarudzbeUri;
    return '$getSveNarudzbeUri?${params.join('&')}';
  }

  static String get getBrojNarudzbiPoStatusuUri =>
      '$baseUrl/api/Narudzba/GetBrojNarudzbiPoStatusu';

  static String getDetaljNarudzbeAdminUri(int narudzbaId) =>
      '$baseUrl/api/Narudzba/GetDetaljNarudzbeAdmin?narudzbaId=$narudzbaId';

  static String get primijeniNarudzbuUri =>
      '$baseUrl/api/Narudzba/PrimijeniNarudzbu';

  static String get promijeniStatusNarudzbeUri =>
      '$baseUrl/api/Narudzba/PromijeniStatusNarudzbe';

  static String get promijeniRokZavrsetkaUri =>
      '$baseUrl/api/Narudzba/PromijeniRokZavrsetka';

  static String get otkaziNarudzbuUri => '$baseUrl/api/Narudzba/OtkaziNarudzbu';

  static String get getCjenovnikUri => '$baseUrl/api/Cjenovnik/GetCjenovnik';

  static String putCjenovnikUri(int cjenovnikId) =>
      '$baseUrl/api/Cjenovnik/PutCjenovnik/$cjenovnikId';

  static String getPreporukeZaKorisnikaUri({
    required int korisnikId,
    int limit = 3,
  }) =>
      '$baseUrl/api/Preporuke/GetZaKorisnika?korisnikId=$korisnikId&limit=$limit';

  static String getNotifikacijeZaKorisnikaUri({required int korisnikId}) =>
      '$baseUrl/api/Notifikacija/GetZaKorisnika?korisnikId=$korisnikId';

  static String getBrojNeprocitanihNotifikacijaUri({required int korisnikId}) =>
      '$baseUrl/api/Notifikacija/GetBrojNeprocitanih?korisnikId=$korisnikId';

  static String oznaciNotifikacijuProcitanomUri({
    required int notifikacijaId,
    required int korisnikId,
  }) =>
      '$baseUrl/api/Notifikacija/OznaciProcitanom?notifikacijaId=$notifikacijaId&korisnikId=$korisnikId';

  static String oznaciSveNotifikacijeProcitanimUri({required int korisnikId}) =>
      '$baseUrl/api/Notifikacija/OznaciSveProcitanim?korisnikId=$korisnikId';

  static String get kreirajRecenzijuUri => '$baseUrl/api/Recenzija/KreirajRecenziju';

  static String getInfoPoOznaciUri(String unos, {int? korisnikId}) {
    final encoded = Uri.encodeComponent(unos.trim());
    if (korisnikId != null) {
      return '$baseUrl/api/Narudzba/GetInfoPoOznaci?unos=$encoded&korisnikId=$korisnikId';
    }
    return '$baseUrl/api/Narudzba/GetInfoPoOznaci?unos=$encoded';
  }

  static String get radnikPokreniDostavuUri =>
      '$baseUrl/api/Narudzba/RadnikPokreniDostavu';

  static String get korisnikPotvrdiPreuzimanjeUri =>
      '$baseUrl/api/Narudzba/KorisnikPotvrdiPreuzimanje';
}
