/// Statusi narudžbe iz baze — redoslijed poslovnog toka.
class NarudzbaStatusi {
  NarudzbaStatusi._();

  static const kreirana = 'Kreirana';
  static const primljena = 'Primljena';
  static const uObradi = 'U obradi';
  static const gotova = 'Gotova';
  static const preuzeta = 'Preuzeta';

  static const filterOpcije = <String?, String>{
    null: 'Sve',
    kreirana: 'Kreirane',
    primljena: 'Primljene',
    uObradi: 'U obradi',
    gotova: 'Gotove',
    preuzeta: 'Preuzete',
  };
}

class NarudzbaAdminAkcija {
  const NarudzbaAdminAkcija({
    required this.tip,
    required this.label,
    this.sljedeciStatusNaziv,
    this.zahtijevaRokZavrsetka = false,
  });

  static const tipPrimijeni = 'Primijeni';
  static const tipPromijeniStatus = 'PromijeniStatus';

  final String tip;
  final String label;
  final String? sljedeciStatusNaziv;
  final bool zahtijevaRokZavrsetka;

  factory NarudzbaAdminAkcija.fromJson(Map<String, dynamic> json) {
    return NarudzbaAdminAkcija(
      tip: json['tip'] as String,
      label: json['label'] as String,
      sljedeciStatusNaziv: json['sljedeciStatusNaziv'] as String?,
      zahtijevaRokZavrsetka: json['zahtijevaRokZavrsetka'] as bool? ?? false,
    );
  }
}
