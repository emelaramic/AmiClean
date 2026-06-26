class Notifikacija {
  const Notifikacija({
    required this.id,
    this.narudzbaId,
    required this.naslov,
    required this.poruka,
    required this.datumSlanja,
    required this.procitano,
  });

  final int id;
  final int? narudzbaId;
  final String naslov;
  final String poruka;
  final DateTime datumSlanja;
  final bool procitano;

  factory Notifikacija.fromJson(Map<String, dynamic> json) {
    return Notifikacija(
      id: json['id'] as int,
      narudzbaId: json['narudzbaId'] as int?,
      naslov: json['naslov'] as String,
      poruka: json['poruka'] as String,
      datumSlanja: DateTime.parse(json['datumSlanja'] as String),
      procitano: json['procitano'] as bool,
    );
  }
}
