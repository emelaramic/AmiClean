import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/auth/auth_session.dart';
import 'core/routing/auth_gate.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/korisnik_service.dart';

class AmiCleanApp extends StatelessWidget {
  AmiCleanApp({
    super.key,
    ApiClient? apiClient,
    AuthSession? authSession,
    AuthService? authService,
    KorisnikService? korisnikService,
  })  : _authSession = authSession ?? AuthSession(),
        _authService = authService ??
            AuthService(apiClient: apiClient ?? ApiClient()),
        _korisnikService = korisnikService ??
            KorisnikService(apiClient: apiClient ?? ApiClient());

  final AuthSession _authSession;
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
        authService: _authService,
        korisnikService: _korisnikService,
      ),
    );
  }
}
