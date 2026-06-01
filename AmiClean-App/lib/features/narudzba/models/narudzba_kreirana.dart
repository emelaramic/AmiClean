class NarudzbaKreirana {
  const NarudzbaKreirana({
    required this.id,
    required this.statusNaziv,
    required this.nacinPredaje,
    required this.ukupnaCijena,
    required this.datumKreiranja,
    required this.poruka,
  });

  final int id;
  final String statusNaziv;
  final String nacinPredaje;
  final double ukupnaCijena;
  final DateTime datumKreiranja;
  final String poruka;

  factory NarudzbaKreirana.fromJson(Map<String, dynamic> json) {
    return NarudzbaKreirana(
      id: json['id'] as int,
      statusNaziv: json['statusNaziv'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      ukupnaCijena: (json['ukupnaCijena'] as num).toDouble(),
      datumKreiranja: DateTime.parse(json['datumKreiranja'] as String),
      poruka: json['poruka'] as String,
    );
  }
}
