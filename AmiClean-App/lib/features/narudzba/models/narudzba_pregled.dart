import '../../recenzije/models/recenzija.dart';

class NarudzbaPregled {
  const NarudzbaPregled({
    required this.id,
    required this.datumKreiranja,
    required this.statusNaziv,
    required this.nacinPredaje,
    required this.nacinPredajeNaziv,
    required this.ukupnaCijena,
    required this.popustIznos,
    required this.ukupnoZaPlatiti,
    this.kuponKod,
    required this.brojStavki,
    required this.mozeSeRecenzirati,
  });

  final int id;
  final DateTime datumKreiranja;
  final String statusNaziv;
  final String nacinPredaje;
  final String nacinPredajeNaziv;
  final double ukupnaCijena;
  final double popustIznos;
  final double ukupnoZaPlatiti;
  final String? kuponKod;
  final int brojStavki;
  final bool mozeSeRecenzirati;

  bool get imaPopust => popustIznos > 0;

  factory NarudzbaPregled.fromJson(Map<String, dynamic> json) {
    final ukupna = (json['ukupnaCijena'] as num).toDouble();
    final popust = (json['popustIznos'] as num?)?.toDouble() ?? 0;
    return NarudzbaPregled(
      id: json['id'] as int,
      datumKreiranja: DateTime.parse(json['datumKreiranja'] as String),
      statusNaziv: json['statusNaziv'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      nacinPredajeNaziv: json['nacinPredajeNaziv'] as String,
      ukupnaCijena: ukupna,
      popustIznos: popust,
      ukupnoZaPlatiti:
          (json['ukupnoZaPlatiti'] as num?)?.toDouble() ?? ukupna - popust,
      kuponKod: json['kuponKod'] as String?,
      brojStavki: json['brojStavki'] as int,
      mozeSeRecenzirati: json['mozeSeRecenzirati'] as bool? ?? false,
    );
  }
}

class NarudzbaDetalj {
  const NarudzbaDetalj({
    required this.id,
    required this.datumKreiranja,
    required this.statusNaziv,
    required this.nacinPredaje,
    required this.nacinPredajeNaziv,
    required this.ukupnaCijena,
    required this.popustIznos,
    required this.ukupnoZaPlatiti,
    this.kuponKod,
    this.napomena,
    this.adresaPreuzimanja,
    this.rokZavrsetka,
    required this.stavke,
    required this.mozeSeOtkazati,
    required this.mozeSeRecenzirati,
    this.recenzija,
  });

  final int id;
  final DateTime datumKreiranja;
  final String statusNaziv;
  final String nacinPredaje;
  final String nacinPredajeNaziv;
  final double ukupnaCijena;
  final double popustIznos;
  final double ukupnoZaPlatiti;
  final String? kuponKod;
  final String? napomena;
  final String? adresaPreuzimanja;
  final DateTime? rokZavrsetka;
  final List<StavkaPregled> stavke;
  final bool mozeSeOtkazati;
  final bool mozeSeRecenzirati;
  final Recenzija? recenzija;

  bool get imaPopust => popustIznos > 0;

  factory NarudzbaDetalj.fromJson(Map<String, dynamic> json) {
    final stavkeJson = json['stavke'] as List<dynamic>? ?? [];
    final recenzijaJson = json['recenzija'] as Map<String, dynamic>?;
    final ukupna = (json['ukupnaCijena'] as num).toDouble();
    final popust = (json['popustIznos'] as num?)?.toDouble() ?? 0;
    return NarudzbaDetalj(
      id: json['id'] as int,
      datumKreiranja: DateTime.parse(json['datumKreiranja'] as String),
      statusNaziv: json['statusNaziv'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      nacinPredajeNaziv: json['nacinPredajeNaziv'] as String,
      ukupnaCijena: ukupna,
      popustIznos: popust,
      ukupnoZaPlatiti:
          (json['ukupnoZaPlatiti'] as num?)?.toDouble() ?? ukupna - popust,
      kuponKod: json['kuponKod'] as String?,
      napomena: json['napomena'] as String?,
      adresaPreuzimanja: json['adresaPreuzimanja'] as String?,
      rokZavrsetka: json['rokZavrsetka'] == null
          ? null
          : DateTime.parse(json['rokZavrsetka'] as String),
      stavke: stavkeJson
          .map((e) => StavkaPregled.fromJson(e as Map<String, dynamic>))
          .toList(),
      mozeSeOtkazati: json['mozeSeOtkazati'] as bool? ?? false,
      mozeSeRecenzirati: json['mozeSeRecenzirati'] as bool? ?? false,
      recenzija: recenzijaJson == null
          ? null
          : Recenzija.fromJson(recenzijaJson),
    );
  }
}

class StavkaPregled {
  const StavkaPregled({
    required this.id,
    required this.artikalNaziv,
    required this.kategorija,
    required this.kolicina,
    required this.cijenaJedinicna,
    required this.ukupno,
    this.napomena,
    required this.usluge,
  });

  final int id;
  final String artikalNaziv;
  final String kategorija;
  final double kolicina;
  final double cijenaJedinicna;
  final double ukupno;
  final String? napomena;
  final List<StavkaUslugaPregled> usluge;

  factory StavkaPregled.fromJson(Map<String, dynamic> json) {
    final uslugeJson = json['usluge'] as List<dynamic>? ?? [];
    return StavkaPregled(
      id: json['id'] as int,
      artikalNaziv: json['artikalNaziv'] as String,
      kategorija: json['kategorija'] as String,
      kolicina: (json['kolicina'] as num).toDouble(),
      cijenaJedinicna: (json['cijenaJedinicna'] as num).toDouble(),
      ukupno: (json['ukupno'] as num).toDouble(),
      napomena: json['napomena'] as String?,
      usluge: uslugeJson
          .map((e) => StavkaUslugaPregled.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get kolicinaTekst {
    if (kategorija == 'Tepisi') {
      return kolicina == kolicina.roundToDouble()
          ? '${kolicina.toInt()} m²'
          : '${kolicina.toStringAsFixed(2)} m²';
    }
    return kolicina == kolicina.roundToDouble()
        ? '${kolicina.toInt()} kom'
        : '$kolicina kom';
  }
}

class StavkaUslugaPregled {
  const StavkaUslugaPregled({
    required this.uslugaNaziv,
    required this.cijena,
  });

  final String uslugaNaziv;
  final double cijena;

  factory StavkaUslugaPregled.fromJson(Map<String, dynamic> json) {
    return StavkaUslugaPregled(
      uslugaNaziv: json['uslugaNaziv'] as String,
      cijena: (json['cijena'] as num).toDouble(),
    );
  }
}
