import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/auth/auth_session.dart';
import 'core/cart/cart_session.dart';
import 'core/routing/auth_gate.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/korisnik_service.dart';

class AmiCleanApp extends StatelessWidget {
  AmiCleanApp({
    super.key,
    ApiClient? apiClient,
    AuthSession? authSession,
    CartSession? cartSession,
    AuthService? authService,
    KorisnikService? korisnikService,
  })  : _authSession = authSession ?? AuthSession(),
        _cartSession = cartSession ?? CartSession(),
        _authService = authService ??
            AuthService(apiClient: apiClient ?? ApiClient()),
        _korisnikService = korisnikService ??
            KorisnikService(apiClient: apiClient ?? ApiClient());

  final AuthSession _authSession;
  final CartSession _cartSession;
  final AuthService _authService;
  final KorisnikService _korisnikService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmiClean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: AuthGate(
        session: _authSession,
        cart: _cartSession,
        authService: _authService,
        korisnikService: _korisnikService,
      ),
    );
  }
}
