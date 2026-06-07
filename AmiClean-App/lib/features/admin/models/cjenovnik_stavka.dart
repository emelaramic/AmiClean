class CjenovnikStavka {
  const CjenovnikStavka({
    required this.id,
    required this.artikalId,
    required this.artikalNaziv,
    required this.artikalKategorija,
    required this.uslugaId,
    required this.uslugaNaziv,
    required this.cijena,
    this.cijenaMax,
    required this.vaziOd,
    this.vaziDo,
  });

  final int id;
  final int artikalId;
  final String artikalNaziv;
  final String artikalKategorija;
  final int uslugaId;
  final String uslugaNaziv;
  final double cijena;
  final double? cijenaMax;
  final DateTime vaziOd;
  final DateTime? vaziDo;

  bool get jeTepih => artikalKategorija == 'Tepisi';

  factory CjenovnikStavka.fromJson(Map<String, dynamic> json) {
    return CjenovnikStavka(
      id: _readInt(json, const ['id', 'iD_Cjenovnika', 'id_Cjenovnika']),
      artikalId: _readInt(json, const ['artikalId', 'fK_Artikal', 'fk_Artikal']),
      artikalNaziv: json['artikalNaziv'] as String? ??
          (json['artikal'] as Map<String, dynamic>?)?['naziv'] as String? ??
          'Nepoznat artikal',
      artikalKategorija: json['artikalKategorija'] as String? ??
          (json['artikal'] as Map<String, dynamic>?)?['kategorija'] as String? ??
          '',
      uslugaId: _readInt(json, const ['uslugaId', 'fK_Usluga', 'fk_Usluga']),
      uslugaNaziv: json['uslugaNaziv'] as String? ??
          (json['usluga'] as Map<String, dynamic>?)?['naziv'] as String? ??
          'Nepoznata usluga',
      cijena: (json['cijena'] as num).toDouble(),
      cijenaMax: json['cijenaMax'] == null
          ? json['cijena_Max'] == null
              ? null
              : (json['cijena_Max'] as num).toDouble()
          : (json['cijenaMax'] as num).toDouble(),
      vaziOd: _readDate(json['vaziOd'] ?? json['vazi_Od']),
      vaziDo: json['vaziDo'] == null && json['vazi_Do'] == null
          ? null
          : _readDate(json['vaziDo'] ?? json['vazi_Do']),
    );
  }

  Map<String, dynamic> toUpdateJson({required double novaCijena}) {
    return {'cijena': novaCijena};
  }

  CjenovnikStavka copyWith({double? cijena}) {
    return CjenovnikStavka(
      id: id,
      artikalId: artikalId,
      artikalNaziv: artikalNaziv,
      artikalKategorija: artikalKategorija,
      uslugaId: uslugaId,
      uslugaNaziv: uslugaNaziv,
      cijena: cijena ?? this.cijena,
      cijenaMax: cijenaMax,
      vaziOd: vaziOd,
      vaziDo: vaziDo,
    );
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  static DateTime _readDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
