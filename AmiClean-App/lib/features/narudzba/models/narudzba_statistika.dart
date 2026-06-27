class NarudzbaStatistika {
  const NarudzbaStatistika({
    required this.ukupno,
    required this.aktivne,
    required this.poStatusu,
  });

  final int ukupno;
  final int aktivne;
  final List<StatusBroj> poStatusu;

  int brojZaStatus(String statusNaziv) {
    for (final s in poStatusu) {
      if (s.statusNaziv == statusNaziv) return s.broj;
    }
    return 0;
  }

  int get potrebnaPaznja =>
      brojZaStatus('Kreirana') + brojZaStatus('Primljena');

  factory NarudzbaStatistika.fromJson(Map<String, dynamic> json) {
    final lista = json['poStatusu'] as List<dynamic>? ?? [];
    return NarudzbaStatistika(
      ukupno: json['ukupno'] as int? ?? 0,
      aktivne: json['aktivne'] as int? ?? 0,
      poStatusu: lista
          .map((e) => StatusBroj.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StatusBroj {
  const StatusBroj({required this.statusNaziv, required this.broj});

  final String statusNaziv;
  final int broj;

  factory StatusBroj.fromJson(Map<String, dynamic> json) {
    return StatusBroj(
      statusNaziv: json['statusNaziv'] as String,
      broj: json['broj'] as int,
    );
  }
}
