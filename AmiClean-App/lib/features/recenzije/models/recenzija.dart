class Recenzija {
  const Recenzija({
    required this.id,
    required this.narudzbaId,
    required this.ocjena,
    this.komentar,
    required this.datumObjave,
  });

  final int id;
  final int narudzbaId;
  final int ocjena;
  final String? komentar;
  final DateTime datumObjave;

  factory Recenzija.fromJson(Map<String, dynamic> json) {
    return Recenzija(
      id: json['id'] as int,
      narudzbaId: json['narudzbaId'] as int,
      ocjena: json['ocjena'] as int,
      komentar: json['komentar'] as String?,
      datumObjave: DateTime.parse(json['datumObjave'] as String),
    );
  }
}
