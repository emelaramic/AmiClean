import 'package:flutter/foundation.dart';

import '../../features/katalog/models/artikal_katalog.dart';
import '../../features/narudzba/models/cart_stavka.dart';

class CartSession extends ChangeNotifier {
  final List<CartStavka> _stavke = [];
  int _nextId = 1;

  List<CartStavka> get stavke => List.unmodifiable(_stavke);
  int get brojStavki => _stavke.length;
  bool get isEmpty => _stavke.isEmpty;

  double get ukupno =>
      _stavke.fold(0, (sum, s) => sum + s.ukupnaCijena);

  void dodajStavku({
    required ArtikalKatalog artikal,
    required List<UslugaCijena> odabraneUsluge,
    required double kolicina,
    String? napomena,
  }) {
    _stavke.add(
      CartStavka(
        id: _nextId++,
        artikalId: artikal.id,
        artikalNaziv: artikal.naziv,
        kategorija: artikal.kategorija,
        kolicina: kolicina,
        usluge: odabraneUsluge,
        napomena: napomena,
      ),
    );
    notifyListeners();
  }

  void ukloniStavku(int id) {
    _stavke.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void ocisti() {
    _stavke.clear();
    notifyListeners();
  }
}
