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

  static String getMojeNarudzbeUri(int korisnikId) =>
      '$baseUrl/api/Narudzba/GetMojeNarudzbe?korisnikId=$korisnikId';

  static String getDetaljNarudzbeUri({
    required int narudzbaId,
    required int korisnikId,
  }) =>
      '$baseUrl/api/Narudzba/GetDetaljNarudzbe?narudzbaId=$narudzbaId&korisnikId=$korisnikId';

  static String get getSveNarudzbeUri => '$baseUrl/api/Narudzba/GetSveNarudzbe';

  static String getSveNarudzbeUriFiltered(String? statusNaziv) {
    if (statusNaziv == null || statusNaziv.isEmpty) {
      return getSveNarudzbeUri;
    }
    return '$getSveNarudzbeUri?statusNaziv=${Uri.encodeComponent(statusNaziv)}';
  }

  static String getDetaljNarudzbeAdminUri(int narudzbaId) =>
      '$baseUrl/api/Narudzba/GetDetaljNarudzbeAdmin?narudzbaId=$narudzbaId';

  static String get primijeniNarudzbuUri =>
      '$baseUrl/api/Narudzba/PrimijeniNarudzbu';

  static String get promijeniStatusNarudzbeUri =>
      '$baseUrl/api/Narudzba/PromijeniStatusNarudzbe';
}
