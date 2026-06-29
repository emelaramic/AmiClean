class RadnikDostava {
  const RadnikDostava({
    required this.narudzbaId,
    required this.korisnikPunoIme,
    required this.adresaDostave,
    required this.logistikaStatusNaziv,
    required this.brojStavki,
    required this.datumPrijema,
    required this.jeMojaDostava,
    required this.mozePokrenuti,
    this.korisnikTelefon,
    this.rokZavrsetka,
    this.vozacPunoIme,
  });

  final int narudzbaId;
  final String korisnikPunoIme;
  final String? korisnikTelefon;
  final String adresaDostave;
  final String logistikaStatusNaziv;
  final int brojStavki;
  final DateTime datumPrijema;
  final DateTime? rokZavrsetka;
  final String? vozacPunoIme;
  final bool jeMojaDostava;
  final bool mozePokrenuti;

  bool get jeUToku => logistikaStatusNaziv == 'U toku';

  factory RadnikDostava.fromJson(Map<String, dynamic> json) {
    return RadnikDostava(
      narudzbaId: json['narudzbaId'] as int,
      korisnikPunoIme: json['korisnikPunoIme'] as String,
      korisnikTelefon: json['korisnikTelefon'] as String?,
      adresaDostave: json['adresaDostave'] as String,
      logistikaStatusNaziv: json['logistikaStatusNaziv'] as String,
      brojStavki: json['brojStavki'] as int,
      datumPrijema: DateTime.parse(json['datumPrijema'] as String),
      rokZavrsetka: json['rokZavrsetka'] == null
          ? null
          : DateTime.parse(json['rokZavrsetka'] as String),
      vozacPunoIme: json['vozacPunoIme'] as String?,
      jeMojaDostava: json['jeMojaDostava'] as bool,
      mozePokrenuti: json['mozePokrenuti'] as bool,
    );
  }
}

class RadnikDostaveLista {
  const RadnikDostaveLista({
    required this.spremne,
    required this.uToku,
  });

  final List<RadnikDostava> spremne;
  final List<RadnikDostava> uToku;

  bool get jePrazno => spremne.isEmpty && uToku.isEmpty;

  factory RadnikDostaveLista.fromJson(Map<String, dynamic> json) {
    List<RadnikDostava> parseList(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<Map<String, dynamic>>()
          .map(RadnikDostava.fromJson)
          .toList();
    }

    return RadnikDostaveLista(
      spremne: parseList(json['spremne']),
      uToku: parseList(json['uToku']),
    );
  }
}
