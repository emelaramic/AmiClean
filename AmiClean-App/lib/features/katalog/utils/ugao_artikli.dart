import '../models/artikal_katalog.dart';

/// Ugao je u bazi dva artikla; u UI se biraju kao jedna grupa.
class UgaoArtikli {
  UgaoArtikli._();

  static const String grupaNaziv = 'Ugao';
  static const String manjiNaziv = 'Ugao (manji)';
  static const String velikiNaziv = 'Ugao (veliki)';

  static bool jeVarijanta(String naziv) =>
      naziv == manjiNaziv || naziv == velikiNaziv;

  static List<ArtikalKatalog> varijante(List<ArtikalKatalog> artikli) =>
      artikli.where((a) => jeVarijanta(a.naziv)).toList();

  /// Artikli za padajući izbor — Ugao varijante su grupisane pod jednom stavkom.
  static List<ArtikalKatalog> zaPadajuciIzbor(List<ArtikalKatalog> artikli) {
    final imaUgao = artikli.any((a) => jeVarijanta(a.naziv));
    final ostali = artikli.where((a) => !jeVarijanta(a.naziv)).toList();
    if (!imaUgao) return ostali;

    return [
      ...ostali,
      ArtikalKatalog(
        id: -1,
        naziv: grupaNaziv,
        kategorija: artikli.firstWhere((a) => jeVarijanta(a.naziv)).kategorija,
        usluge: const [],
      ),
    ];
  }

  static bool jeGrupa(ArtikalKatalog? artikal) =>
      artikal != null && artikal.id == -1 && artikal.naziv == grupaNaziv;

  static ArtikalKatalog? pronadjiVarijantu(
    List<ArtikalKatalog> artikli,
    String naziv,
  ) {
    for (final a in artikli) {
      if (a.naziv == naziv) return a;
    }
    return null;
  }
}

/// Vrijednost u padajućem izboru: običan artikal ili grupa Ugao.
sealed class ArtikalIzbor {}

class ArtikalIzborObicni extends ArtikalIzbor {
  ArtikalIzborObicni(this.artikal);
  final ArtikalKatalog artikal;
}

class ArtikalIzborUgao extends ArtikalIzbor {}

/// Trenutno odabrani artikal za prikaz usluga i cijena.
ArtikalKatalog? rijeseniArtikal({
  required List<ArtikalKatalog> sviArtikli,
  required ArtikalIzbor? izbor,
  required String? ugaoVarijantaNaziv,
}) {
  if (izbor == null) return null;
  if (izbor is ArtikalIzborObicni) return izbor.artikal;
  if (izbor is ArtikalIzborUgao && ugaoVarijantaNaziv != null) {
    return UgaoArtikli.pronadjiVarijantu(sviArtikli, ugaoVarijantaNaziv);
  }
  return null;
}

List<ArtikalIzbor> artikalIzbori(List<ArtikalKatalog> artikli) {
  return UgaoArtikli.zaPadajuciIzbor(artikli).map((a) {
    if (UgaoArtikli.jeGrupa(a)) return ArtikalIzborUgao();
    return ArtikalIzborObicni(a);
  }).toList();
}

String artikalIzborNaziv(ArtikalIzbor izbor) {
  return switch (izbor) {
    ArtikalIzborObicni(:final artikal) => artikal.naziv,
    ArtikalIzborUgao() => UgaoArtikli.grupaNaziv,
  };
}

ArtikalIzbor? artikalIzborPoNazivu(List<ArtikalIzbor> opcije, String naziv) {
  for (final o in opcije) {
    if (artikalIzborNaziv(o) == naziv) return o;
  }
  return null;
}
