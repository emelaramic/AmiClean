import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../models/prijava_response.dart';
import '../services/auth_service.dart';
import '../services/korisnik_service.dart';
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
  static const _avatarSize = 88.0;

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
      MaterialPageRoute<void>(
        builder: (context) => RegistracijaScreen(
          korisnikService: widget.korisnikService,
        ),
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
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AmiCleanColors.pageBackground,
        ),
        child: SafeArea(
          child: AbsorbPointer(
            absorbing: _isSubmitting,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: _avatarSize / 2),
                        child: _buildLoginCard(),
                      ),
                      _buildAvatar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: AmiCleanColors.darkBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_outline,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AmiCleanColors.loginCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          _avatarSize / 2 + 16,
          24,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AmiClean',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hemijska čistionica',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xD9FFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 20),
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
          _buildLoginButton(
            label: 'PRIJAVA',
            onPressed: _prijavaKorisnika,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _openRegistracija,
            child: const Text(
              'Nemaš račun? Registriraj se',
              style: TextStyle(color: Colors.white),
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
          _buildLoginButton(
            label: 'PRIJAVA',
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

  Widget _buildLoginButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _isSubmitting ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AmiCleanColors.darkBlue,
          disabledBackgroundColor:
              AmiCleanColors.darkBlue.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}
