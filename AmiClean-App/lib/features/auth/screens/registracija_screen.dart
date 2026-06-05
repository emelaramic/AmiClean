import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../models/registracija_request.dart';
import '../services/korisnik_service.dart';
import '../widgets/auth_brand_layout.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/login_underline_field.dart';

class RegistracijaScreen extends StatefulWidget {
  const RegistracijaScreen({super.key, required this.korisnikService});

  final KorisnikService korisnikService;

  @override
  State<RegistracijaScreen> createState() => _RegistracijaScreenState();
}

class _RegistracijaScreenState extends State<RegistracijaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  final _adresaController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _potvrdaLozinkeController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _adresaController.dispose();
    _lozinkaController.dispose();
    _potvrdaLozinkeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final korisnik = await widget.korisnikService.registriraj(
        RegistracijaRequest(
          ime: _imeController.text,
          prezime: _prezimeController.text,
          email: _emailController.text,
          brojTelefona: _telefonController.text,
          adresaStanovanja: _adresaController.text,
          lozinka: _lozinkaController.text,
        ),
      );

      if (!mounted) return;

      _clearForm();
      await _showSuccessDialog(korisnik.punoIme);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showErrorSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Neočekivana greška. Pokušaj ponovno.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _imeController.clear();
    _prezimeController.clear();
    _emailController.clear();
    _telefonController.clear();
    _adresaController.clear();
    _lozinkaController.clear();
    _potvrdaLozinkeController.clear();
  }

  Future<void> _showSuccessDialog(String punoIme) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: AmiCleanColors.mediumBlue,
          size: 48,
        ),
        title: const Text('Registracija uspješna'),
        content: Text('Račun za $punoIme je kreiran. Možete se prijaviti.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AmiCleanColors.darkBlue,
            ),
            child: const Text('Na prijavu'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AmiCleanColors.darkBlue,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isSubmitting,
      child: AuthBrandLayout(
        avatarIcon: Icons.person_add_outlined,
        subtitle: 'Registracija',
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: AmiCleanColors.darkBlue,
          tooltip: 'Natrag na prijavu',
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginUnderlineField(
                controller: _imeController,
                label: 'Ime *',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ime je obavezno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              LoginUnderlineField(
                controller: _prezimeController,
                label: 'Prezime *',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Prezime je obavezno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              LoginUnderlineField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return null;
                  final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailPattern.hasMatch(email)) {
                    return 'Unesi ispravan email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              LoginUnderlineField(
                controller: _telefonController,
                label: 'Broj telefona',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              LoginUnderlineField(
                controller: _adresaController,
                label: 'Adresa stanovanja',
                icon: Icons.home_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              LoginUnderlineField(
                controller: _lozinkaController,
                label: 'Lozinka *',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lozinka je obavezna';
                  }
                  if (value.length < 6) {
                    return 'Najmanje 6 znakova';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              LoginUnderlineField(
                controller: _potvrdaLozinkeController,
                label: 'Potvrda lozinke *',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Potvrdi lozinku';
                  }
                  if (value != _lozinkaController.text) {
                    return 'Lozinke se ne podudaraju';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'REGISTRUJ SE',
                loading: _isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Već imaš račun? Prijavi se',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
