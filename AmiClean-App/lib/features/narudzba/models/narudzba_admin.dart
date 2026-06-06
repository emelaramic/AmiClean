import 'narudzba_pregled.dart';
import 'narudzba_status.dart';

export 'narudzba_status.dart';

class NarudzbaAdminPregled {
  const NarudzbaAdminPregled({
    required this.id,
    required this.datumKreiranja,
    required this.statusNaziv,
    required this.nacinPredaje,
    required this.nacinPredajeNaziv,
    required this.ukupnaCijena,
    required this.brojStavki,
    required this.korisnikPunoIme,
    this.korisnikTelefon,
  });

  final int id;
  final DateTime datumKreiranja;
  final String statusNaziv;
  final String nacinPredaje;
  final String nacinPredajeNaziv;
  final double ukupnaCijena;
  final int brojStavki;
  final String korisnikPunoIme;
  final String? korisnikTelefon;

  factory NarudzbaAdminPregled.fromJson(Map<String, dynamic> json) {
    return NarudzbaAdminPregled(
      id: json['id'] as int,
      datumKreiranja: DateTime.parse(json['datumKreiranja'] as String),
      statusNaziv: json['statusNaziv'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      nacinPredajeNaziv: json['nacinPredajeNaziv'] as String,
      ukupnaCijena: (json['ukupnaCijena'] as num).toDouble(),
      brojStavki: json['brojStavki'] as int,
      korisnikPunoIme: json['korisnikPunoIme'] as String,
      korisnikTelefon: json['korisnikTelefon'] as String?,
    );
  }
}

class NarudzbaAdminDetalj {
  const NarudzbaAdminDetalj({
    required this.id,
    required this.datumKreiranja,
    required this.statusNaziv,
    required this.nacinPredaje,
    required this.nacinPredajeNaziv,
    required this.ukupnaCijena,
    this.napomena,
    this.adresaPreuzimanja,
    this.rokZavrsetka,
    required this.stavke,
    required this.korisnikId,
    required this.korisnikPunoIme,
    this.korisnikEmail,
    this.korisnikTelefon,
    this.korisnikAdresaStanovanja,
    required this.mozeSePrimijeti,
    required this.dozvoljeneAkcije,
  });

  final int id;
  final DateTime datumKreiranja;
  final String statusNaziv;
  final String nacinPredaje;
  final String nacinPredajeNaziv;
  final double ukupnaCijena;
  final String? napomena;
  final String? adresaPreuzimanja;
  final DateTime? rokZavrsetka;
  final List<StavkaPregled> stavke;
  final int korisnikId;
  final String korisnikPunoIme;
  final String? korisnikEmail;
  final String? korisnikTelefon;
  final String? korisnikAdresaStanovanja;
  final bool mozeSePrimijeti;
  final List<NarudzbaAdminAkcija> dozvoljeneAkcije;

  factory NarudzbaAdminDetalj.fromJson(Map<String, dynamic> json) {
    final stavkeJson = json['stavke'] as List<dynamic>? ?? [];
    return NarudzbaAdminDetalj(
      id: json['id'] as int,
      datumKreiranja: DateTime.parse(json['datumKreiranja'] as String),
      statusNaziv: json['statusNaziv'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      nacinPredajeNaziv: json['nacinPredajeNaziv'] as String,
      ukupnaCijena: (json['ukupnaCijena'] as num).toDouble(),
      napomena: json['napomena'] as String?,
      adresaPreuzimanja: json['adresaPreuzimanja'] as String?,
      rokZavrsetka: json['rokZavrsetka'] == null
          ? null
          : DateTime.parse(json['rokZavrsetka'] as String),
      stavke: stavkeJson
          .map((e) => StavkaPregled.fromJson(e as Map<String, dynamic>))
          .toList(),
      korisnikId: json['korisnikId'] as int,
      korisnikPunoIme: json['korisnikPunoIme'] as String,
      korisnikEmail: json['korisnikEmail'] as String?,
      korisnikTelefon: json['korisnikTelefon'] as String?,
      korisnikAdresaStanovanja: json['korisnikAdresaStanovanja'] as String?,
      mozeSePrimijeti: json['mozeSePrimijeti'] as bool,
      dozvoljeneAkcije: (json['dozvoljeneAkcije'] as List<dynamic>? ?? [])
          .map((e) => NarudzbaAdminAkcija.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NarudzbaStatusPromjena {
  const NarudzbaStatusPromjena({
    required this.id,
    required this.statusNaziv,
    this.rokZavrsetka,
    required this.poruka,
  });

  final int id;
  final String statusNaziv;
  final DateTime? rokZavrsetka;
  final String poruka;

  factory NarudzbaStatusPromjena.fromJson(Map<String, dynamic> json) {
    return NarudzbaStatusPromjena(
      id: json['id'] as int,
      statusNaziv: json['statusNaziv'] as String,
      rokZavrsetka: json['rokZavrsetka'] == null
          ? null
          : DateTime.parse(json['rokZavrsetka'] as String),
      poruka: json['poruka'] as String,
    );
  }
}
