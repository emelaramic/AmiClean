import 'package:flutter/material.dart';

import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/auth/models/prijava_response.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/services/korisnik_service.dart';
import '../../features/korisnik/screens/korisnik_home_screen.dart';
import '../auth/auth_session.dart';
import '../cart/cart_session.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.session,
    required this.cart,
    required this.authService,
    required this.korisnikService,
  });

  final AuthSession session;
  final CartSession cart;
  final AuthService authService;
  final KorisnikService korisnikService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (!session.isLoggedIn) {
          return LoginScreen(
            authService: authService,
            korisnikService: korisnikService,
            session: session,
          );
        }

        return switch (session.user!.uloga) {
          UserRole.admin => AdminHomeScreen(session: session),
          UserRole.korisnik => KorisnikHomeScreen(session: session, cart: cart),
        };
      },
    );
  }
}
