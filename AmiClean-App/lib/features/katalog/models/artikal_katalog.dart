class UslugaCijena {
  const UslugaCijena({
    required this.uslugaId,
    required this.uslugaNaziv,
    required this.cjenovnikId,
    required this.cijena,
    this.cijenaMax,
    this.cijenaOpis,
  });

  final int uslugaId;
  final String uslugaNaziv;
  final int cjenovnikId;
  final double cijena;
  final double? cijenaMax;
  final String? cijenaOpis;

  factory UslugaCijena.fromJson(Map<String, dynamic> json) {
    return UslugaCijena(
      uslugaId: json['uslugaId'] as int,
      uslugaNaziv: json['uslugaNaziv'] as String,
      cjenovnikId: json['cjenovnikId'] as int,
      cijena: (json['cijena'] as num).toDouble(),
      cijenaMax: json['cijenaMax'] == null
          ? null
          : (json['cijenaMax'] as num).toDouble(),
      cijenaOpis: json['cijenaOpis'] as String?,
    );
  }

  String get cijenaTekst {
    final min = _formatKm(cijena);
    if (cijenaMax != null) {
      return '$min – ${_formatKm(cijenaMax!)}';
    }
    return min;
  }

  String _formatKm(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} KM';
    }
    return '${value.toStringAsFixed(2)} KM';
  }
}

class ArtikalKatalog {
  const ArtikalKatalog({
    required this.id,
    required this.naziv,
    required this.kategorija,
    this.opis,
    required this.usluge,
  });

  final int id;
  final String naziv;
  final String kategorija;
  final String? opis;
  final List<UslugaCijena> usluge;

  factory ArtikalKatalog.fromJson(Map<String, dynamic> json) {
    final uslugeJson = json['usluge'] as List<dynamic>? ?? [];
    return ArtikalKatalog(
      id: json['id'] as int,
      naziv: json['naziv'] as String,
      kategorija: json['kategorija'] as String,
      opis: json['opis'] as String?,
      usluge: uslugeJson
          .map((e) => UslugaCijena.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
