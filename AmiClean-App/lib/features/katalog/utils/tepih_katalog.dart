/// Konstante i pomoćne funkcije za tepihe (cijena po m², dimenzije).
class TepihKatalog {
  TepihKatalog._();

  static const String kategorija = 'Tepisi';

  static bool jeTepih(String kategorija) => kategorija == TepihKatalog.kategorija;

  static double? parsirajDecimal(String tekst) {
    final normalizirano = tekst.trim().replaceAll(',', '.');
    if (normalizirano.isEmpty) return null;
    return double.tryParse(normalizirano);
  }

  /// Površina u m² iz dužine i širine u metrima.
  static double? povrsina({required String duzina, required String sirina}) {
    final d = parsirajDecimal(duzina);
    final s = parsirajDecimal(sirina);
    if (d == null || s == null || d <= 0 || s <= 0) return null;
    return d * s;
  }

  static String formatM2(double vrijednost) {
    if (vrijednost == vrijednost.roundToDouble()) {
      return vrijednost.toInt().toString();
    }
    return vrijednost.toStringAsFixed(2);
  }
}

/// Regex za decimalni unos dimenzija (metri).
final decimalDimenzijaRegex = RegExp(r'^\d*[,.]?\d*');

/// Regex za cijeli broj komada.
final cijeliBrojRegex = RegExp(r'^\d*');
