import 'package:flutter/foundation.dart';

import '../../features/auth/models/prijava_response.dart';

class AuthSession extends ChangeNotifier {
  PrijavaResponse? _user;

  PrijavaResponse? get user => _user;
  bool get isLoggedIn => _user != null;

  void login(PrijavaResponse response) {
    _user = response;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
