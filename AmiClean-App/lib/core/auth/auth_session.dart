import 'package:flutter/foundation.dart';

import '../../features/auth/models/korisnik.dart';
import '../../features/auth/models/prijava_response.dart';

class AuthSession extends ChangeNotifier {
  PrijavaResponse? _user;

  PrijavaResponse? get user => _user;
  bool get isLoggedIn => _user != null;

  void login(PrijavaResponse response) {
    _user = response;
    notifyListeners();
  }

  void syncProfil(Korisnik profil) {
    final current = _user;
    if (current == null || current.id != profil.id) return;

    _user = PrijavaResponse(
      id: current.id,
      ime: current.ime,
      prezime: current.prezime,
      uloga: current.uloga,
      email: profil.email ?? current.email,
      korisnickoIme: current.korisnickoIme,
      ulogaZaposlenika: current.ulogaZaposlenika,
      brojTelefona: profil.brojTelefona,
      adresaStanovanja: profil.adresaStanovanja,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
