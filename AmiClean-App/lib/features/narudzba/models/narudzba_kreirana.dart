class NarudzbaKreirana {
  const NarudzbaKreirana({
    required this.id,
    required this.statusNaziv,
    required this.nacinPredaje,
    required this.ukupnaCijena,
    required this.popustIznos,
    required this.ukupnoZaPlatiti,
    this.kuponKod,
    required this.datumKreiranja,
    required this.poruka,
  });

  final int id;
  final String statusNaziv;
  final String nacinPredaje;
  final double ukupnaCijena;
  final double popustIznos;
  final double ukupnoZaPlatiti;
  final String? kuponKod;
  final DateTime datumKreiranja;
  final String poruka;

  factory NarudzbaKreirana.fromJson(Map<String, dynamic> json) {
    return NarudzbaKreirana(
      id: json['id'] as int,
      statusNaziv: json['statusNaziv'] as String,
      nacinPredaje: json['nacinPredaje'] as String,
      ukupnaCijena: (json['ukupnaCijena'] as num).toDouble(),
      popustIznos: (json['popustIznos'] as num?)?.toDouble() ?? 0,
      ukupnoZaPlatiti: (json['ukupnoZaPlatiti'] as num?)?.toDouble() ??
          (json['ukupnaCijena'] as num).toDouble(),
      kuponKod: json['kuponKod'] as String?,
      datumKreiranja: DateTime.parse(json['datumKreiranja'] as String),
      poruka: json['poruka'] as String,
    );
  }
}
