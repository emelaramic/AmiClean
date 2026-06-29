class StavkaOznakaInfo {
  const StavkaOznakaInfo({
    required this.brojOznake,
    required this.stavkaId,
    required this.artikalNaziv,
    required this.narudzbaId,
    required this.statusNarudzbe,
    required this.nacinPredaje,
    required this.nacinPredajeNaziv,
    required this.korisnikPunoIme,
    required this.mozePokrenutiDostavu,
    required this.mozePotvrditiPreuzimanje,
    required this.poruka,
    this.adresaDostave,
    this.logistikaStatusNaziv,
  });

  final String brojOznake;
  final int stavkaId;
  final String artikalNaziv;
  final int narudzbaId;
  final String statusNarudzbe;
  final String nacinPredaje;
  final String nacinPredajeNaziv;
  final String? adresaDostave;
  final String korisnikPunoIme;
  final String? logistikaStatusNaziv;
  final bool mozePokrenutiDostavu;
  final bool mozePotvrditiPreuzimanje;
  final String poruka;

  bool get imaDostavu => nacinPredaje == 'PreuzimanjeIDostava';

  factory StavkaOznakaInfo.fromJson(Map<String, dynamic> json) {
    return StavkaOznakaInfo(
      brojOznake: json['brojOznake'] as String,
      stavkaId: json['stavkaId'] as int,
      artikalNaziv: json['artikalNaziv'] as String,
      narudzbaId: json['narudzbaId'] as int,
      statusNarudzbe: json['statusNarudzbe'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      nacinPredajeNaziv: json['nacinPredajeNaziv'] as String,
      adresaDostave: json['adresaDostave'] as String?,
      korisnikPunoIme: json['korisnikPunoIme'] as String,
      logistikaStatusNaziv: json['logistikaStatusNaziv'] as String?,
      mozePokrenutiDostavu: json['mozePokrenutiDostavu'] as bool,
      mozePotvrditiPreuzimanje: json['mozePotvrditiPreuzimanje'] as bool? ?? false,
      poruka: json['poruka'] as String,
    );
  }
}

class RadnikOznakaRezultat {
  const RadnikOznakaRezultat({
    required this.narudzbaId,
    required this.statusNarudzbe,
    required this.dostavaPokrenuta,
    required this.poruka,
    this.logistikaStatusNaziv,
  });

  final int narudzbaId;
  final String statusNarudzbe;
  final String? logistikaStatusNaziv;
  final bool dostavaPokrenuta;
  final String poruka;

  factory RadnikOznakaRezultat.fromJson(Map<String, dynamic> json) {
    return RadnikOznakaRezultat(
      narudzbaId: json['narudzbaId'] as int,
      statusNarudzbe: json['statusNarudzbe'] as String,
      logistikaStatusNaziv: json['logistikaStatusNaziv'] as String?,
      dostavaPokrenuta: json['dostavaPokrenuta'] as bool,
      poruka: json['poruka'] as String,
    );
  }
}

class KorisnikOznakaRezultat {
  const KorisnikOznakaRezultat({
    required this.narudzbaId,
    required this.statusNarudzbe,
    required this.preuzimanjePotvrdeno,
    required this.poruka,
    this.logistikaStatusNaziv,
  });

  final int narudzbaId;
  final String statusNarudzbe;
  final String? logistikaStatusNaziv;
  final bool preuzimanjePotvrdeno;
  final String poruka;

  factory KorisnikOznakaRezultat.fromJson(Map<String, dynamic> json) {
    return KorisnikOznakaRezultat(
      narudzbaId: json['narudzbaId'] as int,
      statusNarudzbe: json['statusNarudzbe'] as String,
      logistikaStatusNaziv: json['logistikaStatusNaziv'] as String?,
      preuzimanjePotvrdeno: json['preuzimanjePotvrdeno'] as bool,
      poruka: json['poruka'] as String,
    );
  }
}
