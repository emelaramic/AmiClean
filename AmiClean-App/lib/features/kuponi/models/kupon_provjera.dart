class KuponProvjera {
  const KuponProvjera({
    required this.vazeci,
    this.poruka,
    this.kod,
    this.postotakPopusta = 0,
    this.popustIznos = 0,
    this.ukupnoNakonPopusta = 0,
  });

  final bool vazeci;
  final String? poruka;
  final String? kod;
  final double postotakPopusta;
  final double popustIznos;
  final double ukupnoNakonPopusta;

  factory KuponProvjera.fromJson(Map<String, dynamic> json) {
    return KuponProvjera(
      vazeci: json['vazeci'] as bool? ?? false,
      poruka: json['poruka'] as String?,
      kod: json['kod'] as String?,
      postotakPopusta: (json['postotakPopusta'] as num?)?.toDouble() ?? 0,
      popustIznos: (json['popustIznos'] as num?)?.toDouble() ?? 0,
      ukupnoNakonPopusta: (json['ukupnoNakonPopusta'] as num?)?.toDouble() ?? 0,
    );
  }
}
