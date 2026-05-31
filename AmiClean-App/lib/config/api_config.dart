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
  static String get prijavaKorisnikUri => '$baseUrl/api/Korisnik/Prijava';
  static String get prijavaZaposlenikUri => '$baseUrl/api/Zaposlenik/Prijava';
  static String get getKategorijeUri => '$baseUrl/api/Catalog/GetKategorije';
  static String get getKatalogUri => '$baseUrl/api/Catalog/GetKatalog';
}
