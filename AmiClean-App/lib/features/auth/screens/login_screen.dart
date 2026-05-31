import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../models/prijava_response.dart';
import '../services/auth_service.dart';
import '../services/korisnik_service.dart';
import 'registracija_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.korisnikService,
    required this.session,
  });

  final AuthService authService;
  final KorisnikService korisnikService;
  final AuthSession session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _korisnikFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _korisnikLozinkaController = TextEditingController();
  final _korisnickoImeController = TextEditingController();
  final _adminLozinkaController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscureKorisnikPassword = true;
  bool _obscureAdminPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _korisnikLozinkaController.dispose();
    _korisnickoImeController.dispose();
    _adminLozinkaController.dispose();
    super.dispose();
  }

  Future<void> _prijavaKorisnika() async {
    if (!_korisnikFormKey.currentState!.validate()) return;
    await _executeLogin(() => widget.authService.prijavaKorisnika(
          email: _emailController.text,
          lozinka: _korisnikLozinkaController.text,
        ));
  }

  Future<void> _prijavaAdmina() async {
    if (!_adminFormKey.currentState!.validate()) return;
    await _executeLogin(() => widget.authService.prijavaZaposlenika(
          korisnickoIme: _korisnickoImeController.text,
          lozinka: _adminLozinkaController.text,
        ));
  }

  Future<void> _executeLogin(Future<PrijavaResponse> Function() login) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await login();
      widget.session.login(response);
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Neočekivana greška. Pokušaj ponovno.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  void _openRegistracija() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RegistracijaScreen(
          korisnikService: widget.korisnikService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AmiClean — Prijava'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Korisnik'),
            Tab(text: 'Admin'),
          ],
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isSubmitting,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildKorisnikTab(),
            _buildAdminTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildKorisnikTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _korisnikFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email je obavezan';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _korisnikLozinkaController,
              obscureText: _obscureKorisnikPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _prijavaKorisnika(),
              decoration: InputDecoration(
                labelText: 'Lozinka',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureKorisnikPassword = !_obscureKorisnikPassword,
                  ),
                  icon: Icon(
                    _obscureKorisnikPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lozinka je obavezna';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _prijavaKorisnika,
              child: Text(_isSubmitting ? 'Prijava...' : 'Prijavi se'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _openRegistracija,
              child: const Text('Nemaš račun? Registriraj se'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _adminFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _korisnickoImeController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Korisničko ime',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Korisničko ime je obavezno';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _adminLozinkaController,
              obscureText: _obscureAdminPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _prijavaAdmina(),
              decoration: InputDecoration(
                labelText: 'Lozinka',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureAdminPassword = !_obscureAdminPassword,
                  ),
                  icon: Icon(
                    _obscureAdminPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lozinka je obavezna';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _prijavaAdmina,
              child: Text(_isSubmitting ? 'Prijava...' : 'Prijavi se kao admin'),
            ),
          ],
        ),
      ),
    );
  }
}
