import '../../katalog/models/artikal_katalog.dart';

class CartStavka {
  const CartStavka({
    required this.id,
    required this.artikalId,
    required this.artikalNaziv,
    required this.kategorija,
    required this.kolicina,
    required this.usluge,
    this.napomena,
  });

  final int id;
  final int artikalId;
  final String artikalNaziv;
  final String kategorija;
  final double kolicina;
  final List<UslugaCijena> usluge;
  final String? napomena;

  double get cijenaPoJedinici =>
      usluge.fold(0, (sum, u) => sum + u.cijena);

  double get ukupnaCijena => kolicina * cijenaPoJedinici;

  String get uslugeTekst => usluge.map((u) => u.uslugaNaziv).join(', ');

  String get kolicinaTekst {
    if (kategorija == 'Tepisi') {
      return '$kolicina m²';
    }
    return kolicina == kolicina.roundToDouble()
        ? '${kolicina.toInt()} kom'
        : '$kolicina kom';
  }

  String formatKm(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} KM';
    }
    return '${value.toStringAsFixed(2)} KM';
  }
}
