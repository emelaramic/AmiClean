import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../models/prijava_response.dart';
import '../services/auth_service.dart';
import '../services/korisnik_service.dart';
import '../utils/auth_page_route.dart';
import '../widgets/auth_brand_layout.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/login_underline_field.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final _korisnikFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _korisnikLozinkaController = TextEditingController();
  final _korisnickoImeController = TextEditingController();
  final _adminLozinkaController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscureKorisnikPassword = true;
  bool _obscureAdminPassword = true;
  bool _rememberMe = false;
  int _selectedTab = 0;

  @override
  void dispose() {
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
          backgroundColor: AmiCleanColors.darkBlue,
        ),
      );
  }

  void _openRegistracija() {
    Navigator.of(context).push(
      AuthPageRoute<void>(
        page: RegistracijaScreen(korisnikService: widget.korisnikService),
      ),
    );
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Za reset lozinke kontaktirajte AmiClean ili koristite registraciju.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: AuthBrandLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoleTabs(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedTab == 0
                  ? _buildKorisnikForm(key: const ValueKey('korisnik'))
                  : _buildAdminForm(key: const ValueKey('admin')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTabs() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _roleTab(label: 'Korisnik', index: 0),
          _roleTab(label: 'Admin', index: 1),
        ],
      ),
    );
  }

  Widget _roleTab({required String label, required int index}) {
    final selected = _selectedTab == index;
    return Expanded(
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => setState(() => _selectedTab = index),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKorisnikForm({required Key key}) {
    return Form(
      key: _korisnikFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginUnderlineField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email je obavezan';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          LoginUnderlineField(
            controller: _korisnikLozinkaController,
            label: 'Lozinka',
            icon: Icons.lock_outline,
            obscureText: _obscureKorisnikPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _prijavaKorisnika(),
            suffix: IconButton(
              onPressed: () => setState(
                () => _obscureKorisnikPassword = !_obscureKorisnikPassword,
              ),
              icon: Icon(
                _obscureKorisnikPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lozinka je obavezna';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildOptionsRow(showForgotPassword: true),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'PRIJAVA',
            loading: _isSubmitting,
            onPressed: _prijavaKorisnika,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _openRegistracija,
            child: const Text(
              'Nemaš račun? Registriraj se',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminForm({required Key key}) {
    return Form(
      key: _adminFormKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginUnderlineField(
            controller: _korisnickoImeController,
            label: 'Korisničko ime',
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Korisničko ime je obavezno';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          LoginUnderlineField(
            controller: _adminLozinkaController,
            label: 'Lozinka',
            icon: Icons.lock_outline,
            obscureText: _obscureAdminPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _prijavaAdmina(),
            suffix: IconButton(
              onPressed: () => setState(
                () => _obscureAdminPassword = !_obscureAdminPassword,
              ),
              icon: Icon(
                _obscureAdminPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lozinka je obavezna';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildOptionsRow(showForgotPassword: false),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'PRIJAVA',
            loading: _isSubmitting,
            onPressed: _prijavaAdmina,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsRow({required bool showForgotPassword}) {
    return Row(
      children: [
        SizedBox(
          height: 36,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) =>
                setState(() => _rememberMe = value ?? false),
            activeColor: AmiCleanColors.darkBlue,
            checkColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const Text(
          'Zapamti me',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        const Spacer(),
        if (showForgotPassword)
          TextButton(
            onPressed: _onForgotPassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Zaboravljena lozinka?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
