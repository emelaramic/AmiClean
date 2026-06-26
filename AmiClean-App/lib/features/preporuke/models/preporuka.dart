import 'package:flutter/material.dart';

class Preporuka {
  const Preporuka({
    required this.artikalId,
    required this.naziv,
    required this.kategorija,
    this.opis,
    required this.tip,
    required this.razlog,
    this.odCijena,
    this.cijenaOpis,
  });

  final int artikalId;
  final String naziv;
  final String kategorija;
  final String? opis;
  final String tip;
  final String razlog;
  final double? odCijena;
  final String? cijenaOpis;

  factory Preporuka.fromJson(Map<String, dynamic> json) {
    return Preporuka(
      artikalId: json['artikalId'] as int,
      naziv: json['naziv'] as String,
      kategorija: json['kategorija'] as String,
      opis: json['opis'] as String?,
      tip: json['tip'] as String,
      razlog: json['razlog'] as String,
      odCijena: json['odCijena'] == null
          ? null
          : (json['odCijena'] as num).toDouble(),
      cijenaOpis: json['cijenaOpis'] as String?,
    );
  }

  String get tipZaPrikaz => switch (tip) {
        'Historija' => 'Na temelju vaših narudžbi',
        'Komplementarno' => 'Preporučena kombinacija',
        'Popularno' => 'Popularno',
        _ => tip,
      };

  IconData get tipIkona => switch (tip) {
        'Historija' => Icons.history_rounded,
        'Komplementarno' => Icons.auto_awesome_rounded,
        'Popularno' => Icons.trending_up_rounded,
        _ => Icons.recommend_rounded,
      };
}
